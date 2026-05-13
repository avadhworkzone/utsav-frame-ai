import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/responsive/screen_size.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import 'public_form_controller.dart';

class PublicFormView extends StatelessWidget {
  const PublicFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PublicFormController());
    final size = screenSizeOf(context);
    final pad = size == ScreenSize.mobile ? 14.0 : 18.0;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, 8, pad, pad),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: GlassCard(
            padding: const EdgeInsets.all(18),
            child: size == ScreenSize.mobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Header(),
                      const SizedBox(height: 12),
                      _PosterPreview(c: c),
                      const SizedBox(height: 14),
                      _Form(c: c),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _PosterPreview(c: c)),
                      const SizedBox(width: 14),
                      Expanded(child: _Form(c: c)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Public Link Form', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(
          'Users enter details and download a personalized poster generated from the template.',
          style: tt.bodyMedium?.copyWith(color: tt.bodyMedium?.color?.withOpacity(0.75)),
        ),
      ],
    );
  }
}

class _PosterPreview extends StatelessWidget {
  const _PosterPreview({required this.c});
  final PublicFormController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.brandGradient(opacity: 0.20)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withOpacity(0.10),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: Text(
                        'Event Poster',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Obx(() {
                      final bytes = c.userImageBytes.value;
                      return Container(
                        width: 180,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                          color: Colors.white.withOpacity(0.12),
                          image: bytes == null ? null : DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
                        ),
                        child: bytes == null
                            ? const Center(child: Icon(Icons.person_outline, size: 44))
                            : const SizedBox.shrink(),
                      );
                    }),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.20)),
                          ),
                          child: Text(
                            c.nameValue.value.isEmpty ? 'Your Name' : c.nameValue.value,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.c});
  final PublicFormController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(),
        const SizedBox(height: 14),
        TextField(
          controller: c.name,
          decoration: const InputDecoration(
            labelText: 'Your name',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => AppButton.ghost(
            label: c.userImageBytes.value == null ? 'Upload profile image' : 'Change image',
            icon: Icons.photo_camera_outlined,
            expand: true,
            onPressed: c.pickUserImage,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => GradientButton(
            label: 'Generate',
            icon: Icons.auto_awesome,
            expand: true,
            loading: c.isGenerating.value,
            onPressed: c.generate,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => AppButton.primary(
            label: 'Download image',
            icon: Icons.download_outlined,
            expand: true,
            onPressed: c.generatedBytes.value == null ? null : c.download,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: c.isGenerating.value
                ? Container(
                    key: const ValueKey('loading'),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.30)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Generating your poster…',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('idle')),
          ),
        ),
      ],
    );
  }
}
