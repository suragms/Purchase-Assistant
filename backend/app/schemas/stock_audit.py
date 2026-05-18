from __future__ import annotations

import uuid
from datetime import date, datetime
from decimal import Decimal
from pydantic import BaseModel, Field


class StockAuditItemBase(BaseModel):
    item_id: uuid.UUID
    system_qty: Decimal = Field(..., max_digits=10, decimal_places=2)
    counted_qty: Decimal = Field(..., max_digits=10, decimal_places=2)


class StockAuditItemCreate(StockAuditItemBase):
    pass


class StockAuditItem(StockAuditItemBase):
    id: uuid.UUID
    audit_id: uuid.UUID
    difference_qty: Decimal = Field(..., max_digits=10, decimal_places=2)

    model_config = {"from_attributes": True}


class StockAuditBase(BaseModel):
    notes: str | None = None


class StockAuditCreate(StockAuditBase):
    audit_date: date | None = None
    items: list[StockAuditItemCreate] = Field(default_factory=list)


class StockAuditUpdate(BaseModel):
    notes: str | None = None
    status: str | None = None  # draft or completed
    items: list[StockAuditItemCreate] | None = None


class StockAuditOut(BaseModel):
    id: uuid.UUID
    audit_date: date
    auditor_id: uuid.UUID | None
    status: str
    notes: str | None
    created_at: datetime
    updated_at: datetime
    items: list[StockAuditItem] = Field(default_factory=list)

    model_config = {"from_attributes": True}
