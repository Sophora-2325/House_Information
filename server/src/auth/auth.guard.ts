import {
  CanActivate,
  createParamDecorator,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { Request } from 'express';
import { PrismaService } from '../common/prisma.service.js';
import type { User } from '../generated/prisma/client.js';

export interface JwtPayload {
  sub: string;
}

type AuthedRequest = Request & { user?: User };

@Injectable()
export class AuthService {
  constructor(
    private readonly jwt: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  sign(user: User) {
    return this.jwt.signAsync({ sub: user.id } satisfies JwtPayload);
  }

  /** 解析请求中的 Bearer Token，Token 无效或账户不可用时返回 null。 */
  async resolve(req: Request): Promise<User | null> {
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) return null;
    try {
      const payload = await this.jwt.verifyAsync<JwtPayload>(header.slice(7));
      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
      });
      return user?.status === 'ACTIVE' ? user : null;
    } catch {
      return null;
    }
  }
}

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly auth: AuthService) {}

  async canActivate(ctx: ExecutionContext) {
    const req = ctx.switchToHttp().getRequest<AuthedRequest>();
    const user = await this.auth.resolve(req);
    if (!user) throw new UnauthorizedException('请先登录');
    req.user = user;
    return true;
  }
}

/** 已登录时注入用户，未登录也放行。 */
@Injectable()
export class OptionalAuthGuard implements CanActivate {
  constructor(private readonly auth: AuthService) {}

  async canActivate(ctx: ExecutionContext) {
    const req = ctx.switchToHttp().getRequest<AuthedRequest>();
    req.user = (await this.auth.resolve(req)) ?? undefined;
    return true;
  }
}

/** 需与 AuthGuard 一起使用，且放在其后。 */
@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(ctx: ExecutionContext) {
    const req = ctx.switchToHttp().getRequest<AuthedRequest>();
    if (req.user?.role !== 'ADMIN') throw new ForbiddenException('需要管理员权限');
    return true;
  }
}

export const CurrentUser = createParamDecorator(
  (_: unknown, ctx: ExecutionContext) =>
    ctx.switchToHttp().getRequest<AuthedRequest>().user,
);
