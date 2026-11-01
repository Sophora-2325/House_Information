import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final _formKey = GlobalKey<FormState>();
  final city = TextEditingController(text: '北京市');
  final district = TextEditingController();
  final community = TextEditingController();
  final area = TextEditingController();
  final rooms = TextEditingController();
  final floor = TextEditingController();
  final totalFloors = TextEditingController();
  final price = TextEditingController();
  final decoration = TextEditingController();
  final orientation = TextEditingController();
  final description = TextEditingController();

  String identity = '房主';
  bool agreed = false;
  bool showAgreeError = false;
  bool submitted = false;

  List<TextEditingController> get _basicFields => [
    city,
    district,
    community,
    area,
    rooms,
    floor,
    totalFloors,
  ];

  int get _activeStep {
    final basicDone = _basicFields.every((c) => c.text.trim().isNotEmpty);
    if (!basicDone) return 0;
    if (price.text.trim().isEmpty) return 1;
    return 2;
  }

  @override
  void dispose() {
    for (final c in [
      city,
      district,
      community,
      area,
      rooms,
      floor,
      totalFloors,
      price,
      decoration,
      orientation,
      description,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _refresh() {
    setState(() {});
    if (submitted) _formKey.currentState?.validate();
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    setState(() {
      submitted = true;
      showAgreeError = !agreed;
    });
    if (!valid) {
      showTip(context, '还有必填项没有填写');
      return;
    }
    if (!agreed) {
      showTip(context, '请先确认发布权限声明');
      return;
    }
    showTip(context, '已提交审核（原型）');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackBar(title: '发布房源', onBack: () => context.pop()),
      bottomNavigationBar: BottomActionBar(
        children: [
          SecondaryButton(
            label: '保存草稿',
            onPressed: () => showTip(context, '草稿已保存（原型）'),
          ),
          PrimaryButton(label: '提交审核', onPressed: _submit),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            StepBar(
              active: _activeStep,
              labels: const ['基础信息', '房屋情况', '确认提交'],
            ),
            const SizedBox(height: 18),
            const SectionTitle('基础信息'),
            const FieldLabel('所在城市', required: true),
            AppTextField(
              hint: '请选择城市',
              controller: city,
              options: const ['北京市'],
              pickerTitle: '首期开放城市',
              requiredMessage: '请选择城市',
              onChanged: _refresh,
            ),
            const SizedBox(height: 14),
            const FieldLabel('所在区域', required: true),
            AppTextField(
              hint: '请选择区域',
              controller: district,
              options: const ['朝阳区', '海淀区', '丰台区', '西城区', '东城区'],
              requiredMessage: '请选择区域',
              onChanged: _refresh,
            ),
            const SizedBox(height: 14),
            const FieldLabel('小区名称', required: true),
            AppTextField(
              hint: '请输入小区名称',
              controller: community,
              requiredMessage: '请输入小区名称',
              onChanged: _refresh,
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(child: FieldLabel('建筑面积（㎡）', required: true)),
                SizedBox(width: 12),
                Expanded(child: FieldLabel('户型', required: true)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    hint: '例如 98',
                    controller: area,
                    keyboardType: TextInputType.number,
                    requiredMessage: '请输入面积',
                    onChanged: _refresh,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    hint: '请选择户型',
                    controller: rooms,
                    options: const [
                      '1室1厅',
                      '2室1厅',
                      '2室2厅',
                      '3室1厅',
                      '3室2厅',
                      '4室2厅',
                      '5室及以上',
                    ],
                    requiredMessage: '请选择户型',
                    onChanged: _refresh,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(child: FieldLabel('所在楼层', required: true)),
                SizedBox(width: 12),
                Expanded(child: FieldLabel('总楼层', required: true)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    hint: '例如 12',
                    controller: floor,
                    keyboardType: TextInputType.number,
                    requiredMessage: '请输入楼层',
                    onChanged: _refresh,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    hint: '例如 28',
                    controller: totalFloors,
                    keyboardType: TextInputType.number,
                    requiredMessage: '请输入总楼层',
                    onChanged: _refresh,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const SectionTitle('价格与房屋情况'),
            const FieldLabel('出售总价（万元）', required: true),
            AppTextField(
              hint: '例如 520',
              controller: price,
              keyboardType: TextInputType.number,
              requiredMessage: '请输入出售总价',
              onChanged: _refresh,
            ),
            const SizedBox(height: 14),
            const FieldLabel('装修情况'),
            AppTextField(
              hint: '请选择装修情况',
              controller: decoration,
              options: const ['毛坯', '简装', '精装', '豪装'],
            ),
            const SizedBox(height: 14),
            const FieldLabel('房屋朝向'),
            AppTextField(
              hint: '请选择朝向',
              controller: orientation,
              options: const ['南北通透', '朝南', '朝东', '朝西', '朝北'],
            ),
            const SizedBox(height: 14),
            const FieldLabel('房屋描述'),
            AppTextField(
              hint: '选填，简要描述采光、装修和交通',
              controller: description,
              maxLines: 4,
            ),
            const SizedBox(height: 22),
            const SectionTitle('房屋照片'),
            const Text(
              '最多 6 张，第一张作为封面。',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [_PhotoSlot(onTap: () => showTip(context, '原型暂不上传图片'))],
            ),
            const SizedBox(height: 8),
            const Text(
              '请上传房屋实拍照片，避免包含身份证件、私人联系方式等敏感信息。',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle('发布确认'),
            const FieldLabel('发布者身份', required: true),
            ChoiceWrap(
              options: const ['房主', '授权代理人'],
              selected: identity,
              onSelected: (value) => setState(() => identity = value),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: agreed,
              onChanged: (value) => setState(() {
                agreed = value ?? false;
                if (agreed) showAgreeError = false;
              }),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
              title: const Text(
                '我确认有权发布该房源信息，并保证填写内容真实。平台核验的是账户身份，不是房屋产权。',
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
              subtitle: showAgreeError
                  ? const Text(
                      '提交前需要勾选此声明',
                      style: TextStyle(color: AppColors.danger, fontSize: 12),
                    )
                  : null,
            ),
            const NoticeBox(text: '房源公开展示期限为 30 天，可免费确认信息并续期。'),
          ],
        ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.mint.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_outlined, color: AppColors.primary),
            SizedBox(height: 4),
            Text(
              '添加图片',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
