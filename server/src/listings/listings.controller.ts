import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  AdminGuard,
  AuthGuard,
  CurrentUser,
  OptionalAuthGuard,
} from '../auth/auth.guard.js';
import type { User } from '../generated/prisma/client.js';
import {
  ListingInputDto,
  ListingQueryDto,
  ReasonDto,
  StatusQueryDto,
  SubmitListingDto,
} from './listings.dto.js';
import { ListingsService } from './listings.service.js';

const uuid = new ParseUUIDPipe({
  version: '4',
  exceptionFactory: () => new BadRequestException('房源编号格式不正确'),
});

@Controller('listings')
export class ListingsController {
  constructor(private readonly listings: ListingsService) {}

  @Get()
  search(@Query() query: ListingQueryDto) {
    return this.listings.search(query);
  }

  @Get('mine')
  @UseGuards(AuthGuard)
  mine(@CurrentUser() user: User, @Query() query: StatusQueryDto) {
    return this.listings.mine(user, query.status);
  }

  @Get(':id')
  @UseGuards(OptionalAuthGuard)
  detail(@Param('id', uuid) id: string, @CurrentUser() user?: User) {
    return this.listings.detail(id, user);
  }

  @Post()
  @UseGuards(AuthGuard)
  create(@CurrentUser() user: User, @Body() dto: ListingInputDto) {
    return this.listings.create(user, dto);
  }

  @Patch(':id')
  @UseGuards(AuthGuard)
  update(
    @CurrentUser() user: User,
    @Param('id', uuid) id: string,
    @Body() dto: ListingInputDto,
  ) {
    return this.listings.update(user, id, dto);
  }

  @Post(':id/submit')
  @HttpCode(200)
  @UseGuards(AuthGuard)
  submit(
    @CurrentUser() user: User,
    @Param('id', uuid) id: string,
    @Body() dto: SubmitListingDto,
  ) {
    return this.listings.submit(user, id, dto);
  }

  @Post(':id/pause')
  @HttpCode(200)
  @UseGuards(AuthGuard)
  pause(@CurrentUser() user: User, @Param('id', uuid) id: string) {
    return this.listings.pause(user, id);
  }

  @Post(':id/renew')
  @HttpCode(200)
  @UseGuards(AuthGuard)
  renew(@CurrentUser() user: User, @Param('id', uuid) id: string) {
    return this.listings.renew(user, id);
  }

  @Post(':id/mark-sold')
  @HttpCode(200)
  @UseGuards(AuthGuard)
  markSold(@CurrentUser() user: User, @Param('id', uuid) id: string) {
    return this.listings.markSold(user, id);
  }

  @Post(':id/favorite')
  @HttpCode(200)
  @UseGuards(AuthGuard)
  favorite(@CurrentUser() user: User, @Param('id', uuid) id: string) {
    return this.listings.addFavorite(user, id);
  }

  @Delete(':id/favorite')
  @UseGuards(AuthGuard)
  unfavorite(@CurrentUser() user: User, @Param('id', uuid) id: string) {
    return this.listings.removeFavorite(user, id);
  }
}

@Controller('favorites')
@UseGuards(AuthGuard)
export class FavoritesController {
  constructor(private readonly listings: ListingsService) {}

  @Get()
  list(@CurrentUser() user: User) {
    return this.listings.favorites(user);
  }
}

@Controller('admin/listings')
@UseGuards(AuthGuard, AdminGuard)
export class AdminListingsController {
  constructor(private readonly listings: ListingsService) {}

  @Get()
  queue(@Query() query: StatusQueryDto) {
    return this.listings.reviewQueue(query.status);
  }

  @Post(':id/approve')
  @HttpCode(200)
  approve(@CurrentUser() admin: User, @Param('id', uuid) id: string) {
    return this.listings.approve(admin, id);
  }

  @Post(':id/reject')
  @HttpCode(200)
  reject(
    @CurrentUser() admin: User,
    @Param('id', uuid) id: string,
    @Body() dto: ReasonDto,
  ) {
    return this.listings.reject(admin, id, dto.reason);
  }

  @Post(':id/remove')
  @HttpCode(200)
  remove(
    @CurrentUser() admin: User,
    @Param('id', uuid) id: string,
    @Body() dto: ReasonDto,
  ) {
    return this.listings.remove(admin, id, dto.reason);
  }
}
