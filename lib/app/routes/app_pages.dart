import 'package:get/get.dart';

import '../../features/auth/auth_binding.dart';
import '../../features/auth/forgot_view.dart';
import '../../features/auth/login_view.dart';
import '../../features/auth/onboarding_view.dart';
import '../../features/auth/signup_view.dart';
import '../../features/public/template_public_view.dart';
import '../../features/shell/shell_binding.dart';
import '../../features/shell/shell_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgot,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.shell,
      page: () => const ShellView(),
      bindings: [
        AuthBinding(),
        ShellBinding(),
      ],
    ),
    GetPage(
      name: AppRoutes.publicTemplate,
      page: () => const TemplatePublicView(),
    ),
  ];
}
