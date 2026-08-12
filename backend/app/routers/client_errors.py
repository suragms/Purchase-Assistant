"""Client error ingestion endpoint — structured logging only, no DB, no PII."""

import logging
import time

from fastapi import APIRouter
from pydantic import BaseModel, Field

router = APIRouter(tags=["client-errors"])
logger = logging.getLogger("harisree.client_errors")

_last_log_ts: float = 0.0
_MIN_INTERVAL_S = 0.5


class ClientErrorPayload(BaseModel):
    """Sanitised client error — never contains PII."""

    error_type: str = Field(..., max_length=120)
    message: str = Field(..., max_length=500)
    stack: str = Field(default="", max_length=2000)
    route: str = Field(default="", max_length=200)
    platform: str = Field(default="", max_length=30)
    app_version: str = Field(default="", max_length=30)
    is_debug: bool = False


@router.post("/v1/client-errors")
async def ingest_client_error(payload: ClientErrorPayload):
    """Accept a sanitised client error and write it to the server log.

    Throttled server-side (≥0.5 s between writes) so a runaway client
    cannot flood logs.  No database — purely log-based observability.
    """
    global _last_log_ts
    now = time.monotonic()
    if now - _last_log_ts < _MIN_INTERVAL_S:
        return {"ok": True, "logged": False}
    _last_log_ts = now

    logger.warning(
        "CLIENT_ERROR %s | type=%s route=%s platform=%s version=%s debug=%s",
        payload.message[:200],
        payload.error_type,
        payload.route or "-",
        payload.platform or "-",
        payload.app_version or "-",
        payload.is_debug,
    )
    if payload.stack:
        logger.info("CLIENT_ERROR_STACK\n%s", payload.stack[:2000])
    return {"ok": True, "logged": True}
