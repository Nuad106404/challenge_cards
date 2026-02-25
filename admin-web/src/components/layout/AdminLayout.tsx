'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { getToken } from '@/services/api';
import Sidebar from './Sidebar';

interface AdminLayoutProps {
  children: React.ReactNode;
}

export default function AdminLayout({ children }: AdminLayoutProps) {
  const router = useRouter();

  useEffect(() => {
    if (!getToken()) {
      router.replace('/login');
    }
  }, [router]);

  return (
    <div
      style={{
        display: 'flex',
        minHeight: '100vh',
        background: 'linear-gradient(160deg, #F5F3FF 0%, #FDF2F8 50%, #FFF7ED 100%)',
        position: 'relative',
      }}
    >
      {/* Noise texture overlay */}
      <div
        style={{
          position: 'fixed',
          inset: 0,
          backgroundImage:
            'url("data:image/svg+xml,%3Csvg viewBox=\'0 0 256 256\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cfilter id=\'noise\'%3E%3CfeTurbulence type=\'fractalNoise\' baseFrequency=\'0.9\' numOctaves=\'4\' stitchTiles=\'stitch\'/%3E%3C/filter%3E%3Crect width=\'100%25\' height=\'100%25\' filter=\'url(%23noise)\' opacity=\'0.04\'/%3E%3C/svg%3E")',
          backgroundRepeat: 'repeat',
          backgroundSize: '128px 128px',
          pointerEvents: 'none',
          zIndex: 0,
        }}
      />
      <Sidebar />
      <main
        style={{
          flex: 1,
          padding: '40px 40px 40px 36px',
          overflowY: 'auto',
          position: 'relative',
          zIndex: 1,
        }}
      >
        {children}
      </main>
    </div>
  );
}
