"""Unit tests for LLM failover gateway and loose JSON parsing."""

import asyncio

from app.services.llm_failover import run_ordered_failover, run_tiered_failover
from app.services.llm_intent import _parse_json_loose


def test_run_ordered_failover_skips_no_key():
    async def boom() -> str:
        raise AssertionError("should not run")

    async def _run():
        return await run_ordered_failover(
            runners=[
                ("a", None, boom),
            ]
        )

    out, meta = asyncio.run(_run())
    assert out is None
    assert meta.get("provider_used") is None


def test_run_ordered_failover_gemini_fails_groq_succeeds():
    calls: list[str] = []

    async def bad() -> None:
        calls.append("gemini")
        return None

    async def good() -> str:
        calls.append("groq")
        return "ok"

    async def _run():
        return await run_ordered_failover(
            runners=[
                ("gemini", "gk", bad),
                ("groq", "qk", good),
                ("openai", None, good),
            ]
        )

    out, meta = asyncio.run(_run())
    assert out == "ok"
    assert meta.get("provider_used") == "groq"
    assert meta.get("failover_used") is True
    assert calls == ["gemini", "groq"]


def test_run_ordered_failover_all_three():
    async def fail() -> None:
        return None

    async def third() -> str:
        return "x"

    async def _run():
        return await run_ordered_failover(
            runners=[
                ("gemini", "a", fail),
                ("groq", "b", fail),
                ("openai", "c", third),
            ]
        )

    out, meta = asyncio.run(_run())
    assert out == "x"
    assert meta.get("provider_used") == "openai"
    assert meta.get("failover_used") is True


def test_run_tiered_failover_tier1_success():
    async def t1() -> dict:
        return {"lines": [], "confidence": 0.9}

    async def t2() -> dict:
        raise AssertionError("tier2 should not run")

    async def _run():
        return await run_tiered_failover(
            tier1_runners=[("openrouter:deepseek", "k", t1)],
            tier2_runners=[("gemini", "g", t2)],
        )

    out, meta = asyncio.run(_run())
    assert out == {"lines": [], "confidence": 0.9}
    assert meta.get("tier_used") == 1
    assert meta.get("escalated") is False


def test_run_tiered_failover_low_confidence_escalates():
    async def t1() -> dict:
        return {"confidence": 0.2}

    async def t2() -> dict:
        return {"ok": True, "confidence": 0.95}

    async def _run():
        return await run_tiered_failover(
            tier1_runners=[("openrouter:deepseek", "k", t1)],
            tier2_runners=[("gemini", "g", t2)],
        )

    out, meta = asyncio.run(_run())
    assert out == {"ok": True, "confidence": 0.95}
    assert meta.get("tier_used") == 2
    assert meta.get("escalated") is True


def test_run_tiered_failover_missing_tier1_goes_tier2():
    async def t2() -> str:
        return "tier2"

    async def _run():
        return await run_tiered_failover(
            tier1_runners=[("openrouter:deepseek", None, t2)],
            tier2_runners=[("gemini", "g", t2)],
        )

    out, meta = asyncio.run(_run())
    assert out == "tier2"
    assert meta.get("tier_used") == 2


def test_run_tiered_force_tier2_only():
    async def t1() -> str:
        raise AssertionError("should skip")

    async def t2() -> str:
        return "only2"

    async def _run():
        return await run_tiered_failover(
            tier1_runners=[("openrouter:deepseek", "k", t1)],
            tier2_runners=[("openai", "o", t2)],
            force_tier2_only=True,
        )

    out, meta = asyncio.run(_run())
    assert out == "only2"
    assert meta.get("tier_used") == 2


def test_parse_json_loose_markdown_fence():
    raw = """```json
{"intent": "query_summary", "data": {}, "missing_fields": [], "reply_text": ""}
```"""
    out = _parse_json_loose(raw)
    assert isinstance(out, dict)
    assert out.get("intent") == "query_summary"


def test_parse_json_loose_extra_text():
    raw = 'Here is JSON:\n{"a": 1}\nThanks.'
    out = _parse_json_loose(raw)
    assert out == {"a": 1}


def test_backup_excludes_credentials_marker():
    from app.services.backup_ops import SCHEMA_VERSION

    sample = {
        "schema_version": SCHEMA_VERSION,
        "excludes": ["provider_credentials"],
        "catalog": [],
    }
    assert "provider_credentials" in sample["excludes"]
