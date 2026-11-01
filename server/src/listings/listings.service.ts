import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../common/prisma.service.js';
import type {
  Listing,
  ListingStatus,
  Prisma,
  User,
} from '../generated/prisma/client.js';
import type {
  ListingInputDto,
  ListingQueryDto,
  SubmitListingDto,
} from './listings.dto.js';
import {
  ListingWithImages,
  toCard,
  toOwnerDetail,
  toPublicDetail,
} from './listing.view.js';

const DISPLAY_DAYS = 30;
const DAY_MS = 24 * 60 * 60 * 1000;

const REQUIRED_FIELDS: Array<[keyof Listing, string]> = [
  ['city', '城市'],
  ['district', '区域'],
  ['community', '小区名称'],
  ['areaSqm', '建筑面积'],
  ['rooms', '户型'],
  ['priceWan', '出售总价'],
];

/** 已公开的房源修改这些字段后需要重新审核。 */
const REVIEW_FIELDS = [
  'city',
  'district',
  'community',
  'priceWan',
  'publisherRole',
] as const;

const EDITABLE: ListingStatus[] = [
  'draft',
  'rejected',
  'pending_review',
  'published',
  'paused',
];

const withImages = { images: true } as const;

@Injectable()
export class ListingsService {
  constructor(private readonly prisma: PrismaService) {}

  /** 把过期的展示中房源转为 expired，并记录状态日志。 */
  async expireOverdue() {
    const overdue = await this.prisma.listing.findMany({
      where: { status: 'published', expiresAt: { lt: new Date() } },
      select: { id: true },
    });
    if (overdue.length === 0) return;
    const ids = overdue.map((l) => l.id);
    await this.prisma.$transaction([
      this.prisma.listing.updateMany({
        where: { id: { in: ids }, status: 'published' },
        data: { status: 'expired' },
      }),
      this.prisma.listingStatusLog.createMany({
        data: ids.map((listingId) => ({
          listingId,
          fromStatus: 'published' as const,
          toStatus: 'expired' as const,
          note: '展示期限已到',
        })),
      }),
    ]);
  }

  async search(q: ListingQueryDto) {
    await this.expireOverdue();
    const where: Prisma.ListingWhereInput = { status: 'published' };
    if (q.keyword) {
      where.OR = [
        { community: { contains: q.keyword, mode: 'insensitive' } },
        { district: { contains: q.keyword, mode: 'insensitive' } },
      ];
    }
    if (q.district) where.district = q.district;
    if (q.rooms) where.rooms = { startsWith: q.rooms };
    if (q.priceMin != null || q.priceMax != null) {
      where.priceWan = { gte: q.priceMin, lte: q.priceMax };
    }
    if (q.areaMin != null || q.areaMax != null) {
      where.areaSqm = { gte: q.areaMin, lte: q.areaMax };
    }
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.listing.count({ where }),
      this.prisma.listing.findMany({
        where,
        include: withImages,
        orderBy: [{ confirmedAt: 'desc' }, { id: 'asc' }],
        skip: (q.page - 1) * q.pageSize,
        take: q.pageSize,
      }),
    ]);
    return { items: rows.map(toCard), total, page: q.page, pageSize: q.pageSize };
  }

  async detail(id: string, viewer?: User) {
    await this.expireOverdue();
    const listing = await this.prisma.listing.findUnique({
      where: { id },
      include: withImages,
    });
    if (!listing) throw new NotFoundException('房源不存在');
    const isOwner = viewer?.id === listing.publisherId;
    if (isOwner || viewer?.role === 'ADMIN') {
      return { ...toOwnerDetail(listing), isOwner, isFavorite: await this.isFavorite(id, viewer) };
    }
    if (listing.status !== 'published') throw new NotFoundException('房源不存在');
    return { ...toPublicDetail(listing), isOwner: false, isFavorite: await this.isFavorite(id, viewer) };
  }

  private async isFavorite(listingId: string, viewer?: User) {
    if (!viewer) return false;
    const fav = await this.prisma.favorite.findUnique({
      where: { userId_listingId: { userId: viewer.id, listingId } },
    });
    return fav != null;
  }

  async mine(user: User, status?: ListingStatus) {
    await this.expireOverdue();
    const rows = await this.prisma.listing.findMany({
      where: { publisherId: user.id, status },
      include: withImages,
      orderBy: { updatedAt: 'desc' },
    });
    return rows.map(toOwnerDetail);
  }

  async create(user: User, dto: ListingInputDto) {
    const { imageKeys, ...fields } = dto;
    for (let attempt = 0; ; attempt++) {
      try {
        const listing = await this.prisma.listing.create({
          data: {
            ...fields,
            code: generateCode(),
            publisherId: user.id,
            images: imageKeys && {
              create: imageKeys.map((storageKey, sortOrder) => ({ storageKey, sortOrder })),
            },
            statusLogs: { create: { toStatus: 'draft', operatorId: user.id } },
          },
          include: withImages,
        });
        return toOwnerDetail(listing);
      } catch (e) {
        if (attempt < 3 && isUniqueViolation(e)) continue;
        throw e;
      }
    }
  }

  async update(user: User, id: string, dto: ListingInputDto) {
    const listing = await this.ownListing(user, id);
    if (!EDITABLE.includes(listing.status)) {
      throw new ConflictException('当前状态的房源不能修改');
    }
    const { imageKeys, ...fields } = dto;
    const needsReview =
      (listing.status === 'published' || listing.status === 'paused') &&
      REVIEW_FIELDS.some((key) => {
        const next = fields[key];
        if (next === undefined) return false;
        const current = listing[key];
        const currentValue =
          current != null && typeof current === 'object' ? Number(current) : current;
        return next !== currentValue;
      });

    const updated = await this.prisma.$transaction(async (tx) => {
      if (imageKeys) {
        await tx.listingImage.deleteMany({ where: { listingId: id } });
        await tx.listingImage.createMany({
          data: imageKeys.map((storageKey, sortOrder) => ({ listingId: id, storageKey, sortOrder })),
        });
      }
      if (needsReview) {
        await tx.listingStatusLog.create({
          data: {
            listingId: id,
            fromStatus: listing.status,
            toStatus: 'pending_review',
            operatorId: user.id,
            note: '修改关键信息，重新审核',
          },
        });
      }
      return tx.listing.update({
        where: { id },
        data: {
          ...fields,
          ...(needsReview && { status: 'pending_review', submittedAt: new Date() }),
        },
        include: withImages,
      });
    });
    return toOwnerDetail(updated);
  }

  async submit(user: User, id: string, dto: SubmitListingDto) {
    if (!dto.agreedDeclaration) {
      throw new BadRequestException('请确认你有权发布该房源信息');
    }
    const listing = await this.ownListing(user, id);
    if (listing.status === 'pending_review') return this.ownerView(id);
    if (listing.status !== 'draft' && listing.status !== 'rejected') {
      throw new ConflictException('只有草稿或被驳回的房源可以提交审核');
    }
    const missing = REQUIRED_FIELDS.filter(([key]) => listing[key] == null).map(
      ([, label]) => label,
    );
    if (missing.length > 0) {
      throw new BadRequestException(`还有必填项没有填写：${missing.join('、')}`);
    }
    return this.transition(listing, 'pending_review', user.id, {
      submittedAt: new Date(),
      rejectReason: null,
    });
  }

  async pause(user: User, id: string) {
    const listing = await this.ownListing(user, id);
    if (listing.status === 'paused') return this.ownerView(id);
    if (listing.status !== 'published') throw new ConflictException('只有展示中的房源可以暂停');
    return this.transition(listing, 'paused', user.id);
  }

  /** 确认信息仍然有效：恢复展示并重新计算 30 天有效期。 */
  async renew(user: User, id: string) {
    const listing = await this.ownListing(user, id);
    if (!['published', 'paused', 'expired'].includes(listing.status)) {
      throw new ConflictException('当前状态的房源不能续期');
    }
    const now = new Date();
    return this.transition(listing, 'published', user.id, {
      confirmedAt: now,
      expiresAt: new Date(now.getTime() + DISPLAY_DAYS * DAY_MS),
    });
  }

  async markSold(user: User, id: string) {
    const listing = await this.ownListing(user, id);
    if (listing.status === 'sold') return this.ownerView(id);
    if (!['published', 'paused', 'expired'].includes(listing.status)) {
      throw new ConflictException('当前状态的房源不能标记已售');
    }
    return this.transition(listing, 'sold', user.id);
  }

  async approve(admin: User, id: string) {
    const listing = await this.findOrThrow(id);
    if (listing.status !== 'pending_review') throw new ConflictException('该房源不在待审核状态');
    const now = new Date();
    return this.transition(listing, 'published', admin.id, {
      publishedAt: listing.publishedAt ?? now,
      confirmedAt: now,
      expiresAt: new Date(now.getTime() + DISPLAY_DAYS * DAY_MS),
      rejectReason: null,
    });
  }

  async reject(admin: User, id: string, reason: string) {
    const listing = await this.findOrThrow(id);
    if (listing.status !== 'pending_review') throw new ConflictException('该房源不在待审核状态');
    return this.transition(listing, 'rejected', admin.id, { rejectReason: reason }, reason);
  }

  async remove(admin: User, id: string, reason: string) {
    const listing = await this.findOrThrow(id);
    if (listing.status === 'removed') return this.ownerView(id);
    return this.transition(listing, 'removed', admin.id, {}, reason);
  }

  async reviewQueue(status: ListingStatus = 'pending_review') {
    const rows = await this.prisma.listing.findMany({
      where: { status },
      include: withImages,
      orderBy: { submittedAt: 'asc' },
    });
    return rows.map(toOwnerDetail);
  }

  async addFavorite(user: User, listingId: string) {
    const listing = await this.findOrThrow(listingId);
    if (listing.status !== 'published' && listing.publisherId !== user.id) {
      throw new NotFoundException('房源不存在');
    }
    await this.prisma.favorite.upsert({
      where: { userId_listingId: { userId: user.id, listingId } },
      update: {},
      create: { userId: user.id, listingId },
    });
    return { favorite: true };
  }

  async removeFavorite(user: User, listingId: string) {
    await this.prisma.favorite.deleteMany({ where: { userId: user.id, listingId } });
    return { favorite: false };
  }

  async favorites(user: User) {
    await this.expireOverdue();
    const rows = await this.prisma.favorite.findMany({
      where: { userId: user.id },
      include: { listing: { include: withImages } },
      orderBy: { createdAt: 'desc' },
    });
    return rows.map((f) => toCard(f.listing));
  }

  private async findOrThrow(id: string) {
    const listing = await this.prisma.listing.findUnique({ where: { id } });
    if (!listing) throw new NotFoundException('房源不存在');
    return listing;
  }

  private async ownListing(user: User, id: string) {
    const listing = await this.findOrThrow(id);
    if (listing.publisherId !== user.id) throw new NotFoundException('房源不存在');
    return listing;
  }

  private async ownerView(id: string) {
    const listing = await this.prisma.listing.findUniqueOrThrow({
      where: { id },
      include: withImages,
    });
    return toOwnerDetail(listing);
  }

  private async transition(
    listing: Listing,
    to: ListingStatus,
    operatorId: string,
    data: Prisma.ListingUpdateInput = {},
    note?: string,
  ) {
    const [updated] = await this.prisma.$transaction([
      this.prisma.listing.update({
        where: { id: listing.id },
        data: { ...data, status: to },
        include: withImages,
      }),
      this.prisma.listingStatusLog.create({
        data: { listingId: listing.id, fromStatus: listing.status, toStatus: to, operatorId, note },
      }),
    ]);
    return toOwnerDetail(updated as ListingWithImages);
  }
}

function generateCode() {
  const now = new Date();
  const date = `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}`;
  const rand = String(Math.floor(Math.random() * 10000)).padStart(4, '0');
  return `FS${date}${rand}`;
}

function isUniqueViolation(e: unknown) {
  return typeof e === 'object' && e != null && (e as { code?: string }).code === 'P2002';
}
