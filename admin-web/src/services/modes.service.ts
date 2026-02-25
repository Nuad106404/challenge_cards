import apiClient from './api';
import { GameMode } from '@/types';

export type CreateGameModePayload = {
  slug: string;
  name: Record<string, string>;
  description: Record<string, string>;
  isActive?: boolean;
  sortOrder?: number;
};

export type UpdateGameModePayload = Partial<CreateGameModePayload>;

export const modesService = {
  async getAll(): Promise<GameMode[]> {
    const { data } = await apiClient.get<GameMode[]>('/admin/modes');
    return data;
  },

  async create(payload: CreateGameModePayload): Promise<GameMode> {
    const { data } = await apiClient.post<GameMode>('/admin/modes', payload);
    return data;
  },

  async update(id: string, payload: UpdateGameModePayload): Promise<GameMode> {
    const { data } = await apiClient.put<GameMode>(`/admin/modes/${id}`, payload);
    return data;
  },

  async remove(id: string): Promise<void> {
    await apiClient.delete(`/admin/modes/${id}`);
  },
};
