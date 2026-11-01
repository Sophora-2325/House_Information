import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module.js';
import { PrismaModule } from './common/prisma.service.js';
import { ListingsModule } from './listings/listings.module.js';
import { UsersController } from './users/users.controller.js';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    ListingsModule,
  ],
  controllers: [UsersController],
})
export class AppModule {}
