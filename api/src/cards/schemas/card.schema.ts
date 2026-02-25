import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Schema as MongooseSchema } from 'mongoose';

export type CardDocument = Card & Document;

@Schema({ timestamps: true, collection: 'cards' })
export class Card {
  @Prop({ type: MongooseSchema.Types.ObjectId, ref: 'Pack', required: true })
  packId: MongooseSchema.Types.ObjectId;

  @Prop({ enum: ['question', 'dare', 'vote', 'punishment', 'bonus', 'minigame'], required: true })
  type: string;

  @Prop({ type: Map, of: String, required: true })
  text: Map<string, string>;

  @Prop({ type: [String], default: [] })
  tags: string[];

  @Prop({ enum: ['easy', 'medium', 'hard'], default: 'medium' })
  difficulty: string;

  @Prop({ enum: ['all', '18+'], default: 'all' })
  ageRating: string;

  @Prop({ default: 0, min: 0, max: 6 })
  diceCount: number;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ enum: ['draft', 'review', 'published'], default: 'draft' })
  status: string;

  @Prop({ enum: ['manual', 'image'], default: 'manual' })
  contentSource: string;

  @Prop({ required: false })
  imageUrl?: string;

  @Prop({
    type: {
      width: Number,
      height: Number,
      size: Number,
      mime: String,
    },
    required: false,
  })
  imageMeta?: {
    width: number;
    height: number;
    size: number;
    mime: string;
  };
}

export const CardSchema = SchemaFactory.createForClass(Card);

CardSchema.index({ packId: 1, status: 1 });
CardSchema.index({ ageRating: 1, isActive: 1 });
