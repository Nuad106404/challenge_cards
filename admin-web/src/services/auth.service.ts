import apiClient, { setToken, removeToken } from './api';
import { AuthResponse, AdminUser } from '@/types';

export const authService = {
  async login(userId: string, password: string): Promise<AuthResponse> {
    const { data } = await apiClient.post<AuthResponse>('/admin/auth/login', {
      userId,
      password,
    });
    setToken(data.accessToken);
    return data;
  },

  logout(): void {
    removeToken();
  },

  async getUsers(): Promise<AdminUser[]> {
    const { data } = await apiClient.get<AdminUser[]>('/admin/auth/users');
    return data;
  },
};
