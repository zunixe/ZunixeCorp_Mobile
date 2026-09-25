import 'package:supabase_flutter/supabase_flutter.dart';

/// Hasil pendaftaran: langsung login / perlu verifikasi email / gagal.
enum RegisterResult { loggedIn, needVerification, failed }

/// Nama tampil user — logika murni agar dapat di-unit-test.
String displayNameFor(User? user) {
  final meta = user?.userMetadata;
  final name = meta?['full_name'] as String? ?? meta?['name'] as String?;
  if (name != null && name.trim().isNotEmpty) return name;
  return user?.email?.split('@').first ?? 'User';
}
