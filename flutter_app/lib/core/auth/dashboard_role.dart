import '../models/session.dart';

/// Full warehouse control center (owner, admin, manager, super admin).
bool sessionHasOwnerDashboard(Session s) {
  if (s.isSuperAdmin) return true;
  final r = s.primaryBusiness.role.toLowerCase();
  return r == 'owner' || r == 'admin' || r == 'manager' || r == 'super_admin';
}

/// ₹ prices, rates, profit, UPI, and financial totals (AGENTS role display).
/// Managers still get purchase history / reports via other gates — not Home profit strips.
bool sessionCanSeeFinancialMoney(Session s) {
  if (s.isSuperAdmin) return true;
  final r = s.primaryBusiness.role.toLowerCase();
  return r == 'owner' || r == 'admin' || r == 'super_admin';
}

String dashboardRoleLabel(Session s) {
  if (s.isSuperAdmin) return 'Admin';
  final r = s.primaryBusiness.role.toLowerCase();
  return switch (r) {
    'owner' => 'Owner',
    'admin' => 'Admin',
    'manager' => 'Manager',
    'super_admin' => 'Admin',
    _ => r.isEmpty ? 'Staff' : r[0].toUpperCase() + r.substring(1),
  };
}
