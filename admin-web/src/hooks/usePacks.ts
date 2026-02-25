'use client';

import { useState, useEffect, useCallback } from 'react';
import { packsService, CreatePackPayload, UpdatePackPayload } from '@/services/packs.service';
import { Pack } from '@/types';

export function usePacks() {
  const [packs, setPacks] = useState<Pack[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchPacks = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await packsService.getAll();
      setPacks(data);
    } catch {
      setError('Failed to load packs');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchPacks();
  }, [fetchPacks]);

  const createPack = useCallback(async (payload: CreatePackPayload): Promise<Pack> => {
    const pack = await packsService.create(payload);
    await fetchPacks();
    return pack;
  }, [fetchPacks]);

  const updatePack = useCallback(async (id: string, payload: UpdatePackPayload): Promise<Pack> => {
    const pack = await packsService.update(id, payload);
    await fetchPacks();
    return pack;
  }, [fetchPacks]);

  const deletePack = useCallback(async (id: string): Promise<void> => {
    await packsService.remove(id);
    await fetchPacks();
  }, [fetchPacks]);

  return { packs, loading, error, fetchPacks, createPack, updatePack, deletePack };
}
