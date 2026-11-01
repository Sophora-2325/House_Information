# 房市直通后端

NestJS + Prisma + PostgreSQL。

## 本地启动

```powershell
# 1. 启动数据库（首次会创建 fangshi_dev 库）
cd ..\infra; docker compose up -d; cd ..\server

# 2. 环境变量
Copy-Item .env.example .env

# 3. 安装依赖、建表、写入演示数据
npm install
npm run db:migrate
npm run db:generate
npm run db:seed

# 4. 启动（开发模式自动重载）
npm run start:dev
```

接口文档：<http://127.0.0.1:3000/docs>

## 演示账号

未接入短信服务前，非生产环境验证码固定为 `.env` 中的 `SMS_DEV_CODE`（默认 `123456`）。

| 手机号 | 角色 |
| --- | --- |
| 13812345621 | 演示用户，名下有 4 套房源 |
| 13800000000 | 管理员 |

## 测试

接口测试使用独立的 `fangshi_test` 库，首次需要创建并建表：

```powershell
docker exec fangshi-postgres-1 createdb -U fangshi fangshi_test
$env:DATABASE_URL="postgresql://fangshi:fangshi_dev@127.0.0.1:5432/fangshi_test"; npx prisma migrate deploy; Remove-Item Env:DATABASE_URL
npm run test:e2e
```

## 响应格式

- 成功：`{ "data": ... }`
- 失败：`{ "error": { "code": HTTP 状态码, "message": "中文提示" } }`
