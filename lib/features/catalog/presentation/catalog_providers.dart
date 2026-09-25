import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/core/network/supabase_client_provider.dart';
import 'package:zunixe_corp_mobile/features/catalog/catalog.dart';

/// Repository katalog untuk graph Riverpod. Override di test dengan
/// mock/fake [ProductRepository].
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositorySupabase(
    client: ref.watch(supabaseClientProvider),
  ),
  name: 'productRepositoryProvider',
);
