import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class UserCreateIn(BaseModel):
    full_name: str = Field(min_length=1, max_length=255)
    phone: str = Field(min_length=6, max_length=32)
    role: str = Field(pattern="^(manager|staff)$")
    password: str | None = None
    is_active: bool = True


class UserPatchIn(BaseModel):
    full_name: str | None = None
    phone: str | None = None
    role: str | None = Field(default=None, pattern="^(manager|staff|owner)$")
    is_active: bool | None = None


class TodayStatsOut(BaseModel):
    scans: int = 0
    stock_updates: int = 0
    items_created: int = 0


class UserListOut(BaseModel):
    id: uuid.UUID
    name: str | None
    phone: str | None
    email: str
    role: str
    is_active: bool
    last_login_at: datetime | None
    last_active_at: datetime | None
    today_stats: TodayStatsOut


class UserCreateOut(BaseModel):
    user: UserListOut
    generated_password: str | None = None


class ResetPasswordOut(BaseModel):
    new_password: str


class ActivityLogIn(BaseModel):
    action_type: str
    item_id: uuid.UUID | None = None
    item_name: str | None = None
    details: dict | None = None


class ActivityLogOut(BaseModel):
    id: uuid.UUID
    user_name: str | None = None
    action_type: str
    item_id: uuid.UUID | None
    item_name: str | None
    details: dict | None
    created_at: datetime

    model_config = {"from_attributes": True}
