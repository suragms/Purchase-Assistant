# Production data source (Render Postgres)

The live app reads and writes **Render Postgres** (`harisree-db`), not Supabase.

| Layer | Host / ID |
|-------|-----------|
| Flutter web (Vercel) | `API_BASE_URL` → `https://my-purchases-api.onrender.com` |
| API (`my-purchases-api`) | `DATABASE_URL` → internal `dpg-d8fu1p77f7vs73eooiu0-a/harisree_db` |
| Local `pg_dump` / Alembic | Render **external** URL from Dashboard → Connect |

Verify anytime:

```http
GET https://my-purchases-api.onrender.com/health/ready
```

Expect `"db":"ok"` and `alembic_version` at head.

After deploy, hard-refresh the PWA (Ctrl+Shift+R) so the browser does not use a cached `main.dart.js`.
