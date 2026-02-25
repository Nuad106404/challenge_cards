import apiClient from './api';
import { Card } from '@/types';

export type CreateCardPayload = Omit<Card, '_id' | 'createdAt' | 'updatedAt' | 'packId'> & { packId: string };
export type UpdateCardPayload = Partial<CreateCardPayload>;

export const cardsService = {
  async getAll(params?: {
    packId?: string;
    type?: string;
    ageRating?: string;
    status?: string;
    isActive?: boolean;
  }): Promise<Card[]> {
    const { data } = await apiClient.get<Card[]>('/admin/cards', { params });
    return data;
  },

  async getOne(id: string): Promise<Card> {
    const { data } = await apiClient.get<Card>(`/admin/cards/${id}`);
    return data;
  },

  async create(payload: CreateCardPayload): Promise<Card> {
    const { data } = await apiClient.post<Card>('/admin/cards', payload);
    return data;
  },

  async update(id: string, payload: UpdateCardPayload): Promise<Card> {
    const { data } = await apiClient.put<Card>(`/admin/cards/${id}`, payload);
    return data;
  },

  async remove(id: string): Promise<void> {
    await apiClient.delete(`/admin/cards/${id}`);
  },
};
