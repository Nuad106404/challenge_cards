import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Card, CardDocument } from './schemas/card.schema';
import { CreateCardDto } from './dto/create-card.dto';
import { CreateImageCardDto } from './dto/create-image-card.dto';
import { UpdateCardDto } from './dto/update-card.dto';

interface CardFilters {
  packId?: string;
  type?: string;
  ageRating?: string;
  status?: string;
  isActive?: boolean;
}

@Injectable()
export class CardsService {
  constructor(@InjectModel(Card.name) private cardModel: Model<CardDocument>) {}

  async create(createCardDto: CreateCardDto): Promise<Card> {
    const card = new this.cardModel(createCardDto);
    return card.save();
  }

  async createImageCard(createImageCardDto: CreateImageCardDto): Promise<Card> {
    const cardData = {
      ...createImageCardDto,
      contentSource: 'image',
      text: {}, // Empty text map for image cards
      diceCount: 0,
    };
    const card = new this.cardModel(cardData);
    return card.save();
  }

  async findAll(filters?: CardFilters): Promise<Card[]> {
    const query: Record<string, unknown> = {};
    if (filters?.packId) query.packId = filters.packId;
    if (filters?.type) query.type = filters.type;
    if (filters?.ageRating) query.ageRating = filters.ageRating;
    if (filters?.status) query.status = filters.status;
    if (filters?.isActive !== undefined) query.isActive = filters.isActive;
    return this.cardModel.find(query).populate('packId', 'slug title').exec();
  }

  async findOne(id: string): Promise<Card> {
    const card = await this.cardModel.findById(id).populate('packId', 'slug title').exec();
    if (!card) throw new NotFoundException(`Card #${id} not found`);
    return card;
  }

  async findByPack(packId: string, ageRating?: string): Promise<Card[]> {
    const query: Record<string, unknown> = {
      packId,
      isActive: true,
      status: 'published',
    };
    if (ageRating) query.ageRating = { $in: ['all', ageRating] };
    return this.cardModel.find(query).exec();
  }

  async update(id: string, updateCardDto: UpdateCardDto): Promise<Card> {
    const card = await this.cardModel
      .findByIdAndUpdate(id, updateCardDto, { new: true, runValidators: true })
      .exec();
    if (!card) throw new NotFoundException(`Card #${id} not found`);
    return card;
  }

  async remove(id: string): Promise<void> {
    const result = await this.cardModel.findByIdAndDelete(id).exec();
    if (!result) throw new NotFoundException(`Card #${id} not found`);
  }

  async bulkUpdateStatus(packId: string, status: string): Promise<void> {
    await this.cardModel.updateMany({ packId }, { status }).exec();
  }
}
