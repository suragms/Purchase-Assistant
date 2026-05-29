# ROLE MATRIX — HARISREE PURCHASE ASSISTANT
> What each role sees, can do, and cannot do.

---

## ROLES IN SYSTEM

| Role | Who Is This |
|------|-------------|
| `owner` | Business owner (Harisree). Full access. |
| `manager` | Senior staff / admin. Most access, no financials. |
| `staff` | Warehouse worker. Task-focused. No financials. |
| `cash_buyer` | Staff who does local cash purchases only. |

---

## OWNER ROLE

### Pages: ALL
### Actions:
| Action | Allowed |
|--------|---------|
| View all stock | ✅ |
| View purchase rates | ✅ |
| View profit/margin | ✅ |
| Create purchase orders | ✅ |
| Edit purchase orders | ✅ |
| Delete purchase orders | ✅ |
| Mark purchase delivered | ✅ |
| Edit stock manually | ✅ |
| Set opening stock | ✅ |
| View all reports | ✅ |
| Manage users | ✅ |
| Set reorder levels | ✅ |
| Approve reorder requests | ✅ |
| View expense tracker | ✅ |
| Add expenses | ✅ |
| View activity logs | ✅ |
| Export data | ✅ |

### Hidden from owner:
- Nothing.

---

## MANAGER ROLE

### Pages: All except User Management
### Actions:
| Action | Allowed |
|--------|---------|
| View all stock | ✅ |
| View purchase rates | ❌ (redacted) |
| View profit/margin | ❌ |
| Create purchase orders | ✅ |
| Edit purchase orders | ✅ |
| Delete purchase orders | ❌ |
| Mark purchase delivered | ✅ |
| Edit stock manually | ✅ |
| Set opening stock | ✅ |
| View reports (qty only, no value) | ✅ |
| Manage users | ❌ |
| Set reorder levels | ✅ |
| Approve reorder requests | ✅ |
| Add expenses | ✅ |
| View activity logs | ✅ (own only) |
| Export data | ✅ (qty only) |

### Implementation:

**File:** `backend/app/services/staff_view.py`

```python
def should_redact_financials(role: str) -> bool:
    return role in ("manager", "staff", "cash_buyer")

def can_delete_purchases(role: str) -> bool:
    return role == "owner"

def can_manage_users(role: str) -> bool:
    return role == "owner"
```

---

## STAFF ROLE

### Pages: Home, Stock (limited), Purchases (view only)
### Actions:
| Action | Allowed |
|--------|---------|
| View stock levels | ✅ |
| View purchase rates | ❌ |
| Create purchase orders | ❌ |
| Edit purchase orders | ❌ |
| Delete purchase orders | ❌ |
| Mark purchase delivered | ❌ (can mark "arrived") |
| Verify delivery (physical count vs invoice) | ✅ |
| Log cash buy (quick staff purchase) | ✅ |
| Set opening stock | ❌ |
| Update physical count | ✅ |
| Notify owner | ✅ |
| Add to reorder list | ✅ |
| View reports | ❌ |
| View expenses | ❌ |
| View activity logs | ✅ (own only) |

### Flutter — Hide for staff:

```dart
// Anywhere financial data is shown:
if (ref.read(sessionProvider)?.role != 'staff')
  PurchaseRateColumn(rate: item.lastRate),

// Purchase create button — hide for staff:
if (role == 'owner' || role == 'manager')
  NewPurchaseButton(),

// Delete button — hide for everyone except owner:
if (role == 'owner')
  DeleteButton(),
```

---

## CASH_BUYER ROLE

### Pages: Home (simplified), Quick Purchase only
### Actions:
| Action | Allowed |
|--------|---------|
| Log cash buy (quick purchase) | ✅ |
| View own purchases today | ✅ |
| View stock levels | ✅ (basic — name + qty) |
| View purchase rates | ❌ |
| Create formal purchase orders | ❌ |
| Update physical count | ❌ |
| Notify owner | ✅ |
| View reports | ❌ |

### Simplified home for cash_buyer:

```dart
// cash_buyer sees only:
// 1. Quick Purchase button (large, prominent)
// 2. Low stock items (what to buy)
// 3. My purchases today (what I bought)
```

---

## PERMISSION CHECKS — BACKEND

**File:** `backend/app/services/permissions.py`

```python
PERMISSIONS = {
    "owner": {
        "stock_view", "stock_edit", "stock_delete",
        "purchase_create", "purchase_edit", "purchase_delete", "purchase_deliver",
        "report_view", "report_export",
        "user_manage",
        "expense_view", "expense_add",
        "catalog_edit",
    },
    "manager": {
        "stock_view", "stock_edit",
        "purchase_create", "purchase_edit", "purchase_deliver",
        "report_view",
        "expense_add",
        "catalog_edit",
    },
    "staff": {
        "stock_view", "stock_physical_count",
        "purchase_verify",
        "staff_purchase_log",
        "notify_owner",
        "reorder_request",
    },
    "cash_buyer": {
        "stock_view",
        "staff_purchase_log",
        "notify_owner",
    },
}

def has_permission(role: str, permission: str) -> bool:
    return permission in PERMISSIONS.get(role, set())
```

**Apply to every endpoint:**
```python
# Example:
@router.delete("/{purchase_id}")
async def delete_purchase(
    ...,
    _m: Membership = Depends(require_permission("purchase_delete")),
):
    ...
```

---

## USER MANAGEMENT PAGE UX FIX

### Current Problem
Tabs inside user management page have nested scrolling. Row data is cut off.

### New Layout

**File:** `lib/features/admin/presentation/user_management_page.dart`

```
Users Tab:
  [Search bar]
  [Role filter chips: All | Owner | Manager | Staff | Cash Buyer]
  User rows (Name, Role, Status, Last Active)
  Each row: tap → slide-in detail (not new page)

Permissions Tab:
  Simple table: Feature vs Role checkboxes
  READ ONLY — permissions are hardcoded in backend

Activity Log Tab:
  Who | Action | Item | Before | After | When
  Filter by user/date
```

**No nested scrolling. All tabs use `SliverList` from the same outer `CustomScrollView`.**
