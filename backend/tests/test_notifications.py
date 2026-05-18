import uuid

from fastapi.testclient import TestClient

from app.main import app


def test_notifications_openapi_paths():
    client = TestClient(app)
    r = client.get("/openapi.json")
    assert r.status_code == 200
    spec = r.json()
    paths = spec.get("paths", {})
    assert any(
        p.startswith("/v1/businesses/{business_id}/notifications") for p in paths
    )


def test_notification_dedupe_key_length():
    iid = uuid.uuid4()
    uid = uuid.uuid4()
    day = "2026-05-18"
    key = f"low_stock:{iid}:{day}:{uid}"
    assert len(key) <= 220
