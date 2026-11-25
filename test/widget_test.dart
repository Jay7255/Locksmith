import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:locksmith/game_source.dart';
import 'package:locksmith/save_inject.dart';

void main() {
  final page = File('assets/game/index.html').readAsStringSync();

  test('game page is bundled and talks to the app', () {
    expect(page, contains('window.__SAVE__ = null;'));
    expect(page, contains('AdBridge'));
    expect(page, contains('window.onAdResult'));
    for (final type in ['rewarded', 'interstitial', 'save', 'copy', 'privacy']) {
      expect(page, contains("type: '$type'"), reason: type);
    }
  });

  test('saved progress is injected into the page', () {
    final out = injectSave(page, '{"level":7,"coins":350}');
    expect(out, contains('window.__SAVE__ = {"level":7,"coins":350};'));
  });

  test('bad or missing saves leave the page alone', () {
    expect(injectSave(page, null), page);
    expect(injectSave(page, 'not json'), page);
  });

  test('a save cannot break out of the script tag', () {
    final out = injectSave(page, '{"x":"</script><b>"}');
    expect(out, isNot(contains('"</script>')));
  });

  test('game page has a version number', () {
    expect(gameVersion(page), greaterThan(0));
  });

  test('a newer downloaded game is used, an older or broken one is not', () {
    final v = gameVersion(page);
    final newer = page.replaceFirst('content="$v"', 'content="${v + 1}"');
    final older = page.replaceFirst('content="$v"', 'content="${v - 1}"');
    expect(chooseGame(bundled: page, cached: newer), newer);
    expect(chooseGame(bundled: page, cached: older), page);
    expect(chooseGame(bundled: page, cached: '<html>404</html>'), page);
    expect(chooseGame(bundled: page, cached: null), page);
  });
}
