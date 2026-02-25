import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { LocalAdsController } from './local-ads.controller';
import { LocalAdsService } from './local-ads.service';
import { LocalAd, LocalAdSchema } from './schemas/local-ad.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: LocalAd.name, schema: LocalAdSchema }])],
  controllers: [LocalAdsController],
  providers: [LocalAdsService],
  exports: [LocalAdsService],
})
export class LocalAdsModule {}
