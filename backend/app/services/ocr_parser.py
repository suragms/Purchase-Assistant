"""Purchase bill text parsing helpers (supplier hint + tabular rows).

Legacy regex/heuristic parsing for tests and non-image flows. Bill scans use OpenAI Vision via scanner v2/v3 — see ``purchase_scan_service``."""

from __future__ import annotations

import re
from typing import Any

from app.services.bill_line_extract import extract_purchase_lines_from_text


MALAYALAM_TO_ENGLISH: dict[str, str] = {
    # Rice
    "arishi": "rice",
    "ari": "rice",
    "matta": "matta rice",
    "cherumani": "cherumani rice",
    "jaya": "jaya rice",
    # Sugar
    "suger": "sugar",
    "sujar": "sugar",
    "chakkarappetti": "sugar",
    "chakka": "sugar",
    "sharkkara": "sugar",
    # Pulses
    "payar": "cherupayar",
    "cherupayar": "cherupayar",
    "kadala": "kadala",
    "uzhunnu": "uzhunnu",
    "thuvara": "thuvara",
    "parippu": "masoor dall",
    # Spices
    "malli": "malli",
    "jeerakam": "jeerakam",
    "manjal": "manjal",
    "mulaku": "chilli",
    "chilli": "chilli",
    "uluva": "uluva",
    # Flour
    "rava": "maida atta sooji",
    "sooji": "maida atta sooji",
    "maida": "maida atta sooji",
    "atta": "wheat flour",
    "kadalamavu": "kadalamavu",
    # Other
    "ellu": "ellu",
    "kappalandi": "kappalandi",
    "avil": "avil",
    "bellam": "bellam",
}


def normalize_item_name(raw: str) -> str:
    """Normalise Malayalam/Manglish item names to stable catalog-like names."""
    s = (raw or "").strip()
    if not s:
        return ""
    lower = s.lower()
    for mal, eng in MALAYALAM_TO_ENGLISH.items():
        if mal in lower:
            return eng.upper()
    return s.upper()


def extract_supplier_candidate(lines: list[str]) -> str | None:
    """Pick a tentative supplier/header line — conservative; callers must confirm."""
    for raw in lines[:12]:
        t = raw.strip()
        if len(t) < 5 or len(t) > 200:
            continue
        # Skip obvious table / numeric-heavy rows
        if re.search(r"^\s*\d+(\.\d+)?\s*(bag|kg|kgs)\b", t, re.I):
            continue
        if re.match(r"^[\d₹Rs.,\s]+$", t, re.I):
            continue
        if "total" == t.strip().split()[0].lower():
            continue
        return t
    return None


_UNIT_ALIASES = {
    "bags": "bag",
    # Master rebuild: sacks are not supported; normalize to BAG.
    "sack": "bag",
    "sacks": "bag",
    "boxes": "box",
    "box": "box",
    "tins": "tin",
    "tin": "tin",
    "pcs": "piece",
    "pc": "piece",
    "piece": "piece",
    "pieces": "piece",
    "kgs": "kg",
    "kilogram": "kg",
}


def normalize_purchase_unit(u: str) -> str:
    t = (u or "").strip().lower()
    if not t:
        return "kg"
    return _UNIT_ALIASES.get(t, t)


def extract_item_rows(text: str) -> tuple[list[dict[str, Any]], list[str]]:
    """Structured lines + keys that commonly need confirmation when ambiguous."""
    raw = extract_purchase_lines_from_text(text)
    missing: list[str] = []
    out: list[dict[str, Any]] = []
    for idx, e in enumerate(raw):
        name = normalize_item_name((e.get("item_name") or "").strip())
        qty = float(e.get("qty") or 0)
        unit = normalize_purchase_unit(str(e.get("unit") or "kg"))
        rate = float(e.get("landing_cost") or 0)
        pref = f"line_{idx}"
        if not name:
            missing.append(f"{pref}.item_name")
        if qty <= 0:
            missing.append(f"{pref}.qty")
        if rate <= 0:
            missing.append(f"{pref}.rate")
        if unit not in ("kg", "bag", "box", "tin", "piece"):
            missing.append(f"{pref}.unit")
        out.append(
            {
                "name": name or "Unknown item",
                "qty": qty,
                "unit": unit,
                "rate": rate,
            }
        )
    if not out:
        missing.extend(["supplier_name", "items", "qty", "unit", "rate"])
    return out, missing


def extract_header_charges(text: str) -> dict[str, Any]:
    """Best-effort header charge extraction from OCR/pasted bill text (regex).

    Does not invent values: only fills keys when a number is found near a keyword.
    """
    t = (text or "").lower()
    out: dict[str, Any] = {
        "delivered_rate": None,
        "billty_rate": None,
        "freight_amount": None,
        "freight_type": None,
    }
    if not t.strip():
        return out

    def _first_float(pat: str) -> float | None:
        m = re.search(pat, t, flags=re.I)
        if not m:
            return None
        try:
            v = float(m.group(1))
            return v if v > 0 else None
        except Exception:  # noqa: BLE001
            return None

    delivered = _first_float(
        r"(?:delivered|delhead|delivery|deliv)\D{0,12}(\d+(?:\.\d+)?)"
    )
    billty = _first_float(r"(?:billty|bilti|bilty)\D{0,12}(\d+(?:\.\d+)?)")
    freight = _first_float(r"(?:freight|frt|transport)\D{0,12}(\d+(?:\.\d+)?)")

    ft: str | None = None
    if "freight included" in t or "frt included" in t:
        ft = "included"
    elif freight is not None:
        ft = "separate"

    if delivered is not None:
        out["delivered_rate"] = delivered
    if billty is not None:
        out["billty_rate"] = billty
    if freight is not None:
        out["freight_amount"] = freight
    if ft is not None:
        out["freight_type"] = ft
    return out


def normalize_scan_text(text: str | bytes) -> str:
    """Best-effort decode for stubs / mis-encoded uploads.

    Safety: if raw image bytes are mistakenly passed here, return empty string.
    """
    if not text:
        return ""
    if isinstance(text, (bytes, bytearray)):
        try:
            decoded = bytes(text).decode("utf-8", errors="replace")
        except Exception:  # noqa: BLE001
            return ""
        head = decoded[:40]
        if "JFIF" in head or "Exif" in head or head.startswith("\ufffd\ufffdJFIF") or "\xff\xd8\xff" in head:
            return ""
        return decoded
    return text or ""


async def extract_item_rows_via_ai(
    text: str,
    *,
    db=None,
    business_id=None,
) -> tuple[list[dict[str, Any]], list[str], dict[str, Any]]:
    """Optional AI assist for bill text — same validation shape as [extract_item_rows].

    Uses tiered failover (OpenRouter → Gemini/Groq/OpenAI). Never invents money;
    callers must still validate against catalog/DB before save.
    """
    from app.config import get_settings
    from app.services.llm_failover import extract_json_with_failover

    settings = get_settings()
    if not settings.enable_ai or not settings.enable_ai_extraction:
        rows, missing = extract_item_rows(text)
        return rows, missing, {"provider_used": None, "skipped": "ai_disabled"}

    prompt = (
        "Extract purchase bill line items as JSON with keys: "
        'lines (array of {item_name, qty, unit, landing_cost}), '
        "confidence (0-1). Return JSON only.\n\n"
        f"Bill text:\n{(text or '')[:8000]}"
    )
    data, meta = await extract_json_with_failover(
        prompt,
        settings=settings,
        db=db,
        business_id=business_id,
        feature="ocr_lines",
        endpoint="ocr_parser.extract_item_rows_via_ai",
    )
    if not isinstance(data, dict):
        rows, missing = extract_item_rows(text)
        return rows, missing, {**meta, "fallback": "heuristic"}

    raw_lines = data.get("lines") or data.get("items") or []
    if not isinstance(raw_lines, list) or not raw_lines:
        rows, missing = extract_item_rows(text)
        return rows, missing, {**meta, "fallback": "heuristic_empty_ai"}

    # Reuse heuristic normalizer path by rebuilding a simple text table.
    rebuilt = "\n".join(
        f"{(ln.get('item_name') or '')} {ln.get('qty') or ''} "
        f"{ln.get('unit') or 'kg'} {ln.get('landing_cost') or 0}"
        for ln in raw_lines
        if isinstance(ln, dict)
    )
    rows, missing = extract_item_rows(rebuilt or text)
    return rows, missing, meta
