import { Global, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { AuthController, SmsCodeService } from './auth.controller.js';
import {
  AdminGuard,
  AuthGuard,
  AuthService,
  OptionalAuthGuard,
} from './auth.guard.js';

@Global()
@Module({
  imports: [
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.getOrThrow<string>('JWT_SECRET'),
        signOptions: { expiresIn: '30d' },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, SmsCodeService, AuthGuard, OptionalAuthGuard, AdminGuard],
  exports: [AuthService, AuthGuard, OptionalAuthGuard, AdminGuard],
})
export class AuthModule {}
