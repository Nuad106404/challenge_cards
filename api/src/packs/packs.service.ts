import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Pack, PackDocument } from './schemas/pack.schema';
import { CreatePackDto } from './dto/create-pack.dto';
import { UpdatePackDto } from './dto/update-pack.dto';

@Injectable()
export class PacksService {
  constructor(@InjectModel(Pack.name) private packModel: Model<PackDocument>) {}

  async create(createPackDto: CreatePackDto): Promise<Pack> {
    const pack = new this.packModel(createPackDto);
    return pack.save();
  }

  async findAll(filters?: { mode?: string; ageRating?: string; isActive?: boolean }): Promise<Pack[]> {
    const query: Record<string, unknown> = {};
    if (filters?.mode) query.mode = filters.mode;
    if (filters?.ageRating) query.ageRating = filters.ageRating;
    if (filters?.isActive !== undefined) query.isActive = filters.isActive;
    return this.packModel.find(query).sort({ sortOrder: 1, createdAt: -1 }).exec();
  }

  async findOne(id: string): Promise<Pack> {
    const pack = await this.packModel.findById(id).exec();
    if (!pack) throw new NotFoundException(`Pack #${id} not found`);
    return pack;
  }

  async findBySlug(slug: string): Promise<Pack> {
    const pack = await this.packModel.findOne({ slug }).exec();
    if (!pack) throw new NotFoundException(`Pack with slug "${slug}" not found`);
    return pack;
  }

  async update(id: string, updatePackDto: UpdatePackDto): Promise<Pack> {
    const pack = await this.packModel
      .findByIdAndUpdate(id, updatePackDto, { new: true, runValidators: true })
      .exec();
    if (!pack) throw new NotFoundException(`Pack #${id} not found`);
    return pack;
  }

  async remove(id: string): Promise<void> {
    const result = await this.packModel.findByIdAndDelete(id).exec();
    if (!result) throw new NotFoundException(`Pack #${id} not found`);
  }
}
