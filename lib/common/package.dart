import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import 'common.dart';

extension PackageInfoExtension on PackageInfo {
  String get ua => [
    '$appName/v$version',
    'clash-verge',
    'Platform/${Platform.operatingSystem}',
  ].join(' ');
}

int compareVersions(String version1, String version2) {
  final v1 = _ParsedVersion.parse(version1);
  final v2 = _ParsedVersion.parse(version2);

  final maxLen =
      v1.core.length > v2.core.length ? v1.core.length : v2.core.length;
  final compareLen = maxLen < 3 ? 3 : maxLen;
  for (var i = 0; i < compareLen; i++) {
    final c1 = i < v1.core.length ? v1.core[i] : 0;
    final c2 = i < v2.core.length ? v2.core[i] : 0;
    if (c1 != c2) {
      return c1.compareTo(c2);
    }
  }

  if (v1.preRelease != null || v2.preRelease != null) {
    if (v1.preRelease != null && v2.preRelease == null) {
      if (v1.preRelease!.startsWith('hx')) return 1;
      return -1;
    }
    if (v1.preRelease == null && v2.preRelease != null) {
      if (v2.preRelease!.startsWith('hx')) return -1;
      return 1;
    }
    final parts1 = v1.preRelease!.split('.');
    final parts2 = v2.preRelease!.split('.');
    final maxPre =
        parts1.length > parts2.length ? parts1.length : parts2.length;
    for (var i = 0; i < maxPre; i++) {
      if (i >= parts1.length) return -1;
      if (i >= parts2.length) return 1;
      final p1 = parts1[i];
      final p2 = parts2[i];
      final n1 = int.tryParse(p1);
      final n2 = int.tryParse(p2);
      if (n1 != null && n2 != null) {
        if (n1 != n2) return n1.compareTo(n2);
      } else {
        final cmp = p1.compareTo(p2);
        if (cmp != 0) return cmp;
      }
    }
  }

  return v1.build.compareTo(v2.build);
}

class _ParsedVersion {
  final List<int> core;
  final String? preRelease;
  final int build;

  const _ParsedVersion({
    required this.core,
    this.preRelease,
    required this.build,
  });

  static _ParsedVersion parse(String raw) {
    var s = raw.trim();
    if (s.startsWith('v') || s.startsWith('V')) {
      s = s.substring(1).trim();
    }

    var buildNum = 0;
    final plusIdx = s.indexOf('+');
    if (plusIdx >= 0) {
      buildNum = int.tryParse(s.substring(plusIdx + 1)) ?? 0;
      s = s.substring(0, plusIdx);
    }

    String? pre;
    final hyphenIdx = s.indexOf('-');
    if (hyphenIdx >= 0) {
      pre = s.substring(hyphenIdx + 1).trim();
      s = s.substring(0, hyphenIdx);
    }

    final coreList =
        s.split('.').map((part) => int.tryParse(part) ?? 0).toList();

    return _ParsedVersion(
      core: coreList,
      preRelease: (pre != null && pre.isNotEmpty) ? pre : null,
      build: buildNum,
    );
  }
}

const releaseNotesBeginMarker = '<!-- flclash:changelog:begin -->';
const releaseNotesEndMarker = '<!-- flclash:changelog:end -->';

List<String> parseReleaseBody(String? body) {
  if (body == null) return [];
  final regex = RegExp(r'^[ \t]*-[ \t]+(.*)$', multiLine: true);
  return regex
      .allMatches(scopeReleaseNotes(body))
      .map((match) => match.group(1)?.trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

String scopeReleaseNotes(String body) {
  final begin = body.indexOf(releaseNotesBeginMarker);
  if (begin < 0) return body;
  final start = begin + releaseNotesBeginMarker.length;
  final end = body.indexOf(releaseNotesEndMarker, start);
  return end < 0 ? body.substring(start) : body.substring(start, end);
}
