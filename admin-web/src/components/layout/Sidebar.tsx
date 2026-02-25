'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useState } from 'react';
import { authService } from '@/services/auth.service';

const NAV_ITEMS = [
  { href: '/dashboard', label: 'Dashboard', emoji: '⊞' },
  { href: '/modes',     label: 'Modes',     emoji: '◈' },
  { href: '/packs',     label: 'Packs',     emoji: '⊛' },
  { href: '/cards',     label: 'Cards',     emoji: '◉' },
  { href: '/ads',       label: 'Ads',       emoji: '◎' },
  { href: '/config',    label: 'Config',    emoji: '⊙' },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const [hoveredHref, setHoveredHref] = useState<string | null>(null);
  const [logoutHovered, setLogoutHovered] = useState(false);

  const handleLogout = () => {
    authService.logout();
    router.push('/login');
  };

  return (
    <>
      <style>{`
        @keyframes sidebarFadeIn {
          from { opacity: 0; transform: translateX(-10px); }
          to   { opacity: 1; transform: translateX(0); }
        }
      `}</style>

      <aside
        style={{
          width: '236px',
          minHeight: '100vh',
          height: '100vh',
          background: 'linear-gradient(180deg, #141422 0%, #1B1B2F 60%, #111827 100%)',
          borderRight: '1px solid rgba(255,255,255,0.05)',
          display: 'flex',
          flexDirection: 'column',
          padding: '28px 0 24px',
          flexShrink: 0,
          position: 'sticky',
          top: 0,
          zIndex: 10,
          animation: 'sidebarFadeIn 0.3s ease both',
        }}
      >

        {/* ── Brand Header ── */}
        <div style={{ padding: '0 18px 28px' }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: '11px' }}>
            <div style={{
              width: '38px', height: '38px', borderRadius: '11px',
              background: 'linear-gradient(135deg, #8B5CF6, #EC4899)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: '20px',
              boxShadow: '0 0 30px rgba(139,92,246,0.25), 0 4px 14px rgba(139,92,246,0.4)',
            }}>🃏</div>
            <div>
              <div style={{ fontWeight: 700, fontSize: '14.5px', color: 'rgba(255,255,255,0.95)', letterSpacing: '0.15px', lineHeight: 1.2 }}>
                Challenge Cards
              </div>
              <div style={{ fontSize: '10.5px', fontWeight: 500, color: 'rgba(255,255,255,0.4)', marginTop: '2px', letterSpacing: '0.8px', textTransform: 'uppercase' }}>
                Admin Panel
              </div>
            </div>
          </div>
        </div>

        {/* ── Divider ── */}
        <div style={{ height: '1px', background: 'rgba(255,255,255,0.06)', margin: '0 18px 20px' }} />

        {/* ── Nav ── */}
        <nav style={{ flex: '0 0 auto', padding: '0 10px', display: 'flex', flexDirection: 'column', gap: '3px' }}>
          {NAV_ITEMS.map(({ href, label, emoji }) => {
            const active = pathname === href || pathname.startsWith(href + '/');
            const hovered = hoveredHref === href;

            return (
              <Link
                key={href}
                href={href}
                onMouseEnter={() => setHoveredHref(href)}
                onMouseLeave={() => setHoveredHref(null)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '10px',
                  padding: '10px 13px',
                  borderRadius: '10px',
                  textDecoration: 'none',
                  fontSize: '13.5px',
                  fontWeight: active ? 600 : 400,
                  letterSpacing: '0.15px',
                  transition: 'all 150ms ease-out',
                  /* Colors */
                  color: active ? '#ffffff' : 'rgba(255,255,255,0.65)',
                  /* Background */
                  background: active
                    ? 'linear-gradient(135deg, #8B5CF6, #EC4899)'
                    : hovered
                    ? 'rgba(255,255,255,0.05)'
                    : 'transparent',
                  /* Active glow */
                  boxShadow: active
                    ? '0 6px 18px rgba(236,72,153,0.25)'
                    : 'none',
                  /* Hover lift */
                  transform: hovered && !active ? 'scale(1.02)' : 'scale(1)',
                }}
              >
                <span style={{
                  fontSize: '15px',
                  lineHeight: 1,
                  opacity: active ? 1 : 0.6,
                  transition: 'opacity 150ms ease-out',
                }}>
                  {emoji}
                </span>
                {label}
              </Link>
            );
          })}
        </nav>

        {/* ── Spacer + Divider ── */}
        <div style={{ height: '1px', background: 'rgba(255,255,255,0.06)', margin: '24px 18px 20px' }} />

        {/* ── Sign Out ── */}
        <div style={{ padding: '0 10px' }}>
          <button
            onClick={handleLogout}
            onMouseEnter={() => setLogoutHovered(true)}
            onMouseLeave={() => setLogoutHovered(false)}
            style={{
              width: '100%',
              padding: '10px 13px',
              background: logoutHovered ? 'rgba(239,68,68,0.15)' : 'rgba(239,68,68,0.08)',
              border: '1px solid rgba(239,68,68,0.3)',
              borderRadius: '10px',
              color: '#F87171',
              cursor: 'pointer',
              fontSize: '13.5px',
              fontWeight: 500,
              letterSpacing: '0.15px',
              transition: 'all 150ms ease-out',
              textAlign: 'left',
              display: 'flex',
              alignItems: 'center',
              gap: '9px',
              transform: logoutHovered ? 'scale(1.02)' : 'scale(1)',
            }}
          >
            {/* Logout icon (arrow out of box) */}
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
              <polyline points="16 17 21 12 16 7" />
              <line x1="21" y1="12" x2="9" y2="12" />
            </svg>
            Sign Out
          </button>
        </div>

      </aside>
    </>
  );
}
