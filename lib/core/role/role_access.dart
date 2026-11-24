/// Access rules for the seller and developer portals.
///
/// The developer console is restricted to the store administrator.
/// Add or remove administrator e-mails in [kAdminEmails] before publishing.
const Set<String> kAdminEmails = {
  'admin@glowcare.dz',
  'dev@glowcare.dz',
  'admin@glowcare.com',
};

bool isAdminEmail(String? email) {
  final normalized = (email ?? '').trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return kAdminEmails.contains(normalized);
}
