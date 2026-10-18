import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/network/supabase_client_provider.dart';

import '../../helpers/mock_supabase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('overrideWithValue -> mengembalikan client yang di-override', () {
    final client = MockSupabaseClient();
    final container = ProviderContainer(
      overrides: [supabaseClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    expect(container.read(supabaseClientProvider), same(client));
    // Client yang sama dibagikan ke pembaca berikutnya (singleton per-container).
    expect(container.read(supabaseClientProvider), same(client));
  });

  test('default tanpa init Supabase -> melempar error', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // `Supabase.instance` belum diinisialisasi di test -> error.
    expect(
      () => container.read(supabaseClientProvider),
      throwsA(anything),
    );
  });
}
