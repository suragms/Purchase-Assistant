"""Ordered / tiered LLM failover for purchase AI JSON extraction."""

from __future__ import annotations

import logging
import time
import uuid
from typing import Any, Awaitable, Callable

from sqlalchemy.ext.asyncio import AsyncSession

from app.config import Settings, get_settings

logger = logging.getLogger(__name__)

ProviderFn = Callable[..., Awaitable[Any]]

# Rough INR paise per 1k tokens (static estimates for owner dashboard).
MODEL_COST_PAISE_PER_1K: dict[str, int] = {
    "deepseek/deepseek-chat": 2,
    "moonshotai/kimi-k2": 3,
    "xiaomi/mimo": 2,
    "gemini": 8,
    "groq": 4,
    "openai": 40,
    "openrouter": 5,
}

OPENROUTER_TIER1_MODELS = (
    "deepseek/deepseek-chat",
    "moonshotai/kimi-k2",
    "xiaomi/mimo",
)


async def resolve_provider_keys(
    settings: Settings,
    db: AsyncSession | None,
    business_id: uuid.UUID | None = None,
) -> dict[str, str | None]:
    """DB credentials first (owner settings), then deployment env. Never log values."""
    from app.services.provider_credentials import resolve_key

    return {
        "gemini": await resolve_key(
            db, business_id, "gemini_key", settings.google_ai_api_key
        ),
        "groq": await resolve_key(
            db, business_id, "groq_key", settings.groq_api_key
        ),
        "openai": await resolve_key(
            db, business_id, "openai_key", settings.openai_api_key
        ),
        "openrouter": await resolve_key(
            db, business_id, "openrouter_key", settings.openrouter_api_key
        ),
    }


def any_llm_key(keys: dict[str, str | None]) -> bool:
    return bool(
        (keys.get("gemini") or "").strip()
        or (keys.get("groq") or "").strip()
        or (keys.get("openai") or "").strip()
        or (keys.get("openrouter") or "").strip()
    )


async def run_ordered_failover(
    *,
    runners: list[tuple[str, str | None, ProviderFn]],
) -> tuple[Any | None, dict[str, Any]]:
    """
    Try each (name, key, async_fn) in order. Skip if key missing.
    Returns (first truthy result, meta with attempts). Empty string counts as failure.
    """
    attempts: list[dict[str, Any]] = []
    tried_with_key = 0
    for name, key, fn in runners:
        k = (key or "").strip()
        if not k:
            attempts.append({"provider": name, "skipped": True, "reason": "no_key"})
            continue
        tried_with_key += 1
        try:
            out = await fn()
            if out is not None and not (isinstance(out, str) and not out.strip()):
                attempts.append({"provider": name, "ok": True})
                return out, {
                    "provider_used": name,
                    "failover": attempts,
                    "failover_used": tried_with_key > 1,
                }
            attempts.append({"provider": name, "ok": False, "reason": "empty_response"})
        except Exception as e:  # noqa: BLE001
            attempts.append(
                {
                    "provider": name,
                    "ok": False,
                    "error": str(e)[:300],
                }
            )
    return None, {"provider_used": None, "failover": attempts, "failover_used": False}


def _result_needs_escalation(result: Any) -> bool:
    """Escalate when structured output is empty or marked low-confidence."""
    if result is None:
        return True
    if isinstance(result, str) and not result.strip():
        return True
    if isinstance(result, dict):
        if not result:
            return True
        conf = result.get("confidence")
        if isinstance(conf, (int, float)) and conf < 0.55:
            return True
        if result.get("escalate") is True:
            return True
        missing = result.get("missing_fields")
        if isinstance(missing, list) and len(missing) >= 3:
            return True
    return False


async def run_tiered_failover(
    *,
    tier1_runners: list[tuple[str, str | None, ProviderFn]],
    tier2_runners: list[tuple[str, str | None, ProviderFn]],
    force_tier2_only: bool = False,
) -> tuple[Any | None, dict[str, Any]]:
    """
    Tier 1 (cheap OpenRouter models) then Tier 2 (Gemini → Groq → OpenAI).
    Escalates on Tier 1 exhaustion or low-confidence / invalid structured output.
    """
    meta: dict[str, Any] = {
        "tier_used": None,
        "escalated": False,
        "provider_used": None,
        "tier1": None,
        "tier2": None,
    }
    if not force_tier2_only and tier1_runners:
        out, t1 = await run_ordered_failover(runners=tier1_runners)
        meta["tier1"] = t1
        if out is not None and not _result_needs_escalation(out):
            meta["tier_used"] = 1
            meta["provider_used"] = t1.get("provider_used")
            return out, meta
        if out is not None:
            meta["escalated"] = True
            meta["tier1_rejected"] = "low_confidence_or_schema"

    out2, t2 = await run_ordered_failover(runners=tier2_runners)
    meta["tier2"] = t2
    meta["tier_used"] = 2 if out2 is not None else None
    meta["provider_used"] = t2.get("provider_used")
    if meta.get("tier1") is not None:
        meta["escalated"] = True
    return out2, meta


async def log_ai_usage(
    db: AsyncSession | None,
    *,
    business_id: uuid.UUID | None,
    feature: str,
    endpoint: str,
    provider: str | None,
    model: str | None,
    tier: int | None,
    tokens_in: int | None = None,
    tokens_out: int | None = None,
    latency_ms: int | None = None,
    escalated: bool = False,
    confidence: float | None = None,
) -> None:
    if db is None:
        return
    try:
        from app.models.owner_ops import AiUsageLog

        tin = int(tokens_in or 0)
        tout = int(tokens_out or 0)
        rate = MODEL_COST_PAISE_PER_1K.get((model or provider or "").lower(), 5)
        cost = int(((tin + tout) / 1000.0) * rate) if (tin or tout) else None
        db.add(
            AiUsageLog(
                business_id=business_id,
                feature=feature[:64],
                endpoint=(endpoint or "")[:128],
                provider=(provider or "none")[:64],
                model=(model or "")[:128] or None,
                tier=tier,
                tokens_in=tin or None,
                tokens_out=tout or None,
                latency_ms=latency_ms,
                escalated=escalated,
                confidence=confidence,
                cost_estimate_paise=cost,
            )
        )
        await db.commit()
    except Exception as e:  # noqa: BLE001
        logger.warning("ai_usage_log write failed: %s", e)
        try:
            await db.rollback()
        except Exception:  # noqa: BLE001
            pass


async def extract_json_with_failover(
    prompt: str,
    *,
    settings: Settings | None = None,
    db: AsyncSession | None = None,
    business_id: uuid.UUID | None = None,
    feature: str = "json_extract",
    endpoint: str = "llm_failover",
) -> tuple[dict[str, Any] | None, dict[str, Any]]:
    """Public entry for OCR/intent strict-JSON via tiered failover."""
    from app.services import llm_intent as li

    settings = settings or get_settings()
    keys = await resolve_provider_keys(settings, db, business_id)
    force_t2 = bool(getattr(settings, "ai_force_tier2_only", False))
    or_key = (keys.get("openrouter") or "").strip()

    tier1: list[tuple[str, str | None, ProviderFn]] = []
    for model in OPENROUTER_TIER1_MODELS:
        m = model

        async def _or_run(model_slug: str = m) -> dict[str, Any] | None:
            return await li._openai_json(
                prompt,
                settings,
                or_key,
                base_url="https://openrouter.ai/api/v1",
                model=model_slug,
            )

        tier1.append((f"openrouter:{model}", or_key or None, _or_run))

    async def _gem() -> dict[str, Any] | None:
        return await li._gemini_json(prompt, settings, keys.get("gemini") or "")

    async def _groq() -> dict[str, Any] | None:
        return await li._groq_json(prompt, settings, keys.get("groq") or "")

    async def _oai() -> dict[str, Any] | None:
        return await li._openai_json(prompt, settings, keys.get("openai") or "")

    tier2: list[tuple[str, str | None, ProviderFn]] = [
        ("gemini", keys.get("gemini"), _gem),
        ("groq", keys.get("groq"), _groq),
        ("openai", keys.get("openai"), _oai),
    ]

    started = time.perf_counter()
    out, meta = await run_tiered_failover(
        tier1_runners=tier1,
        tier2_runners=tier2,
        force_tier2_only=force_t2 or not or_key,
    )
    latency = int((time.perf_counter() - started) * 1000)
    conf = None
    if isinstance(out, dict) and isinstance(out.get("confidence"), (int, float)):
        conf = float(out["confidence"])
    await log_ai_usage(
        db,
        business_id=business_id,
        feature=feature,
        endpoint=endpoint,
        provider=meta.get("provider_used"),
        model=str(meta.get("provider_used") or ""),
        tier=meta.get("tier_used"),
        latency_ms=latency,
        escalated=bool(meta.get("escalated")),
        confidence=conf,
    )
    if out is not None and not isinstance(out, dict):
        return None, {**meta, "error": "schema_reject_non_dict"}
    return out, meta
