import { useState, useEffect, useCallback } from 'react';
import { GameMode } from '@/types';
import { modesService, CreateGameModePayload, UpdateGameModePayload } from '@/services/modes.service';

export function useModes() {
  const [modes, setModes] = useState<GameMode[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchModes = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await modesService.getAll();
      setModes(data);
    } catch {
      setError('Failed to load modes');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchModes();
  }, [fetchModes]);

  const createMode = async (payload: CreateGameModePayload) => {
    const created = await modesService.create(payload);
    setModes((prev) => [...prev, created]);
  };

  const updateMode = async (id: string, payload: UpdateGameModePayload) => {
    const updated = await modesService.update(id, payload);
    setModes((prev) => prev.map((m) => (m._id === id ? updated : m)));
  };

  const deleteMode = async (id: string) => {
    await modesService.remove(id);
    setModes((prev) => prev.filter((m) => m._id !== id));
  };

  return { modes, loading, error, createMode, updateMode, deleteMode };
}
