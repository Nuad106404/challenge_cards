import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type AppConfigDocument = AppConfig & Document;

@Schema({ timestamps: true, collection: 'app_configs' })
export class AppConfig {
  @Prop({ default: true })
  adsEnabled: boolean;

  @Prop({ default: '' })
  admobAppId: string;

  @Prop({ default: '' })
  admobBannerId: string;

  @Prop({ default: '' })
  admobInterstitialId: string;

  @Prop({ default: 1 })
  contentVersion: number;

  @Prop({ default: '1.0.0' })
  minAppVersion: string;

  @Prop({
    type: [{ code: String, label: String }],
    default: [
      { code: 'en', label: 'English' },
      { code: 'th', label: 'Thai (ภาษาไทย)' },
    ],
  })
  supportedLanguages: { code: string; label: string }[];

  @Prop({ default: 5 })
  adRotationDuration: number; // Global rotation duration in seconds for all ads

  @Prop({ default: '' })
  apiBaseUrl: string; // Overrides the bootstrap API_BASE_URL on mobile clients
}

export const AppConfigSchema = SchemaFactory.createForClass(AppConfig);
