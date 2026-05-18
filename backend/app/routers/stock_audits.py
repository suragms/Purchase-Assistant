import uuid
from datetime import date
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.deps import get_current_user
from app.models import User
from app.models.stock_audit import StockAudit, StockAuditItem
from app.schemas.stock_audit import StockAuditCreate, StockAuditOut, StockAuditUpdate

router = APIRouter(prefix="/v1/stock-audits", tags=["stock-audits"])


@router.post("", response_model=StockAuditOut, status_code=status.HTTP_201_CREATED)
async def create_stock_audit(
    audit_in: StockAuditCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Create a new stock audit as draft."""
    db_audit = StockAudit(
        audit_date=audit_in.audit_date or date.today(),
        auditor_id=current_user.id,
        status="draft",
        notes=audit_in.notes,
    )
    db.add(db_audit)
    await db.flush()

    for item_in in audit_in.items:
        diff_qty = item_in.system_qty - item_in.counted_qty
        db_item = StockAuditItem(
            audit_id=db_audit.id,
            item_id=item_in.item_id,
            system_qty=item_in.system_qty,
            counted_qty=item_in.counted_qty,
            difference_qty=diff_qty,
        )
        db.add(db_item)

    await db.commit()

    result = await db.execute(
        select(StockAudit)
        .where(StockAudit.id == db_audit.id)
        .options(selectinload(StockAudit.items))
    )
    return result.scalar_one()


@router.get("", response_model=list[StockAuditOut])
async def list_stock_audits(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    skip: int = 0,
    limit: int = 100,
):
    """List stock audits paginated."""
    result = await db.execute(
        select(StockAudit)
        .order_by(StockAudit.created_at.desc())
        .offset(skip)
        .limit(limit)
        .options(selectinload(StockAudit.items))
    )
    return result.scalars().all()


@router.get("/{audit_id}", response_model=StockAuditOut)
async def get_stock_audit(
    audit_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Retrieve details of a single stock audit."""
    result = await db.execute(
        select(StockAudit)
        .where(StockAudit.id == audit_id)
        .options(selectinload(StockAudit.items))
    )
    audit = result.scalar_one_or_none()
    if not audit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Stock audit not found",
        )
    return audit


@router.put("/{audit_id}", response_model=StockAuditOut)
async def update_stock_audit(
    audit_id: uuid.UUID,
    audit_in: StockAuditUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Update stock audit details. Only draft audits can be modified."""
    result = await db.execute(
        select(StockAudit)
        .where(StockAudit.id == audit_id)
        .options(selectinload(StockAudit.items))
    )
    db_audit = result.scalar_one_or_none()
    if not db_audit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Stock audit not found",
        )

    if db_audit.status == "completed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Completed stock audits cannot be modified",
        )

    if audit_in.notes is not None:
        db_audit.notes = audit_in.notes

    if audit_in.status is not None:
        if audit_in.status not in ["draft", "completed"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid status. Must be draft or completed",
            )
        db_audit.status = audit_in.status

    if audit_in.items is not None:
        # Clear old items, cascade delete-orphan will handle DB deletions
        db_audit.items.clear()

        # Create and append new items
        for item_in in audit_in.items:
            diff_qty = item_in.system_qty - item_in.counted_qty
            db_item = StockAuditItem(
                item_id=item_in.item_id,
                system_qty=item_in.system_qty,
                counted_qty=item_in.counted_qty,
                difference_qty=diff_qty,
            )
            db_audit.items.append(db_item)

    await db.commit()

    result = await db.execute(
        select(StockAudit)
        .where(StockAudit.id == audit_id)
        .options(selectinload(StockAudit.items))
    )
    return result.scalar_one()


@router.delete("/{audit_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_stock_audit(
    audit_id: uuid.UUID,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Delete a stock audit. Only draft audits can be deleted."""
    result = await db.execute(select(StockAudit).where(StockAudit.id == audit_id))
    db_audit = result.scalar_one_or_none()
    if not db_audit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Stock audit not found",
        )

    if db_audit.status == "completed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Completed stock audits cannot be deleted",
        )

    await db.delete(db_audit)
    await db.commit()
    return None
