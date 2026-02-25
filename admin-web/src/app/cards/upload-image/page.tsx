'use client';

import React, { useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import AdminLayout from '@/components/layout/AdminLayout';
import { usePacks } from '@/hooks/usePacks';
import { uploadsService } from '@/services/uploads.service';
import { formInput, formLabel } from '@/components/shared/ui';

export default function UploadImageCardPage() {
  const router = useRouter();
  const { packs } = usePacks();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string>('');
  const [uploading, setUploading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const [packId, setPackId] = useState('');
  const [type, setType] = useState<'question' | 'dare' | 'vote' | 'punishment' | 'bonus' | 'minigame'>('question');
  const [tags, setTags] = useState<string[]>([]);
  const [tagInput, setTagInput] = useState('');
  const [difficulty, setDifficulty] = useState<'easy' | 'medium' | 'hard'>('medium');
  const [ageRating, setAgeRating] = useState<'all' | '18+'>('all');
  const [status, setStatus] = useState<'draft' | 'review' | 'published'>('draft');

  const [uploadedFileInfo, setUploadedFileInfo] = useState<any>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    if (!selectedFile) return;

    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (!allowedTypes.includes(selectedFile.type)) {
      setError('Invalid file type. Only JPG, PNG, and WebP are allowed.');
      return;
    }

    if (selectedFile.size > 5 * 1024 * 1024) {
      setError('File size must be less than 5MB.');
      return;
    }

    setFile(selectedFile);
    setError('');
    
    const reader = new FileReader();
    reader.onloadend = () => {
      setPreview(reader.result as string);
    };
    reader.readAsDataURL(selectedFile);
  };

  const handleUpload = async () => {
    if (!file) {
      setError('Please select a file');
      return;
    }

    setUploading(true);
    setError('');

    try {
      const fileInfo = await uploadsService.uploadCardImage(file);
      setUploadedFileInfo(fileInfo);
      setError('');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to upload image');
    } finally {
      setUploading(false);
    }
  };

  const handleAddTag = () => {
    const tag = tagInput.trim();
    if (tag && !tags.includes(tag)) {
      setTags([...tags, tag]);
      setTagInput('');
    }
  };

  const handleRemoveTag = (tagToRemove: string) => {
    setTags(tags.filter(t => t !== tagToRemove));
  };

  const handleSubmit = async () => {
    if (!uploadedFileInfo) {
      setError('Please upload an image first');
      return;
    }

    if (!packId) {
      setError('Please select a pack');
      return;
    }

    setSaving(true);
    setError('');

    try {
      await uploadsService.createImageCard({
        packId,
        type,
        tags,
        difficulty,
        ageRating,
        status,
        imageUrl: uploadedFileInfo.url,
        imageMeta: {
          width: uploadedFileInfo.width,
          height: uploadedFileInfo.height,
          size: uploadedFileInfo.size,
          mime: uploadedFileInfo.mime,
        },
      });

      router.push('/cards');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Failed to create card');
    } finally {
      setSaving(false);
    }
  };

  const [dragOver, setDragOver] = useState(false);

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setDragOver(false);
    const dropped = e.dataTransfer.files?.[0];
    if (!dropped) return;
    const synth = { target: { files: e.dataTransfer.files } } as unknown as React.ChangeEvent<HTMLInputElement>;
    handleFileChange(synth);
  };

  const fi = formInput;
  const fl = formLabel;

  return (
    <AdminLayout>
      <style>{`
        @keyframes fadeUp { from { opacity:0; transform:translateY(12px); } to { opacity:1; transform:translateY(0); } }
        @keyframes spin   { to { transform:rotate(360deg); } }
        .up-fade { animation: fadeUp 0.3s ease both; }
      `}</style>

      {/* ── Page Header ── */}
      <div className="up-fade" style={{ display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '28px' }}>
        <div style={{ width: '50px', height: '50px', borderRadius: '14px', background: 'linear-gradient(135deg, #10B981, #06B6D4)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '22px', boxShadow: '0 6px 18px rgba(16,185,129,0.28)', flexShrink: 0 }}>📤</div>
        <div>
          <h1 style={{ margin: 0, fontSize: '22px', fontWeight: 800, color: '#1a1a2e', letterSpacing: '-0.4px' }}>Upload Card Image</h1>
          <p style={{ margin: '3px 0 0', fontSize: '13px', color: '#999' }}>Upload an image and fill in card metadata — the card is created on submit</p>
        </div>
      </div>

      {/* ── Step indicators ── */}
      <div className="up-fade" style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '28px' }}>
        {(['Upload Image', 'Card Details', 'Create'] as const).map((label, i) => {
          const done = i === 0 ? !!uploadedFileInfo : i === 1 ? (!!uploadedFileInfo && !!packId) : false;
          const active = i === 0 ? !uploadedFileInfo : i === 1 ? !!uploadedFileInfo : false;
          return (
            <React.Fragment key={label}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '7px' }}>
                <div style={{ width: '24px', height: '24px', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '11px', fontWeight: 800, background: done ? 'linear-gradient(135deg,#10B981,#06B6D4)' : active ? 'linear-gradient(135deg,#8B5CF6,#EC4899)' : 'rgba(0,0,0,0.06)', color: (done || active) ? '#fff' : '#bbb', flexShrink: 0 }}>
                  {done ? '✓' : i + 1}
                </div>
                <span style={{ fontSize: '12.5px', fontWeight: 600, color: active ? '#8B5CF6' : done ? '#10B981' : '#bbb' }}>{label}</span>
              </div>
              {i < 2 && <div style={{ flex: 1, height: '1px', background: done ? 'rgba(16,185,129,0.3)' : 'rgba(0,0,0,0.06)', maxWidth: '40px' }} />}
            </React.Fragment>
          );
        })}
      </div>

      {/* ── Error Banner ── */}
      {error && (
        <div style={{ padding: '12px 16px', background: 'rgba(239,68,68,0.08)', border: '1px solid rgba(239,68,68,0.2)', borderRadius: '12px', color: '#dc2626', fontSize: '13.5px', marginBottom: '20px' }}>
          ⚠ {error}
        </div>
      )}

      {/* ── Main Content: 2-column layout ── */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', alignItems: 'start' }}>

        {/* ── LEFT: Upload zone ── */}
        <div style={{ background: 'rgba(255,255,255,0.70)', backdropFilter: 'blur(14px)', WebkitBackdropFilter: 'blur(14px)', borderRadius: '20px', border: '1px solid rgba(255,255,255,0.45)', boxShadow: '0 12px 32px rgba(0,0,0,0.05)', overflow: 'hidden' }}>
          <div style={{ padding: '16px 20px 12px', borderBottom: '1px solid rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ width: '4px', height: '16px', borderRadius: '3px', background: 'linear-gradient(180deg,#10B981,#06B6D4)', flexShrink: 0 }} />
            <span style={{ fontWeight: 700, fontSize: '14px', color: '#1a1a2e' }}>
              {uploadedFileInfo ? '✓ Image Uploaded' : 'Step 1 — Select Image'}
            </span>
          </div>
          <div style={{ padding: '20px' }}>
            <input ref={fileInputRef} type="file" accept="image/jpeg,image/jpg,image/png,image/webp" onChange={handleFileChange} style={{ display: 'none' }} />

            {/* Drag-drop zone */}
            {!preview && (
              <div
                onDragOver={(e) => { e.preventDefault(); setDragOver(true); }}
                onDragLeave={() => setDragOver(false)}
                onDrop={handleDrop}
                onClick={() => fileInputRef.current?.click()}
                style={{
                  border: `2px dashed ${dragOver ? '#8B5CF6' : 'rgba(0,0,0,0.12)'}`,
                  borderRadius: '14px',
                  padding: '40px 20px',
                  textAlign: 'center',
                  cursor: 'pointer',
                  background: dragOver ? 'rgba(139,92,246,0.04)' : 'rgba(0,0,0,0.015)',
                  transition: 'all 0.15s',
                  marginBottom: '14px',
                }}
              >
                <div style={{ fontSize: '36px', marginBottom: '10px', opacity: 0.4 }}>🖼️</div>
                <div style={{ fontSize: '14px', fontWeight: 600, color: '#555', marginBottom: '4px' }}>Drop image here or click to browse</div>
                <div style={{ fontSize: '12px', color: '#bbb' }}>JPG, PNG, WebP · Max 5 MB</div>
              </div>
            )}

            {/* Preview */}
            {preview && (
              <div style={{ marginBottom: '14px' }}>
                <img src={preview} alt="Preview" style={{ width: '100%', maxHeight: '240px', objectFit: 'contain', borderRadius: '12px', border: '1px solid rgba(0,0,0,0.08)', background: '#fafafa' }} />
                {file && (
                  <div style={{ marginTop: '8px', padding: '8px 12px', background: 'rgba(0,0,0,0.03)', borderRadius: '8px', fontSize: '12px', color: '#888' }}>
                    <strong style={{ color: '#444' }}>{file.name}</strong> · {(file.size / 1024).toFixed(1)} KB
                  </div>
                )}
              </div>
            )}

            {/* Buttons row */}
            <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
              <button onClick={() => fileInputRef.current?.click()}
                style={{ padding: '9px 18px', background: 'rgba(0,0,0,0.05)', border: '1px solid rgba(0,0,0,0.10)', borderRadius: '10px', cursor: 'pointer', fontSize: '13px', fontWeight: 600, color: '#555' }}>
                {file ? '↺ Change File' : '↑ Select File'}
              </button>
              {file && !uploadedFileInfo && (
                <button onClick={handleUpload} disabled={uploading}
                  style={{ padding: '9px 18px', background: 'linear-gradient(135deg,#10B981,#06B6D4)', border: 'none', borderRadius: '10px', cursor: uploading ? 'not-allowed' : 'pointer', fontSize: '13px', fontWeight: 700, color: '#fff', opacity: uploading ? 0.65 : 1, boxShadow: '0 4px 12px rgba(16,185,129,0.3)', transition: 'all 0.15s', display: 'flex', alignItems: 'center', gap: '6px' }}>
                  {uploading ? (
                    <><span style={{ display: 'inline-block', animation: 'spin 0.8s linear infinite' }}>◌</span> Uploading…</>
                  ) : '↑ Upload Image'}
                </button>
              )}
            </div>

            {/* Upload success chip */}
            {uploadedFileInfo && (
              <div style={{ marginTop: '12px', padding: '10px 14px', background: 'rgba(16,185,129,0.08)', border: '1px solid rgba(16,185,129,0.22)', borderRadius: '10px', fontSize: '13px', color: '#065f46', fontWeight: 600 }}>
                ✓ Uploaded · {uploadedFileInfo.width}×{uploadedFileInfo.height}px
              </div>
            )}
          </div>
        </div>

        {/* ── RIGHT: Card Metadata ── */}
        <div style={{ background: 'rgba(255,255,255,0.70)', backdropFilter: 'blur(14px)', WebkitBackdropFilter: 'blur(14px)', borderRadius: '20px', border: '1px solid rgba(255,255,255,0.45)', boxShadow: '0 12px 32px rgba(0,0,0,0.05)', overflow: 'hidden' }}>
          <div style={{ padding: '16px 20px 12px', borderBottom: '1px solid rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ width: '4px', height: '16px', borderRadius: '3px', background: 'linear-gradient(180deg,#8B5CF6,#EC4899)', flexShrink: 0 }} />
            <span style={{ fontWeight: 700, fontSize: '14px', color: '#1a1a2e' }}>Step 2 — Card Details</span>
          </div>
          <div style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
            {/* Pack */}
            <div>
              <label style={fl}>Pack *</label>
              <select style={fi} value={packId} onChange={(e) => setPackId(e.target.value)}>
                <option value="">— Select a pack —</option>
                {packs.map((pack) => (
                  <option key={pack._id} value={pack._id}>{pack.title.en || pack.slug}</option>
                ))}
              </select>
            </div>

            {/* Type + Status */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
              <div>
                <label style={fl}>Type *</label>
                <select style={fi} value={type} onChange={(e) => setType(e.target.value as typeof type)}>
                  <option value="question">Question</option>
                  <option value="dare">Dare</option>
                  <option value="vote">Vote</option>
                  <option value="punishment">Punishment</option>
                  <option value="bonus">Bonus</option>
                  <option value="minigame">Minigame</option>
                </select>
              </div>
              <div>
                <label style={fl}>Status</label>
                <select style={fi} value={status} onChange={(e) => setStatus(e.target.value as typeof status)}>
                  <option value="draft">Draft</option>
                  <option value="review">Review</option>
                  <option value="published">Published</option>
                </select>
              </div>
            </div>

            {/* Difficulty + Age */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
              <div>
                <label style={fl}>Difficulty</label>
                <select style={fi} value={difficulty} onChange={(e) => setDifficulty(e.target.value as typeof difficulty)}>
                  <option value="easy">Easy</option>
                  <option value="medium">Medium</option>
                  <option value="hard">Hard</option>
                </select>
              </div>
              <div>
                <label style={fl}>Age Rating</label>
                <select style={fi} value={ageRating} onChange={(e) => setAgeRating(e.target.value as typeof ageRating)}>
                  <option value="all">All Ages</option>
                  <option value="18+">18+</option>
                </select>
              </div>
            </div>

            {/* Tags */}
            <div>
              <label style={fl}>Tags</label>
              <div style={{ display: 'flex', gap: '8px', marginBottom: '8px' }}>
                <input style={{ ...fi, flex: 1 }} type="text" value={tagInput} onChange={(e) => setTagInput(e.target.value)}
                  onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); handleAddTag(); } }}
                  placeholder="Type tag and press Enter" />
                <button type="button" onClick={handleAddTag}
                  style={{ padding: '9px 14px', background: 'rgba(139,92,246,0.08)', border: '1px solid rgba(139,92,246,0.2)', borderRadius: '10px', cursor: 'pointer', fontSize: '13px', fontWeight: 600, color: '#8B5CF6', whiteSpace: 'nowrap' }}>
                  + Add
                </button>
              </div>
              {tags.length > 0 && (
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
                  {tags.map((tag) => (
                    <span key={tag} style={{ display: 'inline-flex', alignItems: 'center', gap: '5px', padding: '4px 10px', background: 'rgba(139,92,246,0.08)', border: '1px solid rgba(139,92,246,0.18)', borderRadius: '20px', fontSize: '12px', color: '#6d28d9', fontWeight: 600 }}>
                      {tag}
                      <button type="button" onClick={() => handleRemoveTag(tag)}
                        style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#a78bfa', fontSize: '14px', lineHeight: 1, padding: '0 1px' }}>×</button>
                    </span>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* ── Footer Actions ── */}
      <div style={{ display: 'flex', gap: '12px', marginTop: '24px', justifyContent: 'flex-end' }}>
        <button onClick={() => router.push('/cards')}
          style={{ padding: '11px 24px', background: '#fff', border: '1px solid rgba(0,0,0,0.12)', borderRadius: '12px', cursor: 'pointer', fontSize: '14px', fontWeight: 600, color: '#555' }}>
          Cancel
        </button>
        <button onClick={handleSubmit} disabled={!uploadedFileInfo || saving}
          style={{ padding: '11px 28px', background: (!uploadedFileInfo || saving) ? 'rgba(0,0,0,0.08)' : 'linear-gradient(135deg,#8B5CF6,#EC4899)', border: 'none', borderRadius: '12px', cursor: (!uploadedFileInfo || saving) ? 'not-allowed' : 'pointer', fontSize: '14px', fontWeight: 700, color: (!uploadedFileInfo || saving) ? '#aaa' : '#fff', boxShadow: (!uploadedFileInfo || saving) ? 'none' : '0 4px 16px rgba(139,92,246,0.35)', transition: 'all 0.15s', display: 'flex', alignItems: 'center', gap: '8px' }}>
          {saving ? (
            <><span style={{ display: 'inline-block', animation: 'spin 0.8s linear infinite' }}>◌</span> Creating Card…</>
          ) : '🎴 Upload & Create Card'}
        </button>
      </div>
    </AdminLayout>
  );
}
