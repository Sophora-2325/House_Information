import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import {
  ListingStatus,
  PrismaClient,
  PublisherRole,
} from '../src/generated/prisma/client.js';

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL! }),
});

const img = (id: string) =>
  `https://images.unsplash.com/photo-${id}?auto=format&fit=crop&w=1200&q=70`;
const A = img('1600210492486-724fe5c67fb0');
const B = img('1600585154340-be6161a56a0c');
const C = img('1600121848594-d8644e57abab');
const D = img('1616594039964-ae9021a400a0');
const E = img('1600607687939-ce8a6c25118c');
const F = img('1560448204-e02f11c3d0e2');

const DAY = 24 * 60 * 60 * 1000;
const daysAgo = (n: number) => new Date(Date.now() - n * DAY);

interface SeedListing {
  code: string;
  community: string;
  district: string;
  highlight: string;
  rooms: string;
  areaSqm: number;
  floor: number;
  totalFloors: number;
  priceWan: number;
  publisherRole: PublisherRole;
  description: string;
  images: string[];
  status: ListingStatus;
  /** 最近确认距今天数，仅展示中的房源使用 */
  confirmedDaysAgo?: number;
  mine?: boolean;
}

const listings: SeedListing[] = [
  {
    code: 'FS20260021', community: '阳光花园', district: '朝阳区', highlight: '距地铁约500米',
    rooms: '3室2厅', areaSqm: 118, floor: 12, totalFloors: 26, priceWan: 520, publisherRole: 'OWNER',
    description: '采光充足，南北通透，交通便利。房屋信息由发布者填写，可通过意向交流进一步确认。',
    images: [A, B, C, D, E, F], status: 'published', confirmedDaysAgo: 0, mine: true,
  },
  {
    code: 'FS20260018', community: '锦绣华府', district: '海淀区', highlight: '环境安静',
    rooms: '2室1厅', areaSqm: 89, floor: 22, totalFloors: 28, priceWan: 368, publisherRole: 'AGENT',
    description: '小区环境安静，生活配套齐全。价格与房屋现状以发布者最新确认为准。',
    images: [B, C, D], status: 'published', confirmedDaysAgo: 1,
  },
  {
    code: 'FS20260014', community: '悦城小区', district: '丰台区', highlight: '配套成熟',
    rooms: '4室2厅', areaSqm: 135, floor: 9, totalFloors: 18, priceWan: 610, publisherRole: 'OWNER',
    description: '户型方正，配套成熟。平台未核验产权，交易前请自行核实。',
    images: [C, E], status: 'published', confirmedDaysAgo: 2,
  },
  {
    code: 'FS20260011', community: '新城雅苑', district: '朝阳区', highlight: '近商圈',
    rooms: '2室1厅', areaSqm: 76, floor: 3, totalFloors: 18, priceWan: 295, publisherRole: 'OWNER',
    description: '近商圈，出行方便。楼层与朝向信息由发布者填写。',
    images: [D, F], status: 'published', confirmedDaysAgo: 3,
  },
  {
    code: 'FS20260009', community: '翠微家园', district: '海淀区', highlight: '近地铁',
    rooms: '2室1厅', areaSqm: 92, floor: 16, totalFloors: 20, priceWan: 410, publisherRole: 'OWNER',
    description: '近地铁，生活便利。', images: [F, A], status: 'published', confirmedDaysAgo: 0, mine: true,
  },
  {
    code: 'FS20260030', community: '望京新城', district: '朝阳区', highlight: '近公园',
    rooms: '3室1厅', areaSqm: 105, floor: 10, totalFloors: 24, priceWan: 480, publisherRole: 'OWNER',
    description: '草稿尚未提交审核，暂不公开展示。', images: [E], status: 'draft', mine: true,
  },
  {
    code: 'FS20260031', community: '芳古园', district: '朝阳区', highlight: '近学校',
    rooms: '3室1厅', areaSqm: 101, floor: 2, totalFloors: 6, priceWan: 455, publisherRole: 'AGENT',
    description: '近学校，楼栋安静。', images: [A, D], status: 'pending_review', mine: true,
  },
];

async function main() {
  await prisma.user.upsert({
    where: { phone: '13800000000' },
    update: { role: 'ADMIN' },
    create: { phone: '13800000000', nickname: '管理员', role: 'ADMIN' },
  });
  const demo = await prisma.user.upsert({
    where: { phone: '13812345621' },
    update: {},
    create: { phone: '13812345621', nickname: '演示用户' },
  });
  const other = await prisma.user.upsert({
    where: { phone: '13900000001' },
    update: {},
    create: { phone: '13900000001', nickname: '其他发布者' },
  });

  for (const l of listings) {
    const { images, confirmedDaysAgo, mine, code, status, ...fields } = l;
    const published = status === 'published';
    const confirmedAt = published ? daysAgo(confirmedDaysAgo ?? 0) : null;
    const data = {
      ...fields,
      city: '北京市',
      status,
      publisherId: mine ? demo.id : other.id,
      submittedAt: status === 'draft' ? null : daysAgo(5),
      publishedAt: published ? daysAgo(10) : null,
      confirmedAt,
      expiresAt: confirmedAt && new Date(confirmedAt.getTime() + 30 * DAY),
    };
    const listing = await prisma.listing.upsert({
      where: { code },
      update: data,
      create: { ...data, code },
    });
    await prisma.listingImage.deleteMany({ where: { listingId: listing.id } });
    await prisma.listingImage.createMany({
      data: images.map((storageKey, sortOrder) => ({ listingId: listing.id, storageKey, sortOrder })),
    });
  }
  console.log(`已写入 3 个账号、${listings.length} 套房源`);
}

await main();
await prisma.$disconnect();
