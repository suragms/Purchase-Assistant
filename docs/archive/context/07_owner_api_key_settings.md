# FEATURE: Owner-Editable API Keys (WhatsApp, AI providers, Staff Accounts)

## Context
Today all provider keys (Gemini, Groq, OpenAI, and the currently-unused OpenRouter key) live in env vars / `config.py`, requiring a redeploy to change. Goal: owner can update these — plus new WhatsApp Business API credentials and staff WhatsApp numbers — from a settings screen, without a redeploy, and without ever exposing key values back to the frontend.

## Task
### Step 1 — Storage
New table `provider_credential`: `id, business_id, credential_type (whatsapp_api_key/whatsapp_staff_number/openrouter_key/gemini_key/groq_key/openai_key), encrypted_value, last_4_chars, updated_by, updated_at`. Encrypt `encrypted_value` at rest — check if an encryption utility already exists in the deployment/config layer before adding a new one.

### Step 2 — Read path with fallback
Settings service reads DB-backed value first (short in-memory TTL cache to avoid a DB hit on every AI/WhatsApp call), falls back to the existing env var if no DB value is set. This means current env-based deployment keeps working unchanged, and the new UI is purely additive.

### Step 3 — Write path
`PUT /v1/businesses/{business_id}/settings/credentials/{credential_type}` — owner-role-only. Accepts the new value, stores encrypted, **never returns the value in the response** — return only `last_4_chars` and `updated_at` for confirmation.

### Step 4 — Read/display path
`GET /v1/businesses/{business_id}/settings/credentials` — returns masked values only (`credential_type`, `last_4_chars`, `updated_at`, `updated_by`), never the plaintext value, for any account including the owner. If the owner needs to fully verify a key, that's a re-enter-and-save action, not a reveal action.

### Step 5 — Audit
Every credential change logged: who, when, which credential type — explicitly never the value itself, masked or otherwise, in the audit log.

### Step 6 — Flutter settings screen
Owner-only. One form per credential type, write-only text fields (no pre-fill with the real value — show "•••• last4" placeholder), explicit save action per field, confirmation toast showing last-4 on success.

## Edge cases
- Owner saves an invalid/malformed key (e.g. WhatsApp token that doesn't authenticate) — validate synchronously where possible (a cheap test call to the provider) and surface a clear error before persisting, rather than silently storing a broken key.
- Concurrent edits (two admin sessions editing the same credential) — last-write-wins is acceptable here, but the audit log should make it visible if this happens.
- Missing credential at call time (never configured) — calling code (AI failover, WhatsApp sender) must degrade gracefully (skip that provider/tier, don't crash) — this already matches the existing pattern in `llm_failover.py` for missing keys.

## Deliverable
- Migration for `provider_credential`
- Settings read/write service with cache + env-var fallback
- `GET`/`PUT` endpoints, owner-gated
- Flutter owner settings screen

## Risk
Medium — this handles secrets. Encryption-at-rest and the never-return-plaintext rule are non-negotiable. Test that a raw DB dump/backup (file 04) doesn't leak these in a more recoverable form than the encryption is meant to provide — confirm the backup export logic either excludes this table or keeps it encrypted in the export too.

## Tests
- Save + masked read round-trip (correct last-4 shown, no plaintext ever in the response body — check this at the HTTP layer, not just the code path).
- Fallback to env var when no DB value exists.
- Audit log entry created on every change, with no plaintext leakage in the log.
- Confirm `04_auto_backup_restore.md`'s backup export doesn't expose these credentials in plaintext.
