class Listing {
  const Listing({
    required this.id,
    required this.community,
    required this.district,
    required this.nearby,
    required this.rooms,
    required this.area,
    required this.floorLabel,
    required this.price,
    required this.confirmedShort,
    required this.confirmedLabel,
    required this.publisherType,
    required this.description,
    required this.images,
    required this.code,
    this.mineStatus,
    this.mineHint,
  });

  final String id;
  final String community;
  final String district;
  final String nearby;
  final String rooms;
  final int area;
  final String floorLabel;
  final int price;
  final String confirmedShort;
  final String confirmedLabel;
  final String publisherType;
  final String description;
  final List<String> images;
  final String code;

  /// 我的房源中的状态：展示中、待审核、草稿、已下架。公开列表为空。
  final String? mineStatus;
  final String? mineHint;

  String get cityLine => '北京市 · $district';
  String get specLine => '$rooms · ${area}㎡ · $floorLabel';
}

class Agency {
  const Agency({
    required this.id,
    required this.name,
    required this.district,
    required this.category,
    required this.summary,
    required this.intro,
    required this.areaLabel,
    required this.scopes,
  });

  final String id;
  final String name;
  final String district;
  final String category;
  final String summary;
  final String intro;
  final String areaLabel;
  final List<String> scopes;

  String get meta => '$district · $category';
}

const _roomA =
    'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=1200&q=70';
const _roomB =
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=70';
const _roomC =
    'https://images.unsplash.com/photo-1600121848594-d8644e57abab?auto=format&fit=crop&w=1200&q=70';
const _roomD =
    'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?auto=format&fit=crop&w=1200&q=70';
const _roomE =
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=70';
const _roomF =
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1200&q=70';

const homeListings = <Listing>[
  Listing(
    id: 'yghy',
    community: '阳光花园',
    district: '朝阳区',
    nearby: '距地铁约500米',
    rooms: '3室2厅',
    area: 118,
    floorLabel: '中层',
    price: 520,
    confirmedShort: '今日确认',
    confirmedLabel: '今日确认在售',
    publisherType: '房主',
    description: '采光充足，南北通透，交通便利。房屋信息由发布者填写，可通过意向交流进一步确认。',
    images: [_roomA, _roomB, _roomC, _roomD, _roomE, _roomF],
    code: 'FS20260021',
    mineStatus: '展示中',
    mineHint: '距到期还有18天',
  ),
  Listing(
    id: 'jxhf',
    community: '锦绣华府',
    district: '海淀区',
    nearby: '环境安静',
    rooms: '2室1厅',
    area: 89,
    floorLabel: '高层',
    price: 368,
    confirmedShort: '昨日确认',
    confirmedLabel: '昨日确认在售',
    publisherType: '授权代理人',
    description: '小区环境安静，生活配套齐全。价格与房屋现状以发布者最新确认为准。',
    images: [_roomB, _roomC, _roomD],
    code: 'FS20260018',
    mineStatus: '待审核',
    mineHint: '提交于今日 09:10',
  ),
  Listing(
    id: 'ycxq',
    community: '悦城小区',
    district: '丰台区',
    nearby: '配套成熟',
    rooms: '4室2厅',
    area: 135,
    floorLabel: '中层',
    price: 610,
    confirmedShort: '2天前确认',
    confirmedLabel: '2天前确认在售',
    publisherType: '房主',
    description: '户型方正，配套成熟。平台未核验产权，交易前请自行核实。',
    images: [_roomC, _roomE],
    code: 'FS20260014',
  ),
  Listing(
    id: 'xcyy',
    community: '新城雅苑',
    district: '朝阳区',
    nearby: '近商圈',
    rooms: '2室1厅',
    area: 76,
    floorLabel: '低层',
    price: 295,
    confirmedShort: '3天前确认',
    confirmedLabel: '3天前确认在售',
    publisherType: '房主',
    description: '近商圈，出行方便。楼层与朝向信息由发布者填写。',
    images: [_roomD, _roomF],
    code: 'FS20260011',
  ),
];

const extraMineListings = <Listing>[
  Listing(
    id: 'draft-wj',
    community: '望京新城',
    district: '朝阳区',
    nearby: '近公园',
    rooms: '3室1厅',
    area: 105,
    floorLabel: '中层',
    price: 480,
    confirmedShort: '未提交',
    confirmedLabel: '草稿未提交',
    publisherType: '房主',
    description: '草稿尚未提交审核，暂不公开展示。',
    images: [_roomE],
    code: 'FS20260030',
    mineStatus: '草稿',
    mineHint: '保存于昨天 21:05',
  ),
  Listing(
    id: 'cwjy',
    community: '翠微家园',
    district: '海淀区',
    nearby: '近地铁',
    rooms: '2室1厅',
    area: 92,
    floorLabel: '高层',
    price: 410,
    confirmedShort: '今日确认',
    confirmedLabel: '今日确认在售',
    publisherType: '房主',
    description: '近地铁，生活便利。',
    images: [_roomF, _roomA],
    code: 'FS20260009',
    mineStatus: '展示中',
    mineHint: '距到期还有9天',
  ),
  Listing(
    id: 'fgy',
    community: '芳古园',
    district: '朝阳区',
    nearby: '近学校',
    rooms: '3室1厅',
    area: 101,
    floorLabel: '低层',
    price: 455,
    confirmedShort: '昨日确认',
    confirmedLabel: '昨日确认在售',
    publisherType: '授权代理人',
    description: '近学校，楼栋安静。',
    images: [_roomA, _roomD],
    code: 'FS20260007',
    mineStatus: '展示中',
    mineHint: '距到期还有22天',
  ),
  Listing(
    id: 'jmdl',
    community: '角门东里',
    district: '丰台区',
    nearby: '近商圈',
    rooms: '1室1厅',
    area: 56,
    floorLabel: '中层',
    price: 210,
    confirmedShort: '已下架',
    confirmedLabel: '已停止展示',
    publisherType: '房主',
    description: '该房源已下架，不再接受新的意向。',
    images: [_roomB],
    code: 'FS20260004',
    mineStatus: '已下架',
    mineHint: '下架于 10月12日',
  ),
  Listing(
    id: 'xly',
    community: '西罗园',
    district: '丰台区',
    nearby: '交通便利',
    rooms: '2室1厅',
    area: 78,
    floorLabel: '高层',
    price: 268,
    confirmedShort: '已下架',
    confirmedLabel: '已停止展示',
    publisherType: '房主',
    description: '发布者已停止展示该房源。',
    images: [_roomC],
    code: 'FS20260002',
    mineStatus: '已下架',
    mineHint: '下架于 10月8日',
  ),
];

final allListings = <Listing>[...homeListings, ...extraMineListings];

Listing listingById(String id) {
  return allListings.firstWhere((item) => item.id == id);
}

List<Listing> get myListings {
  return allListings.where((item) => item.mineStatus != null).toList();
}

const agencies = <Agency>[
  Agency(
    id: 'cx',
    name: '城信房产咨询',
    district: '朝阳区',
    category: '房屋估价',
    summary: '提供房屋价格咨询、估价机构信息。',
    intro: '提供房屋信息咨询、估价服务介绍及相关手续指导。具体专业服务内容由委托双方另行协商。',
    areaLabel: '北京朝阳',
    scopes: ['房屋估价', '产权咨询', '过户咨询'],
  ),
  Agency(
    id: 'aj',
    name: '安居过户服务',
    district: '海淀区',
    category: '过户代办',
    summary: '交易材料准备与过户手续咨询。',
    intro: '提供不动产过户材料准备和手续咨询。平台不参与收费、委托履行及房屋交易。',
    areaLabel: '北京海淀',
    scopes: ['过户代办'],
  ),
  Agency(
    id: 'mx',
    name: '明信产权咨询',
    district: '丰台区',
    category: '产权咨询',
    summary: '产权手续咨询及相关服务介绍。',
    intro: '提供产权手续与相关材料的信息咨询。具体服务由机构独立提供。',
    areaLabel: '北京丰台',
    scopes: ['产权咨询'],
  ),
  Agency(
    id: 'll',
    name: '邻里房产咨询',
    district: '东城区',
    category: '其他咨询',
    summary: '房屋买卖流程与政策信息咨询。',
    intro: '提供房产交易流程、材料清单等一般信息咨询，不替代专业法律或评估意见。',
    areaLabel: '北京东城',
    scopes: ['其他咨询'],
  ),
];

Agency agencyById(String id) {
  return agencies.firstWhere((item) => item.id == id);
}

const serviceCategories = ['全部', '房屋估价', '产权咨询', '过户代办', '其他咨询'];
