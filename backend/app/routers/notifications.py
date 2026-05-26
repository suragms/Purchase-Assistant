import uuid
from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.deps import get_current_user, require_membership
from app.models import User
from app.models.notification import AppNotification
from app.schemas.notification import (
    NotificationBulkActionOut,
    NotificationOut,
    NotificationReadPatch,
    UnreadCountOut,
)

router = APIRouter(prefix="/v1/businesses/{business_id}/notifications", tags=["notifications"])


@router.get("", response_model=list[NotificationOut])
async def list_notifications(
    business_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    user: Annotated[User, Depends(get_current_user)],
    _m: Annotated[object, Depends(require_membership)],
    page: int = Query(1, ge=1),
    per_page: int = Query(50, ge=1, le=100),
    kind: str | None = Query(default=None, max_length=64),
):
    del _m
    off = (page - 1) * per_page
    filters = [
        AppNotification.business_id == business_id,
        AppNotification.user_id == user.id,
    ]
    if kind:
        filters.append(AppNotification.kind == kind.strip())
    r = await db.execute(
        select(AppNotification)
        .where(*filters)
        .order_by(AppNotification.created_at.desc())
        .offset(off)
        .limit(per_page)
    )
    return [NotificationOut.model_validate(x) for x in r.scalars().all()]


@router.get("/unread-count", response_model=UnreadCountOut)
async def unread_count(
    business_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    user: Annotated[User, Depends(get_current_user)],
    _m: Annotated[object, Depends(require_membership)],
):
    del _m
    r = await db.execute(
        select(func.count())
        .select_from(AppNotification)
        .where(
            AppNotification.business_id == business_id,
            AppNotification.user_id == user.id,
            AppNotification.read_at.is_(None),
        )
    )
    return UnreadCountOut(unread=int(r.scalar_one() or 0))


@router.post("/mark-all-read", response_model=NotificationBulkActionOut)
async def mark_all_read(
    business_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    user: Annotated[User, Depends(get_current_user)],
    _m: Annotated[object, Depends(require_membership)],
    kind: str | None = Query(default=None, max_length=64),
):
    del _m
    filters = [
        AppNotification.business_id == business_id,
        AppNotification.user_id == user.id,
        AppNotification.read_at.is_(None),
    ]
    if kind:
        filters.append(AppNotification.kind == kind.strip())
    res = await db.execute(
        update(AppNotification)
        .where(*filters)
        .values(read_at=datetime.now(timezone.utc))
    )
    await db.commit()
    return NotificationBulkActionOut(updated=int(res.rowcount or 0))


@router.delete("/clear-all", response_model=NotificationBulkActionOut)
async def clear_all(
    business_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    user: Annotated[User, Depends(get_current_user)],
    _m: Annotated[object, Depends(require_membership)],
    kind: str | None = Query(default=None, max_length=64),
):
    del _m
    filters = [
        AppNotification.business_id == business_id,
        AppNotification.user_id == user.id,
    ]
    if kind:
        filters.append(AppNotification.kind == kind.strip())
    res = await db.execute(delete(AppNotification).where(*filters))
    await db.commit()
    return NotificationBulkActionOut(updated=int(res.rowcount or 0))


@router.patch("/{notification_id}", response_model=NotificationOut)
async def patch_notification(
    business_id: uuid.UUID,
    notification_id: uuid.UUID,
    body: NotificationReadPatch,
    db: Annotated[AsyncSession, Depends(get_db)],
    user: Annotated[User, Depends(get_current_user)],
    _m: Annotated[object, Depends(require_membership)],
):
    del _m
    r = await db.execute(
        select(AppNotification).where(
            AppNotification.id == notification_id,
            AppNotification.business_id == business_id,
            AppNotification.user_id == user.id,
        )
    )
    row = r.scalar_one_or_none()
    if not row:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Notification not found")
    if body.read:
        row.read_at = datetime.now(timezone.utc)
    else:
        row.read_at = None
    await db.commit()
    await db.refresh(row)
    return NotificationOut.model_validate(row)
