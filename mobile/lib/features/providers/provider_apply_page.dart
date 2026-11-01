import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';

class ProviderApplyPage extends StatefulWidget {
  const ProviderApplyPage({super.key});

  @override
  State<ProviderApplyPage> createState() => _ProviderApplyPageState();
}

class _ProviderApplyPageState extends State<ProviderApplyPage> {
  final subjectType = TextEditingController(text: '机构服务商');
  final region = TextEditingController(text: '北京市 · 朝阳区');
  String scope = '产权咨询';

  @override
  void dispose() {
    subjectType.dispose();
    region.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackBar(title: '申请第三方入驻', onBack: () => context.pop()),
      bottomNavigationBar: BottomActionBar(
        children: [
          SecondaryButton(
            label: '保存草稿',
            onPressed: () => showTip(context, '入驻草稿已保存（原型）'),
          ),
          PrimaryButton(
            label: '下一步',
            onPressed: () => showTip(context, '资料已记录，正式版将进入资质提交（原型）'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const StepBar(active: 0, labels: ['1 填写信息', '2 提交资料', '3 等待审核']),
          const SizedBox(height: 18),
          const SectionTitle('机构 / 个人信息'),
          const FieldLabel('申请主体类型', required: true),
          AppTextField(
            hint: '请选择主体类型',
            controller: subjectType,
            options: const ['机构服务商', '个人执业者'],
          ),
          const SizedBox(height: 14),
          const FieldLabel('主体名称', required: true),
          const AppTextField(hint: '请输入机构名称'),
          const SizedBox(height: 14),
          const FieldLabel('所在地区', required: true),
          AppTextField(
            hint: '请选择所在地区',
            controller: region,
            options: const [
              '北京市 · 朝阳区',
              '北京市 · 海淀区',
              '北京市 · 丰台区',
              '北京市 · 西城区',
              '北京市 · 东城区',
            ],
          ),
          const SizedBox(height: 14),
          const FieldLabel('联系人', required: true),
          const AppTextField(hint: '请输入联系人'),
          const SizedBox(height: 14),
          const FieldLabel('联系电话', required: true),
          const AppTextField(
            hint: '请输入有效联系电话',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          const SectionTitle('服务范围'),
          ChoiceWrap(
            options: const ['房屋估价', '产权咨询', '过户代办', '其他咨询'],
            selected: scope,
            onSelected: (value) => setState(() => scope = value),
          ),
          const SizedBox(height: 18),
          const SectionTitle('资质证明材料'),
          InkWell(
            onTap: () => showTip(context, '原型暂不上传证明材料'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 110,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD5DEE2),
                  style: BorderStyle.solid,
                ),
                color: const Color(0xFFF8FBFA),
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
                    '上传资质材料',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
