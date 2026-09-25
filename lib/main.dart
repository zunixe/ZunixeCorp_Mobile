import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/app/app_router.dart';
import 'package:zunixe_corp_mobile/core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ahafaueeukvffkdzlkuv.supabase.co',
    publishableKey: 'sb_publishable_wu-3jDpD-Bmld79QA1Oc6w_ROc9MDuo',
  );
  runApp(const ProviderScope(child: ZunixeApp()));
}

class ZunixeApp extends ConsumerWidget {
  const ZunixeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'zunixe.com',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Ubuntu',
        primaryColor: AppColors.brand,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          primary: AppColors.brand,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.ink,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
