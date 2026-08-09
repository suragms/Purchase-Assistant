#!/usr/bin/env python3
"""Check backend/.env has required keys present (never print values)."""

from __future__ import annotations

import sys
from pathlib import Path

REQUIRED = (
    "DATABASE_URL",
    "JWT_SECRET",
    "JWT_REFRESH_SECRET",
)
OPTIONAL_LIVE = (
    "CREDENTIAL_ENCRYPTION_KEY",
    "OPENAI_API_KEY",
    "GOOGLE_AI_API_KEY",
    "GROQ_API_KEY",
    "OPENROUTER_API_KEY",
    "WHATSAPP_PHONE_NUMBER_ID",
    "ENABLE_WHATSAPP_PO_DELIVERY",
    "AI_FORCE_TIER2_ONLY",
    "HEXA_USE_SQLITE",
)


def _parse_env(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    if not path.is_file():
        return out
    for line in path.read_text(encoding="utf-8").splitlines():
        s = line.strip()
        if not s or s.startswith("#") or "=" not in s:
            continue
        k, _, v = s.partition("=")
        out[k.strip()] = v.strip()
    return out


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    env_path = root / ".env"
    data = _parse_env(env_path)
    print(f"env_file={'present' if env_path.is_file() else 'MISSING'}: {env_path}")
    missing = [k for k in REQUIRED if not (data.get(k) or "").strip()]
    # SQLite local can omit DATABASE_URL if HEXA_USE_SQLITE=1
    if "DATABASE_URL" in missing and (data.get("HEXA_USE_SQLITE") or "").strip() in (
        "1",
        "true",
        "True",
    ):
        missing = [k for k in missing if k != "DATABASE_URL"]
    for k in REQUIRED:
        present = bool((data.get(k) or "").strip()) or (
            k == "DATABASE_URL"
            and (data.get("HEXA_USE_SQLITE") or "").strip() in ("1", "true", "True")
        )
        print(f"  REQUIRED {k}: {'SET' if present else 'MISSING'}")
    for k in OPTIONAL_LIVE:
        print(f"  OPTIONAL {k}: {'SET' if (data.get(k) or '').strip() else 'unset'}")
    if missing:
        print(f"FAIL missing required keys: {missing}")
        return 1
    print("PASS env key presence check (values not shown)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
