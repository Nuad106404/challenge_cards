import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { GameMode, GameModeDocument } from './schemas/game-mode.schema';
import { CreateGameModeDto } from './dto/create-game-mode.dto';
import { UpdateGameModeDto } from './dto/update-game-mode.dto';

@Injectable()
export class ModesService {
  constructor(@InjectModel(GameMode.name) private gameModeModel: Model<GameModeDocument>) {}

  async create(dto: CreateGameModeDto): Promise<GameMode> {
    const mode = new this.gameModeModel(dto);
    return mode.save();
  }

  async findAll(onlyActive = false): Promise<GameMode[]> {
    const query = onlyActive ? { isActive: true } : {};
    return this.gameModeModel.find(query).sort({ sortOrder: 1, createdAt: 1 }).exec();
  }

  async findOne(id: string): Promise<GameMode> {
    const mode = await this.gameModeModel.findById(id).exec();
    if (!mode) throw new NotFoundException(`GameMode #${id} not found`);
    return mode;
  }

  async update(id: string, dto: UpdateGameModeDto): Promise<GameMode> {
    const mode = await this.gameModeModel
      .findByIdAndUpdate(id, dto, { new: true, runValidators: true })
      .exec();
    if (!mode) throw new NotFoundException(`GameMode #${id} not found`);
    return mode;
  }

  async remove(id: string): Promise<void> {
    const result = await this.gameModeModel.findByIdAndDelete(id).exec();
    if (!result) throw new NotFoundException(`GameMode #${id} not found`);
  }
}
