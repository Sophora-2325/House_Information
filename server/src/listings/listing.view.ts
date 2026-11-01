import type {
  Listing,
  ListingImage,
} from '../generated/prisma/client.js';

export type ListingWithImages = Listing & { images: ListingImage[] };

function imageUrl(key: string) {
  if (/^https?:\/\//.test(key)) return key;
  const base = process.env.IMAGE_BASE_URL ?? '';
  return `${base}/${key}`;
}

export function floorLabel(floor: number | null, total: number | null) {
  if (floor == null || !total) return null;
  const ratio = floor / total;
  if (ratio <= 1 / 3) return '低层';
  if (ratio <= 2 / 3) return '中层';
  return '高层';
}

const num = (v: { toNumber(): number } | null) => (v == null ? null : v.toNumber());

function sortedImages(listing: ListingWithImages) {
  return [...listing.images]
    .sort((a, b) => a.sortOrder - b.sortOrder)
    .map((img) => imageUrl(img.storageKey));
}

/** 列表卡片字段，不含发布者任何身份信息。 */
export function toCard(listing: ListingWithImages) {
  const images = sortedImages(listing);
  return {
    id: listing.id,
    code: listing.code,
    community: listing.community,
    district: listing.district,
    highlight: listing.highlight,
    rooms: listing.rooms,
    areaSqm: num(listing.areaSqm),
    floorLabel: floorLabel(listing.floor, listing.totalFloors),
    priceWan: num(listing.priceWan),
    status: listing.status,
    confirmedAt: listing.confirmedAt,
    coverImage: images[0] ?? null,
  };
}

export function toPublicDetail(listing: ListingWithImages) {
  return {
    ...toCard(listing),
    city: listing.city,
    publisherRole: listing.publisherRole,
    decoration: listing.decoration,
    orientation: listing.orientation,
    description: listing.description,
    images: sortedImages(listing),
    publishedAt: listing.publishedAt,
  };
}

/** 发布者本人可见：含审核与有效期信息。 */
export function toOwnerDetail(listing: ListingWithImages) {
  return {
    ...toPublicDetail(listing),
    floor: listing.floor,
    totalFloors: listing.totalFloors,
    imageKeys: [...listing.images]
      .sort((a, b) => a.sortOrder - b.sortOrder)
      .map((img) => img.storageKey),
    rejectReason: listing.rejectReason,
    submittedAt: listing.submittedAt,
    expiresAt: listing.expiresAt,
    createdAt: listing.createdAt,
    updatedAt: listing.updatedAt,
  };
}
