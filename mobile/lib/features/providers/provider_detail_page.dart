import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/mock_data.dart';

class ProviderDetailPage extends StatelessWidget {
  const ProviderDetailPage({super.key, required this.agencyId});

  final String agencyId;

  @override
  Widget build(BuildContext context) {
    final agency = agencyById(agencyId);
    return Scaffold(
      appBar: AppBackBar(title: '机构详情', onBack: () => context.pop()),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: '查看联系方式',
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(agency.name),
                  content: const Text(
                    '以下为机构公开联系方式（示例）：\n电话 010-6800-2100\n\n服务由第三方独立提供，平台不参与收费和委托。',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('知道了'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agency.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '北京市 · ${agency.district}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '服务范围',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final scope in agency.scopes)
                      ChoicePill(
                        label: scope,
                        selected: scope == agency.category,
                        onTap: () {},
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '机构简介',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  agency.intro,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '主体与资质信息',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _InfoRow(label: '主体名称', value: agency.name),
                const Divider(height: 1),
                const _InfoRow(label: '审核状态', value: '资料已审核'),
                const Divider(height: 1),
                _InfoRow(label: '服务地区', value: agency.areaLabel),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const NoticeBox(text: '服务由第三方独立提供。平台不参与收费、委托履行及房屋交易。'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
