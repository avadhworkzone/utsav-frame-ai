import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import 'auth_controller.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthController>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.brandGradient(opacity: 0.22)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Create account', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Full name',
                        hint: 'Your name',
                        prefixIcon: Icons.person_outline,
                        controller: c.fullName,
                      ),
                      const SizedBox(height: 14),
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
                          hint: 'Create a secure password',
                          prefixIcon: Icons.lock_outline,
                          controller: c.password,
                          obscureText: c.obscurePassword.value,
                          suffixIcon: c.obscurePassword.value ? Icons.visibility : Icons.visibility_off,
                          onSuffixTap: () => c.obscurePassword.toggle(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Obx(
                        () => GradientButton(
                          label: 'Create account',
                          icon: Icons.auto_awesome,
                          expand: true,
                          loading: c.isBusy.value,
                          onPressed: c.signup,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SocialRow(c: c),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text('Already have an account?', style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(onPressed: () => Get.offNamed(AppRoutes.login), child: const Text('Login')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
