import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Satu-satunya titik akses singleton Supabase di UI.
///
/// Di test, override dengan client palsu:
/// `supabaseClientProvider.overrideWithValue(mockClient)`.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
  name: 'supabaseClientProvider',
);
