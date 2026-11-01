import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/favorites.dart';
import '../../data/inquiries.dart';
import '../../data/mock_data.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteCount = ref.watch(favoriteIdsProvider).length;
    final published = myListings
        .where((item) => item.mineStatus == '展示中')
        .length;
    final pending = myListings.where((item) => item.mineStatus == '待审核').length;
    final removed = myListings.where((item) => item.mineStatus == '已下架').length;

    return Scaffold(
      appBar: AppBackBar(title: '我的', onBack: () => context.go('/home')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFFD7EFEB),
                  child: Icon(Icons.person, color: AppColors.primary, size: 28),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '用户 138****5621',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '普通用户 · 信息自主发布',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      '我的房源',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => context.go('/mine'),
                      child: const Row(
                        children: [
                          Text(
                            '查看全部',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Stat(
                      value: '$published',
                      label: '展示中',
                      onTap: () => context.go('/mine'),
                    ),
                    _Stat(
                      value: '$pending',
                      label: '待审核',
                      onTap: () => context.go('/mine'),
                    ),
                    _Stat(
                      value: '$removed',
                      label: '已下架',
                      onTap: () => context.go('/mine'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.favorite_border,
                  label: '我的收藏',
                  trailing: '$favoriteCount',
                  onTap: () => context.push('/profile/favorites'),
                ),
                const Divider(height: 1, indent: 52),
                _MenuTile(
                  icon: Icons.chat_bubble_outline,
                  label: '我的意向',
                  trailing: '${ref.watch(inquiryStoreProvider).length}',
                  onTap: () => context.go('/inquiries'),
                ),
                const Divider(height: 1, indent: 52),
                _MenuTile(
                  icon: Icons.warning_amber_outlined,
                  label: '我的举报与反馈',
                  onTap: () => context.push('/reports'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.grid_view_outlined,
                  label: '申请第三方服务身份',
                  onTap: () => context.push('/providers/apply'),
                ),
                const Divider(height: 1, indent: 52),
                _MenuTile(
                  icon: Icons.verified_user_outlined,
                  label: '隐私与账户安全',
                  onTap: () => context.push('/profile/settings'),
                ),
                const Divider(height: 1, indent: 52),
                _MenuTile(
                  icon: Icons.settings_outlined,
                  label: '设置',
                  onTap: () => context.push('/profile/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.onTap});

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }
}
