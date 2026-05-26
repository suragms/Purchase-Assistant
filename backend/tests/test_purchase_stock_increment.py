import uuid
from decimal import Decimal

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_delivery_confirmation_increments_stock():
    u = uuid.uuid4().hex[:8]
    email = f"stk{u}@test.hexa.local"
    r = client.post(
        "/v1/auth/register",
        json={"username": f"su{u}", "email": email, "password": "testpass12"},
    )
    assert r.status_code == 200, r.text
    h = {"Authorization": f"Bearer {r.json()['access_token']}"}
    bid = client.get("/v1/me/businesses", headers=h).json()[0]["id"]
    cat = client.post(
        f"/v1/businesses/{bid}/item-categories", headers=h, json={"name": "Cat"}
    ).json()["id"]
    sup = client.post(
        f"/v1/businesses/{bid}/suppliers",
        headers=h,
        json={"name": "Sup", "phone": "9000000099", "gst_number": "22AAAAA0000A1Z5"},
    ).json()["id"]
    item = client.post(
        f"/v1/businesses/{bid}/catalog-items",
        headers=h,
        json={
            "category_id": cat,
            "name": "Soap Bar",
            "default_unit": "piece",
            "default_supplier_ids": [sup],
        },
    )
    assert item.status_code == 201, item.text
    iid = item.json()["id"]

    purchase = client.post(
        f"/v1/businesses/{bid}/trade-purchases",
        headers=h,
        json={
            "supplier_id": sup,
            "purchase_date": "2026-05-18",
            "status": "confirmed",
            "lines": [
                {
                    "catalog_item_id": iid,
                    "item_name": "Soap Bar",
                    "qty": "10",
                    "unit": "piece",
                    "purchase_rate": "100",
                    "landing_cost": "100",
                }
            ],
        },
    )
    assert purchase.status_code in (200, 201), purchase.text
    pid = purchase.json()["id"]

    stock = client.get(f"/v1/businesses/{bid}/stock/{iid}", headers=h)
    assert stock.status_code == 200, stock.text
    assert Decimal(str(stock.json()["current_stock"])) == Decimal("0")

    delivered = client.patch(
        f"/v1/businesses/{bid}/trade-purchases/{pid}/delivery",
        headers=h,
        json={"is_delivered": True},
    )
    assert delivered.status_code == 200, delivered.text

    stock = client.get(f"/v1/businesses/{bid}/stock/{iid}", headers=h)
    assert stock.status_code == 200, stock.text
    assert Decimal(str(stock.json()["current_stock"])) == Decimal("10")
