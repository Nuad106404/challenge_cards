'use client';

import { useState, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { authService } from '@/services/auth.service';
import { AdminUser } from '@/types';

export function useAuth() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [user, setUser] = useState<AdminUser | null>(null);

  const login = useCallback(async (userId: string, password: string) => {
    setLoading(true);
    setError(null);
    try {
      const response = await authService.login(userId, password);
      setUser(response.user);
      router.push('/dashboard');
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string } } })
        ?.response?.data?.message ?? 'Login failed';
      setError(Array.isArray(msg) ? msg.join(', ') : msg);
    } finally {
      setLoading(false);
    }
  }, [router]);

  const logout = useCallback(() => {
    authService.logout();
    router.push('/login');
  }, [router]);

  return { login, logout, loading, error, user };
}
