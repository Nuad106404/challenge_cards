import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ModesController } from './modes.controller';
import { ModesService } from './modes.service';
import { GameMode, GameModeSchema } from './schemas/game-mode.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: GameMode.name, schema: GameModeSchema }])],
  controllers: [ModesController],
  providers: [ModesService],
  exports: [ModesService],
})
export class ModesModule {}
