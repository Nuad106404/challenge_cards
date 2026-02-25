'use client';

import { useState, useEffect, useCallback } from 'react';
import { configService, UpdateConfigPayload } from '@/services/config.service';
import { AppConfig, PublishResult } from '@/types';

export function useConfig() {
  const [config, setConfig] = useState<AppConfig | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [publishing, setPublishing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchConfig = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await configService.getConfig();
      setConfig(data);
    } catch {
      setError('Failed to load config');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchConfig();
  }, [fetchConfig]);

  const updateConfig = useCallback(async (payload: UpdateConfigPayload): Promise<AppConfig> => {
    setSaving(true);
    try {
      const updated = await configService.updateConfig(payload);
      setConfig(updated);
      return updated;
    } finally {
      setSaving(false);
    }
  }, []);

  const publish = useCallback(async (packId?: string): Promise<PublishResult> => {
    setPublishing(true);
    try {
      const result = await configService.publish(packId);
      await fetchConfig();
      return result;
    } finally {
      setPublishing(false);
    }
  }, [fetchConfig]);

  return { config, loading, saving, publishing, error, fetchConfig, updateConfig, publish };
}
