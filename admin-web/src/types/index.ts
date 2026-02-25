export type LocalizedText = Record<string, string>;

export interface Pack {
  _id: string;
  slug: string;
  title: LocalizedText;
  description: LocalizedText;
  mode: string;
  ageRating: 'all' | '18+';
  isActive: boolean;
  coverImageUrl: string;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
}

export interface Card {
  _id: string;
  packId: string | Pack;
  type: 'question' | 'dare' | 'vote' | 'punishment' | 'bonus' | 'minigame';
  text: LocalizedText;
  tags: string[];
  difficulty: 'easy' | 'medium' | 'hard';
  ageRating: 'all' | '18+';
  diceCount: number;
  isActive: boolean;
  status: 'draft' | 'review' | 'published';
  contentSource?: 'manual' | 'image';
  imageUrl?: string;
  imageMeta?: {
    width: number;
    height: number;
    size: number;
    mime: string;
  };
  createdAt: string;
  updatedAt: string;
}

export interface GameMode {
  _id: string;
  slug: string;
  name: LocalizedText;
  description: LocalizedText;
  isActive: boolean;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
}

export interface SupportedLanguage {
  code: string;
  label: string;
}

export interface AppConfig {
  _id: string;
  adsEnabled: boolean;
  admobAppId: string;
  admobBannerId: string;
  admobInterstitialId: string;
  adRotationDuration: number;
  contentVersion: number;
  minAppVersion: string;
  supportedLanguages: SupportedLanguage[];
  apiBaseUrl: string;
  updatedAt: string;
}

export interface AdminUser {
  userId: string;
  name: string;
  role: 'admin' | 'editor';
  isActive: boolean;
}

export interface AuthResponse {
  accessToken: string;
  user: AdminUser;
}

export interface PublishResult {
  contentVersion: number;
  publishedCards: number;
  packId?: string;
}

export interface ApiError {
  message: string | string[];
  statusCode: number;
  error?: string;
}
