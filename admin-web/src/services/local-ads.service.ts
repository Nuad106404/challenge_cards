import apiClient from './api';

export interface LocalAd {
  _id: string;
  label: string;
  imageUrl: string;
  linkUrl: string;
  isActive: boolean;
  order: number;
  createdAt: string;
  updatedAt: string;
}

export interface CreateLocalAdPayload {
  label: string;
  imageUrl: string;
  linkUrl?: string;
  isActive?: boolean;
  order?: number;
}

export interface UpdateLocalAdPayload {
  label?: string;
  imageUrl?: string;
  linkUrl?: string;
  isActive?: boolean;
  order?: number;
}

export const localAdsService = {
  async getAll(): Promise<LocalAd[]> {
    const { data } = await apiClient.get<LocalAd[]>('/admin/local-ads');
    return data;
  },

  async create(payload: CreateLocalAdPayload): Promise<LocalAd> {
    const { data } = await apiClient.post<LocalAd>('/admin/local-ads', payload);
    return data;
  },

  async update(id: string, payload: UpdateLocalAdPayload): Promise<LocalAd> {
    const { data } = await apiClient.put<LocalAd>(`/admin/local-ads/${id}`, payload);
    return data;
  },

  async toggle(id: string): Promise<LocalAd> {
    const { data } = await apiClient.patch<LocalAd>(`/admin/local-ads/${id}/toggle`);
    return data;
  },

  async remove(id: string): Promise<void> {
    await apiClient.delete(`/admin/local-ads/${id}`);
  },

  async reorder(ids: string[]): Promise<void> {
    await apiClient.post('/admin/local-ads/reorder', { ids });
  },

  async uploadImage(file: File): Promise<{ url: string }> {
    const form = new FormData();
    form.append('file', file);
    const { data } = await apiClient.post<{ url: string }>('/admin/local-ads/upload-image', form, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return data;
  },
};
