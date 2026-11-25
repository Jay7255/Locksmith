/// Where the newest game page lives. The app downloads it in the background
/// and uses it the next time it starts, so game changes reach players
/// without a new app install. Must be a public repository.
const remoteGameUrl =
    'https://raw.githubusercontent.com/Jay7255/Locksmith/main/assets/game/index.html';

/// The number in `<meta name="game-version" content="N">`, or 0 if missing.
int gameVersion(String html) {
  final m = RegExp(r'<meta name="game-version" content="(\d+)">').firstMatch(html);
  return m == null ? 0 : int.parse(m.group(1)!);
}

/// A downloaded page is only used if it really is the game: it must have
/// the save marker and the app bridge, and not be older than the page
/// that shipped inside the app.
bool isUsableGame(String? html, int bundledVersion) {
  if (html == null || html.length < 1000) return false;
  if (!html.contains('window.__SAVE__ = null;')) return false;
  if (!html.contains('AdBridge')) return false;
  return gameVersion(html) >= bundledVersion;
}

/// The cached download if it's good, otherwise the page inside the app.
String chooseGame({required String bundled, String? cached}) =>
    isUsableGame(cached, gameVersion(bundled)) ? cached! : bundled;
