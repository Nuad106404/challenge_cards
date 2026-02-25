import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type AdminUserDocument = AdminUser & Document;

@Schema({ timestamps: true, collection: 'admin_users' })
export class AdminUser {
  @Prop({ required: true, unique: true, trim: true })
  userId: string;

  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ required: true })
  passwordHash: string;

  @Prop({ enum: ['admin', 'editor'], default: 'admin' })
  role: string;

  @Prop({ default: true })
  isActive: boolean;
}

export const AdminUserSchema = SchemaFactory.createForClass(AdminUser);
