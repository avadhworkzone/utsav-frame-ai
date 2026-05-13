import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_hover.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 900;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.brandGradient(opacity: 0.24)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isMobile
                    ? _Mobile()
                    : Row(
                        children: [
                          const Expanded(child: _Hero()),
                          const SizedBox(width: 18),
                          Expanded(child: _AuthCard()),
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

class _Mobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _Hero(),
        SizedBox(height: 16),
        _AuthCard(),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('PosterCraft', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Create dynamic event posters.\nShare a link.\nUsers generate personalized images.',
            style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w800, height: 1.05),
          ),
          const SizedBox(height: 12),
          Text(
            'A modern SaaS-style platform for creators to build templates with editable placeholders (name, image, text) and let attendees generate their own poster instantly.',
            style: tt.bodyLarge?.copyWith(
              color: tt.bodyLarge?.color?.withOpacity(0.80),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _Pill(icon: Icons.layers_outlined, label: 'Drag & Drop Editor'),
              _Pill(icon: Icons.link, label: 'Shareable Links'),
              _Pill(icon: Icons.cloud_download_outlined, label: 'Instant Download'),
              _Pill(icon: Icons.phone_iphone, label: 'Mobile + Web'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
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

class _AuthCard extends StatelessWidget {
  const _AuthCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Get started',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Login or create an account to build templates and share links.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
          ),
          const SizedBox(height: 14),
          AnimatedHover(
            onTap: () => Get.toNamed(AppRoutes.login),
            child: const GradientButton(label: 'Login', icon: Icons.login, expand: true),
          ),
          const SizedBox(height: 10),
          AnimatedHover(
            onTap: () => Get.toNamed(AppRoutes.signup),
            child: const AppButton.ghost(label: 'Create account', icon: Icons.person_add, expand: true),
          ),
          const SizedBox(height: 12),
          Text(
            'By continuing you agree to the Terms & Privacy Policy.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.70),
                ),
          ),
        ],
      ),
    );
  }
}
