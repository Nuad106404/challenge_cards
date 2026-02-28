'use client';

import { usePacks } from '@/hooks/usePacks';
import { useCards } from '@/hooks/useCards';
import { useConfig } from '@/hooks/useConfig';
import { useState } from 'react';

// ── Stat card accent gradients ──────────────────────────────────────────────
const CARD_ACCENTS = [
  'linear-gradient(90deg, #8B5CF6, #EC4899)',
  'linear-gradient(90deg, #EC4899, #F97316)',
  'linear-gradient(90deg, #10B981, #06B6D4)',
  'linear-gradient(90deg, #06B6D4, #8B5CF6)',
  'linear-gradient(90deg, #F59E0B, #EC4899)',
];

interface StatCardProps {
  label: string;
  value: string | number;
  sub?: string;
  accent: string;
  index: number;
}

function StatCard({ label, value, sub, accent, index }: StatCardProps) {
  const [hovered, setHovered] = useState(false);
  return (
    <div
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        background: 'rgba(255,255,255,0.68)',
        backdropFilter: 'blur(8px)',
        WebkitBackdropFilter: 'blur(8px)',
        borderRadius: '20px',
        border: '1px solid rgba(255,255,255,0.5)',
        boxShadow: hovered
          ? '0 16px 40px rgba(0,0,0,0.1), 0 0 0 1px rgba(139,92,246,0.15)'
          : '0 8px 24px rgba(0,0,0,0.06)',
        overflow: 'hidden',
        transform: hovered ? 'translateY(-3px) scale(1.02)' : 'translateY(0) scale(1)',
        transition: 'all 0.22s ease',
        animation: `cardFadeUp 0.4s ease ${index * 0.07}s both`,
        flex: '1 1 170px',
        minWidth: '160px',
      }}
    >
      {/* Top accent bar */}
      <div style={{ height: '3px', background: accent }} />
      <div style={{ padding: '20px 22px 22px' }}>
        <div
          style={{
            fontSize: '32px',
            fontWeight: 700,
            color: '#16103a',
            letterSpacing: '-0.5px',
            lineHeight: 1.1,
          }}
        >
          {value}
        </div>
        <div
          style={{
            fontSize: '13px',
            fontWeight: 600,
            color: '#6b7280',
            marginTop: '6px',
            letterSpacing: '0.2px',
          }}
        >
          {label}
        </div>
        {sub && (
          <div
            style={{
              fontSize: '11px',
              color: '#a78bfa',
              marginTop: '4px',
              fontWeight: 500,
              letterSpacing: '0.1px',
            }}
          >
            {sub}
          </div>
        )}
      </div>
    </div>
  );
}

function StatusBadge({ active }: { active: boolean }) {
  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: '5px',
        padding: '3px 10px',
        borderRadius: '20px',
        fontSize: '12px',
        fontWeight: 600,
        letterSpacing: '0.2px',
        background: active
          ? 'linear-gradient(135deg, rgba(16,185,129,0.15), rgba(6,182,212,0.12))'
          : 'rgba(107,114,128,0.1)',
        color: active ? '#059669' : '#9ca3af',
        border: `1px solid ${active ? 'rgba(16,185,129,0.25)' : 'rgba(107,114,128,0.15)'}`,
      }}
    >
      <span
        style={{
          width: '5px',
          height: '5px',
          borderRadius: '50%',
          background: active ? '#10b981' : '#9ca3af',
          display: 'inline-block',
        }}
      />
      {active ? 'Active' : 'Inactive'}
    </span>
  );
}

export default function DashboardPage() {
  const { packs } = usePacks();
  const { cards } = useCards();
  const { config } = useConfig();
  const [hoveredRow, setHoveredRow] = useState<string | null>(null);

  const activePacks = packs.filter((p) => p.isActive).length;
  const publishedCards = cards.filter((c) => c.status === 'published').length;
  const draftCards = cards.filter((c) => c.status === 'draft').length;

  const stats: Array<{ label: string; value: string | number; sub?: string }> = [
    { label: 'Total Packs', value: packs.length, sub: `${activePacks} active` },
    { label: 'Total Cards', value: cards.length, sub: `${publishedCards} published` },
    { label: 'Draft Cards', value: draftCards },
    { label: 'Content Version', value: config?.contentVersion ?? '—' },
    { label: 'Ads Enabled', value: config?.adsEnabled ? 'Yes' : 'No' },
  ];

  return (
    <>
      <style>{`
        @keyframes cardFadeUp {
          from { opacity: 0; transform: translateY(12px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes tableFadeIn {
          from { opacity: 0; transform: translateY(8px); }
          to   { opacity: 1; transform: translateY(0); }
        }
      `}</style>

      {/* Page header */}
      <div style={{ marginBottom: '32px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '6px' }}>
          <div
            style={{
              width: '32px',
              height: '32px',
              borderRadius: '10px',
              background: 'linear-gradient(135deg, #8B5CF6, #EC4899)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '16px',
              boxShadow: '0 4px 12px rgba(139,92,246,0.3)',
            }}
          >
            ⊞
          </div>
          <h1
            style={{
              margin: 0,
              fontSize: '22px',
              fontWeight: 700,
              color: '#16103a',
              letterSpacing: '-0.2px',
            }}
          >
            Dashboard
          </h1>
        </div>
        <p style={{ margin: '0 0 0 44px', color: '#9ca3af', fontSize: '13px', letterSpacing: '0.1px' }}>
          Overview of your Challenge Cards content
        </p>
      </div>

      {/* Stat cards */}
      <div
        style={{
          display: 'flex',
          gap: '16px',
          flexWrap: 'wrap',
          marginBottom: '32px',
        }}
      >
        {stats.map((s, i) => (
          <StatCard
            key={s.label}
            label={s.label}
            value={s.value}
            sub={s.sub}
            accent={CARD_ACCENTS[i % CARD_ACCENTS.length]}
            index={i}
          />
        ))}
      </div>

      {/* Recent Packs table */}
      <div
        style={{
          background: 'rgba(255,255,255,0.72)',
          backdropFilter: 'blur(10px)',
          WebkitBackdropFilter: 'blur(10px)',
          borderRadius: '20px',
          border: '1px solid rgba(255,255,255,0.5)',
          boxShadow: '0 8px 32px rgba(0,0,0,0.06)',
          overflow: 'hidden',
          animation: 'tableFadeIn 0.5s ease 0.35s both',
        }}
      >
        {/* Table header bar */}
        <div
          style={{
            padding: '20px 28px 16px',
            borderBottom: '1px solid rgba(0,0,0,0.05)',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
          }}
        >
          <div
            style={{
              width: '6px',
              height: '22px',
              borderRadius: '3px',
              background: 'linear-gradient(180deg, #8B5CF6, #EC4899)',
            }}
          />
          <h2
            style={{
              margin: 0,
              fontSize: '15px',
              fontWeight: 700,
              color: '#16103a',
              letterSpacing: '0.1px',
            }}
          >
            Recent Packs
          </h2>
          <span
            style={{
              marginLeft: 'auto',
              fontSize: '12px',
              color: '#a78bfa',
              fontWeight: 600,
              background: 'rgba(139,92,246,0.08)',
              padding: '3px 10px',
              borderRadius: '20px',
              border: '1px solid rgba(139,92,246,0.15)',
            }}
          >
            {packs.length} total
          </span>
        </div>

        {packs.length === 0 ? (
          <div style={{ padding: '40px 28px', color: '#9ca3af', fontSize: '14px', textAlign: 'center' }}>
            No packs yet.
          </div>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px' }}>
            <thead>
              <tr style={{ background: 'rgba(0,0,0,0.015)' }}>
                {['Title', 'Mode', 'Age Rating', 'Status'].map((h) => (
                  <th
                    key={h}
                    style={{
                      textAlign: 'left',
                      padding: '10px 28px',
                      color: '#9ca3af',
                      fontWeight: 600,
                      fontSize: '11px',
                      letterSpacing: '0.6px',
                      textTransform: 'uppercase',
                      borderBottom: '1px solid rgba(0,0,0,0.05)',
                    }}
                  >
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {packs.slice(0, 8).map((pack) => {
                const isHovered = hoveredRow === pack._id;
                return (
                  <tr
                    key={pack._id}
                    onMouseEnter={() => setHoveredRow(pack._id)}
                    onMouseLeave={() => setHoveredRow(null)}
                    style={{
                      borderBottom: '1px solid rgba(0,0,0,0.04)',
                      background: isHovered ? 'rgba(139,92,246,0.04)' : 'transparent',
                      transition: 'background 0.15s ease',
                    }}
                  >
                    <td
                      style={{
                        padding: '13px 28px',
                        fontWeight: 600,
                        color: '#1f1b3a',
                        letterSpacing: '0.1px',
                      }}
                    >
                      {pack.title['en'] ?? Object.values(pack.title)[0]}
                    </td>
                    <td
                      style={{
                        padding: '13px 28px',
                        color: '#6b7280',
                        textTransform: 'capitalize',
                        letterSpacing: '0.1px',
                      }}
                    >
                      {pack.mode}
                    </td>
                    <td style={{ padding: '13px 28px', color: '#6b7280' }}>
                      {pack.ageRating}
                    </td>
                    <td style={{ padding: '13px 28px' }}>
                      <StatusBadge active={pack.isActive} />
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
    </>
  );
}
