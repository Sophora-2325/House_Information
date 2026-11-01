import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/common.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String district = '朝阳区';
  String price = '400-600';
  String area = '90-120';
  String rooms = '3室';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackBar(title: '筛选房源', onBack: () => context.pop()),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                const SectionTitle('区域'),
                ChoiceWrap(
                  options: const ['不限', '朝阳区', '海淀区', '丰台区', '西城区', '东城区'],
                  selected: district,
                  onSelected: (value) => setState(() => district = value),
                ),
                const SizedBox(height: 20),
                const SectionTitle('价格范围（万元）'),
                ChoiceWrap(
                  options: const [
                    '不限',
                    '200以下',
                    '200-400',
                    '400-600',
                    '600-800',
                    '800以上',
                  ],
                  selected: price,
                  onSelected: (value) => setState(() => price = value),
                ),
                const SizedBox(height: 20),
                const SectionTitle('面积范围（㎡）'),
                ChoiceWrap(
                  options: const [
                    '不限',
                    '70以下',
                    '70-90',
                    '90-120',
                    '120-150',
                    '150以上',
                  ],
                  selected: area,
                  onSelected: (value) => setState(() => area = value),
                ),
                const SizedBox(height: 20),
                const SectionTitle('户型'),
                ChoiceWrap(
                  options: const ['不限', '1室', '2室', '3室', '4室及以上'],
                  selected: rooms,
                  onSelected: (value) => setState(() => rooms = value),
                ),
                const SizedBox(height: 20),
                const NoticeBox(text: '筛选仅依据发布者填写的信息进行匹配，房屋具体情况请自行核实。'),
              ],
            ),
          ),
          BottomActionBar(
            children: [
              SecondaryButton(
                label: '重置条件',
                onPressed: () => setState(() {
                  district = '不限';
                  price = '不限';
                  area = '不限';
                  rooms = '不限';
                }),
              ),
              PrimaryButton(
                label: '查看符合条件的房源',
                onPressed: () {
                  showTip(context, '已按$district、$price万、$area㎡、$rooms筛选（原型）');
                  context.pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
