import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '房市直通',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                '房源信息直连 · 自主沟通',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const Spacer(),
              const Align(
                alignment: Alignment.centerLeft,
                child: FieldLabel('手机号码', required: true),
              ),
              const AppTextField(
                hint: '请输入手机号',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: FieldLabel('短信验证码', required: true),
              ),
              const _CodeField(),
              const SizedBox(height: 20),
              PrimaryButton(
                label: '登录 / 注册',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    '登录即表示同意',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showTip(context, '用户协议将在正式版本提供'),
                    child: const Text(
                      '《用户协议》',
                      style: TextStyle(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                  const Text(
                    '和',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showTip(context, '隐私政策将在正式版本提供'),
                    child: const Text(
                      '《隐私政策》',
                      style: TextStyle(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  '免费发布 · 免费查看 · 自主联系',
                  style: TextStyle(color: Color(0xFF9AA7AC), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '请输入验证码',
        hintStyle: const TextStyle(color: Color(0xFF9AA7AC), fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        suffixIcon: TextButton(
          onPressed: () => showTip(context, '验证码已发送（原型）'),
          child: const Text('获取验证码'),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
