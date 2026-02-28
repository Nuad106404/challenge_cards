'use client';

import { useState } from 'react';
import PackForm from '@/components/packs/PackForm';
import { usePacks } from '@/hooks/usePacks';
import { useModes } from '@/hooks/useModes';
import { useConfig } from '@/hooks/useConfig';
import { Pack } from '@/types';
import { CreatePackPayload } from '@/services/packs.service';
import { PageHeader, TableShell, THead, TRow, td, Badge, Btn, Modal, ConfirmModal, EmptyState, LoadingState, SlugChip, AlertBanner, pageFadeIn } from '@/components/shared/ui';

type ModalState = { mode: 'create' } | { mode: 'edit'; pack: Pack };

export default function PacksPage() {
  const { packs, loading, error, createPack, updatePack, deletePack } = usePacks();
  const { modes } = useModes();
  const { config } = useConfig();
  const languages = config?.supportedLanguages ?? [];
  const [modal, setModal] = useState<ModalState | null>(null);
  const [formLoading, setFormLoading] = useState(false);
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);

  const handleSubmit = async (payload: CreatePackPayload) => {
    setFormLoading(true);
    try {
      if (modal?.mode === 'edit') await updatePack(modal.pack._id, payload);
      else await createPack(payload);
      setModal(null);
    } finally {
      setFormLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    await deletePack(id);
    setDeleteConfirm(null);
  };

  return (
    <>
      <style>{pageFadeIn}</style>

      <PageHeader
        icon="⊛"
        title="Packs"
        subtitle={`${packs.length} pack${packs.length !== 1 ? 's' : ''} total`}
        accent="linear-gradient(135deg, #EC4899, #F97316)"
        action={<Btn onClick={() => setModal({ mode: 'create' })}>+ New Pack</Btn>}
      />

      {error && <AlertBanner message={error} type="error" />}

      {loading ? (
        <LoadingState />
      ) : packs.length === 0 ? (
        <TableShell title="Packs" count={0}>
          <EmptyState icon="⊛" message="No packs yet." action={<Btn onClick={() => setModal({ mode: 'create' })}>Create your first pack</Btn>} />
        </TableShell>
      ) : (
        <TableShell title="Packs" count={packs.length}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px' }}>
            <THead cols={['Title', 'Slug', 'Mode', 'Age', 'Sort', 'Status', 'Actions']} />
            <tbody>
              {packs.map((pack) => (
                <TRow key={pack._id} id={pack._id}>
                  <td style={{ ...td, fontWeight: 600, color: '#1f1b3a' }}>
                    <div>{pack.title['en'] ?? Object.values(pack.title)[0]}</div>
                    <div style={{ fontSize: '12px', color: '#9ca3af', marginTop: '2px' }}>{pack.title['th'] ?? Object.values(pack.title)[1] ?? ''}</div>
                  </td>
                  <td style={td}><SlugChip value={pack.slug} /></td>
                  <td style={{ ...td, color: '#6b7280', textTransform: 'capitalize' }}>{pack.mode}</td>
                  <td style={{ ...td, color: '#6b7280' }}>{pack.ageRating}</td>
                  <td style={{ ...td, color: '#6b7280' }}>{pack.sortOrder}</td>
                  <td style={td}><Badge variant={pack.isActive ? 'active' : 'inactive'} /></td>
                  <td style={td}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <Btn variant="ghost" size="sm" onClick={() => setModal({ mode: 'edit', pack })}>Edit</Btn>
                      <Btn variant="danger" size="sm" onClick={() => setDeleteConfirm(pack._id)}>Delete</Btn>
                    </div>
                  </td>
                </TRow>
              ))}
            </tbody>
          </table>
        </TableShell>
      )}

      {modal && (
        <Modal title={modal.mode === 'edit' ? 'Edit Pack' : 'New Pack'} onClose={() => setModal(null)}>
          <PackForm
            initial={modal.mode === 'edit' ? modal.pack : undefined}
            modes={modes}
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
    </>
  );
}
