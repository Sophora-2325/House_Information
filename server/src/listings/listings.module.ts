import { Module } from '@nestjs/common';
import {
  AdminListingsController,
  FavoritesController,
  ListingsController,
} from './listings.controller.js';
import { ListingsService } from './listings.service.js';

@Module({
  controllers: [ListingsController, FavoritesController, AdminListingsController],
  providers: [ListingsService],
})
export class ListingsModule {}
