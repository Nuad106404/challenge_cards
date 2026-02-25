import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type LocalAdDocument = LocalAd & Document;

@Schema({ timestamps: true, collection: 'local_ads' })
export class LocalAd {
  @Prop({ required: true })
  label: string;

  @Prop({ required: true })
  imageUrl: string;

  @Prop({ default: '' })
  linkUrl: string;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ default: 0 })
  order: number;
}

export const LocalAdSchema = SchemaFactory.createForClass(LocalAd);
