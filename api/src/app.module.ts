import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthModule } from './auth/auth.module';
import { PacksModule } from './packs/packs.module';
import { CardsModule } from './cards/cards.module';
import { AppConfigModule } from './config/config.module';
import { PublishModule } from './publish/publish.module';
import { ModesModule } from './modes/modes.module';
import { LocalAdsModule } from './local-ads/local-ads.module';
import { UploadsModule } from './uploads/uploads.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        uri: configService.get<string>('MONGODB_URI'),
      }),
      inject: [ConfigService],
    }),
    AuthModule,
    PacksModule,
    CardsModule,
    AppConfigModule,
    PublishModule,
    ModesModule,
    LocalAdsModule,
    UploadsModule,
  ],
})
export class AppModule {}
