-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('USER', 'ADMIN');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'DISABLED', 'DELETING');

-- CreateEnum
CREATE TYPE "PublisherRole" AS ENUM ('OWNER', 'AGENT');

-- CreateEnum
CREATE TYPE "ListingStatus" AS ENUM ('draft', 'pending_review', 'published', 'paused', 'sold', 'expired', 'rejected', 'removed');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "nickname" VARCHAR(40),
    "role" "UserRole" NOT NULL DEFAULT 'USER',
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listings" (
    "id" UUID NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "publisherId" UUID NOT NULL,
    "publisherRole" "PublisherRole" NOT NULL DEFAULT 'OWNER',
    "city" VARCHAR(20),
    "district" VARCHAR(20),
    "community" VARCHAR(60),
    "highlight" VARCHAR(30),
    "areaSqm" DECIMAL(8,2),
    "rooms" VARCHAR(20),
    "floor" INTEGER,
    "totalFloors" INTEGER,
    "priceWan" DECIMAL(10,2),
    "decoration" VARCHAR(20),
    "orientation" VARCHAR(20),
    "description" VARCHAR(500),
    "status" "ListingStatus" NOT NULL DEFAULT 'draft',
    "rejectReason" VARCHAR(200),
    "submittedAt" TIMESTAMP(3),
    "publishedAt" TIMESTAMP(3),
    "confirmedAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "listings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listing_images" (
    "id" UUID NOT NULL,
    "listingId" UUID NOT NULL,
    "storageKey" VARCHAR(300) NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "listing_images_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "listing_status_logs" (
    "id" UUID NOT NULL,
    "listingId" UUID NOT NULL,
    "fromStatus" "ListingStatus",
    "toStatus" "ListingStatus" NOT NULL,
    "operatorId" UUID,
    "note" VARCHAR(200),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "listing_status_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "favorites" (
    "userId" UUID NOT NULL,
    "listingId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "favorites_pkey" PRIMARY KEY ("userId","listingId")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "listings_code_key" ON "listings"("code");

-- CreateIndex
CREATE INDEX "listings_status_confirmedAt_idx" ON "listings"("status", "confirmedAt");

-- CreateIndex
CREATE INDEX "listings_district_idx" ON "listings"("district");

-- CreateIndex
CREATE INDEX "listings_priceWan_idx" ON "listings"("priceWan");

-- CreateIndex
CREATE INDEX "listings_areaSqm_idx" ON "listings"("areaSqm");

-- CreateIndex
CREATE INDEX "listings_publisherId_idx" ON "listings"("publisherId");

-- CreateIndex
CREATE INDEX "listing_images_listingId_sortOrder_idx" ON "listing_images"("listingId", "sortOrder");

-- CreateIndex
CREATE INDEX "listing_status_logs_listingId_createdAt_idx" ON "listing_status_logs"("listingId", "createdAt");

-- AddForeignKey
ALTER TABLE "listings" ADD CONSTRAINT "listings_publisherId_fkey" FOREIGN KEY ("publisherId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_images" ADD CONSTRAINT "listing_images_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "listing_status_logs" ADD CONSTRAINT "listing_status_logs_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "favorites" ADD CONSTRAINT "favorites_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "favorites" ADD CONSTRAINT "favorites_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "listings"("id") ON DELETE CASCADE ON UPDATE CASCADE;
