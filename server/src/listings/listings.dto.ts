import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  Equals,
  IsArray,
  IsIn,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Length,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export const LISTING_STATUSES = [
  'draft',
  'pending_review',
  'published',
  'paused',
  'sold',
  'expired',
  'rejected',
  'removed',
] as const;

/** 草稿可以只填一部分，必填项在提交审核时校验。 */
export class ListingInputDto {
  @IsOptional()
  @IsIn(['OWNER', 'AGENT'])
  publisherRole?: 'OWNER' | 'AGENT';

  @IsOptional()
  @IsString()
  @Length(1, 20)
  city?: string;

  @IsOptional()
  @IsString()
  @Length(1, 20)
  district?: string;

  @IsOptional()
  @IsString()
  @Length(1, 60)
  community?: string;

  @IsOptional()
  @IsString()
  @MaxLength(30)
  highlight?: string;

  /** 建筑面积，单位平方米 */
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(1)
  @Max(10000)
  areaSqm?: number;

  @IsOptional()
  @IsString()
  @Length(1, 20)
  rooms?: string;

  @IsOptional()
  @IsInt()
  @Min(-5)
  @Max(200)
  floor?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(200)
  totalFloors?: number;

  /** 出售总价，单位万元 */
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(1)
  @Max(100000)
  priceWan?: number;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  decoration?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  orientation?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  /** 图片存储 key，按展示顺序排列，最多 6 张 */
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(6)
  @IsString({ each: true })
  @MaxLength(300, { each: true })
  imageKeys?: string[];
}

export class SubmitListingDto {
  @Equals(true, { message: '请确认你有权发布该房源信息' })
  agreedDeclaration: boolean;
}

export class ReasonDto {
  @IsString()
  @Length(1, 200)
  reason: string;
}

export class ListingQueryDto {
  @IsOptional()
  @IsString()
  @MaxLength(30)
  keyword?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  district?: string;

  /** 户型前缀，如“3室” */
  @IsOptional()
  @IsString()
  @MaxLength(10)
  rooms?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  priceMin?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  priceMax?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  areaMin?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  areaMax?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  pageSize: number = 20;
}

export class StatusQueryDto {
  @IsOptional()
  @IsIn(LISTING_STATUSES)
  status?: (typeof LISTING_STATUSES)[number];
}
