import apiClient from './api';
import { Pack } from '@/types';

export type CreatePackPayload = Omit<Pack, '_id' | 'createdAt' | 'updatedAt'>;
export type UpdatePackPayload = Partial<CreatePackPayload>;

export const packsService = {
  async getAll(params?: { mode?: string; ageRating?: string; isActive?: boolean }): Promise<Pack[]> {
    const { data } = await apiClient.get<Pack[]>('/admin/packs', { params });
    return data;
  },

  async getOne(id: string): Promise<Pack> {
    const { data } = await apiClient.get<Pack>(`/admin/packs/${id}`);
    return data;
  },

  async create(payload: CreatePackPayload): Promise<Pack> {
    const { data } = await apiClient.post<Pack>('/admin/packs', payload);
    return data;
  },

  async update(id: string, payload: UpdatePackPayload): Promise<Pack> {
    const { data } = await apiClient.put<Pack>(`/admin/packs/${id}`, payload);
    return data;
  },

  async remove(id: string): Promise<void> {
    await apiClient.delete(`/admin/packs/${id}`);
  },
};
