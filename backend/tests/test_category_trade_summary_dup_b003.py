"""DUP-B-003: category trade-summary uses trade_line_amount_expr + report statuses."""

import uuid
from datetime import date, timedelta

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def _setup():
    u = uuid.uuid4().hex[:10]
    email = f"cts{u}@test.hexa.local"
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
        json={"name": f"CTSCat{u}"},
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
        json={"name": f"CTSSup{u}", "phone": "9000000099", "gst_number": "32AAAAA0000A1Z1"},
    )
    assert s.status_code == 201, s.text
    sid = s.json()["id"]
    item = client.post(
        f"/v1/businesses/{bid}/catalog-items",
        headers=h,
        json={
            "category_id": cid,
            "name": f"CTSItem{u}",
            "type_id": tid,
            "default_unit": "bag",
            "default_kg_per_bag": 50,
            "hsn_code": "10063090",
            "default_supplier_ids": [sid],
        },
    )
    assert item.status_code == 201, item.text
    iid = item.json()["id"]
    return h, bid, iid, sid, cid, item.json()["name"]


def test_category_trade_summary_uses_line_amount_expr_weight_path():
    h, bid, iid, sid, cid, iname = _setup()
    d0 = date.today() - timedelta(days=1)
    body = {
        "purchase_date": d0.isoformat(),
        "supplier_id": sid,
        "status": "saved",
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

    # status=saved must count (report SSOT) — old path required confirmed only.
    sm = client.get(
        f"/v1/businesses/{bid}/item-categories/{cid}/trade-summary",
        headers=h,
    )
    assert sm.status_code == 200, sm.text
    data = sm.json()
    assert abs(float(data["total_line_amount"]) - 20000.0) < 0.01
    row = next(x for x in data["items"] if x["catalog_item_id"] == iid)
    assert abs(float(row["period_line_total"]) - 20000.0) < 0.01
    assert abs(float(row["period_qty_bags"]) - 10.0) < 0.01


def test_category_trade_summary_excludes_draft():
    h, bid, iid, sid, cid, iname = _setup()
    d0 = date.today()
    body = {
        "purchase_date": d0.isoformat(),
        "supplier_id": sid,
        "status": "draft",
        "lines": [
            {
                "catalog_item_id": iid,
                "item_name": iname,
                "qty": 3,
                "unit": "bag",
                "landing_cost": "1000",
                "kg_per_unit": 50,
                "landing_cost_per_kg": "20",
                "tax_percent": 0,
            },
        ],
    }
    pr = client.post(f"/v1/businesses/{bid}/trade-purchases", headers=h, json=body)
    assert pr.status_code == 201, pr.text
    sm = client.get(
        f"/v1/businesses/{bid}/item-categories/{cid}/trade-summary",
        headers=h,
    )
    assert sm.status_code == 200, sm.text
    data = sm.json()
    assert float(data["total_line_amount"]) == 0.0
