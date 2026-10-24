// Pemeriksa batas modul Zunixe Mobile.
//
// Menegakkan aturan yang didokumentasikan di ARCHITECTURE.md:
//   1. `core/**` tidak boleh mengimpor `features/**` atau `app/**`.
//   2. `features/**` tidak boleh mengimpor `app/**`.
//   3. Lintas-fitur hanya boleh lewat BARREL (`features/<b>/<b>.dart`),
//      dilarang menembus `features/<b>/{domain,data,presentation}/**`.
//   4. Grafik impor antar-fitur wajib BEBAS SIKLUS (asiklik).
//   5. `**/domain/**` tidak boleh mengimpor `**/data/**` atau
//      `**/presentation/**`.
//
// Jalankan: `dart run tool/check_imports.dart`
// Keluar dengan kode 1 bila ada pelanggaran (dipakai sebagai gate CI).
//
// Tanpa dependency eksternal — hanya `dart:io`.

import 'dart:io';

void main() {
  final files = _dartFiles('lib');
  final violations = <String>[];
  final graph = <String, Set<String>>{};

  for (final file in files) {
    final rel = _rel(file); // contoh: features/cart/presentation/x.dart
    final src = File(file).readAsStringSync();
    final area = _areaOf(rel); // 'core' | 'features/cart' | 'app' | null
    final layer = _layerOf(rel); // 'domain' | 'data' | 'presentation' | null

    for (final target in _imports(src)) {
      // target: path relatif setelah nama package, contoh: features/cart/cart.dart
      final tArea = _areaOf(target);
      final tLayer = _layerOf(target);

      // R1: core -> features/app
      if (area == 'core' &&
          (tArea == 'app' || (tArea?.startsWith('features/') ?? false))) {
        violations
            .add('$rel  →  $target   [core tidak boleh impor features/app]');
      }

      // R2: features -> app
      if ((area?.startsWith('features/') ?? false) && tArea == 'app') {
        violations.add('$rel  →  $target   [fitur tidak boleh impor app]');
      }

      // R3: lintas-fitur wajib lewat barrel
      if (_isFeature(area) && _isFeature(tArea) && tArea != area) {
        final feature = tArea!.substring('features/'.length);
        final barrel = 'features/$feature/$feature.dart';
        if (target != barrel) {
          violations
              .add('$rel  →  $target   [lintas-fitur wajib barrel: $barrel]');
        }
      }

      // R5: domain -> data/presentation
      if (layer == 'domain' && (tLayer == 'data' || tLayer == 'presentation')) {
        violations.add('$rel  →  $target   [domain tidak boleh impor $tLayer]');
      }

      // Graf antar-fitur (untuk deteksi siklus)
      if (_isFeature(area) && _isFeature(tArea) && tArea != area) {
        graph.putIfAbsent(area!, () => <String>{}).add(tArea!);
      }
    }
  }

  // R4: deteksi siklus antar-fitur
  violations.addAll(_findCycles(graph));

  if (violations.isEmpty) {
    stdout.writeln('check_imports: OK — tidak ada pelanggaran batas modul.');
    return;
  }

  stderr.writeln(
      'check_imports: ${violations.length} pelanggaran batas modul:\n');
  for (final v in violations) {
    stderr.writeln('  • $v');
  }
  exit(1);
}

List<String> _dartFiles(String dir) {
  return Directory(dir)
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path)
      .where((p) => p.endsWith('.dart'))
      .toList()
    ..sort();
}

String _rel(String path) =>
    path.replaceFirst(RegExp(r'^\.?/?'), '').replaceFirst(RegExp(r'^lib/'), '');

/// Ekstrak target impor internal package (relatif setelah `package:.../`).
Iterable<String> _imports(String src) {
  final re = RegExp(
      r'''^\s*import\s+['"]package:zunixe_corp_mobile/([^'"]+)['"]''',
      multiLine: true);
  return re.allMatches(src).map((m) => m.group(1)!);
}

String? _areaOf(String rel) {
  final parts = rel.split('/');
  if (parts.length < 2) return null;
  if (parts.first == 'core') return 'core';
  if (parts.first == 'app') return 'app';
  if (parts.first == 'features' && parts.length >= 2) {
    return 'features/${parts[1]}';
  }
  return null;
}

bool _isFeature(String? area) => area?.startsWith('features/') ?? false;

String? _layerOf(String rel) {
  final parts = rel.split('/');
  // features/<f>/<layer>/...
  if (parts.length >= 3 && parts.first == 'features') {
    final layer = parts[2];
    if (layer == 'domain' || layer == 'data' || layer == 'presentation') {
      return layer;
    }
  }
  return null;
}

List<String> _findCycles(Map<String, Set<String>> graph) {
  final found = <String>[];
  final visiting = <String>{};
  final done = <String>{};
  final stack = <String>[];

  void dfs(String node) {
    if (done.contains(node)) return;
    if (visiting.contains(node)) {
      final start = stack.indexOf(node);
      final cycle = [...stack.sublist(start), node]
          .map((f) => f.substring('features/'.length))
          .join(' → ');
      found.add('siklus antar-fitur: $cycle');
      return;
    }
    visiting.add(node);
    stack.add(node);
    for (final next in graph[node] ?? const <String>{}) {
      dfs(next);
    }
    stack.removeLast();
    visiting.remove(node);
    done.add(node);
  }

  for (final node in graph.keys) {
    dfs(node);
  }
  // buang duplikat (siklus bisa terdeteksi dari beberapa titik)
  return found.toSet().toList();
}
