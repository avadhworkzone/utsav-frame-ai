import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/responsive/screen_size.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/auth_controller.dart';
import '../dashboard/dashboard_view.dart';
import '../editor/template_editor_view.dart';
import '../marketplace/marketplace_view.dart';
import '../settings/settings_view.dart';
import 'shell_controller.dart';

class ShellView extends StatelessWidget {
  const ShellView({super.key});

  static const _tabs = <_ShellTab>[
    _ShellTab('Dashboard', Icons.dashboard_outlined, DashboardView()),
    _ShellTab('Editor', Icons.space_dashboard_outlined, TemplateEditorView()),
    _ShellTab('Marketplace', Icons.storefront_outlined, MarketplaceView()),
    _ShellTab('Settings', Icons.settings_outlined, SettingsView()),
  ];

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);
    final c = Get.find<ShellController>();

    return Obx(() {
      final index = c.index.value.clamp(0, _tabs.length - 1);
      final tab = _tabs[index];
      return Scaffold(
        body: Row(
          children: [
            if (size != ScreenSize.mobile) _Sidebar(tabs: _tabs),
            Expanded(
              child: Column(
                children: [
                  _TopBar(title: tab.label),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: KeyedSubtree(
                        key: ValueKey(tab.label),
                        child: tab.view,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: size == ScreenSize.mobile
            ? _BottomNav(
                tabs: _tabs,
                index: index,
                onChanged: c.setIndex,
              )
            : null,
      );
    });
  }
}

class _ShellTab {
  const _ShellTab(this.label, this.icon, this.view);
  final String label;
  final IconData icon;
  final Widget view;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.tabs});
  final List<_ShellTab> tabs;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShellController>();
    final collapsed = c.sidebarCollapsed;
    final width = collapsed.value ? 88.0 : 260.0;

    return Obx(() {
      final w = collapsed.value ? 88.0 : 260.0;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: w,
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Column(
          children: [
            GlassCard(
              padding: EdgeInsets.symmetric(horizontal: collapsed.value ? 10 : 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome),
                  if (!collapsed.value) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'PosterGen',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  IconButton(
                    tooltip: collapsed.value ? 'Expand' : 'Collapse',
                    onPressed: c.toggleSidebar,
                    icon: Icon(collapsed.value ? Icons.chevron_right : Icons.chevron_left),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(10),
                child: Obx(() {
                  final selected = c.index.value;
                  return ListView.separated(
                    itemCount: tabs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final isSelected = i == selected;
                      return _NavItem(
                        collapsed: collapsed.value,
                        label: tabs[i].label,
                        icon: tabs[i].icon,
                        selected: isSelected,
                        onTap: () => c.setIndex(i),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.collapsed,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final bool collapsed;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = selected ? cs.primary.withOpacity(0.14) : Colors.transparent;
    final fg = selected ? cs.primary : Theme.of(context).iconTheme.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? cs.primary.withOpacity(0.30) : Colors.transparent),
        ),
        child: collapsed
            ? Center(child: Icon(icon, color: fg))
            : Row(
                children: [
                  Icon(icon, color: fg),
                  const SizedBox(width: 12),
                  Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
              ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);
    final auth = Get.find<AuthController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            if (size == ScreenSize.mobile)
              Text('PosterGen', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            if (size == ScreenSize.mobile) const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (size != ScreenSize.mobile) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search templates...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ],
            if (size == ScreenSize.mobile)
              IconButton(
                tooltip: 'Search',
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<int>(
              tooltip: 'Account',
              itemBuilder: (context) => const [
                PopupMenuItem(value: 0, child: Text('Profile')),
                PopupMenuItem(value: 1, child: Text('Logout')),
              ],
              onSelected: (v) {
                if (v == 1) auth.logout();
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                child: const Icon(Icons.person_outline, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  final List<_ShellTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onChanged,
      destinations: [
        for (final t in tabs) NavigationDestination(icon: Icon(t.icon), label: t.label),
      ],
    );
  }
}
