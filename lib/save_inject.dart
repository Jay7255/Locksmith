import 'dart:convert';

/// The game page starts with `window.__SAVE__ = null;`. Before loading it we
/// swap that for the player's saved progress, so the game starts where they
/// left off. Anything that is not valid JSON is ignored.
String injectSave(String html, String? saved) {
  const marker = 'window.__SAVE__ = null;';
  if (saved == null || saved.isEmpty) return html;
  try {
    final clean = jsonEncode(jsonDecode(saved)).replaceAll('</', r'<\/');
    return html.replaceFirst(marker, 'window.__SAVE__ = $clean;');
  } catch (_) {
    return html;
  }
}
