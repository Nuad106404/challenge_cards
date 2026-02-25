'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import AdminLayout from '@/components/layout/AdminLayout';
import { localAdsService, LocalAd } from '@/services/local-ads.service';

const API_BASE = (process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3001').replace(/\/api$/, '');

function resolveImageUrl(url: string) {
  if (!url) return '';
  if (url.startsWith('http')) return url;
  return `${API_BASE}${url}`;
}

export default function AdsPage() {
  const [ads, setAds] = useState<LocalAd[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // New ad form state
  const [showForm, setShowForm] = useState(false);
  const [formLabel, setFormLabel] = useState('');
  const [formImageUrl, setFormImageUrl] = useState('');
  const [formLinkUrl, setFormLinkUrl] = useState('');
  const [formUploading, setFormUploading] = useState(false);
  const [formSaving, setFormSaving] = useState(false);
  const [formMsg, setFormMsg] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Edit state
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editLabel, setEditLabel] = useState('');
  const [editLinkUrl, setEditLinkUrl] = useState('');
  const [editSaving, setEditSaving] = useState(false);

  // Toggle loading state per ad
  const [togglingId, setTogglingId] = useState<string | null>(null);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const fetchAds = useCallback(async () => {
    setLoading(true);
    try {
      const data = await localAdsService.getAll();
      setAds(data);
    } catch {
      setError('Failed to load ads.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchAds(); }, [fetchAds]);

  const handleUploadImage = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setFormUploading(true);
    setFormMsg('');
    try {
      const { url } = await localAdsService.uploadImage(file);
      setFormImageUrl(url);
      setFormMsg('Image uploaded.');
    } catch {
      setFormMsg('Upload failed.');
    } finally {
      setFormUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  const handleCreate = async () => {
    if (!formLabel.trim() || !formImageUrl.trim()) {
      setFormMsg('Label and image are required.');
      return;
    }
    setFormSaving(true);
    setFormMsg('');
    try {
      const ad = await localAdsService.create({
        label: formLabel.trim(),
        imageUrl: formImageUrl.trim(),
        linkUrl: formLinkUrl.trim(),
      });
      setAds((prev) => [...prev, ad]);
      setFormLabel('');
      setFormImageUrl('');
      setFormLinkUrl('');
      setShowForm(false);
    } catch {
      setFormMsg('Failed to create ad.');
    } finally {
      setFormSaving(false);
    }
  };

  const handleToggle = async (ad: LocalAd) => {
    if (togglingId === ad._id) return;
    setTogglingId(ad._id);
    try {
      const updated = await localAdsService.toggle(ad._id);
      setAds((prev) => prev.map((a) => (a._id === ad._id ? updated : a)));
    } finally {
      setTogglingId(null);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this ad?')) return;
    setDeletingId(id);
    try {
      await localAdsService.remove(id);
      setAds((prev) => prev.filter((a) => a._id !== id));
    } catch {
      setError('Failed to delete ad.');
    } finally {
      setDeletingId(null);
    }
  };

  const startEdit = (ad: LocalAd) => {
    setEditingId(ad._id);
    setEditLabel(ad.label);
    setEditLinkUrl(ad.linkUrl);
  };

  const handleSaveEdit = async (id: string) => {
    setEditSaving(true);
    try {
      const updated = await localAdsService.update(id, {
        label: editLabel.trim(),
        linkUrl: editLinkUrl.trim(),
      });
      setAds((prev) => prev.map((a) => (a._id === id ? updated : a)));
      setEditingId(null);
    } catch {
      setError('Failed to update ad.');
    } finally {
      setEditSaving(false);
    }
  };

  const handleMoveUp = async (index: number) => {
    if (index === 0) return;
    const reordered = [...ads];
    [reordered[index - 1], reordered[index]] = [reordered[index], reordered[index - 1]];
    setAds(reordered);
    await localAdsService.reorder(reordered.map((a) => a._id));
  };

  const handleMoveDown = async (index: number) => {
    if (index === ads.length - 1) return;
    const reordered = [...ads];
    [reordered[index], reordered[index + 1]] = [reordered[index + 1], reordered[index]];
    setAds(reordered);
    await localAdsService.reorder(reordered.map((a) => a._id));
  };

  const activeCount = ads.filter((a) => a.isActive).length;

  const [hoveredAdId, setHoveredAdId] = useState<string | null>(null);

  const glass: React.CSSProperties = {
    background: 'rgba(255,255,255,0.70)',
    backdropFilter: 'blur(14px)',
    WebkitBackdropFilter: 'blur(14px)',
    borderRadius: '20px',
    border: '1px solid rgba(255,255,255,0.45)',
    boxShadow: '0 12px 32px rgba(0,0,0,0.05)',
    marginBottom: '24px',
  };

  const moInput: React.CSSProperties = {
    padding: '9px 14px',
    border: '1px solid rgba(0,0,0,0.10)',
    borderRadius: '12px',
    fontSize: '13.5px',
    background: '#fff',
    outline: 'none',
    boxSizing: 'border-box' as const,
    width: '100%',
  };

  const fieldLabel: React.CSSProperties = {
    display: 'block',
    fontSize: '11px',
    fontWeight: 700,
    color: '#888',
    textTransform: 'uppercase' as const,
    letterSpacing: '0.5px',
    marginBottom: '6px',
  };

  const actionBtn = (bg: string, color: string, border?: string): React.CSSProperties => ({
    padding: '5px 12px',
    background: bg,
    color,
    border: border ?? 'none',
    borderRadius: '8px',
    fontSize: '12px',
    fontWeight: 600,
    cursor: 'pointer',
    transition: 'opacity 0.12s',
  });

  return (
    <AdminLayout>
      <style>{`
        @keyframes fadeUp { from { opacity:0; transform:translateY(14px); } to { opacity:1; transform:translateY(0); } }
        @keyframes spin   { to { transform:rotate(360deg); } }
        .ad-fade-1 { animation: fadeUp 0.35s ease both; }
        .ad-fade-2 { animation: fadeUp 0.35s 0.06s ease both; }
        .ad-fade-3 { animation: fadeUp 0.35s 0.12s ease both; }
      `}</style>

      {/* ── Page Header ── */}
      <div className="ad-fade-1" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '28px', gap: '16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
          <div style={{
            width: '50px', height: '50px', borderRadius: '14px', flexShrink: 0,
            background: 'linear-gradient(135deg, #F59E0B, #EC4899)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: '22px', boxShadow: '0 6px 18px rgba(236,72,153,0.28)',
          }}>◎</div>
          <div>
            <h1 style={{ margin: 0, fontSize: '22px', fontWeight: 800, color: '#1a1a2e', letterSpacing: '-0.4px' }}>Local Ads</h1>
            <p style={{ margin: '3px 0 0', fontSize: '13px', color: '#999' }}>
              Upload banner ads, set click URLs, and toggle on/off. Active ads rotate in the mobile app.
            </p>
          </div>
        </div>
        <button
          onClick={() => { setShowForm((v) => !v); setFormMsg(''); }}
          style={{
            flexShrink: 0,
            padding: '10px 22px',
            borderRadius: '12px',
            fontWeight: 700,
            fontSize: '13.5px',
            cursor: 'pointer',
            transition: 'all 0.15s',
            background: showForm ? 'rgba(0,0,0,0.06)' : 'linear-gradient(135deg, #8B5CF6, #EC4899)',
            color: showForm ? '#555' : '#fff',
            border: showForm ? '1px solid rgba(0,0,0,0.10)' : 'none',
            boxShadow: showForm ? 'none' : '0 4px 14px rgba(139,92,246,0.38)',
          }}
        >
          {showForm ? '✕ Cancel' : '+ New Ad'}
        </button>
      </div>

      {/* ── Error Banner ── */}
      {error && (
        <div style={{ ...glass, padding: '14px 20px', background: 'rgba(254,226,226,0.85)', border: '1px solid rgba(239,68,68,0.22)', fontSize: '13.5px', color: '#b91c1c' }}>
          {error}
        </div>
      )}

      {/* ── New Ad Form ── */}
      {showForm && (
        <div style={{ ...glass, border: '1px solid rgba(139,92,246,0.20)' }}>
          <div style={{ padding: '18px 24px 14px', borderBottom: '1px solid rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div style={{ width: '4px', height: '18px', borderRadius: '3px', background: 'linear-gradient(180deg,#8B5CF6,#EC4899)', flexShrink: 0 }} />
            <span style={{ fontWeight: 700, fontSize: '15px', color: '#1a1a2e' }}>New Ad</span>
          </div>
          <div style={{ padding: '20px 24px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            {/* Label */}
            <div>
              <label style={fieldLabel}>Label *</label>
              <input type="text" value={formLabel} onChange={(e) => setFormLabel(e.target.value)}
                placeholder="e.g. Summer Promo" style={moInput} />
            </div>
            {/* Click URL */}
            <div>
              <label style={fieldLabel}>Click URL</label>
              <input type="text" value={formLinkUrl} onChange={(e) => setFormLinkUrl(e.target.value)}
                placeholder="https://yoursite.com" style={moInput} />
            </div>
            {/* Banner Image */}
            <div style={{ gridColumn: '1 / -1' }}>
              <label style={fieldLabel}>Banner Image *</label>
              {formImageUrl && (
                <div style={{ marginBottom: '10px', display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <img src={resolveImageUrl(formImageUrl)} alt="Preview"
                    style={{ height: '52px', maxWidth: '280px', objectFit: 'contain', borderRadius: '10px', border: '1px solid rgba(0,0,0,0.08)' }} />
                  <button onClick={() => setFormImageUrl('')}
                    style={actionBtn('rgba(239,68,68,0.08)', '#ef4444', '1px solid rgba(239,68,68,0.25)')}>Remove</button>
                </div>
              )}
              <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                <input ref={fileInputRef} type="file" accept="image/*" onChange={handleUploadImage} style={{ display: 'none' }} />
                <button disabled={formUploading} onClick={() => fileInputRef.current?.click()}
                  style={actionBtn('rgba(0,0,0,0.05)', '#444', '1px solid rgba(0,0,0,0.10)')}>
                  {formUploading ? 'Uploading…' : '↑ Upload'}
                </button>
                <span style={{ color: '#ccc', fontSize: '12px' }}>or paste URL →</span>
                <input type="text" value={formImageUrl} onChange={(e) => setFormImageUrl(e.target.value)}
                  placeholder="https://example.com/banner.jpg"
                  style={{ ...moInput, fontFamily: 'monospace', fontSize: '12px' }} />
              </div>
            </div>
            {/* Feedback message */}
            {formMsg && (
              <div style={{ gridColumn: '1 / -1', fontSize: '12.5px', fontWeight: 500, color: formMsg.includes('fail') || formMsg.includes('required') ? '#ef4444' : '#10b981' }}>
                {formMsg}
              </div>
            )}
            {/* Submit */}
            <div style={{ gridColumn: '1 / -1' }}>
              <button onClick={handleCreate} disabled={formSaving} style={{
                padding: '10px 26px',
                background: 'linear-gradient(135deg, #8B5CF6, #EC4899)',
                color: '#fff', border: 'none', borderRadius: '12px',
                fontWeight: 700, fontSize: '13.5px',
                cursor: formSaving ? 'not-allowed' : 'pointer',
                opacity: formSaving ? 0.65 : 1,
                boxShadow: '0 4px 14px rgba(139,92,246,0.32)',
                transition: 'all 0.15s',
              }}>
                {formSaving ? 'Creating…' : 'Create Ad'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── Stats Row ── */}
      <div className="ad-fade-2" style={{ display: 'flex', gap: '16px', marginBottom: '24px' }}>
        {([
          { label: 'Total Ads',  value: ads.length,                color: '#8B5CF6' },
          { label: 'Active',     value: activeCount,               color: '#10B981' },
          { label: 'Paused',     value: ads.length - activeCount,  color: '#6B7280' },
        ] as { label: string; value: number; color: string }[]).map(({ label, value, color }) => (
          <div key={label} style={{
            flex: 1,
            background: 'rgba(255,255,255,0.72)',
            backdropFilter: 'blur(14px)',
            WebkitBackdropFilter: 'blur(14px)',
            border: '1px solid rgba(255,255,255,0.45)',
            borderRadius: '16px',
            padding: '16px 20px',
            boxShadow: '0 4px 16px rgba(0,0,0,0.04)',
          }}>
            <div style={{ fontSize: '11px', fontWeight: 700, color: '#aaa', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: '6px' }}>{label}</div>
            <div style={{ fontSize: '28px', fontWeight: 800, color, lineHeight: 1 }}>{value}</div>
          </div>
        ))}
      </div>

      {/* ── Ad Cards Section ── */}
      <div className="ad-fade-3" style={{ ...glass, padding: 0, overflow: 'hidden' }}>
        {/* Section header */}
        <div style={{ padding: '18px 24px 14px', borderBottom: '1px solid rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ width: '4px', height: '18px', borderRadius: '3px', background: 'linear-gradient(180deg,#F59E0B,#EC4899)', flexShrink: 0 }} />
          <span style={{ fontWeight: 700, fontSize: '15px', color: '#1a1a2e' }}>All Ads</span>
          <span style={{ fontSize: '12px', color: '#bbb', marginLeft: '2px' }}>{ads.length} total · {activeCount} active</span>
        </div>

        {/* Body */}
        <div style={{ padding: '16px' }}>
          {loading ? (
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px', padding: '52px', color: '#bbb' }}>
              <span style={{ fontSize: '20px', animation: 'spin 1s linear infinite', display: 'inline-block' }}>◌</span>
              Loading…
            </div>
          ) : ads.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px' }}>
              <div style={{ fontSize: '42px', marginBottom: '12px', opacity: 0.22 }}>◎</div>
              <div style={{ color: '#bbb', fontSize: '14px' }}>No ads yet. Click &quot;+ New Ad&quot; to create one.</div>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {ads.map((ad, index) => {
                const hov = hoveredAdId === ad._id;
                return (
                  <div
                    key={ad._id}
                    onMouseEnter={() => setHoveredAdId(ad._id)}
                    onMouseLeave={() => setHoveredAdId(null)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '16px',
                      padding: '14px 16px',
                      background: hov
                        ? 'rgba(255,255,255,0.96)'
                        : ad.isActive
                          ? 'rgba(16,185,129,0.04)'
                          : 'rgba(255,255,255,0.60)',
                      border: `1px solid ${ad.isActive ? 'rgba(16,185,129,0.18)' : 'rgba(0,0,0,0.07)'}`,
                      borderRadius: '14px',
                      transition: 'all 0.15s ease',
                      transform: hov ? 'scale(1.01)' : 'scale(1)',
                      boxShadow: hov ? '0 6px 20px rgba(0,0,0,0.07)' : '0 1px 3px rgba(0,0,0,0.03)',
                    }}
                  >
                    {/* Thumbnail */}
                    <div style={{ flexShrink: 0 }}>
                      {ad.imageUrl ? (
                        <img
                          src={resolveImageUrl(ad.imageUrl)}
                          alt={ad.label}
                          style={{ width: '92px', height: '46px', objectFit: 'cover', borderRadius: '10px', border: '1px solid rgba(0,0,0,0.07)' }}
                        />
                      ) : (
                        <div style={{ width: '92px', height: '46px', background: 'rgba(0,0,0,0.05)', borderRadius: '10px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '11px', color: '#ccc' }}>
                          No image
                        </div>
                      )}
                    </div>

                    {/* Info / inline edit */}
                    <div style={{ flex: 1, minWidth: 0 }}>
                      {editingId === ad._id ? (
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '7px' }}>
                          <input
                            value={editLabel}
                            onChange={(e) => setEditLabel(e.target.value)}
                            placeholder="Label"
                            style={{ ...moInput, fontSize: '13px', padding: '6px 10px' }}
                          />
                          <input
                            value={editLinkUrl}
                            onChange={(e) => setEditLinkUrl(e.target.value)}
                            placeholder="Click URL"
                            style={{ ...moInput, fontSize: '12px', padding: '6px 10px', fontFamily: 'monospace' }}
                          />
                          <div style={{ display: 'flex', gap: '7px' }}>
                            <button
                              onClick={() => handleSaveEdit(ad._id)}
                              disabled={editSaving}
                              style={actionBtn('#10B981', '#fff')}
                            >
                              {editSaving ? 'Saving…' : 'Save'}
                            </button>
                            <button
                              onClick={() => setEditingId(null)}
                              style={actionBtn('rgba(0,0,0,0.05)', '#555', '1px solid rgba(0,0,0,0.10)')}
                            >
                              Cancel
                            </button>
                          </div>
                        </div>
                      ) : (
                        <>
                          <div style={{ fontWeight: 700, fontSize: '14px', color: '#1a1a2e', marginBottom: '3px' }}>
                            {ad.label}
                          </div>
                          {ad.linkUrl && (
                            <div style={{ fontSize: '12px', color: '#aaa', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                              🔗 {ad.linkUrl}
                            </div>
                          )}
                        </>
                      )}
                    </div>

                    {/* Status chip */}
                    <span style={{
                      flexShrink: 0,
                      padding: '4px 11px',
                      borderRadius: '20px',
                      fontSize: '11.5px',
                      fontWeight: 700,
                      background: ad.isActive ? 'rgba(16,185,129,0.12)' : 'rgba(107,114,128,0.10)',
                      color: ad.isActive ? '#059669' : '#6B7280',
                    }}>
                      {ad.isActive ? 'Active' : 'Disabled'}
                    </span>

                    {/* Actions */}
                    <div style={{ display: 'flex', gap: '6px', flexShrink: 0, alignItems: 'center' }}>
                      {/* Reorder arrows */}
                      <div style={{ display: 'flex', flexDirection: 'column', gap: '2px' }}>
                        <button
                          onClick={() => handleMoveUp(index)}
                          disabled={index === 0}
                          title="Move up"
                          style={{ padding: '3px 7px', background: 'none', border: '1px solid rgba(0,0,0,0.09)', borderRadius: '6px', cursor: index === 0 ? 'not-allowed' : 'pointer', color: '#bbb', fontSize: '10px', opacity: index === 0 ? 0.3 : 1 }}
                        >▲</button>
                        <button
                          onClick={() => handleMoveDown(index)}
                          disabled={index === ads.length - 1}
                          title="Move down"
                          style={{ padding: '3px 7px', background: 'none', border: '1px solid rgba(0,0,0,0.09)', borderRadius: '6px', cursor: index === ads.length - 1 ? 'not-allowed' : 'pointer', color: '#bbb', fontSize: '10px', opacity: index === ads.length - 1 ? 0.3 : 1 }}
                        >▼</button>
                      </div>
                      {/* Toggle */}
                      <button
                        onClick={() => handleToggle(ad)}
                        disabled={togglingId === ad._id}
                        style={actionBtn(
                          ad.isActive ? 'rgba(107,114,128,0.08)' : 'rgba(16,185,129,0.10)',
                          ad.isActive ? '#6B7280' : '#059669',
                          `1px solid ${ad.isActive ? 'rgba(107,114,128,0.20)' : 'rgba(16,185,129,0.25)'}`,
                        )}
                      >
                        {togglingId === ad._id ? '…' : ad.isActive ? 'Disable' : 'Enable'}
                      </button>
                      {/* Edit */}
                      {editingId !== ad._id && (
                        <button
                          onClick={() => startEdit(ad)}
                          style={actionBtn('rgba(0,0,0,0.05)', '#444', '1px solid rgba(0,0,0,0.10)')}
                        >Edit</button>
                      )}
                      {/* Delete */}
                      <button
                        onClick={() => handleDelete(ad._id)}
                        disabled={deletingId === ad._id}
                        style={actionBtn('rgba(239,68,68,0.07)', '#ef4444', '1px solid rgba(239,68,68,0.20)')}
                      >
                        {deletingId === ad._id ? '…' : 'Delete'}
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
