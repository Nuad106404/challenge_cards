import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { LocalAd, LocalAdDocument } from './schemas/local-ad.schema';
import { CreateLocalAdDto } from './dto/create-local-ad.dto';
import { UpdateLocalAdDto } from './dto/update-local-ad.dto';

@Injectable()
export class LocalAdsService {
  constructor(
    @InjectModel(LocalAd.name) private localAdModel: Model<LocalAdDocument>,
  ) {}

  async findAll(): Promise<LocalAd[]> {
    return this.localAdModel.find().sort({ order: 1, createdAt: 1 }).exec();
  }

  async findActive(): Promise<LocalAd[]> {
    return this.localAdModel.find({ isActive: true }).sort({ order: 1, createdAt: 1 }).exec();
  }

  async create(dto: CreateLocalAdDto): Promise<LocalAd> {
    const count = await this.localAdModel.countDocuments().exec();
    return this.localAdModel.create({ ...dto, order: dto.order ?? count });
  }

  async update(id: string, dto: UpdateLocalAdDto): Promise<LocalAd> {
    const doc = await this.localAdModel
      .findByIdAndUpdate(id, dto, { new: true, runValidators: true })
      .exec();
    if (!doc) throw new NotFoundException('Ad not found');
    return doc;
  }

  async toggle(id: string): Promise<LocalAd> {
    const doc = await this.localAdModel.findById(id).exec();
    if (!doc) throw new NotFoundException('Ad not found');
    doc.isActive = !doc.isActive;
    return doc.save();
  }

  async remove(id: string): Promise<void> {
    const result = await this.localAdModel.findByIdAndDelete(id).exec();
    if (!result) throw new NotFoundException('Ad not found');
  }

  async reorder(ids: string[]): Promise<void> {
    await Promise.all(
      ids.map((id, index) =>
        this.localAdModel.findByIdAndUpdate(id, { order: index }).exec(),
      ),
    );
  }
}
