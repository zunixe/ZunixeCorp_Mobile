import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zunixe_corp_mobile/core/network/supabase_client_provider.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';

import '../../helpers/mock_supabase.dart';
import '../../helpers/riverpod_scope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default -> membangun ProductRepositorySupabase dari client', () {
    final client = MockSupabaseClient();
    stubSupabaseAuth(client);
    final container = ProviderContainer(
      overrides: [supabaseClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(productRepositoryProvider),
      isA<ProductRepositorySupabase>(),
    );
  });

  test('overrideWithValue -> memakai repository yang diberikan', () {
    final repo = MockProductRepository();
    final container = ProviderContainer(
      overrides: [productRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    expect(container.read(productRepositoryProvider), same(repo));
  });
}
