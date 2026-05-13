import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import 'auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.brandGradient(opacity: 0.22)),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: width < 900
                    ? _Card(c: c)
                    : Row(
                        children: [
                          const Expanded(child: _SideCopy()),
                          const SizedBox(width: 18),
                          Expanded(child: _Card(c: c)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideCopy extends StatelessWidget {
  const _SideCopy();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome back', style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(
            'Design templates, track link analytics, and let attendees generate personalized posters in seconds.',
            style: tt.bodyLarge?.copyWith(
              color: tt.bodyLarge?.color?.withOpacity(0.80),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _Chip(icon: Icons.dashboard_outlined, label: 'Creator dashboard'),
              _Chip(icon: Icons.brush_outlined, label: 'Canvas editor'),
              _Chip(icon: Icons.analytics_outlined, label: 'Analytics'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.06 : 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.c});
  final AuthController c;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Login', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email',
                    hint: 'you@company.com',
                    prefixIcon: Icons.alternate_email,
                    controller: c.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => AppTextField(
                      label: 'Password',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      controller: c.password,
                      obscureText: c.obscurePassword.value,
                      suffixIcon: c.obscurePassword.value ? Icons.visibility : Icons.visibility_off,
                      onSuffixTap: () => c.obscurePassword.toggle(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.forgot),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => GradientButton(
                      label: 'Login',
                      icon: Icons.login,
                      expand: true,
                      loading: c.isBusy.value,
                      onPressed: c.login,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SocialRow(c: c),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text('New here?', style: Theme.of(context).textTheme.bodyMedium),
                      TextButton(onPressed: () => Get.offNamed(AppRoutes.signup), child: const Text('Create account')),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow({required this.c});

  final AuthController c;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppButton.ghost(
        label: 'Continue with Google',
        icon: Icons.g_mobiledata,
        expand: true,
        onPressed: c.isBusy.value ? null : c.signInWithGoogle,
      ),
    );
  }
}
