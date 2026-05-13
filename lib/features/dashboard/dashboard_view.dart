import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/responsive/screen_size.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_hover.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/glass_card.dart';
import '../shell/shell_controller.dart';
import '../templates/template_model.dart';
import 'dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DashboardController());
    final size = screenSizeOf(context);
    final padding = size == ScreenSize.mobile ? 14.0 : 18.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 8, padding, padding),
      children: [
        _Header(size: size),
        const SizedBox(height: 14),
        Obx(() {
          final totalTemplates = c.templates.length;
          return _StatsGrid(size: size, totalTemplates: totalTemplates);
        }),
        const SizedBox(height: 14),
        Obx(() {
          final list = c.templates.toList(growable: false);
          return _RecentTemplates(size: size, templates: list);
        }),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.size});
  final ScreenSize size;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Creator Dashboard', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  'Manage your templates and share public links for attendees.',
                  style: tt.bodyMedium?.copyWith(color: tt.bodyMedium?.color?.withOpacity(0.75)),
                ),
              ],
            ),
          ),
          if (size != ScreenSize.mobile)
            GradientButton(
              label: 'New Template',
              icon: Icons.add,
              expand: false,
              onPressed: () => Get.find<ShellController>().setIndex(1),
            ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.size, required this.totalTemplates});
  final ScreenSize size;
  final int totalTemplates;

  @override
  Widget build(BuildContext context) {
    final cols = switch (size) {
      ScreenSize.mobile => 2,
      ScreenSize.tablet => 3,
      ScreenSize.desktop => 4,
    };
    final items = [
      _Stat('Total templates', '$totalTemplates', Icons.layers_outlined, AppColors.primary),
      const _Stat('Generated posters', '—', Icons.image_outlined, AppColors.cyan),
      const _Stat('Link views', '—', Icons.visibility_outlined, AppColors.primary3),
      const _Stat('Clicks', '—', Icons.ads_click_outlined, AppColors.success),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: size == ScreenSize.mobile ? 1.3 : 1.6,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _StatCard(stat: items[i]),
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AnimatedHover(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: stat.color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(stat.icon, color: stat.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(stat.value, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(stat.label, style: tt.bodySmall?.copyWith(color: tt.bodySmall?.color?.withOpacity(0.72))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTemplates extends StatelessWidget {
  const _RecentTemplates({required this.size, required this.templates});
  final ScreenSize size;
  final List<TemplateModel> templates;

  @override
  Widget build(BuildContext context) {
    final cols = switch (size) {
      ScreenSize.mobile => 1,
      ScreenSize.tablet => 2,
      ScreenSize.desktop => 3,
    };

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Recent Templates', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              ),
              TextButton(onPressed: () => Get.find<ShellController>().setIndex(1), child: const Text('Open editor')),
            ],
          ),
          const SizedBox(height: 12),
          if (templates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 46, color: Theme.of(context).colorScheme.primary.withOpacity(0.9)),
                    const SizedBox(height: 10),
                    Text('No templates yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(
                      'Create your first poster template, then share the link.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    GradientButton(
                      label: 'Create template',
                      icon: Icons.add,
                      expand: false,
                      onPressed: () => Get.find<ShellController>().setIndex(1),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.9,
              ),
              itemCount: templates.take(6).length,
              itemBuilder: (context, i) => _TemplateTile(t: templates[i]),
            ),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.t});
  final TemplateModel t;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final updated = t.updatedAt.toLocal().toString().split('.').first;
    return AnimatedHover(
      onTap: () => Get.find<ShellController>().setIndex(1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withOpacity(0.18),
              cs.secondary.withOpacity(0.10),
              cs.tertiary.withOpacity(0.06),
            ],
          ),
          border: Border.all(color: cs.primary.withOpacity(0.16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: t.backgroundUrl != null
                      ? Image.network(
                          t.backgroundUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ThumbFallback(t: t),
                        )
                      : _ThumbFallback(t: t),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.title.isEmpty ? 'Untitled' : t.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Updated $updated',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color?.withOpacity(0.70)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback({required this.t});
  final TemplateModel t;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final grad = t.backgroundGradient;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: grad.enabled
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [grad.color1, grad.color2],
                transform: GradientRotation(grad.angleDeg * 0.017453292519943295),
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.primary.withOpacity(0.35), cs.secondary.withOpacity(0.14)],
              ),
      ),
      child: const Center(child: Icon(Icons.image_outlined, size: 22)),
    );
  }
}
