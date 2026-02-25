import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type GameModeDocument = GameMode & Document;
export type LocalizedText = Map<string, string>;

@Schema({ timestamps: true, collection: 'game_modes' })
export class GameMode {
  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  slug: string;

  @Prop({ type: Map, of: String, required: true })
  name: LocalizedText;

  @Prop({ type: Map, of: String, required: true })
  description: LocalizedText;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ default: 0 })
  sortOrder: number;
}

export const GameModeSchema = SchemaFactory.createForClass(GameMode);
