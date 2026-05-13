import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/responsive/screen_size.dart';
import '../../core/widgets/animated_hover.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../editor/template_editor_controller.dart';
import '../shell/shell_controller.dart';
import '../templates/template_model.dart';
import 'marketplace_controller.dart';

class MarketplaceView extends StatelessWidget {
  const MarketplaceView({super.key});

  static const _categories = <String>[
    'All',
    'Birthday',
    'Seminar',
    'Festival',
    'Corporate',
    'Wedding',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MarketplaceController());
    final size = screenSizeOf(context);
    final pad = size == ScreenSize.mobile ? 14.0 : 18.0;
    final cols = switch (size) {
      ScreenSize.mobile => 1,
      ScreenSize.tablet => 2,
      ScreenSize.desktop => 3,
    };

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 8, pad, pad),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Marketplace', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                'Browse templates published by creators. Tap one to preview.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: c.query,
                decoration: const InputDecoration(
                  hintText: 'Search templates...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final cat in _categories)
                      _Chip(
                        label: cat,
                        selected: c.selectedCategory.value == cat,
                        onTap: () => c.setCategory(cat),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (c.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (c.error.value != null) {
            return EmptyState(title: 'Could not load marketplace', message: c.error.value!, icon: Icons.error_outline);
          }
          final items = c.filtered;
          if (items.isEmpty) {
            return GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const EmptyState(
                    title: 'No templates found',
                    message: 'Publish templates from the editor, or create starter templates for your marketplace.',
                    icon: Icons.storefront_outlined,
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: 'Create starter templates',
                    icon: Icons.auto_awesome,
                    expand: true,
                    onPressed: c.seedStarterTemplates,
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => _MarketCard(t: items[i]),
          );
        }),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withOpacity(0.18) : (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.06 : 0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? cs.primary.withOpacity(0.35) : (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
        ),
        child: Text(label, style: TextStyle(color: selected ? cs.primary : null, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({required this.t});
  final TemplateModel t;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedHover(
      onTap: () {
        Get.find<ShellController>().setIndex(1);
        Get.find<TemplateEditorController>().loadFromMarketplace(t.id);
      },
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: t.backgroundUrl != null
                    ? Image.network(t.backgroundUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _FallbackPreview(cs: cs))
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: t.backgroundGradient.enabled
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [t.backgroundGradient.color1, t.backgroundGradient.color2],
                                  transform: GradientRotation(t.backgroundGradient.angleDeg * 0.017453292519943295),
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    cs.primary.withOpacity(0.25),
                                    cs.secondary.withOpacity(0.10),
                                  ],
                                ),
                        ),
                        child: const Center(child: Icon(Icons.image_outlined, size: 40)),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(t.title.isEmpty ? 'Template' : t.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(
              t.ownerName.trim().isEmpty ? 'Published' : 'By ${t.ownerName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackPreview extends StatelessWidget {
  const _FallbackPreview({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.22),
            cs.tertiary.withOpacity(0.10),
          ],
        ),
      ),
      child: const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
    );
  }
}
