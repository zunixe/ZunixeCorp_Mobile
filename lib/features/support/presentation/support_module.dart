import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/router/feature_module.dart';
import 'package:zunixe_corp_mobile/features/support/presentation/about_screen.dart';
import 'package:zunixe_corp_mobile/features/support/presentation/chat_screen.dart';
import 'package:zunixe_corp_mobile/features/support/presentation/legal_screen.dart';

/// Rute fitur dukungan: tentang kami, chat WhatsApp, halaman legal.
class SupportModule extends FeatureModule {
  const SupportModule();

  @override
  String get name => 'support';

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: AppRoutes.about,
          name: AppRouteNames.about,
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          name: AppRouteNames.chat,
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: AppRoutes.legal,
          name: AppRouteNames.legal,
          builder: (context, state) => LegalScreen(
            slug: state.pathParameters['slug'] ?? 'tos',
          ),
        ),
      ];
}
