# FEATURE: AI Provider Layer — Add OpenRouter (DeepSeek / Kimi / MiMo) as Cheap Tier

## Context
Current chain in `backend/app/services/llm_failover.py` is Gemini → Groq → OpenAI, used by `ocr_parser.py` and `llm_intent.py`. `settings.openrouter_api_key` exists in `config.py` but is dead code — never wired into the runner. Goal: add a cheap-model tier in front of the existing chain, not replace it.

## Design — two-tier routing
```
Tier 1 (cheap, high volume): OpenRouter
  1. deepseek/deepseek-chat (or current DeepSeek-V3 slug — verify at implementation time, slugs change)
  2. moonshotai/kimi-k2 (verify current Kimi slug)
  3. xiaomi/mimo (verify current MiMo slug)

Tier 2 (existing, escalation only): Gemini → Groq → OpenAI (unchanged)
```
Escalation rule: Tier 1 handles all requests first. If the result is low-confidence (reuse whatever confidence scoring `llm_intent.py` already applies) or fails structured-output validation, escalate to Tier 2. Log which tier actually resolved the request.

## Task
### Step 1 — Extend `resolve_provider_keys()`
Add `openrouter` explicitly, don't fold it into the existing dict blindly — it needs its own model-selection logic since "openrouter" is a gateway, not a single model.

### Step 2 — New `run_tiered_failover()` (wraps existing `run_ordered_failover()`)
Tier 1 runs first as its own ordered failover (deepseek → kimi → mimo) using the existing `run_ordered_failover()` primitive unchanged. On Tier 1 exhaustion or low-confidence result, call the existing `run_ordered_failover()` for Tier 2 (Gemini/Groq/OpenAI) exactly as it works today. This means **zero changes to the existing Tier 2 code path** — pure addition.

### Step 3 — Wire into `ocr_parser.py` and `llm_intent.py`
Swap their call from `run_ordered_failover()` to `run_tiered_failover()`. Confirm output shape is unchanged from the callers' perspective — this should be a drop-in swap with no changes needed in the calling code beyond the function name.

### Step 4 — Preserve the "AI never invents business facts" boundary
Tier 1 models must go through the exact same downstream validation as Tier 2 currently does (product ID lookup, price/stock validation against DB) before any extracted data is trusted. Do not weaken this because the model is cheaper — cheap models need the same guardrails, if not more.

### Step 5 — AI usage logging
New table `ai_usage_log`: `id, business_id, feature, endpoint, provider, model, tier, tokens_in, tokens_out, latency_ms, escalated (bool), confidence, created_at`. Log every call, both tiers. This feeds the owner dashboard's AI-usage panel (see file `06_owner_command_center.md`) — build the schema with that consumer in mind.

### Step 6 — Cost tracking
Store a per-model cost-per-token config (even a rough static table is fine — OpenRouter publishes pricing per model) so `ai_usage_log` can be aggregated into an estimated-cost figure without a live pricing API call.

## Edge cases to handle
- OpenRouter itself down/unreachable → falls through cleanly to Tier 2, same as a missing-key skip today.
- Model slug deprecated/renamed by OpenRouter → fail gracefully to next model in Tier 1, then to Tier 2, not a hard error.
- Confidence scoring producing a false "high confidence" wrong extraction — this is a downstream-validation problem, not something Tier 1 selection can fully solve; make sure DB-level validation (product exists, price in range, stock non-negative) still catches it regardless of which tier produced the output.

## Deliverable
Code diff to `llm_failover.py`, `ocr_parser.py`, `llm_intent.py`, new `ai_usage_log` migration + model, cost-config table/constant.

## Risk
Medium — this touches the extraction pipeline used for real purchase/order data. Roll out behind a feature flag (env var to force Tier 2-only) so it can be disabled instantly if Tier 1 quality is worse than expected in production.

## Tests
- Unit test `run_tiered_failover()` with mocked providers: Tier 1 success, Tier 1 low-confidence → Tier 2 escalation, Tier 1 all-keys-missing → Tier 2 direct, all providers down → clean error.
- Integration test: run real Malayalam/Manglish sample inputs through both tiers, compare extraction accuracy before enabling Tier 1 as default in production.
- Confirm `ai_usage_log` row is written on every path (success, escalation, total failure).
