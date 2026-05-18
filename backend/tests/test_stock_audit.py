import uuid
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def _setup_auth_and_item():
    # Register user
    u = uuid.uuid4().hex[:10]
    email = f"e{u}@test.hexa.local"
    r = client.post(
        "/v1/auth/register",
        json={"username": f"u{u}", "email": email, "password": "testpass12"},
    )
    assert r.status_code == 200, r.text
    access = r.json()["access_token"]
    h = {"Authorization": f"Bearer {access}"}

    # Get business
    br = client.get("/v1/me/businesses", headers=h)
    assert br.status_code == 200, br.text
    bid = br.json()[0]["id"]

    # Create category
    cat = client.post(
        f"/v1/businesses/{bid}/item-categories",
        headers=h,
        json={"name": "Test Cat"},
    )
    assert cat.status_code == 201, cat.text
    cid = cat.json()["id"]

    # Create a default supplier first (required by CatalogItem)
    def_sup = client.post(
        f"/v1/businesses/{bid}/suppliers",
        headers=h,
        json={"name": "Item default sup", "phone": "9000000099", "gst_number": "22AAAAA0000A1Z5"},
    )
    assert def_sup.status_code == 201, def_sup.text
    def_sid = def_sup.json()["id"]

    # Create catalog item
    item = client.post(
        f"/v1/businesses/{bid}/catalog-items",
        headers=h,
        json={
            "category_id": cid,
            "name": "Audit Test Rice",
            "default_unit": "kg",
            "default_supplier_ids": [def_sid],
        },
    )
    assert item.status_code == 201, item.text
    iid = item.json()["id"]

    return h, bid, iid


def test_stock_audit_lifecycle():
    h, bid, iid = _setup_auth_and_item()

    # 1. Create a draft stock audit
    payload = {
        "audit_date": "2026-05-18",
        "notes": "Initial draft audit",
        "items": [
            {
                "item_id": iid,
                "system_qty": 100.00,
                "counted_qty": 95.50,
            }
        ]
    }
    r_create = client.post("/v1/stock-audits", headers=h, json=payload)
    assert r_create.status_code == 201, r_create.text
    audit = r_create.json()
    assert audit["status"] == "draft"
    assert audit["notes"] == "Initial draft audit"
    assert len(audit["items"]) == 1
    
    audit_item = audit["items"][0]
    assert audit_item["item_id"] == iid
    assert float(audit_item["system_qty"]) == 100.00
    assert float(audit_item["counted_qty"]) == 95.50
    assert float(audit_item["difference_qty"]) == 4.50  # 100.00 - 95.50

    audit_id = audit["id"]

    # 2. Get list of audits
    r_list = client.get("/v1/stock-audits", headers=h)
    assert r_list.status_code == 200, r_list.text
    audits = r_list.json()
    assert any(a["id"] == audit_id for a in audits)

    # 3. Retrieve single audit
    r_get = client.get(f"/v1/stock-audits/{audit_id}", headers=h)
    assert r_get.status_code == 200, r_get.text
    get_audit = r_get.json()
    assert get_audit["id"] == audit_id
    assert len(get_audit["items"]) == 1

    # 4. Update the draft stock audit
    update_payload = {
        "notes": "Updated notes",
        "items": [
            {
                "item_id": iid,
                "system_qty": 100.00,
                "counted_qty": 98.00,
            }
        ]
    }
    r_update = client.put(f"/v1/stock-audits/{audit_id}", headers=h, json=update_payload)
    assert r_update.status_code == 200, r_update.text
    updated_audit = r_update.json()
    assert updated_audit["notes"] == "Updated notes"
    assert float(updated_audit["items"][0]["difference_qty"]) == 2.00  # 100.00 - 98.00

    # 5. Complete the stock audit
    r_complete = client.put(f"/v1/stock-audits/{audit_id}", headers=h, json={"status": "completed"})
    assert r_complete.status_code == 200, r_complete.text
    completed_audit = r_complete.json()
    assert completed_audit["status"] == "completed"

    # 6. Try to update a completed stock audit (Should fail with 400)
    r_fail_update = client.put(f"/v1/stock-audits/{audit_id}", headers=h, json={"notes": "No changes allowed"})
    assert r_fail_update.status_code == 400, r_fail_update.text
    assert "Completed stock audits cannot be modified" in r_fail_update.json()["detail"]

    # 7. Try to delete a completed stock audit (Should fail with 400)
    r_fail_delete = client.delete(f"/v1/stock-audits/{audit_id}", headers=h)
    assert r_fail_delete.status_code == 400, r_fail_delete.text
    assert "Completed stock audits cannot be deleted" in r_fail_delete.json()["detail"]

    # 8. Create another draft stock audit and delete it
    r_draft2 = client.post("/v1/stock-audits", headers=h, json={"notes": "Draft to delete", "items": []})
    assert r_draft2.status_code == 201, r_draft2.text
    draft2_id = r_draft2.json()["id"]

    r_delete_ok = client.delete(f"/v1/stock-audits/{draft2_id}", headers=h)
    assert r_delete_ok.status_code == 204

    # Verify draft2 is deleted
    r_get_deleted = client.get(f"/v1/stock-audits/{draft2_id}", headers=h)
    assert r_get_deleted.status_code == 404
