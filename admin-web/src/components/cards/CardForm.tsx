'use client';

import { useState, useEffect, FormEvent } from 'react';
import { Card, Pack, SupportedLanguage } from '@/types';
import { CreateCardPayload } from '@/services/cards.service';
import { Toggle, LangTabs, FormSection, formInput, formLabel } from '@/components/shared/ui';

interface CardFormProps {
  initial?: Card;
  packs: Pack[];
  languages: SupportedLanguage[];
  onSubmit: (payload: CreateCardPayload) => Promise<void>;
  onCancel: () => void;
  loading?: boolean;
}

const EMPTY: CreateCardPayload = {
  packId: '',
  type: 'question',
  text: {},
  tags: [],
  difficulty: 'medium',
  ageRating: 'all',
  diceCount: 0,
  isActive: true,
  status: 'draft',
};

export default function CardForm({ initial, packs, languages, onSubmit, onCancel, loading }: CardFormProps) {
  const [form, setForm] = useState<CreateCardPayload>(EMPTY);
  const [tagsInput, setTagsInput] = useState('');
  const [tagDraft, setTagDraft] = useState('');
  const [error, setError] = useState<string | null>(null);
  const langs = languages.length > 0 ? languages : [{ code: 'en', label: 'English' }];
  const [activeLang, setActiveLang] = useState(langs[0].code);

  useEffect(() => {
    if (initial) {
      const packId = typeof initial.packId === 'string' ? initial.packId : initial.packId._id;
      setForm({
        packId,
        type: initial.type,
        text: { ...initial.text },
        tags: [...initial.tags],
        difficulty: initial.difficulty,
        ageRating: initial.ageRating,
        diceCount: initial.diceCount ?? 0,
        isActive: initial.isActive,
        status: initial.status,
      });
      setTagsInput(initial.tags.join(', '));
    }
  }, [initial]);

  const set = (key: keyof CreateCardPayload, value: unknown) =>
    setForm((prev) => ({ ...prev, [key]: value }));

  const setLocalized = (code: string, value: string) =>
    setForm((prev) => ({ ...prev, text: { ...prev.text, [code]: value } }));

  const copyEnToAll = () => {
    const enVal = form.text['en'] ?? '';
    const filled: Record<string, string> = {};
    langs.forEach((l) => { filled[l.code] = form.text[l.code] || enVal; });
    setForm((prev) => ({ ...prev, text: filled }));
  };

  const handleTagsChange = (value: string) => {
    setTagsInput(value);
    set('tags', value.split(',').map((t) => t.trim()).filter(Boolean));
  };

  const addTagChip = () => {
    const tag = tagDraft.trim();
    if (!tag) return;
    const current = form.tags as string[];
    if (!current.includes(tag)) {
      const next = [...current, tag];
      set('tags', next);
      setTagsInput(next.join(', '));
    }
    setTagDraft('');
  };

  const removeTagChip = (tag: string) => {
    const next = (form.tags as string[]).filter((t) => t !== tag);
    set('tags', next);
    setTagsInput(next.join(', '));
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    try {
      await onSubmit(form);
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string | string[] } } })
        ?.response?.data?.message;
      setError(Array.isArray(msg) ? msg.join(', ') : (msg ?? 'Failed to save card'));
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '0' }}>
      {error && (
        <div style={{ padding: '11px 14px', background: 'rgba(239,68,68,0.08)', border: '1px solid rgba(239,68,68,0.2)', borderRadius: '10px', color: '#dc2626', fontSize: '13px', marginBottom: '14px' }}>
          ⚠ {error}
        </div>
      )}

      {/* ── Section 1: Basics ── */}
      <FormSection title="Basics" hint="Pack assignment, card type and publish status">
        <div style={{ marginBottom: '12px' }}>
          <label style={formLabel}>Pack *</label>
          <select style={formInput} value={form.packId} onChange={(e) => set('packId', e.target.value)} required>
            <option value="">— Select a pack —</option>
            {packs.map((p) => (
              <option key={p._id} value={p._id}>
                {p.title['en'] ?? Object.values(p.title)[0] ?? p.slug} ({p.mode})
              </option>
            ))}
          </select>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
          <div>
            <label style={formLabel}>Type *</label>
            <select style={formInput} value={form.type} onChange={(e) => set('type', e.target.value)}>
              <option value="question">Question</option>
              <option value="dare">Dare</option>
              <option value="vote">Vote</option>
              <option value="punishment">Punishment</option>
              <option value="bonus">Bonus</option>
              <option value="minigame">Mini Game</option>
            </select>
          </div>
          <div>
            <label style={formLabel}>Status</label>
            <select style={formInput} value={form.status} onChange={(e) => set('status', e.target.value)}>
              <option value="draft">Draft</option>
              <option value="review">Review</option>
              <option value="published">Published</option>
            </select>
          </div>
        </div>
      </FormSection>

      {/* ── Section 2: Card Text ── */}
      <FormSection title="Card Text" hint="The challenge text shown on the card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
          <LangTabs languages={langs} value={activeLang} onChange={setActiveLang} />
          {activeLang !== 'en' && (
            <button type="button" onClick={copyEnToAll}
              style={{ fontSize: '11px', color: '#8B5CF6', background: 'rgba(139,92,246,0.08)', border: '1px solid rgba(139,92,246,0.2)', borderRadius: '6px', padding: '3px 9px', cursor: 'pointer', marginLeft: '8px', whiteSpace: 'nowrap' }}>
              Copy EN →
            </button>
          )}
        </div>
        {langs.map((l) => (
          <div key={l.code} style={{ display: l.code === activeLang ? 'block' : 'none' }}>
            <label style={formLabel}>{l.label} *</label>
            <textarea
              style={{ ...formInput, minHeight: '88px', resize: 'vertical' }}
              value={form.text[l.code] ?? ''}
              onChange={(e) => setLocalized(l.code, e.target.value)}
              placeholder={`Card text in ${l.label}`}
              required={l.code === langs[0].code}
            />
          </div>
        ))}
        {/* Hidden sync field so comma-string stays in sync */}
        <input type="hidden" value={tagsInput} readOnly />
      </FormSection>

      {/* ── Section 3: Metadata ── */}
      <FormSection title="Metadata" hint="Difficulty, age rating and searchable tags">
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', marginBottom: '14px' }}>
          <div>
            <label style={formLabel}>Difficulty</label>
            <select style={formInput} value={form.difficulty} onChange={(e) => set('difficulty', e.target.value)}>
              <option value="easy">Easy</option>
              <option value="medium">Medium</option>
              <option value="hard">Hard</option>
            </select>
          </div>
          <div>
            <label style={formLabel}>Age Rating</label>
            <select style={formInput} value={form.ageRating} onChange={(e) => set('ageRating', e.target.value)}>
              <option value="all">All Ages</option>
              <option value="18+">18+</option>
            </select>
          </div>
        </div>

        {/* Tags chip UI */}
        <label style={formLabel}>Tags</label>
        <div style={{ display: 'flex', gap: '8px', marginBottom: '8px' }}>
          <input
            style={{ ...formInput, flex: 1 }}
            value={tagDraft}
            onChange={(e) => setTagDraft(e.target.value)}
            onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); addTagChip(); } }}
            placeholder="Type a tag and press Enter"
          />
          <button type="button" onClick={addTagChip}
            style={{ padding: '9px 16px', background: 'rgba(139,92,246,0.08)', border: '1px solid rgba(139,92,246,0.2)', borderRadius: '10px', cursor: 'pointer', fontSize: '13px', fontWeight: 600, color: '#8B5CF6', whiteSpace: 'nowrap' }}>
            + Add
          </button>
        </div>
        {(form.tags as string[]).length > 0 && (
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {(form.tags as string[]).map((tag) => (
              <span key={tag} style={{ display: 'inline-flex', alignItems: 'center', gap: '5px', padding: '4px 10px', background: 'rgba(139,92,246,0.08)', border: '1px solid rgba(139,92,246,0.18)', borderRadius: '20px', fontSize: '12px', color: '#6d28d9', fontWeight: 600 }}>
                {tag}
                <button type="button" onClick={() => removeTagChip(tag)}
                  style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#a78bfa', fontSize: '14px', lineHeight: 1, padding: '0 1px' }}>×</button>
              </span>
            ))}
          </div>
        )}
        <div style={{ marginTop: '4px', fontSize: '11px', color: '#bbb' }}>Also editable as CSV: <input style={{ ...formInput, display: 'inline', width: 'auto', fontSize: '11px', padding: '2px 8px', marginLeft: '6px' }} value={tagsInput} onChange={(e) => handleTagsChange(e.target.value)} placeholder="funny, spicy" /></div>

        {/* Dice count for minigame type */}
        {form.type === 'minigame' && (
          <div style={{ marginTop: '14px', padding: '12px 14px', background: 'rgba(139,92,246,0.04)', border: '1px solid rgba(139,92,246,0.12)', borderRadius: '10px' }}>
            <label style={{ ...formLabel, marginBottom: '10px' }}>Dice Count <span style={{ fontWeight: 400, color: '#bbb', textTransform: 'none', letterSpacing: 0 }}>(0 = no dice)</span></label>
            <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
              <input type="range" min={0} max={6} value={form.diceCount ?? 0}
                onChange={(e) => set('diceCount', Number(e.target.value))} style={{ flex: 1, accentColor: '#8B5CF6' }} />
              <span style={{ minWidth: '28px', textAlign: 'center', fontWeight: 800, fontSize: '20px', color: (form.diceCount ?? 0) > 0 ? '#8B5CF6' : '#ccc' }}>
                {form.diceCount ?? 0}
              </span>
              <span style={{ fontSize: '18px' }}>{Array.from({ length: form.diceCount ?? 0 }, () => '🎲').join('')}</span>
            </div>
          </div>
        )}
      </FormSection>

      {/* ── Footer: Active toggle + actions ── */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: '4px', borderTop: '1px solid rgba(0,0,0,0.06)', marginTop: '4px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <Toggle value={!!form.isActive} onChange={(v) => set('isActive', v)} />
          <div>
            <div style={{ fontSize: '13px', fontWeight: 600, color: '#1a1a2e' }}>Active</div>
            <div style={{ fontSize: '11px', color: '#aaa' }}>Included in game sessions</div>
          </div>
        </div>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button type="button" onClick={onCancel}
            style={{ padding: '9px 20px', background: '#fff', border: '1px solid rgba(0,0,0,0.12)', borderRadius: '10px', cursor: 'pointer', fontSize: '13.5px', fontWeight: 600, color: '#555' }}>
            Cancel
          </button>
          <button type="submit" disabled={loading}
            style={{ padding: '9px 22px', background: 'linear-gradient(135deg, #8B5CF6, #EC4899)', border: 'none', borderRadius: '10px', color: '#fff', cursor: loading ? 'not-allowed' : 'pointer', fontSize: '13.5px', fontWeight: 700, opacity: loading ? 0.65 : 1, boxShadow: '0 4px 14px rgba(139,92,246,0.3)', transition: 'all 0.15s' }}>
            {loading ? 'Saving…' : initial ? 'Update Card' : 'Create Card'}
          </button>
        </div>
      </div>
    </form>
  );
}
