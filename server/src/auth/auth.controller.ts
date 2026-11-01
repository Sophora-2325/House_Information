import {
  BadRequestException,
  Body,
  Controller,
  HttpCode,
  HttpException,
  HttpStatus,
  Injectable,
  Post,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { IsString, Matches } from 'class-validator';
import { PrismaService } from '../common/prisma.service.js';
import { AuthService } from './auth.guard.js';

const PHONE = /^1[3-9]\d{9}$/;
const CODE_TTL_MS = 5 * 60 * 1000;
const RESEND_MS = 60 * 1000;
const MAX_ATTEMPTS = 5;

export class SmsCodeDto {
  @Matches(PHONE, { message: '请输入正确的手机号' })
  phone: string;
}

export class LoginDto {
  @Matches(PHONE, { message: '请输入正确的手机号' })
  phone: string;

  @IsString()
  @Matches(/^\d{6}$/, { message: '验证码为 6 位数字' })
  code: string;
}

interface PendingCode {
  code: string;
  sentAt: number;
  attempts: number;
}

/**
 * 验证码暂存在进程内存中，只适用于单实例部署。
 * 未接入短信服务前，仅非生产环境可用，验证码固定为 SMS_DEV_CODE。
 */
@Injectable()
export class SmsCodeService {
  private readonly pending = new Map<string, PendingCode>();

  constructor(private readonly config: ConfigService) {}

  private get devCode() {
    if (this.config.get('NODE_ENV') === 'production') return null;
    return this.config.get<string>('SMS_DEV_CODE') ?? null;
  }

  send(phone: string) {
    const devCode = this.devCode;
    if (!devCode) throw new ServiceUnavailableException('短信服务尚未开通');
    const last = this.pending.get(phone);
    if (last && Date.now() - last.sentAt < RESEND_MS) {
      throw new HttpException('发送太频繁，请稍后再试', HttpStatus.TOO_MANY_REQUESTS);
    }
    this.pending.set(phone, { code: devCode, sentAt: Date.now(), attempts: 0 });
  }

  verify(phone: string, code: string) {
    const entry = this.pending.get(phone);
    if (!entry || Date.now() - entry.sentAt > CODE_TTL_MS) {
      throw new BadRequestException('请先获取验证码');
    }
    if (entry.code !== code) {
      entry.attempts += 1;
      if (entry.attempts >= MAX_ATTEMPTS) this.pending.delete(phone);
      throw new BadRequestException('验证码错误');
    }
    this.pending.delete(phone);
  }
}

@Controller('auth')
export class AuthController {
  constructor(
    private readonly sms: SmsCodeService,
    private readonly auth: AuthService,
    private readonly prisma: PrismaService,
  ) {}

  @Post('sms-code')
  @HttpCode(200)
  sendCode(@Body() dto: SmsCodeDto) {
    this.sms.send(dto.phone);
    return { sent: true };
  }

  /** 手机号首次登录即注册。 */
  @Post('login')
  @HttpCode(200)
  async login(@Body() dto: LoginDto) {
    this.sms.verify(dto.phone, dto.code);
    const user = await this.prisma.user.upsert({
      where: { phone: dto.phone },
      update: {},
      create: { phone: dto.phone },
    });
    if (user.status !== 'ACTIVE') throw new BadRequestException('账户不可用');
    return { token: await this.auth.sign(user) };
  }

  /** Token 无服务端状态，由客户端删除本地 Token。 */
  @Post('logout')
  @HttpCode(200)
  logout() {
    return { ok: true };
  }
}
