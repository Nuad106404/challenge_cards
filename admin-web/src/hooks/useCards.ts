'use client';

import { useState, useEffect, useCallback } from 'react';
import { cardsService, CreateCardPayload, UpdateCardPayload } from '@/services/cards.service';
import { Card } from '@/types';

export function useCards(packId?: string) {
  const [cards, setCards] = useState<Card[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCards = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await cardsService.getAll(packId ? { packId } : undefined);
      setCards(data);
    } catch {
      setError('Failed to load cards');
    } finally {
      setLoading(false);
    }
  }, [packId]);

  useEffect(() => {
    fetchCards();
  }, [fetchCards]);

  const createCard = useCallback(async (payload: CreateCardPayload): Promise<Card> => {
    const card = await cardsService.create(payload);
    await fetchCards();
    return card;
  }, [fetchCards]);

  const updateCard = useCallback(async (id: string, payload: UpdateCardPayload): Promise<Card> => {
    const card = await cardsService.update(id, payload);
    await fetchCards();
    return card;
  }, [fetchCards]);

  const patchCard = useCallback(async (id: string, payload: UpdateCardPayload): Promise<Card> => {
    const updated = await cardsService.update(id, payload);
    setCards((prev) => prev.map((c) => (c._id === id ? updated : c)));
    return updated;
  }, []);

  const deleteCard = useCallback(async (id: string): Promise<void> => {
    await cardsService.remove(id);
    await fetchCards();
  }, [fetchCards]);

  return { cards, loading, error, fetchCards, createCard, updateCard, patchCard, deleteCard };
}
