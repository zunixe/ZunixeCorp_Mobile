/// Ambil pesan raise EXCEPTION server dari PostgrestException
/// (toString mentah berbentuk "PostgrestException(message: ..., code: ...)").
String serverMessage(Object e, {String fallback = 'Terjadi kesalahan.'}) {
  try {
    final m = (e as dynamic).message as String?;
    if (m != null && m.isNotEmpty) return m;
  } catch (_) {}
  final s = e
      .toString()
      .replaceFirst('Exception: ', '')
      .replaceFirst('Function call error: ', '');
  if (s.isEmpty || s == 'null') return fallback;
  return s;
}
