import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module.js';
import { PrismaService } from '../src/common/prisma.service.js';
import { configureApp } from '../src/setup.js';

describe('房源发布与浏览 (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let seq = 100;

  const api = () => request(app.getHttpServer());

  async function login(phone = `137${String(100000000 + seq++).slice(1)}`) {
    await api().post('/auth/sms-code').send({ phone }).expect(200);
    const res = await api().post('/auth/login').send({ phone, code: '123456' }).expect(200);
    return res.body.data.token as string;
  }

  async function loginAdmin() {
    const phone = '13800000099';
    await prisma.user.upsert({
      where: { phone },
      update: { role: 'ADMIN' },
      create: { phone, role: 'ADMIN' },
    });
    return login(phone);
  }

  const fullListing = {
    city: '北京市',
    district: '海淀区',
    community: 'E2E 小区',
    areaSqm: 90.5,
    rooms: '2室1厅',
    floor: 5,
    totalFloors: 18,
    priceWan: 350,
    imageKeys: ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
  };

  async function publishedListing(owner: string, admin: string, overrides = {}) {
    const created = await api()
      .post('/listings')
      .set('Authorization', `Bearer ${owner}`)
      .send({ ...fullListing, ...overrides })
      .expect(201);
    const id = created.body.data.id as string;
    await api()
      .post(`/listings/${id}/submit`)
      .set('Authorization', `Bearer ${owner}`)
      .send({ agreedDeclaration: true })
      .expect(200);
    await api()
      .post(`/admin/listings/${id}/approve`)
      .set('Authorization', `Bearer ${admin}`)
      .expect(200);
    return id;
  }

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = moduleRef.createNestApplication();
    configureApp(app);
    await app.init();
    prisma = app.get(PrismaService);
    await prisma.favorite.deleteMany();
    await prisma.listing.deleteMany();
    await prisma.user.deleteMany();
  });

  afterAll(async () => {
    await app.close();
  });

  it('验证码错误不能登录，正确后返回 Token', async () => {
    const phone = '13700000001';
    await api().post('/auth/sms-code').send({ phone }).expect(200);
    await api().post('/auth/sms-code').send({ phone }).expect(429);
    const wrong = await api().post('/auth/login').send({ phone, code: '000000' }).expect(400);
    expect(wrong.body.error.message).toBe('验证码错误');
    const ok = await api().post('/auth/login').send({ phone, code: '123456' }).expect(200);
    expect(ok.body.data.token).toBeTypeOf('string');

    const me = await api()
      .get('/users/me')
      .set('Authorization', `Bearer ${ok.body.data.token}`)
      .expect(200);
    expect(me.body.data.phone).toBe('137****0001');
  });

  it('未登录不能发布房源', async () => {
    await api().post('/listings').send(fullListing).expect(401);
  });

  it('草稿缺必填项或未确认声明时不能提交审核', async () => {
    const token = await login();
    const draft = await api()
      .post('/listings')
      .set('Authorization', `Bearer ${token}`)
      .send({ community: '只填了小区' })
      .expect(201);
    expect(draft.body.data.status).toBe('draft');
    const id = draft.body.data.id;

    const missing = await api()
      .post(`/listings/${id}/submit`)
      .set('Authorization', `Bearer ${token}`)
      .send({ agreedDeclaration: true })
      .expect(400);
    expect(missing.body.error.message).toContain('出售总价');

    await api()
      .post(`/listings/${id}/submit`)
      .set('Authorization', `Bearer ${token}`)
      .send({ agreedDeclaration: false })
      .expect(400);
  });

  it('提交、审核通过后才公开展示，公开详情不含发布者信息', async () => {
    const owner = await login();
    const admin = await loginAdmin();
    const created = await api()
      .post('/listings')
      .set('Authorization', `Bearer ${owner}`)
      .send(fullListing)
      .expect(201);
    const id = created.body.data.id;

    await api()
      .post(`/listings/${id}/submit`)
      .set('Authorization', `Bearer ${owner}`)
      .send({ agreedDeclaration: true })
      .expect(200);
    await api().get(`/listings/${id}`).expect(404);
    await api()
      .post(`/admin/listings/${id}/approve`)
      .set('Authorization', `Bearer ${owner}`)
      .expect(403);

    const approved = await api()
      .post(`/admin/listings/${id}/approve`)
      .set('Authorization', `Bearer ${admin}`)
      .expect(200);
    expect(approved.body.data.status).toBe('published');
    expect(approved.body.data.expiresAt).toBeTruthy();

    const pub = await api().get(`/listings/${id}`).expect(200);
    expect(pub.body.data.floorLabel).toBe('低层');
    expect(pub.body.data.images).toHaveLength(2);
    expect(pub.body.data).not.toHaveProperty('publisherId');
    expect(pub.body.data).not.toHaveProperty('floor');
    expect(JSON.stringify(pub.body.data)).not.toMatch(/1\d{10}/);
  });

  it('驳回后显示原因，修改后可重新提交', async () => {
    const owner = await login();
    const admin = await loginAdmin();
    const created = await api()
      .post('/listings')
      .set('Authorization', `Bearer ${owner}`)
      .send(fullListing)
      .expect(201);
    const id = created.body.data.id;
    await api()
      .post(`/listings/${id}/submit`)
      .set('Authorization', `Bearer ${owner}`)
      .send({ agreedDeclaration: true })
      .expect(200);
    await api()
      .post(`/admin/listings/${id}/reject`)
      .set('Authorization', `Bearer ${admin}`)
      .send({ reason: '图片与描述不符' })
      .expect(200);

    const mine = await api()
      .get(`/listings/${id}`)
      .set('Authorization', `Bearer ${owner}`)
      .expect(200);
    expect(mine.body.data.status).toBe('rejected');
    expect(mine.body.data.rejectReason).toBe('图片与描述不符');

    const resubmitted = await api()
      .post(`/listings/${id}/submit`)
      .set('Authorization', `Bearer ${owner}`)
      .send({ agreedDeclaration: true })
      .expect(200);
    expect(resubmitted.body.data.status).toBe('pending_review');
    expect(resubmitted.body.data.rejectReason).toBeNull();
  });

  it('修改已公开房源的价格需要重新审核，改描述不需要', async () => {
    const owner = await login();
    const admin = await loginAdmin();
    const id = await publishedListing(owner, admin);

    const desc = await api()
      .patch(`/listings/${id}`)
      .set('Authorization', `Bearer ${owner}`)
      .send({ description: '补充说明', priceWan: 350 })
      .expect(200);
    expect(desc.body.data.status).toBe('published');

    const price = await api()
      .patch(`/listings/${id}`)
      .set('Authorization', `Bearer ${owner}`)
      .send({ priceWan: 330 })
      .expect(200);
    expect(price.body.data.status).toBe('pending_review');
  });

  it('不能修改别人的房源', async () => {
    const owner = await login();
    const other = await login();
    const admin = await loginAdmin();
    const id = await publishedListing(owner, admin);
    await api()
      .patch(`/listings/${id}`)
      .set('Authorization', `Bearer ${other}`)
      .send({ priceWan: 1 })
      .expect(404);
    await api()
      .post(`/listings/${id}/pause`)
      .set('Authorization', `Bearer ${other}`)
      .expect(404);
  });

  it('暂停后不出现在列表，续期后恢复，标记已售后不能续期', async () => {
    const owner = await login();
    const admin = await loginAdmin();
    const id = await publishedListing(owner, admin, { community: '暂停测试小区' });
    const inList = async () => {
      const res = await api().get('/listings').query({ keyword: '暂停测试' }).expect(200);
      return res.body.data.items.some((i: { id: string }) => i.id === id);
    };
    const auth = { Authorization: `Bearer ${owner}` };

    expect(await inList()).toBe(true);
    await api().post(`/listings/${id}/pause`).set(auth).expect(200);
    expect(await inList()).toBe(false);
    await api().post(`/listings/${id}/renew`).set(auth).expect(200);
    expect(await inList()).toBe(true);
    await api().post(`/listings/${id}/mark-sold`).set(auth).expect(200);
    expect(await inList()).toBe(false);
    await api().post(`/listings/${id}/renew`).set(auth).expect(409);
  });

  it('展示到期的房源自动转为已过期', async () => {
    const owner = await login();
    const admin = await loginAdmin();
    const id = await publishedListing(owner, admin);
    await prisma.listing.update({
      where: { id },
      data: { expiresAt: new Date(Date.now() - 1000) },
    });
    await api().get(`/listings/${id}`).expect(404);
    const mine = await api()
      .get(`/listings/${id}`)
      .set('Authorization', `Bearer ${owner}`)
      .expect(200);
    expect(mine.body.data.status).toBe('expired');
  });

  it('按区域、价格、户型筛选并分页', async () => {
    const owner = await login();
    const admin = await loginAdmin();
    await publishedListing(owner, admin, { community: '筛选甲', district: '西城区', priceWan: 800, rooms: '3室2厅' });
    await publishedListing(owner, admin, { community: '筛选乙', district: '西城区', priceWan: 300, rooms: '2室1厅' });

    const cheap = await api()
      .get('/listings')
      .query({ district: '西城区', priceMax: 500 })
      .expect(200);
    expect(cheap.body.data.items.map((i: { community: string }) => i.community)).toEqual(['筛选乙']);

    const rooms = await api().get('/listings').query({ district: '西城区', rooms: '3室' }).expect(200);
    expect(rooms.body.data.items.map((i: { community: string }) => i.community)).toEqual(['筛选甲']);

    const page = await api().get('/listings').query({ district: '西城区', pageSize: 1, page: 2 }).expect(200);
    expect(page.body.data.total).toBe(2);
    expect(page.body.data.items).toHaveLength(1);
  });

  it('收藏与取消收藏', async () => {
    const owner = await login();
    const viewer = await login();
    const admin = await loginAdmin();
    const id = await publishedListing(owner, admin);
    const auth = { Authorization: `Bearer ${viewer}` };

    await api().post(`/listings/${id}/favorite`).set(auth).expect(200);
    await api().post(`/listings/${id}/favorite`).set(auth).expect(200);
    let favs = await api().get('/favorites').set(auth).expect(200);
    expect(favs.body.data).toHaveLength(1);
    const detail = await api().get(`/listings/${id}`).set(auth).expect(200);
    expect(detail.body.data.isFavorite).toBe(true);

    await api().delete(`/listings/${id}/favorite`).set(auth).expect(200);
    favs = await api().get('/favorites').set(auth).expect(200);
    expect(favs.body.data).toHaveLength(0);
  });
});
