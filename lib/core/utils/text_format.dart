/// Lightweight helpers to make AI/markdown-flavoured strings readable inside
/// plain [Text] widgets (they are not markdown renderers).
String stripMarkdown(String input) {
  var out = input.replaceAllMapped(
    RegExp(r'\*\*(.+?)\*\*', dotAll: true),
    (m) => m.group(1) ?? '',
  );
  out = out.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
  out = out.replaceAll(RegExp(r'^\s*-{3,}\s*$', multiLine: true), '────────────');
  out = out.replaceAll('*', '');
  out = out.replaceAll('`', '');
  return out;
}
