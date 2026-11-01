import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/inquiries.dart';
import '../../data/mock_data.dart';

class ConsentPage extends ConsumerStatefulWidget {
  const ConsentPage({super.key, required this.inquiryId});

  final String inquiryId;

  @override
  ConsumerState<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends ConsumerState<ConsentPage> {
  bool phone = true;
  bool other = false;
  bool shared = false;

  @override
  Widget build(BuildContext context) {
    final inquiry = ref
        .read(inquiryStoreProvider.notifier)
        .byId(widget.inquiryId);
    final listing = listingById(inquiry.listingId);
    final otherRole = inquiry.iAmBuyer ? '房主' : '购房者';
    final otherPhone = inquiry.iAmBuyer ? '139 1024 8826' : '137 6650 3172';

    return Scaffold(
      appBar: AppBackBar(title: '交换联系方式', onBack: () => context.pop()),
      bottomNavigationBar: BottomActionBar(
        children: shared
            ? [
                PrimaryButton(
                  label: '复制对方联系方式',
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: otherPhone.replaceAll(' ', '')),
                    );
                    if (context.mounted) showTip(context, '已复制$otherRole的手机号');
                  },
                ),
              ]
            : [
                SecondaryButton(
                  label: '暂不共享',
                  onPressed: () {
                    showTip(context, '已拒绝共享联系方式');
                    context.pop();
                  },
                ),
                PrimaryButton(
                  label: '同意并共享',
                  onPressed: () {
                    if (!phone && !other) {
                      showTip(context, '请至少选择一种联系方式');
                      return;
                    }
                    setState(() => shared = true);
                  },
                ),
              ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          ListingSummary(listing: listing),
          const SizedBox(height: 12),
          WhiteCard(
            child: Column(
              children: [
                Icon(
                  shared ? Icons.verified : Icons.verified_user_outlined,
                  color: AppColors.primary,
                  size: 42,
                ),
                const SizedBox(height: 8),
                Text(
                  shared ? '双方均已授权' : '双方已表达联系意愿',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  shared
                      ? '$otherRole已同意共享联系方式，你们可以自行联系。'
                      : '仅在双方均同意授权后，才向对方显示所选联系方式。',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (shared) ...[
            SectionTitle('$otherRole的联系方式'),
            WhiteCard(
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      otherPhone,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          const SectionTitle('我将分享的联系方式'),
          WhiteCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                CheckboxListTile(
                  value: phone,
                  onChanged: shared
                      ? null
                      : (value) => setState(() => phone = value ?? false),
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('手机号码：138****5621'),
                ),
                CheckboxListTile(
                  value: other,
                  onChanged: shared
                      ? null
                      : (value) => setState(() => other = value ?? false),
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('其他联系方式（可选）'),
                ),
                if (other && !shared)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: AppTextField(hint: '请输入其他联系方式'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const NoticeBox(text: '授权只对本次意向交流有效。撤回授权无法收回对方已保存的信息。'),
        ],
      ),
    );
  }
}
