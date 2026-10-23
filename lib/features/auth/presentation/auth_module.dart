import 'package:go_router/go_router.dart';
import 'package:zunixe_corp_mobile/core/router/app_routes.dart';
import 'package:zunixe_corp_mobile/core/router/feature_module.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/account_screen.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/login_screen.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/register_screen.dart';
import 'package:zunixe_corp_mobile/features/auth/presentation/reset_password_screen.dart';

/// Rute fitur auth: login, daftar, reset password, akun.
class AuthModule extends FeatureModule {
  const AuthModule();

  @override
  String get name => 'auth';

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: AppRoutes.login,
          name: AppRouteNames.login,
          builder: (context, state) =>
              LoginScreen(from: state.uri.queryParameters['from']),
        ),
        GoRoute(
          path: AppRoutes.account,
          name: AppRouteNames.account,
          builder: (context, state) => const AccountScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: AppRouteNames.register,
          builder: (context, state) =>
              RegisterScreen(from: state.uri.queryParameters['from']),
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          name: AppRouteNames.resetPassword,
          builder: (context, state) => const ResetPasswordScreen(),
        ),
      ];
}
