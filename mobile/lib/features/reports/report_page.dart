import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/mock_data.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String reason = '疑似虚假房源';

  @override
  Widget build(BuildContext context) {
    final listing = listingById('yghy');
    return Scaffold(
      appBar: AppBackBar(title: '举报与反馈', onBack: () => context.pop()),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: '提交举报',
            onPressed: () {
              showTip(context, '举报已提交，处理进度可在此查看（原型）');
              context.pop();
            },
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          WhiteCard(
            child: Row(
              children: [
                ListingImage(url: listing.images.first, width: 96, height: 72),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '举报房源：${listing.community}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '房源编号：${listing.code}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionTitle('举报原因'),
          ChoiceWrap(
            options: const ['疑似虚假房源', '重复发布', '广告引流', '侵犯隐私', '其他问题'],
            selected: reason,
            onSelected: (value) => setState(() => reason = value),
          ),
          const SizedBox(height: 18),
          const SectionTitle('情况描述'),
          const AppTextField(hint: '请描述具体情况，便于管理员核实处理……', maxLines: 5),
          const SizedBox(height: 18),
          const SectionTitle('补充图片（可选）'),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => showTip(context, '原型暂不上传图片'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD5DEE2)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 6),
                    Text(
                      '添加图片',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const NoticeBox(text: '平台将根据规则处理举报。请勿上传无关个人隐私信息或捏造举报内容。'),
        ],
      ),
    );
  }
}
