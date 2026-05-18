import re
import uuid
from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import and_, desc, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.deps import get_current_user, require_membership, require_role
from app.models import Membership, User
from app.models.user_session import StaffActivityLog, UserSession
from app.schemas.users import (
    ActivityLogIn,
    ActivityLogOut,
    ResetPasswordOut,
    TodayStatsOut,
    UserCreateIn,
    UserCreateOut,
    UserListOut,
    UserPatchIn,
)
from app.services.passwords import hash_password
from app.services.readable_password import generate_readable_password

router = APIRouter(prefix="/v1/businesses/{business_id}/users", tags=["users"])


def _phone_digits(phone: str) -> str:
    return re.sub(r"\D", "", phone)


async def _today_stats(db: AsyncSession, business_id: uuid.UUID, user_id: uuid.UUID) -> TodayStatsOut:
    start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    base = and_(
        StaffActivityLog.business_id == business_id,
        StaffActivityLog.user_id == user_id,
        StaffActivityLog.created_at >= start,
    )

    async def count(action: str) -> int:
        r = await db.execute(
            select(func.count())
            .select_from(StaffActivityLog)
            .where(base, StaffActivityLog.action_type == action)
        )
        return int(r.scalar_one())

    return TodayStatsOut(
        scans=await count("SCAN"),
        stock_updates=await count("STOCK_UPDATE"),
        items_created=await count("ITEM_CREATE"),
    )


async def _user_row(
    db: AsyncSession, business_id: uuid.UUID, user: User, membership: Membership
) -> UserListOut:
    stats = await _today_stats(db, business_id, user.id)
    return UserListOut(
        id=user.id,
        name=user.name,
        phone=user.phone,
        email=user.email,
        role=membership.role,
        is_active=user.is_active,
        last_login_at=user.last_login_at,
        last_active_at=user.last_active_at,
        today_stats=stats,
    )


@router.post("", response_model=UserCreateOut, status_code=status.HTTP_201_CREATED)
async def create_user(
    business_id: uuid.UUID,
    body: UserCreateIn,
    db: Annotated[AsyncSession, Depends(get_db)],
    actor: Annotated[Membership, Depends(require_role("owner", "super_admin"))],
    current_user: Annotated[User, Depends(get_current_user)],
):
    digits = _phone_digits(body.phone)
    if len(digits) < 6:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="Invalid phone")
    email = f"{digits}@staff.harisree.local"
    username = f"staff_{digits}"[:64]
    ex = await db.execute(select(User.id).where((User.email == email) | (User.username == username)))
    if ex.first():
        raise HTTPException(status.HTTP_409_CONFLICT, detail="User with this phone already exists")

    plain = body.password.strip() if body.password and body.password.strip() else generate_readable_password()
    user = User(
        email=email,
        username=username,
        password_hash=hash_password(plain),
        phone=body.phone.strip(),
        name=body.full_name.strip(),
        is_active=body.is_active,
        created_by=current_user.id,
    )
    db.add(user)
    await db.flush()
    mem = Membership(user_id=user.id, business_id=business_id, role=body.role)
    db.add(mem)
    await db.commit()
    await db.refresh(user)
    row = await _user_row(db, business_id, user, mem)
    return UserCreateOut(user=row, generated_password=plain if not body.password else None)


@router.get("", response_model=list[UserListOut])
async def list_users(
    business_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    _m: Annotated[Membership, Depends(require_role("owner", "manager", "super_admin"))],
):
    r = await db.execute(
        select(User, Membership)
        .join(Membership, Membership.user_id == User.id)
        .where(Membership.business_id == business_id)
        .order_by(User.name)
    )
    out: list[UserListOut] = []
    for user, mem in r.all():
        out.append(await _user_row(db, business_id, user, mem))
    return out


@router.get("/active-sessions", response_model=list[UserListOut])
async def active_sessions(
    business_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    _m: Annotated[Membership, Depends(require_role("owner", "manager", "super_admin"))],
):
    cutoff = datetime.now(timezone.utc) - timedelta(minutes=5)
    r = await db.execute(
        select(User, Membership)
        .join(Membership, Membership.user_id == User.id)
        .where(
            Membership.business_id == business_id,
            User.last_active_at.isnot(None),
            User.last_active_at >= cutoff,
            User.is_active.is_(True),
        )
    )
    out: list[UserListOut] = []
    for user, mem in r.all():
        out.append(await _user_row(db, business_id, user, mem))
    return out


@router.get("/{user_id}", response_model=UserListOut)
async def get_user(
    business_id: uuid.UUID,
    user_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    _m: Annotated[Membership, Depends(require_role("owner", "manager", "super_admin"))],
):
    r = await db.execute(
        select(User, Membership)
        .join(Membership, Membership.user_id == User.id)
        .where(Membership.business_id == business_id, User.id == user_id)
    )
    row = r.one_or_none()
    if not row:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    user, mem = row
    return await _user_row(db, business_id, user, mem)


@router.patch("/{user_id}", response_model=UserListOut)
async def patch_user(
    business_id: uuid.UUID,
    user_id: uuid.UUID,
    body: UserPatchIn,
    db: Annotated[AsyncSession, Depends(get_db)],
    _m: Annotated[Membership, Depends(require_role("owner", "super_admin"))],
):
    r = await db.execute(
        select(User, Membership)
        .join(Membership, Membership.user_id == User.id)
        .where(Membership.business_id == business_id, User.id == user_id)
    )
    row = r.one_or_none()
    if not row:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    user, mem = row
    if body.full_name is not None:
        user.name = body.full_name.strip()
    if body.phone is not None:
        user.phone = body.phone.strip()
    if body.role is not None:
        mem.role = body.role
    if body.is_active is not None:
        user.is_active = body.is_active
    await db.commit()
    await db.refresh(user)
    return await _user_row(db, business_id, user, mem)


@router.post("/{user_id}/reset-password", response_model=ResetPasswordOut)
async def reset_password(
    business_id: uuid.UUID,
    user_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    _m: Annotated[Membership, Depends(require_role("owner", "super_admin"))],
):
    r = await db.execute(
        select(User)
        .join(Membership, Membership.user_id == User.id)
        .where(Membership.business_id == business_id, User.id == user_id)
    )
    user = r.scalar_one_or_none()
    if not user:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    plain = generate_readable_password()
    user.password_hash = hash_password(plain)
    await db.commit()
    return ResetPasswordOut(new_password=plain)


activity_router = APIRouter(prefix="/v1/businesses/{business_id}/activity-log", tags=["activity"])


@activity_router.post("", response_model=ActivityLogOut, status_code=status.HTTP_201_CREATED)
async def post_activity(
    business_id: uuid.UUID,
    body: ActivityLogIn,
    db: Annotated[AsyncSession, Depends(get_db)],
    user: Annotated[User, Depends(get_current_user)],
    _m: Annotated[Membership, Depends(require_membership)],
):
    display = user.name or user.username
    row = StaffActivityLog(
        business_id=business_id,
        user_id=user.id,
        user_name=display,
        action_type=body.action_type,
        item_id=body.item_id,
        item_name=body.item_name,
        details=body.details,
    )
    db.add(row)
    user.last_active_at = datetime.now(timezone.utc)
    await db.commit()
    await db.refresh(row)
    return ActivityLogOut.model_validate(row)


@activity_router.get("", response_model=list[ActivityLogOut])
async def list_activity(
    business_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    user: Annotated[User, Depends(get_current_user)],
    _m: Annotated[Membership, Depends(require_membership)],
    user_id: uuid.UUID | None = None,
    period: str = Query("today"),
    page: int = Query(1, ge=1),
    per_page: int = Query(50, ge=1, le=200),
):
    uid = user_id or user.id
    now = datetime.now(timezone.utc)
    if period == "week":
        start = now - timedelta(days=7)
    elif period == "month":
        start = now - timedelta(days=30)
    else:
        start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    r = await db.execute(
        select(StaffActivityLog)
        .where(
            StaffActivityLog.business_id == business_id,
            StaffActivityLog.user_id == uid,
            StaffActivityLog.created_at >= start,
        )
        .order_by(desc(StaffActivityLog.created_at))
        .offset((page - 1) * per_page)
        .limit(per_page)
    )
    return [ActivityLogOut.model_validate(x) for x in r.scalars().all()]
