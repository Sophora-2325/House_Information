import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/mock_data.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  String category = '全部';

  @override
  Widget build(BuildContext context) {
    final items = category == '全部'
        ? agencies
        : agencies.where((item) => item.category == category).toList();

    return Scaffold(
      appBar: AppBackBar(title: '第三方服务', onBack: () => context.go('/home')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in serviceCategories) ...[
                  ChoicePill(
                    label: item,
                    selected: item == category,
                    onTap: () => setState(() => category = item),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '可自主联系的服务机构',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              InkWell(
                onTap: () => showTip(context, '首期按北京各区展示'),
                child: const Text(
                  '按地区筛选',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(
                child: Text(
                  '当前分类暂无机构',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          for (final agency in items) ...[
            _AgencyCard(agency: agency),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _AgencyCard extends StatelessWidget {
  const _AgencyCard({required this.agency});

  final Agency agency;

  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      onTap: () => context.push('/providers/${agency.id}'),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF7EB8B4),
              borderRadius: BorderRadius.circular(14),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  agency.meta,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  agency.summary,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 8),
                const StatusPill('机构信息已审核'),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
