'use client';

import { useState } from 'react';
import Link from 'next/link';
import AdminLayout from '@/components/layout/AdminLayout';
import CardForm from '@/components/cards/CardForm';
import { usePacks } from '@/hooks/usePacks';
import { useCards } from '@/hooks/useCards';
import { useConfig } from '@/hooks/useConfig';
import { Card } from '@/types';
import { CreateCardPayload } from '@/services/cards.service';
import { PageHeader, TableShell, THead, TRow, td, Badge, Btn, Modal, ConfirmModal, EmptyState, LoadingState, AlertBanner, selectStyle, pageFadeIn, T } from '@/components/shared/ui';

type ModalState = { mode: 'create' } | { mode: 'edit'; card: Card };

export default function CardsPage() {
  const { packs } = usePacks();
  const { cards, loading, error, createCard, updateCard, patchCard, deleteCard } = useCards();
  const { config } = useConfig();
  const languages = config?.supportedLanguages ?? [];
  const [modal, setModal] = useState<ModalState | null>(null);
  const [formLoading, setFormLoading] = useState(false);
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);
  const [filterPack, setFilterPack] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [togglingId, setTogglingId] = useState<string | null>(null);

  const handleSubmit = async (payload: CreateCardPayload) => {
    setFormLoading(true);
    try {
      if (modal?.mode === 'edit') await updateCard(modal.card._id, payload);
      else await createCard(payload);
      setModal(null);
    } finally {
      setFormLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    await deleteCard(id);
    setDeleteConfirm(null);
  };

  const handleToggleStatus = async (card: Card) => {
    if (togglingId === card._id) return;
    const next = card.status === 'published' ? 'draft' : 'published';
    setTogglingId(card._id);
    try {
      await patchCard(card._id, { status: next });
    } finally {
      setTogglingId(null);
    }
  };

  const getPackName = (packId: string | { _id: string; title?: Record<string, string> }) => {
    if (typeof packId === 'object') {
      const t = packId.title;
      return t ? (t['en'] ?? Object.values(t)[0] ?? packId._id) : packId._id;
    }
    const p = packs.find((pk) => pk._id === packId);
    return p ? (p.title['en'] ?? Object.values(p.title)[0] ?? packId) : packId;
  };

  const filtered = cards.filter((c) => {
    const packId = typeof c.packId === 'object' ? c.packId._id : c.packId;
    if (filterPack && packId !== filterPack) return false;
    if (filterStatus && c.status !== filterStatus) return false;
    return true;
  });

  const statusVariant = (s: string) =>
    s === 'published' ? 'published' : s === 'review' ? 'review' : 'draft';

  return (
    <AdminLayout>
      <style>{pageFadeIn}</style>

      <PageHeader
        icon="◉"
        title="Cards"
        subtitle={`${filtered.length} of ${cards.length} cards`}
        accent="linear-gradient(135deg, #10B981, #06B6D4)"
        action={
          <div style={{ display: 'flex', gap: '10px' }}>
            <Link href="/cards/upload-image" style={{ textDecoration: 'none' }}>
              <Btn variant="success">📤 Upload Image</Btn>
            </Link>
            <Btn onClick={() => setModal({ mode: 'create' })}>+ New Card</Btn>
          </div>
        }
      />

      {/* Filters */}
      <div style={{ display: 'flex', gap: '12px', marginBottom: '24px' }}>
        <select style={{ ...selectStyle, width: '200px' }} value={filterPack} onChange={(e) => setFilterPack(e.target.value)}>
          <option value="">All Packs</option>
          {packs.map((p) => <option key={p._id} value={p._id}>{p.title['en'] ?? Object.values(p.title)[0] ?? p.slug}</option>)}
        </select>
        <select style={{ ...selectStyle, width: '160px' }} value={filterStatus} onChange={(e) => setFilterStatus(e.target.value)}>
          <option value="">All Statuses</option>
          <option value="draft">Draft</option>
          <option value="review">Review</option>
          <option value="published">Published</option>
        </select>
      </div>

      {error && <AlertBanner message={error} type="error" />}

      {loading ? (
        <LoadingState />
      ) : filtered.length === 0 ? (
        <TableShell title="Cards" count={0}>
          <EmptyState icon="◉" message="No cards found." action={<Btn onClick={() => setModal({ mode: 'create' })}>Create your first card</Btn>} />
        </TableShell>
      ) : (
        <TableShell title="Cards" count={filtered.length}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px' }}>
            <THead cols={['Content', 'Pack', 'Type', 'Difficulty', 'Age', 'Status', 'Actions']} />
            <tbody>
              {filtered.map((card) => (
                <TRow key={card._id} id={card._id}>
                  <td style={{ ...td, maxWidth: '260px' }}>
                    {card.contentSource === 'image' && card.imageUrl ? (
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <img
                          src={card.imageUrl}
                          alt="Card preview"
                          style={{ width: '52px', height: '52px', objectFit: 'cover', borderRadius: '10px', border: '1px solid rgba(0,0,0,0.08)' }}
                        />
                        <div>
                          <div style={{ fontSize: '12px', color: T.green, fontWeight: 700, marginBottom: '2px' }}>Image Card</div>
                          <div style={{ fontSize: '11px', color: T.textFaint }}>{card.imageMeta?.width}×{card.imageMeta?.height}</div>
                        </div>
                      </div>
                    ) : (
                      <div>
                        <div style={{ fontWeight: 600, color: '#1f1b3a', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{card.text['en'] ?? Object.values(card.text)[0]}</div>
                        <div style={{ fontSize: '12px', color: T.textFaint, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', marginTop: '2px' }}>{card.text['th'] ?? Object.values(card.text)[1] ?? ''}</div>
                      </div>
                    )}
                  </td>
                  <td style={{ ...td, color: T.textMuted, fontSize: '13px' }}>{getPackName(card.packId)}</td>
                  <td style={{ ...td, color: T.textMuted, textTransform: 'capitalize' }}>{card.type}</td>
                  <td style={{ ...td, color: T.textMuted, textTransform: 'capitalize' }}>{card.difficulty}</td>
                  <td style={{ ...td, color: T.textMuted }}>{card.ageRating}</td>
                  <td style={td}>
                    <button
                      onClick={() => handleToggleStatus(card)}
                      disabled={togglingId === card._id}
                      title={card.status === 'published' ? 'Click to set Draft' : 'Click to Publish'}
                      style={{ background: 'none', border: 'none', padding: 0, cursor: 'pointer', opacity: togglingId === card._id ? 0.4 : 1 }}
                    >
                      <Badge variant={statusVariant(togglingId === card._id ? '…' : card.status) as 'published' | 'draft' | 'review'} />
                    </button>
                  </td>
                  <td style={td}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <Btn variant="ghost" size="sm" onClick={() => setModal({ mode: 'edit', card })}>Edit</Btn>
                      <Btn variant="danger" size="sm" onClick={() => setDeleteConfirm(card._id)}>Delete</Btn>
                    </div>
                  </td>
                </TRow>
              ))}
            </tbody>
          </table>
        </TableShell>
      )}

      {modal && (
        <Modal title={modal.mode === 'edit' ? 'Edit Card' : 'New Card'} onClose={() => setModal(null)}>
          <CardForm
            initial={modal.mode === 'edit' ? modal.card : undefined}
            packs={packs}
            languages={languages}
            onSubmit={handleSubmit}
            onCancel={() => setModal(null)}
            loading={formLoading}
          />
        </Modal>
      )}

      {deleteConfirm && (
        <ConfirmModal
          message="This action cannot be undone."
          onConfirm={() => handleDelete(deleteConfirm)}
          onCancel={() => setDeleteConfirm(null)}
        />
      )}
    </AdminLayout>
  );
}
