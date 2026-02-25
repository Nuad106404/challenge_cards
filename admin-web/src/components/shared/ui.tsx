'use client';

import { useState } from 'react';

// ── Design tokens ────────────────────────────────────────────────────────────
export const T = {
  purple: '#8B5CF6',
  pink: '#EC4899',
  green: '#10B981',
  amber: '#F59E0B',
  red: '#EF4444',
  cyan: '#06B6D4',
  text: '#16103a',
  textMuted: '#6b7280',
  textFaint: '#9ca3af',
};

// ── Glass card container ─────────────────────────────────────────────────────
export const glassCard: React.CSSProperties = {
  background: 'rgba(255,255,255,0.72)',
  backdropFilter: 'blur(10px)',
  WebkitBackdropFilter: 'blur(10px)',
  borderRadius: '20px',
  border: '1px solid rgba(255,255,255,0.5)',
  boxShadow: '0 8px 32px rgba(0,0,0,0.06)',
  overflow: 'hidden',
};

// ── Page header ──────────────────────────────────────────────────────────────
interface PageHeaderProps {
  icon: string;
  title: string;
  subtitle: string;
  accent?: string;
  action?: React.ReactNode;
}
export function PageHeader({ icon, title, subtitle, accent = `linear-gradient(135deg, ${T.purple}, ${T.pink})`, action }: PageHeaderProps) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: '32px', gap: '16px' }}>
      <div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '6px' }}>
          <div style={{
            width: '32px', height: '32px', borderRadius: '10px',
            background: accent, display: 'flex', alignItems: 'center',
            justifyContent: 'center', fontSize: '16px',
            boxShadow: '0 4px 12px rgba(139,92,246,0.3)', flexShrink: 0,
          }}>{icon}</div>
          <h1 style={{ margin: 0, fontSize: '22px', fontWeight: 700, color: T.text, letterSpacing: '-0.2px' }}>{title}</h1>
        </div>
        <p style={{ margin: '0 0 0 44px', color: T.textFaint, fontSize: '13px', letterSpacing: '0.1px' }}>{subtitle}</p>
      </div>
      {action && <div style={{ flexShrink: 0, paddingTop: '2px' }}>{action}</div>}
    </div>
  );
}

// ── Buttons ──────────────────────────────────────────────────────────────────
type BtnVariant = 'primary' | 'success' | 'danger' | 'ghost' | 'dark';
const BTN_COLORS: Record<BtnVariant, { bg: string; color: string; border?: string }> = {
  primary: { bg: `linear-gradient(135deg, ${T.purple}, ${T.pink})`, color: '#fff' },
  success: { bg: `linear-gradient(135deg, ${T.green}, ${T.cyan})`, color: '#fff' },
  danger:  { bg: `linear-gradient(135deg, ${T.red}, #F97316)`, color: '#fff' },
  dark:    { bg: `linear-gradient(135deg, #1e1b3a, #2d2660)`, color: '#fff' },
  ghost:   { bg: 'rgba(0,0,0,0.04)', color: T.textMuted, border: '1px solid rgba(0,0,0,0.08)' },
};

interface BtnProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: BtnVariant;
  size?: 'sm' | 'md';
}
export function Btn({ variant = 'primary', size = 'md', children, style, disabled, ...rest }: BtnProps) {
  const [hov, setHov] = useState(false);
  const c = BTN_COLORS[variant];
  return (
    <button
      {...rest}
      disabled={disabled}
      onMouseEnter={() => setHov(true)}
      onMouseLeave={() => setHov(false)}
      style={{
        padding: size === 'sm' ? '5px 12px' : '8px 16px',
        border: c.border ?? 'none',
        borderRadius: '10px',
        cursor: disabled ? 'not-allowed' : 'pointer',
        fontSize: size === 'sm' ? '12px' : '13px',
        fontWeight: 600,
        background: disabled ? 'rgba(0,0,0,0.08)' : c.bg,
        color: disabled ? T.textFaint : c.color,
        letterSpacing: '0.2px',
        transition: 'all 0.18s ease',
        transform: hov && !disabled ? 'translateY(-1px) scale(1.02)' : 'none',
        boxShadow: hov && !disabled && variant !== 'ghost' ? '0 4px 14px rgba(139,92,246,0.3)' : 'none',
        opacity: disabled ? 0.6 : 1,
        display: 'inline-flex',
        alignItems: 'center',
        gap: '6px',
        ...style,
      }}
    >
      {children}
    </button>
  );
}

// ── Status badge ─────────────────────────────────────────────────────────────
type BadgeVariant = 'active' | 'inactive' | 'published' | 'draft' | 'review';
const BADGE: Record<BadgeVariant, { bg: string; color: string; dot: string; border: string }> = {
  active:    { bg: 'linear-gradient(135deg,rgba(16,185,129,0.15),rgba(6,182,212,0.12))', color: '#059669', dot: T.green,  border: 'rgba(16,185,129,0.25)' },
  inactive:  { bg: 'rgba(107,114,128,0.08)', color: T.textFaint, dot: '#9ca3af', border: 'rgba(107,114,128,0.15)' },
  published: { bg: 'linear-gradient(135deg,rgba(16,185,129,0.15),rgba(6,182,212,0.12))', color: '#059669', dot: T.green,  border: 'rgba(16,185,129,0.25)' },
  draft:     { bg: 'rgba(107,114,128,0.08)', color: T.textFaint, dot: '#9ca3af', border: 'rgba(107,114,128,0.15)' },
  review:    { bg: 'rgba(245,158,11,0.1)',   color: '#92400e',   dot: T.amber,  border: 'rgba(245,158,11,0.25)' },
};
export function Badge({ variant }: { variant: BadgeVariant }) {
  const s = BADGE[variant];
  const label = variant.charAt(0).toUpperCase() + variant.slice(1);
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: '5px',
      padding: '3px 10px', borderRadius: '20px', fontSize: '12px', fontWeight: 600, letterSpacing: '0.2px',
      background: s.bg, color: s.color, border: `1px solid ${s.border}`,
    }}>
      <span style={{ width: '5px', height: '5px', borderRadius: '50%', background: s.dot, display: 'inline-block' }} />
      {label}
    </span>
  );
}

// ── Table shell ──────────────────────────────────────────────────────────────
export function TableShell({ title, count, children }: { title: string; count: number; children: React.ReactNode }) {
  return (
    <div style={glassCard}>
      <div style={{ padding: '20px 28px 16px', borderBottom: '1px solid rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', gap: '10px' }}>
        <div style={{ width: '5px', height: '22px', borderRadius: '3px', background: `linear-gradient(180deg, ${T.purple}, ${T.pink})` }} />
        <h2 style={{ margin: 0, fontSize: '15px', fontWeight: 700, color: T.text }}>{title}</h2>
        <span style={{ marginLeft: 'auto', fontSize: '12px', color: T.purple, fontWeight: 600, background: 'rgba(139,92,246,0.08)', padding: '3px 10px', borderRadius: '20px', border: `1px solid rgba(139,92,246,0.15)` }}>{count} total</span>
      </div>
      {children}
    </div>
  );
}

// ── Table header row ─────────────────────────────────────────────────────────
export function THead({ cols }: { cols: string[] }) {
  return (
    <thead>
      <tr style={{ background: 'rgba(0,0,0,0.015)' }}>
        {cols.map((h) => (
          <th key={h} style={{ textAlign: 'left', padding: '10px 24px', color: T.textFaint, fontWeight: 600, fontSize: '11px', letterSpacing: '0.6px', textTransform: 'uppercase', borderBottom: '1px solid rgba(0,0,0,0.05)' }}>{h}</th>
        ))}
      </tr>
    </thead>
  );
}

// ── Table row with hover ─────────────────────────────────────────────────────
export function TRow({ id, children }: { id: string; children: React.ReactNode }) {
  const [hov, setHov] = useState(false);
  return (
    <tr onMouseEnter={() => setHov(true)} onMouseLeave={() => setHov(false)}
      style={{ borderBottom: '1px solid rgba(0,0,0,0.04)', background: hov ? 'rgba(139,92,246,0.035)' : 'transparent', transition: 'background 0.15s ease' }}>
      {children}
    </tr>
  );
}

export const td: React.CSSProperties = { padding: '13px 24px' };

// ── Glass section card ────────────────────────────────────────────────────────
export function SectionCard({ title, subtitle, children, accent }: { title: string; subtitle?: string; children: React.ReactNode; accent?: string }) {
  return (
    <div style={{ ...glassCard, marginBottom: '24px' }}>
      <div style={{ padding: '20px 28px 16px', borderBottom: '1px solid rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', gap: '10px' }}>
        <div style={{ width: '5px', height: '22px', borderRadius: '3px', background: accent ?? `linear-gradient(180deg, ${T.purple}, ${T.pink})` }} />
        <div>
          <div style={{ fontSize: '15px', fontWeight: 700, color: T.text }}>{title}</div>
          {subtitle && <div style={{ fontSize: '12px', color: T.textFaint, marginTop: '2px' }}>{subtitle}</div>}
        </div>
      </div>
      <div style={{ padding: '24px 28px' }}>{children}</div>
    </div>
  );
}

// ── Input ────────────────────────────────────────────────────────────────────
export const inputStyle: React.CSSProperties = {
  padding: '9px 13px',
  border: '1px solid rgba(0,0,0,0.12)',
  borderRadius: '10px',
  fontSize: '14px',
  background: 'rgba(255,255,255,0.8)',
  color: T.text,
  outline: 'none',
  transition: 'border-color 0.15s',
  boxSizing: 'border-box',
};

// ── Select ───────────────────────────────────────────────────────────────────
export const selectStyle: React.CSSProperties = {
  ...inputStyle,
  cursor: 'pointer',
};

// ── Label ────────────────────────────────────────────────────────────────────
export const labelStyle: React.CSSProperties = {
  display: 'block',
  fontSize: '12px',
  fontWeight: 600,
  marginBottom: '6px',
  color: T.textMuted,
  letterSpacing: '0.3px',
  textTransform: 'uppercase',
};

// ── Error / Success toast ────────────────────────────────────────────────────
export function AlertBanner({ message, type }: { message: string; type: 'error' | 'success' }) {
  const isError = type === 'error';
  return (
    <div style={{
      padding: '12px 16px', borderRadius: '12px', fontSize: '13px', marginBottom: '20px',
      background: isError ? 'rgba(239,68,68,0.08)' : 'rgba(16,185,129,0.08)',
      border: `1px solid ${isError ? 'rgba(239,68,68,0.2)' : 'rgba(16,185,129,0.2)'}`,
      color: isError ? '#dc2626' : '#059669',
      display: 'flex', alignItems: 'center', gap: '8px',
    }}>
      <span>{isError ? '⚠' : '✓'}</span>
      {message}
    </div>
  );
}

// ── Modal shell ──────────────────────────────────────────────────────────────
export function Modal({ title, onClose, children, maxWidth = 640 }: { title: string; onClose: () => void; children: React.ReactNode; maxWidth?: number }) {
  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(10,8,25,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, padding: '20px', backdropFilter: 'blur(4px)' }}>
      <div style={{
        background: 'rgba(255,255,255,0.97)', backdropFilter: 'blur(20px)',
        borderRadius: '20px', width: '100%', maxWidth, maxHeight: '90vh', overflowY: 'auto',
        boxShadow: '0 24px 64px rgba(0,0,0,0.18)', border: '1px solid rgba(255,255,255,0.6)',
      }}>
        <div style={{ padding: '24px 28px 20px', borderBottom: '1px solid rgba(0,0,0,0.06)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <h2 style={{ margin: 0, fontSize: '17px', fontWeight: 700, color: T.text }}>{title}</h2>
          <button onClick={onClose} style={{ background: 'none', border: 'none', fontSize: '20px', cursor: 'pointer', color: T.textFaint, lineHeight: 1, padding: '2px 6px', borderRadius: '6px' }}>×</button>
        </div>
        <div style={{ padding: '24px 28px' }}>{children}</div>
      </div>
    </div>
  );
}

// ── Confirm delete modal ─────────────────────────────────────────────────────
export function ConfirmModal({ message, onConfirm, onCancel }: { message: string; onConfirm: () => void; onCancel: () => void }) {
  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(10,8,25,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, backdropFilter: 'blur(4px)' }}>
      <div style={{
        background: 'rgba(255,255,255,0.97)', borderRadius: '20px', padding: '32px 28px', maxWidth: '400px', width: '90%',
        boxShadow: '0 24px 64px rgba(0,0,0,0.18)', border: '1px solid rgba(255,255,255,0.6)',
      }}>
        <div style={{ width: '44px', height: '44px', borderRadius: '12px', background: 'rgba(239,68,68,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '22px', marginBottom: '16px' }}>⚠</div>
        <h3 style={{ margin: '0 0 8px', fontSize: '16px', fontWeight: 700, color: T.text }}>Confirm Delete</h3>
        <p style={{ margin: '0 0 24px', color: T.textMuted, fontSize: '14px', lineHeight: 1.6 }}>{message}</p>
        <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
          <Btn variant="ghost" onClick={onCancel}>Cancel</Btn>
          <Btn variant="danger" onClick={onConfirm}>Delete</Btn>
        </div>
      </div>
    </div>
  );
}

// ── Empty state ──────────────────────────────────────────────────────────────
export function EmptyState({ icon, message, action }: { icon: string; message: string; action?: React.ReactNode }) {
  return (
    <div style={{ textAlign: 'center', padding: '60px 20px' }}>
      <div style={{ fontSize: '40px', marginBottom: '12px', opacity: 0.4 }}>{icon}</div>
      <p style={{ color: T.textFaint, fontSize: '15px', margin: '0 0 20px' }}>{message}</p>
      {action}
    </div>
  );
}

// ── Loading state ────────────────────────────────────────────────────────────
export function LoadingState() {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '40px 0', color: T.textFaint, justifyContent: 'center' }}>
      <span style={{ fontSize: '18px', animation: 'spin 1s linear infinite', display: 'inline-block' }}>◌</span>
      Loading…
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}

// ── Toggle switch ────────────────────────────────────────────────────────────
export function Toggle({ value, onChange }: { value: boolean; onChange: (v: boolean) => void }) {
  return (
    <div onClick={() => onChange(!value)} style={{ width: '48px', height: '26px', borderRadius: '13px', background: value ? `linear-gradient(135deg, ${T.purple}, ${T.pink})` : 'rgba(0,0,0,0.15)', cursor: 'pointer', position: 'relative', transition: 'background 0.2s', flexShrink: 0, boxShadow: value ? '0 2px 8px rgba(139,92,246,0.4)' : 'none' }}>
      <div style={{ position: 'absolute', top: '3px', left: value ? '25px' : '3px', width: '20px', height: '20px', borderRadius: '50%', background: '#fff', transition: 'left 0.2s', boxShadow: '0 1px 4px rgba(0,0,0,0.2)' }} />
    </div>
  );
}

// ── Monospace chip (for slugs) ────────────────────────────────────────────────
export function SlugChip({ value }: { value: string }) {
  return (
    <span style={{ fontFamily: 'monospace', fontSize: '12px', background: 'rgba(139,92,246,0.08)', color: T.purple, padding: '3px 8px', borderRadius: '6px', border: '1px solid rgba(139,92,246,0.15)' }}>
      {value}
    </span>
  );
}

// ── Page fade-in animation style ─────────────────────────────────────────────
export const pageFadeIn = `
  @keyframes pageFadeUp {
    from { opacity: 0; transform: translateY(10px); }
    to   { opacity: 1; transform: translateY(0); }
  }
`;

// ── Language Tabs ─────────────────────────────────────────────────────────────
interface LangTabsProps {
  languages: { code: string; label: string }[];
  value: string;
  onChange: (code: string) => void;
}
export function LangTabs({ languages, value, onChange }: LangTabsProps) {
  const langs = languages.length > 0 ? languages : [{ code: 'en', label: 'EN' }];
  return (
    <div style={{ display: 'flex', gap: '4px', marginBottom: '14px', background: 'rgba(0,0,0,0.04)', borderRadius: '10px', padding: '3px' }}>
      {langs.map((l) => {
        const active = l.code === value;
        return (
          <button
            key={l.code}
            type="button"
            onClick={() => onChange(l.code)}
            style={{
              flex: 1,
              padding: '6px 10px',
              borderRadius: '8px',
              border: 'none',
              cursor: 'pointer',
              fontSize: '12px',
              fontWeight: 700,
              letterSpacing: '0.4px',
              textTransform: 'uppercase' as const,
              transition: 'all 0.15s',
              background: active ? `linear-gradient(135deg, ${T.purple}, ${T.pink})` : 'transparent',
              color: active ? '#fff' : T.textMuted,
              boxShadow: active ? '0 2px 8px rgba(139,92,246,0.3)' : 'none',
            }}
          >
            {l.code.toUpperCase()}
          </button>
        );
      })}
    </div>
  );
}

// ── Form section card (inside modals) ────────────────────────────────────────
export function FormSection({ title, hint, children }: { title: string; hint?: string; children: React.ReactNode }) {
  return (
    <div style={{
      background: 'rgba(249,250,251,0.7)',
      border: '1px solid rgba(0,0,0,0.07)',
      borderRadius: '14px',
      padding: '16px 18px',
      marginBottom: '16px',
    }}>
      <div style={{ marginBottom: '12px' }}>
        <div style={{ fontSize: '11px', fontWeight: 700, color: T.textMuted, textTransform: 'uppercase', letterSpacing: '0.5px' }}>{title}</div>
        {hint && <div style={{ fontSize: '11.5px', color: T.textFaint, marginTop: '2px' }}>{hint}</div>}
      </div>
      {children}
    </div>
  );
}

// ── Form input / select shared style ─────────────────────────────────────────
export const formInput: React.CSSProperties = {
  width: '100%',
  padding: '9px 13px',
  border: '1px solid rgba(0,0,0,0.10)',
  borderRadius: '10px',
  fontSize: '13.5px',
  background: '#fff',
  color: T.text,
  outline: 'none',
  boxSizing: 'border-box' as const,
  transition: 'box-shadow 0.15s',
  fontFamily: 'inherit',
};

export const formLabel: React.CSSProperties = {
  display: 'block',
  fontSize: '11px',
  fontWeight: 700,
  color: '#888',
  textTransform: 'uppercase' as const,
  letterSpacing: '0.5px',
  marginBottom: '5px',
};
