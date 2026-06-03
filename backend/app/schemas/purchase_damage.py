import uuid
from datetime import datetime
from decimal import Decimal
from typing import Literal

from pydantic import BaseModel, Field

DamageType = Literal["damaged", "short", "missing", "returned"]


class PurchaseDamageReportIn(BaseModel):
    item_name: str = Field(min_length=1, max_length=500)
    qty_damaged: Decimal = Field(gt=0)
    damage_type: DamageType
    notes: str | None = Field(default=None, max_length=4000)


class PurchaseDamageReportOut(BaseModel):
    id: uuid.UUID
    created_at: datetime
    reported_by: str | None = None
    item_name: str
    qty_damaged: Decimal
    damage_type: str
    notes: str | None = None

    model_config = {"from_attributes": True}
