"""AI usage + WhatsApp PO delivery logs.

Idempotent: revision 001 `create_all` may already have created these from ORM.
"""

from __future__ import annotations

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "070_ai_whatsapp_ops"
down_revision: Union[str, None] = "069_owner_ops_tables"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _has_table(name: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    return name in insp.get_table_names()


def _has_index(table: str, index: str) -> bool:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    return any(i["name"] == index for i in insp.get_indexes(table))


def upgrade() -> None:
    if not _has_table("ai_usage_logs"):
        op.create_table(
            "ai_usage_logs",
            sa.Column("id", sa.Uuid(), primary_key=True),
            sa.Column(
                "business_id", sa.Uuid(), sa.ForeignKey("businesses.id"), nullable=True
            ),
            sa.Column(
                "feature",
                sa.String(64),
                nullable=False,
                server_default="json_extract",
            ),
            sa.Column("endpoint", sa.String(128), nullable=False, server_default=""),
            sa.Column("provider", sa.String(64), nullable=False, server_default="none"),
            sa.Column("model", sa.String(128), nullable=True),
            sa.Column("tier", sa.Integer(), nullable=True),
            sa.Column("tokens_in", sa.Integer(), nullable=True),
            sa.Column("tokens_out", sa.Integer(), nullable=True),
            sa.Column("latency_ms", sa.Integer(), nullable=True),
            sa.Column(
                "escalated", sa.Boolean(), nullable=False, server_default=sa.false()
            ),
            sa.Column("confidence", sa.Float(), nullable=True),
            sa.Column("cost_estimate_paise", sa.Integer(), nullable=True),
            sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        )
    if _has_table("ai_usage_logs"):
        if not _has_index("ai_usage_logs", "ix_ai_usage_logs_business_id"):
            op.create_index(
                "ix_ai_usage_logs_business_id", "ai_usage_logs", ["business_id"]
            )
        if not _has_index("ai_usage_logs", "ix_ai_usage_logs_provider"):
            op.create_index("ix_ai_usage_logs_provider", "ai_usage_logs", ["provider"])
        if not _has_index("ai_usage_logs", "ix_ai_usage_logs_created_at"):
            op.create_index(
                "ix_ai_usage_logs_created_at", "ai_usage_logs", ["created_at"]
            )

    if not _has_table("whatsapp_delivery_logs"):
        op.create_table(
            "whatsapp_delivery_logs",
            sa.Column("id", sa.Uuid(), primary_key=True),
            sa.Column(
                "business_id", sa.Uuid(), sa.ForeignKey("businesses.id"), nullable=False
            ),
            sa.Column("po_id", sa.Uuid(), nullable=False),
            sa.Column("staff_id", sa.Uuid(), sa.ForeignKey("users.id"), nullable=True),
            sa.Column("recipient_number", sa.String(32), nullable=True),
            sa.Column(
                "status",
                sa.String(32),
                nullable=False,
                server_default="pending_manual",
            ),
            sa.Column(
                "attempt_count", sa.Integer(), nullable=False, server_default="0"
            ),
            sa.Column("last_attempted_at", sa.DateTime(timezone=True), nullable=True),
            sa.Column("error_message", sa.Text(), nullable=True),
            sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        )
    if _has_table("whatsapp_delivery_logs"):
        if not _has_index(
            "whatsapp_delivery_logs", "ix_whatsapp_delivery_logs_business_id"
        ):
            op.create_index(
                "ix_whatsapp_delivery_logs_business_id",
                "whatsapp_delivery_logs",
                ["business_id"],
            )
        if not _has_index("whatsapp_delivery_logs", "ix_whatsapp_delivery_logs_po_id"):
            op.create_index(
                "ix_whatsapp_delivery_logs_po_id",
                "whatsapp_delivery_logs",
                ["po_id"],
            )
        if not _has_index("whatsapp_delivery_logs", "ix_whatsapp_delivery_logs_status"):
            op.create_index(
                "ix_whatsapp_delivery_logs_status",
                "whatsapp_delivery_logs",
                ["status"],
            )


def downgrade() -> None:
    if _has_table("whatsapp_delivery_logs"):
        op.drop_table("whatsapp_delivery_logs")
    if _has_table("ai_usage_logs"):
        op.drop_table("ai_usage_logs")
