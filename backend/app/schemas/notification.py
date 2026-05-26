import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class NotificationOut(BaseModel):
    id: uuid.UUID
    kind: str
    title: str
    body: str | None
    payload: dict | None
    read_at: datetime | None
    created_at: datetime

    model_config = {"from_attributes": True}


class NotificationReadPatch(BaseModel):
    read: bool = Field(default=True)


class UnreadCountOut(BaseModel):
    unread: int


class NotificationBulkActionOut(BaseModel):
    updated: int
