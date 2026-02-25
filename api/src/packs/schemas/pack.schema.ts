import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type PackDocument = Pack & Document;

@Schema({ timestamps: true, collection: 'packs' })
export class Pack {
  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  slug: string;

  @Prop({ type: Map, of: String, required: true })
  title: Map<string, string>;

  @Prop({ type: Map, of: String, required: true })
  description: Map<string, string>;

  @Prop({ required: true, lowercase: true, trim: true })
  mode: string;

  @Prop({ enum: ['all', '18+'], default: 'all' })
  ageRating: string;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ default: '' })
  coverImageUrl: string;

  @Prop({ default: 0 })
  sortOrder: number;
}

export const PackSchema = SchemaFactory.createForClass(Pack);
