import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AppConfigController } from './config.controller';
import { AppConfigService } from './config.service';
import { AppConfig, AppConfigSchema } from './schemas/app-config.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: AppConfig.name, schema: AppConfigSchema }])],
  controllers: [AppConfigController],
  providers: [AppConfigService],
  exports: [AppConfigService],
})
export class AppConfigModule {}
