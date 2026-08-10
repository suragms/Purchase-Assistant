"""DUP-B-002: owner dashboard spend uses trade_line_amount_expr (not header subtotal)."""

import uuid
from datetime import date

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def _setup():
    u = uuid.uuid4().hex[:10]
    email = f"od{u}@test.hexa.local"
    r = client.post(
        "/v1/auth/register",
        json={"username": f"u{u}", "email": email, "password": "testpass12"},
    )
    assert r.status_code == 200, r.text
    access = r.json()["access_token"]
    h = {"Authorization": f"Bearer {access}"}
    br = client.get("/v1/me/businesses", headers=h)
    bid = br.json()[0]["id"]
    cat = client.post(
        f"/v1/businesses/{bid}/item-categories",
        headers=h,
        json={"name": f"ODCat{u}"},
    )
    assert cat.status_code == 201, cat.text
    cid = cat.json()["id"]
    types = client.get(
        f"/v1/businesses/{bid}/item-categories/{cid}/category-types",
        headers=h,
    )
    assert types.status_code == 200, types.text
    tid = types.json()[0]["id"]
    s = client.post(
        f"/v1/businesses/{bid}/suppliers",
        headers=h,
        json={"name": f"ODSup{u}", "phone": "9000000088", "gst_number": "32AAAAA0000A1Z1"},
    )
    assert s.status_code == 201, s.text
    sid = s.json()["id"]
    item = client.post(
        f"/v1/businesses/{bid}/catalog-items",
        headers=h,
        json={
            "category_id": cid,
            "name": f"ODItem{u}",
            "type_id": tid,
            "default_unit": "bag",
            "default_kg_per_bag": 50,
            "hsn_code": "10063090",
            "default_supplier_ids": [sid],
        },
    )
    assert item.status_code == 201, item.text
    iid = item.json()["id"]
    return h, bid, iid, sid, item.json()["name"]


def test_owner_dashboard_spend_uses_line_amount_expr():
    h, bid, iid, sid, iname = _setup()
    body = {
        "purchase_date": date.today().isoformat(),
        "supplier_id": sid,
        "status": "confirmed",
        "lines": [
            {
                "catalog_item_id": iid,
                "item_name": iname,
                "qty": 10,
                "unit": "bag",
                "landing_cost": "2000",
                "kg_per_unit": 50,
                "landing_cost_per_kg": "40",
                "tax_percent": 0,
            },
        ],
    }
    pr = client.post(f"/v1/businesses/{bid}/trade-purchases", headers=h, json=body)
    assert pr.status_code == 201, pr.text

    dash = client.get(f"/v1/businesses/{bid}/owner/dashboard", headers=h)
    assert dash.status_code == 200, dash.text
    spend = float(dash.json()["comparison"]["spend_last_7_days"])
    # qty * kg * per_kg = 10 * 50 * 40 = 20000 (line SSOT)
    assert abs(spend - 20000.0) < 0.01
