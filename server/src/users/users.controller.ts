import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { IsOptional, IsString, Length } from 'class-validator';
import { CurrentUser, AuthGuard } from '../auth/auth.guard.js';
import { PrismaService } from '../common/prisma.service.js';
import type { User } from '../generated/prisma/client.js';

export class UpdateMeDto {
  @IsOptional()
  @IsString()
  @Length(1, 20)
  nickname?: string;
}

export function maskPhone(phone: string) {
  return `${phone.slice(0, 3)}****${phone.slice(-4)}`;
}

function toMe(user: User) {
  return {
    id: user.id,
    phone: maskPhone(user.phone),
    nickname: user.nickname,
    role: user.role,
  };
}

@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('me')
  async me(@CurrentUser() user: User) {
    const [published, pending, offline] = await Promise.all([
      this.prisma.listing.count({
        where: { publisherId: user.id, status: 'published' },
      }),
      this.prisma.listing.count({
        where: { publisherId: user.id, status: 'pending_review' },
      }),
      this.prisma.listing.count({
        where: {
          publisherId: user.id,
          status: { in: ['paused', 'sold', 'expired', 'removed'] },
        },
      }),
    ]);
    const favorites = await this.prisma.favorite.count({
      where: { userId: user.id },
    });
    return {
      ...toMe(user),
      stats: { published, pending, offline, favorites },
    };
  }

  @Patch('me')
  async update(@CurrentUser() user: User, @Body() dto: UpdateMeDto) {
    const updated = await this.prisma.user.update({
      where: { id: user.id },
      data: { nickname: dto.nickname },
    });
    return toMe(updated);
  }
}
