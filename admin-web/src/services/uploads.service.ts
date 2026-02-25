import apiClient from './api';

export interface UploadedFileInfo {
  url: string;
  path: string;
  mime: string;
  size: number;
  width: number;
  height: number;
}

export interface CreateImageCardPayload {
  packId: string;
  type: 'question' | 'dare' | 'vote' | 'punishment' | 'bonus' | 'minigame';
  tags?: string[];
  difficulty?: 'easy' | 'medium' | 'hard';
  ageRating?: 'all' | '18+';
  status?: 'draft' | 'review' | 'published';
  imageUrl: string;
  imageMeta?: {
    width: number;
    height: number;
    size: number;
    mime: string;
  };
}

export const uploadsService = {
  async uploadCardImage(file: File): Promise<UploadedFileInfo> {
    const formData = new FormData();
    formData.append('file', file);

    const { data } = await apiClient.post<UploadedFileInfo>(
      '/admin/uploads/card-image',
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return data;
  },

  async createImageCard(payload: CreateImageCardPayload) {
    const { data } = await apiClient.post('/admin/cards/image', payload);
    return data;
  },
};
