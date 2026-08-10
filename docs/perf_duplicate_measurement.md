# Perf duplicate measurement log

## Baseline (2026-08-10 local) — VERIFIED_RUNTIME API timings

Auth: `owner@harisree.local` against `http://127.0.0.1:8000`, business `ca913a13-…`.

| Endpoint | Latency |
|----------|---------|
| GET `/health/live` | 9ms |
| GET `/health/ready` | 77ms |
| GET `/reports/home-overview?shell_bundle=true` (30d) | 230ms |
| GET `/stock/shell-bundle` | 41ms (warm) |
| GET `/stock/list` | 20ms (warm/small DB) |
| GET `/trade-purchases?limit=15` | 9ms |

## Baseline — VERIFIED_CODE duplicate owners (pre-fix)

| Screen | Overlapping fetches |
|--------|---------------------|
| Home | home-overview + activity (`trade-purchases`+audit+staff-logs) + RT→warehouse light |
| Boot | pingHealth (live+ready) + extra healthReady |
| Stock | shell-bundle + list after light invalidate |
| Dev | POST `127.0.0.1:7388/ingest` from Home.build / index.html |

HAR browser session: not captured (no DevTools export). Code + API timings above are the baseline.

## After fixes wave 1 (2026-08-10) — VERIFIED_RUNTIME API timings

| Endpoint | Latency | Notes |
|----------|---------|-------|
| GET home-overview shell_bundle+compact | 591ms | includes `recent_trade_purchases` in home_operational (0 rows on empty DB) |
| GET stock/shell-bundle | 382ms | `include_ledger` default false |
| GET stock/list `include_ledger=false` | 57ms | Flutter listStock default |

### Code changes shipped (wave 1)

- P0.1: ingest gated (`HEXA_AGENT_DEBUG_LOG`); removed Home.build + index.html ingest
- P0.2: 8s realtime warehouse coalesce; `forRealtimePoll` skips stock list + low-stock ops
- P0.3: `recent_trade_purchases` in home_operational; activity feed reuses + skips staff-logs on compact
- P1: no duplicate `healthReady` after pingHealth; stock list ledger flag; compact home_shell item cap

### Tests

`flutter test test/perf_duplicate_guards_test.dart` (+ viewport) — pass

## After runtime edge fixes (2026-08-10) — VERIFIED_CODE + hard restart

**Problem (VERIFIED_RUNTIME screenshots):** `home-overview` ×4 identical, failed ingest ×N, Reports center spinner, stock PHYS flash-back, unit→bag desync, Material date-range scroll.

### Code changes shipped (wave 2)

| Fix | Evidence label |
|-----|----------------|
| Home: remove `initState` force refresh + empty-DB cold retry; gate lifecycle resume until first overview settle | VERIFIED_CODE |
| Home dashboard: bust no longer clears `_dashInflight`; stale mid-flight coalesces to **one** follow-up pull | VERIFIED_CODE |
| Ingest: removed `main.dart` FlutterError caller; gate remains default-off | VERIFIED_CODE |
| Purchase unit: set `_unitCtrl` **before** recompute/seed; `_catalogKpb` in recompute | VERIFIED_CODE |
| Stock: reject GET that regresses PHYS/`stock_version` vs overlay; physical patch includes `stock_version` | VERIFIED_CODE |
| Reports: Overview never full-page spinner; charts not blocked on purchases; `operationalReportsProvider` 12s timeout | VERIFIED_CODE |
| Session warm: once per business id; list providers watch `primaryBusiness.id` only | VERIFIED_CODE |
| Cupertino date-range sheet for Reports + Home custom period | VERIFIED_CODE |
| Catalog suggest index identity stable; pick flushes filter query | VERIFIED_CODE |

### Target path (cold login → Home)

| Metric | Pass criteria | Status |
|--------|---------------|--------|
| `home-overview` count | 1 (or 1+hard-fail-retry) | VERIFIED_CODE ownership fixed; re-check in DevTools after hard refresh |
| ingest `7388` | 0 | VERIFIED_CODE (no callers without define); web-server hard-restarted |
| catalog `per_page=500` page1 | 1 on login | VERIFIED_CODE warm-once + bid select |
| Stock PHYS after save | matches entered qty | VERIFIED_CODE regress guard |
| Unit bag form | shows catalog/name kg | VERIFIED_CODE order fix |
| Reports Overview | no infinite full-page spinner | VERIFIED_CODE |
| Date picker | Cupertino wheels | VERIFIED_CODE |

### Tests run

```
flutter analyze <touched files>  — 1 pre-existing info (reportsPdf prefix); no errors
flutter test test/perf_duplicate_guards_test.dart — All tests passed (2)
```

Hard restart: Flutter web-server rebound on `http://127.0.0.1:8080` after freeing port (prior PID held socket).

## After ordered page edge review Gate 0 (2026-08-10)

| Check | Status |
|-------|--------|
| Bugbot on uncommitted | 1 high finding fixed: newer `stock_version` must win over lower PHYS overlay |
| Code-review vs perf plan | Plan P0–P2 present in source (`VERIFIED_CODE`) |
| API `home-overview` curl | **VERIFIED_RUNTIME** ~302ms HTTP 200 |
| Browser Network HAR (1× overview / 0× ingest) | **BLOCKED** — needs operator DevTools hard-refresh |

### Phase 1–2 blocking fixes shipped
- Render `HomeDashboardPayload.banner` + Retry in `HomeSessionDataBanner`
- Login surfaces `StateError` empty-workspace messages
- `sessionCanSeeFinancialMoney` gates Home profit / pending / activity bill totals (AGENTS OWNER money)

Hard restart: Flutter `http://127.0.0.1:8080` + API `:8000` health 200.

