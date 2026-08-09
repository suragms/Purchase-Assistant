# FEATURE: WhatsApp PO Auto-Delivery

## Context
Goal: PO approved → PDF generated → sent to the correct staff's WhatsApp automatically, removing current manual click-through. **Important**: WhatsApp integration was fully removed from this codebase in migration `066_drop_scan_and_whatsapp.py` — this is new build, not reconnecting something that already exists. Depends on `07_owner_api_key_settings.md` (WhatsApp API key + staff numbers must be owner-configurable first) and `05_staff_management.md` (need a reliable staff→task mapping to know who to send to).

## Task
### Step 1 — Confirm existing PDF generation path
Before building a new PDF generator, check `flutter_app/lib/core/services/broker_statement_pdf.dart` and any PDF generation already present in `routers/trade_purchases.py` / `reports_trade.py` for purchase orders. Reuse the existing generator/template if a PO PDF path already exists in some form; extend rather than duplicate.

### Step 2 — Trigger point
On PO approval (the existing approval action/endpoint — locate it in `trade_purchases.py` or wherever PO status transitions are handled), fire an async delivery task: generate PDF → send via WhatsApp Business API using the owner-configured credential (file 07) → log result.

### Step 3 — Recipient resolution
Map the approved PO to the correct staff WhatsApp number via the staff records established in file 05 — never hardcode a number. If no number is on file for the relevant staff member, flag for manual send rather than failing silently.

### Step 4 — Idempotency
A PO approval action (or a webhook, if the WhatsApp API sends delivery confirmations back) firing twice must not send the PDF twice. Dedupe on `po_id + delivery_status` before sending — check `whatsapp_delivery_log` for an existing successful send before dispatching. This is the same duplicate-webhook risk the original project master prompt already calls out for WhatsApp generally — apply it here specifically.

### Step 5 — Delivery logging
New table `whatsapp_delivery_log`: `id, business_id, po_id, staff_id, recipient_number, status (sent/failed/pending_manual), attempt_count, last_attempted_at, error_message, created_at`.

### Step 6 — Failure handling
On send failure: retry with bounded backoff (e.g. 3 attempts, exponential). After exhausting retries, mark `pending_manual` and surface it in the owner dashboard (file 06) as something needing attention — never fail completely silently.

### Step 7 — Owner visibility
Owner dashboard or a dedicated PO-delivery screen shows: sent, failed, pending-manual counts, with a manual "resend" action for anything stuck.

## Edge cases
- Staff member has no WhatsApp number configured → pending_manual, not a crash.
- WhatsApp API rate-limited → respect backoff, don't hammer retries.
- PO edited/re-approved after already sent → decide explicitly whether this should re-send (likely yes, as a new delivery log entry, not overwriting the first) — confirm this behavior with Anandu before implementing, it's a business-logic decision, not a technical one.
- PDF generation itself fails (bad data, missing fields) → this should block the WhatsApp send with a clear error, not send a broken/empty PDF.

## Deliverable
- Migration for `whatsapp_delivery_log`
- Delivery service (PDF generation reuse + WhatsApp send + retry/backoff)
- Hook into existing PO approval flow
- Owner-facing delivery status view with manual resend

## Risk
Medium — sends real business documents to real people; a duplicate-send bug is a visible, embarrassing failure mode (staff getting the same PO twice), and a wrong-recipient bug is worse. Idempotency and recipient-resolution correctness are the two things to test hardest before this goes live.

## Tests
- Approval → PDF generated → correct recipient → sent, end to end.
- Double-approval-trigger (simulate) does not produce a duplicate send.
- Missing staff number → pending_manual, visible in owner view, not a silent drop.
- Retry/backoff behavior on simulated WhatsApp API failure.
- PDF generation failure blocks the send with a clear surfaced error.
