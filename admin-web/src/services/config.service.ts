import apiClient from './api';
import { AppConfig, PublishResult, SupportedLanguage } from '@/types';

export interface UpdateConfigPayload {
  adsEnabled?: boolean;
  admobAppId?: string;
  admobBannerId?: string;
  admobInterstitialId?: string;
  adRotationDuration?: number;
  minAppVersion?: string;
  apiBaseUrl?: string;
  supportedLanguages?: SupportedLanguage[];
}

export const configService = {
  async getConfig(): Promise<AppConfig> {
    const { data } = await apiClient.get<AppConfig>('/admin/config');
    return data;
  },

  async updateConfig(payload: UpdateConfigPayload): Promise<AppConfig> {
    const clean = {
      ...payload,
      ...(payload.supportedLanguages && {
        supportedLanguages: payload.supportedLanguages.map(({ code, label }) => ({ code, label })),
      }),
    };
    const { data } = await apiClient.put<AppConfig>('/admin/config', clean);
    return data;
  },

  async publish(packId?: string): Promise<PublishResult> {
    const { data } = await apiClient.post<PublishResult>('/admin/publish', packId ? { packId } : {});
    return data;
  },
};
