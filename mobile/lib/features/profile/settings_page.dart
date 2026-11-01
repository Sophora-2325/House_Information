import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackBar(title: '设置', onBack: () => context.pop()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          WhiteCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  icon: Icons.person_outline,
                  label: '个人资料',
                  onTap: () => showTip(context, '个人资料将在后续版本编辑'),
                ),
                const Divider(height: 1, indent: 52),
                _Row(
                  icon: Icons.phone_android_outlined,
                  label: '联系方式管理',
                  onTap: () => showTip(context, '当前手机号 138****5621'),
                ),
                const Divider(height: 1, indent: 52),
                _Row(
                  icon: Icons.verified_user_outlined,
                  label: '隐私与授权设置',
                  onTap: () => showTip(context, '联系方式默认不公开，需双方授权'),
                ),
                const Divider(height: 1, indent: 52),
                _Row(
                  icon: Icons.description_outlined,
                  label: '用户协议',
                  onTap: () => showTip(context, '用户协议将在正式版本提供'),
                ),
                const Divider(height: 1, indent: 52),
                _Row(
                  icon: Icons.policy_outlined,
                  label: '隐私政策',
                  onTap: () => showTip(context, '隐私政策将在正式版本提供'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(
                  icon: Icons.info_outline,
                  label: '关于房市直通',
                  onTap: () => showTip(context, '房市直通 V0.1.1 · 免费信息直连'),
                ),
                const Divider(height: 1, indent: 52),
                _Row(
                  icon: Icons.warning_amber_outlined,
                  label: '反馈问题',
                  onTap: () => context.push('/reports'),
                ),
                const Divider(height: 1, indent: 52),
                _Row(
                  icon: Icons.logout,
                  label: '退出登录',
                  onTap: () => context.go('/login'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(
                Icons.warning_amber_outlined,
                color: AppColors.danger,
              ),
              title: const Text(
                '注销账户',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('请先处理未完成的房源与意向记录'),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('注销账户'),
                    content: const Text(
                      '原型不会真正注销账户。正式版本会说明数据处理方式，并要求先处理未完成的房源与意向。',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showTip(context, '已记录注销申请（原型）');
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          const Center(
            child: Text(
              '房市直通 V0.1.1 · 免费信息服务',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
