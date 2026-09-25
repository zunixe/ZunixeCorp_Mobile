import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zunixe_corp_mobile/core/network/supabase_client_provider.dart';
import 'package:zunixe_corp_mobile/features/orders/orders.dart';

/// Repository pesanan untuk graph Riverpod. Override di test dengan
/// mock/fake [OrderRepository].
final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepositorySupabase(
    client: ref.watch(supabaseClientProvider),
  ),
  name: 'orderRepositoryProvider',
);
