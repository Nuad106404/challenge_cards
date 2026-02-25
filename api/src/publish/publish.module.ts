import { Module } from '@nestjs/common';
import { PublishController } from './publish.controller';
import { PublishService } from './publish.service';
import { CardsModule } from '../cards/cards.module';
import { AppConfigModule } from '../config/config.module';

@Module({
  imports: [CardsModule, AppConfigModule],
  controllers: [PublishController],
  providers: [PublishService],
})
export class PublishModule {}
