"""Validate purchase line units against catalog stock-tracking profile."""

from __future__ import annotations

from typing import Any

from app.models.catalog import CatalogItem
from app.services.stock_tracking_profile import line_unit_allowed, profile_from_catalog_item


def validate_purchase_line_unit(
    item: CatalogItem | Any,
    line_unit: str | None,
) -> str | None:
    """Return error message when unit is not allowed; None when OK."""
    profile = profile_from_catalog_item(item)
    ok, msg = line_unit_allowed(profile, line_unit)
    if ok:
        return None
    return msg or "Unit not allowed for this item."
