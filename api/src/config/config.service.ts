import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { AppConfig, AppConfigDocument } from './schemas/app-config.schema';
import { UpdateConfigDto } from './dto/update-config.dto';

@Injectable()
export class AppConfigService implements OnModuleInit {
  constructor(
    @InjectModel(AppConfig.name) private appConfigModel: Model<AppConfigDocument>,
  ) {}

  async onModuleInit() {
    const count = await this.appConfigModel.countDocuments().exec();
    if (count === 0) {
      await this.appConfigModel.create({});
    }
  }

  async getConfig(): Promise<AppConfig> {
    return this.appConfigModel.findOne().exec();
  }

  async updateConfig(updateConfigDto: UpdateConfigDto): Promise<AppConfig> {
    return this.appConfigModel
      .findOneAndUpdate({}, updateConfigDto, { new: true, upsert: true, runValidators: true })
      .exec();
  }

  async bumpContentVersion(): Promise<AppConfig> {
    return this.appConfigModel
      .findOneAndUpdate({}, { $inc: { contentVersion: 1 } }, { new: true, upsert: true })
      .exec();
  }
}
