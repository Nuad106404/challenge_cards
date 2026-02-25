import { Injectable } from '@nestjs/common';
import { CardsService } from '../cards/cards.service';
import { AppConfigService } from '../config/config.service';
import { PublishDto } from './dto/publish.dto';

export interface PublishResult {
  contentVersion: number;
  publishedCards: number;
  packId?: string;
}

@Injectable()
export class PublishService {
  constructor(
    private readonly cardsService: CardsService,
    private readonly appConfigService: AppConfigService,
  ) {}

  async publish(publishDto: PublishDto): Promise<PublishResult> {
    if (publishDto.packId) {
      await this.cardsService.bulkUpdateStatus(publishDto.packId, 'published');
    }

    const updatedConfig = await this.appConfigService.bumpContentVersion();

    const publishedCards = publishDto.packId
      ? (await this.cardsService.findAll({ packId: publishDto.packId, status: 'published' })).length
      : (await this.cardsService.findAll({ status: 'published' })).length;

    return {
      contentVersion: updatedConfig.contentVersion,
      publishedCards,
      packId: publishDto.packId,
    };
  }
}
