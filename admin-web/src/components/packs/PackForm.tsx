'use client';

import { useState, useEffect, FormEvent } from 'react';
import { Pack, GameMode, SupportedLanguage } from '@/types';
import { CreatePackPayload } from '@/services/packs.service';
import { Toggle, LangTabs, FormSection, formInput, formLabel } from '@/components/shared/ui';

interface PackFormProps {
  initial?: Pack;
  modes: GameMode[];
  languages: SupportedLanguage[];
  onSubmit: (payload: CreatePackPayload) => Promise<void>;
  onCancel: () => void;
  loading?: boolean;
}

const EMPTY: CreatePackPayload = {
  slug: '',
  title: {},
  description: {},
  mode: '',
  ageRating: 'all',
  isActive: true,
  coverImageUrl: '',
  sortOrder: 0,
};

export default function PackForm({ initial, modes, languages, onSubmit, onCancel, loading }: PackFormProps) {
  const [form, setForm] = useState<CreatePackPayload>(EMPTY);
  const [error, setError] = useState<string | null>(null);
  const langs = languages.length > 0 ? languages : [{ code: 'en', label: 'English' }];
  const [activeLang, setActiveLang] = useState(langs[0].code);

  useEffect(() => {
    if (initial) {
      setForm({
        slug: initial.slug,
        title: { ...initial.title },
        description: { ...initial.description },
        mode: initial.mode,
        ageRating: initial.ageRating,
        isActive: initial.isActive,
        coverImageUrl: initial.coverImageUrl,
        sortOrder: initial.sortOrder,
      });
    }
  }, [initial]);

  const set = (key: keyof CreatePackPayload, value: unknown) =>
    setForm((prev) => ({ ...prev, [key]: value }));

  const setLocalized = (field: 'title' | 'description', code: string, value: string) =>
    setForm((prev) => ({ ...prev, [field]: { ...prev[field], [code]: value } }));

  const copyEnToAll = (field: 'title' | 'description') => {
    const enVal = form[field]['en'] ?? '';
    const filled: Record<string, string> = {};
    langs.forEach((l) => { filled[l.code] = form[field][l.code] || enVal; });
    setForm((prev) => ({ ...prev, [field]: filled }));
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    try {
      await onSubmit(form);
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string | string[] } } })
        ?.response?.data?.message;
      setError(Array.isArray(msg) ? msg.join(', ') : (msg ?? 'Failed to save pack'));
    }
  };

  const copyBtn = (field: 'title' | 'description') => activeLang !== 'en' ? (
    <button type="button" onClick={() => copyEnToAll(field)}
      style={{ fontSize: '11px', color: '#8B5CF6', background: 'rgba(139,92,246,0.08)', border: '1px solid rgba(139,92,246,0.2)', borderRadius: '6px', padding: '3px 9px', cursor: 'pointer', marginLeft: '8px', whiteSpace: 'nowrap' }}>
      Copy EN →
    </button>
  ) : null;

  return (
    <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '0' }}>
      {error && (
        <div style={{ padding: '11px 14px', background: 'rgba(239,68,68,0.08)', border: '1px solid rgba(239,68,68,0.2)', borderRadius: '10px', color: '#dc2626', fontSize: '13px', marginBottom: '14px' }}>
          ⚠ {error}
        </div>
      )}

      {/* ── Section 1: Basics ── */}
      <FormSection title="Basics" hint="Slug, game mode, audience and display order">
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
          <div>
            <label style={formLabel}>Slug *</label>
            <input style={formInput} value={form.slug}
              onChange={(e) => set('slug', e.target.value.toLowerCase().replace(/\s+/g, '-'))}
              placeholder="e.g. friends-basic" required />
            <div style={{ fontSize: '11px', color: '#bbb', marginTop: '4px' }}>Lowercase, hyphens only</div>
          </div>
          <div>
            <label style={formLabel}>Sort Order</label>
            <input style={formInput} type="number" value={form.sortOrder}
              onChange={(e) => set('sortOrder', Number(e.target.value))} />
          </div>
          <div>
            <label style={formLabel}>Mode *</label>
            <select style={formInput} value={form.mode} onChange={(e) => set('mode', e.target.value)} required>
              <option value="">— Select a mode —</option>
              {modes.map((m) => (
                <option key={m._id} value={m.slug}>{m.name['en'] ?? Object.values(m.name)[0] ?? m.slug}</option>
              ))}
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
      </FormSection>

      {/* ── Section 2: Titles ── */}
      <FormSection title="Titles" hint="Pack title shown to players">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
          <LangTabs languages={langs} value={activeLang} onChange={setActiveLang} />
          {copyBtn('title')}
        </div>
        {langs.map((l) => (
          <div key={l.code} style={{ display: l.code === activeLang ? 'block' : 'none' }}>
            <label style={formLabel}>{l.label} *</label>
            <input style={formInput} value={form.title[l.code] ?? ''}
              onChange={(e) => setLocalized('title', l.code, e.target.value)}
              placeholder={`Pack title in ${l.label}`}
              required={l.code === langs[0].code} />
          </div>
        ))}
      </FormSection>

      {/* ── Section 3: Descriptions ── */}
      <FormSection title="Descriptions" hint="Short description on the pack select screen">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
          <LangTabs languages={langs} value={activeLang} onChange={setActiveLang} />
          {copyBtn('description')}
        </div>
        {langs.map((l) => (
          <div key={l.code} style={{ display: l.code === activeLang ? 'block' : 'none' }}>
            <label style={formLabel}>{l.label} *</label>
            <textarea style={{ ...formInput, minHeight: '80px', resize: 'vertical' }}
              value={form.description[l.code] ?? ''}
              onChange={(e) => setLocalized('description', l.code, e.target.value)}
              placeholder={`Description in ${l.label}`}
              required={l.code === langs[0].code} />
          </div>
        ))}
      </FormSection>

      {/* ── Section 4: Cover Image ── */}
      <FormSection title="Cover Image" hint="Optional thumbnail shown on pack cards">
        <label style={formLabel}>Image URL</label>
        <input style={formInput} value={form.coverImageUrl}
          onChange={(e) => set('coverImageUrl', e.target.value)} placeholder="https://..." />
        {form.coverImageUrl && (
          <div style={{ marginTop: '10px', display: 'flex', alignItems: 'center', gap: '12px' }}>
            <img src={form.coverImageUrl} alt="Cover preview"
              style={{ width: '80px', height: '80px', objectFit: 'cover', borderRadius: '10px', border: '1px solid rgba(0,0,0,0.08)' }}
              onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }} />
            <div style={{ fontSize: '12px', color: '#aaa' }}>Preview</div>
          </div>
        )}
      </FormSection>

      {/* ── Footer: Active toggle + actions ── */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: '4px', borderTop: '1px solid rgba(0,0,0,0.06)', marginTop: '4px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <Toggle value={!!form.isActive} onChange={(v) => set('isActive', v)} />
          <div>
            <div style={{ fontSize: '13px', fontWeight: 600, color: '#1a1a2e' }}>Active</div>
            <div style={{ fontSize: '11px', color: '#aaa' }}>Visible in the mobile app</div>
          </div>
        </div>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button type="button" onClick={onCancel}
            style={{ padding: '9px 20px', background: '#fff', border: '1px solid rgba(0,0,0,0.12)', borderRadius: '10px', cursor: 'pointer', fontSize: '13.5px', fontWeight: 600, color: '#555' }}>
            Cancel
          </button>
          <button type="submit" disabled={loading}
            style={{ padding: '9px 22px', background: 'linear-gradient(135deg, #8B5CF6, #EC4899)', border: 'none', borderRadius: '10px', color: '#fff', cursor: loading ? 'not-allowed' : 'pointer', fontSize: '13.5px', fontWeight: 700, opacity: loading ? 0.65 : 1, boxShadow: '0 4px 14px rgba(139,92,246,0.3)', transition: 'all 0.15s' }}>
            {loading ? 'Saving…' : initial ? 'Update Pack' : 'Create Pack'}
          </button>
        </div>
      </div>
    </form>
  );
}
