'use client';

import { useState } from 'react';
import AdminLayout from '@/components/layout/AdminLayout';
import ModeForm from '@/components/modes/ModeForm';
import { useModes } from '@/hooks/useModes';
import { useConfig } from '@/hooks/useConfig';
import { GameMode } from '@/types';
import { CreateGameModePayload } from '@/services/modes.service';
import { PageHeader, TableShell, THead, TRow, td, Badge, Btn, Modal, ConfirmModal, EmptyState, LoadingState, SlugChip, AlertBanner, pageFadeIn } from '@/components/shared/ui';

type ModalState = { mode: 'create' } | { mode: 'edit'; gameMode: GameMode };

export default function ModesPage() {
  const { modes, loading, error, createMode, updateMode, deleteMode } = useModes();
  const { config } = useConfig();
  const languages = config?.supportedLanguages ?? [];
  const [modal, setModal] = useState<ModalState | null>(null);
  const [formLoading, setFormLoading] = useState(false);
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);

  const handleSubmit = async (payload: CreateGameModePayload) => {
    setFormLoading(true);
    try {
      if (modal?.mode === 'edit') await updateMode(modal.gameMode._id, payload);
      else await createMode(payload);
      setModal(null);
    } finally {
      setFormLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    await deleteMode(id);
    setDeleteConfirm(null);
  };

  return (
    <AdminLayout>
      <style>{pageFadeIn}</style>

      <PageHeader
        icon="◈"
        title="Game Modes"
        subtitle={`${modes.length} mode${modes.length !== 1 ? 's' : ''} configured`}
        accent="linear-gradient(135deg, #8B5CF6, #06B6D4)"
        action={<Btn onClick={() => setModal({ mode: 'create' })}>+ New Mode</Btn>}
      />

      {error && <AlertBanner message={error} type="error" />}

      {loading ? (
        <LoadingState />
      ) : modes.length === 0 ? (
        <TableShell title="Game Modes" count={0}>
          <EmptyState icon="◈" message="No modes yet." action={<Btn onClick={() => setModal({ mode: 'create' })}>Create your first mode</Btn>} />
        </TableShell>
      ) : (
        <TableShell title="Game Modes" count={modes.length}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px' }}>
            <THead cols={['Name', 'Slug', 'Description', 'Sort', 'Status', 'Actions']} />
            <tbody>
              {modes.map((m) => (
                <TRow key={m._id} id={m._id}>
                  <td style={{ ...td, fontWeight: 600, color: '#1f1b3a' }}>
                    <div>{m.name['en'] ?? Object.values(m.name)[0]}</div>
                    <div style={{ fontSize: '12px', color: '#9ca3af', marginTop: '2px' }}>{m.name['th'] ?? Object.values(m.name)[1] ?? ''}</div>
                  </td>
                  <td style={td}><SlugChip value={m.slug} /></td>
                  <td style={{ ...td, color: '#6b7280', maxWidth: '240px' }}>
                    <div style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{m.description['en'] ?? Object.values(m.description)[0]}</div>
                  </td>
                  <td style={{ ...td, color: '#6b7280' }}>{m.sortOrder}</td>
                  <td style={td}><Badge variant={m.isActive ? 'active' : 'inactive'} /></td>
                  <td style={td}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <Btn variant="ghost" size="sm" onClick={() => setModal({ mode: 'edit', gameMode: m })}>Edit</Btn>
                      <Btn variant="danger" size="sm" onClick={() => setDeleteConfirm(m._id)}>Delete</Btn>
                    </div>
                  </td>
                </TRow>
              ))}
            </tbody>
          </table>
        </TableShell>
      )}

      {modal && (
        <Modal title={modal.mode === 'edit' ? 'Edit Mode' : 'New Mode'} onClose={() => setModal(null)}>
          <ModeForm
            initial={modal.mode === 'edit' ? modal.gameMode : undefined}
            languages={languages}
            onSubmit={handleSubmit}
            onCancel={() => setModal(null)}
            loading={formLoading}
          />
        </Modal>
      )}

      {deleteConfirm && (
        <ConfirmModal
          message="This action cannot be undone. Packs using this mode will retain the slug value."
          onConfirm={() => handleDelete(deleteConfirm)}
          onCancel={() => setDeleteConfirm(null)}
        />
      )}
    </AdminLayout>
  );
}
