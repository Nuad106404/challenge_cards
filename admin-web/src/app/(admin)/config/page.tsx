'use client';

import { useState, useEffect } from 'react';
import { useConfig } from '@/hooks/useConfig';
import { SupportedLanguage } from '@/types';
import { Toggle } from '@/components/shared/ui';

export default function ConfigPage() {
  const { config, loading, saving, publishing, error, updateConfig, publish } = useConfig();

  const [adsEnabled, setAdsEnabled] = useState(true);
  const [admobAppId, setAdmobAppId] = useState('');
  const [admobBannerId, setAdmobBannerId] = useState('');
  const [admobInterstitialId, setAdmobInterstitialId] = useState('');
  const [adRotationDuration, setAdRotationDuration] = useState(5);
  const [minAppVersion, setMinAppVersion] = useState('1.0.0');
  const [apiBaseUrl, setApiBaseUrl] = useState('');
  const [supportedLanguages, setSupportedLanguages] = useState<SupportedLanguage[]>([]);
  const [newLangCode, setNewLangCode] = useState('');
  const [newLangLabel, setNewLangLabel] = useState('');
  const [saveMsg, setSaveMsg] = useState('');
  const [publishMsg, setPublishMsg] = useState('');

  useEffect(() => {
    if (config) {
      setAdsEnabled(config.adsEnabled);
      setAdmobAppId(config.admobAppId ?? '');
      setAdmobBannerId(config.admobBannerId ?? '');
      setAdmobInterstitialId(config.admobInterstitialId ?? '');
      setAdRotationDuration(config.adRotationDuration ?? 5);
      setMinAppVersion(config.minAppVersion);
      setApiBaseUrl(config.apiBaseUrl ?? '');
      setSupportedLanguages(config.supportedLanguages ?? []);
    }
  }, [config]);

  const handleSave = async () => {
    setSaveMsg('');
    try {
      await updateConfig({ adsEnabled, admobAppId, admobBannerId, admobInterstitialId, adRotationDuration, minAppVersion, apiBaseUrl, supportedLanguages });
      setSaveMsg('Settings saved successfully.');
    } catch {
      setSaveMsg('Failed to save settings.');
    }
  };

  const addLanguage = () => {
    const code = newLangCode.trim().toLowerCase();
    const label = newLangLabel.trim();
    if (!code || !label) return;
    if (supportedLanguages.some((l) => l.code === code)) return;
    setSupportedLanguages((prev) => [...prev, { code, label }]);
    setNewLangCode('');
    setNewLangLabel('');
  };

  const removeLanguage = (code: string) => {
    setSupportedLanguages((prev) => prev.filter((l) => l.code !== code));
  };

  const handlePublish = async () => {
    setPublishMsg('');
    try {
      const result = await publish();
      setPublishMsg(`Published! Content version is now v${result.contentVersion}. ${result.publishedCards} cards published.`);
    } catch {
      setPublishMsg('Publish failed.');
    }
  };

  const glass: React.CSSProperties = {
    background: 'rgba(255,255,255,0.70)',
    backdropFilter: 'blur(14px)',
    WebkitBackdropFilter: 'blur(14px)',
    borderRadius: '20px',
    border: '1px solid rgba(255,255,255,0.45)',
    boxShadow: '0 12px 32px rgba(0,0,0,0.05)',
    marginBottom: '24px',
    overflow: 'hidden',
  };

  const moInput: React.CSSProperties = {
    padding: '9px 14px',
    border: '1px solid rgba(0,0,0,0.10)',
    borderRadius: '12px',
    fontSize: '13px',
    background: '#fff',
    outline: 'none',
    boxSizing: 'border-box' as const,
    width: '100%',
    fontFamily: 'inherit',
    transition: 'box-shadow 0.15s',
  };

  const monoInput: React.CSSProperties = {
    ...moInput,
    fontFamily: 'monospace',
    fontSize: '12.5px',
  };

  const fieldLabel: React.CSSProperties = {
    display: 'block',
    fontSize: '11px',
    fontWeight: 700,
    color: '#888',
    textTransform: 'uppercase' as const,
    letterSpacing: '0.5px',
    marginBottom: '5px',
  };

  const fieldHint: React.CSSProperties = {
    margin: '0 0 6px',
    fontSize: '12px',
    color: '#aaa',
    lineHeight: 1.5,
  };

  const sectionHead = (accent: string, title: string, subtitle?: string) => (
    <div style={{ padding: '18px 24px 14px', borderBottom: '1px solid rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', gap: '10px' }}>
      <div style={{ width: '4px', height: '18px', borderRadius: '3px', background: accent, flexShrink: 0 }} />
      <div>
        <div style={{ fontWeight: 700, fontSize: '15px', color: '#1a1a2e' }}>{title}</div>
        {subtitle && <div style={{ fontSize: '12px', color: '#aaa', marginTop: '1px' }}>{subtitle}</div>}
      </div>
    </div>
  );

  return (
    <>
      <style>{`
        @keyframes fadeUp { from { opacity:0; transform:translateY(14px); } to { opacity:1; transform:translateY(0); } }
        @keyframes spin   { to { transform:rotate(360deg); } }
        .cfg-s1 { animation: fadeUp 0.35s ease both; }
        .cfg-s2 { animation: fadeUp 0.35s 0.07s ease both; }
        .cfg-s3 { animation: fadeUp 0.35s 0.14s ease both; }
        .cfg-s4 { animation: fadeUp 0.35s 0.21s ease both; }
        .cfg-s5 { animation: fadeUp 0.35s 0.28s ease both; }
      `}</style>

      {/* ── Page Header ── */}
      <div className="cfg-s1" style={{ display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '28px' }}>
        <div style={{
          width: '50px', height: '50px', borderRadius: '14px', flexShrink: 0,
          background: 'linear-gradient(135deg, #06B6D4, #8B5CF6)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: '22px', boxShadow: '0 6px 18px rgba(139,92,246,0.28)',
        }}>⊙</div>
        <div>
          <h1 style={{ margin: 0, fontSize: '22px', fontWeight: 800, color: '#1a1a2e', letterSpacing: '-0.4px' }}>Global Config</h1>
          <p style={{ margin: '3px 0 0', fontSize: '13px', color: '#999' }}>Manage app-wide settings and publish content</p>
        </div>
      </div>

      {error && (
        <div style={{ ...glass, padding: '14px 20px', background: 'rgba(254,226,226,0.85)', border: '1px solid rgba(239,68,68,0.22)', fontSize: '13.5px', color: '#b91c1c' }}>
          {error}
        </div>
      )}

      {loading ? (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px', padding: '80px', color: '#bbb' }}>
          <span style={{ fontSize: '22px', animation: 'spin 1s linear infinite', display: 'inline-block' }}>◌</span>
          Loading…
        </div>
      ) : (
        <>
          {/* ══ SECTION 1 — Monetization ══ */}
          <div className="cfg-s2" style={glass}>
            {sectionHead('linear-gradient(180deg,#8B5CF6,#EC4899)', 'Monetization', 'Ad serving master switch')}
            <div style={{ padding: '20px 24px' }}>
              {/* Ads Enabled toggle row */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px 20px', background: 'rgba(139,92,246,0.04)', borderRadius: '14px', border: '1px solid rgba(139,92,246,0.12)' }}>
                <div>
                  <div style={{ fontSize: '14px', fontWeight: 700, color: '#1a1a2e', marginBottom: '3px' }}>Ads Enabled</div>
                  <div style={{ fontSize: '12px', color: '#aaa' }}>Toggle ads on/off for all users globally</div>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <Toggle value={adsEnabled} onChange={setAdsEnabled} />
                  <span style={{ fontSize: '12.5px', fontWeight: 700, color: adsEnabled ? '#8B5CF6' : '#aaa', minWidth: '28px' }}>
                    {adsEnabled ? 'ON' : 'OFF'}
                  </span>
                </div>
              </div>

              {/* Ad Rotation Duration */}
              <div style={{ marginTop: '20px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div>
                  <label style={fieldLabel}>Ad Rotation Duration (seconds)</label>
                  <p style={fieldHint}>How long each ad shows before rotating to the next.</p>
                  <input
                    type="number" min="1" max="60" value={adRotationDuration}
                    onChange={(e) => setAdRotationDuration(Math.max(1, Math.min(60, parseInt(e.target.value) || 5)))}
                    style={{ ...moInput, width: '120px' }}
                  />
                </div>
              </div>
            </div>
          </div>

          {/* ══ SECTION 2 — Ad IDs ══ */}
          <div className="cfg-s3" style={glass}>
            {sectionHead('linear-gradient(180deg,#06B6D4,#8B5CF6)', 'Ad IDs', 'AdMob unit IDs from the AdMob console')}
            <div style={{ padding: '20px 24px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
              <div style={{ gridColumn: '1 / -1' }}>
                <label style={fieldLabel}>AdMob App ID</label>
                <p style={fieldHint}>App-level ID (ca-app-pub-xxx~xxx). Must also be set in local.properties before building.</p>
                <input type="text" value={admobAppId} onChange={(e) => setAdmobAppId(e.target.value)}
                  placeholder="ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx" style={monoInput} />
              </div>
              <div>
                <label style={fieldLabel}>AdMob Banner ID</label>
                <p style={fieldHint}>Android/iOS banner ad unit ID.</p>
                <input type="text" value={admobBannerId} onChange={(e) => setAdmobBannerId(e.target.value)}
                  placeholder="ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx" style={monoInput} />
              </div>
              <div>
                <label style={fieldLabel}>AdMob Interstitial ID</label>
                <p style={fieldHint}>Android/iOS interstitial ad unit ID.</p>
                <input type="text" value={admobInterstitialId} onChange={(e) => setAdmobInterstitialId(e.target.value)}
                  placeholder="ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx" style={monoInput} />
              </div>
            </div>
          </div>

          {/* ══ SECTION 3 — App Versioning + Save ══ */}
          <div className="cfg-s3" style={glass}>
            {sectionHead('linear-gradient(180deg,#F59E0B,#EC4899)', 'App Versioning', 'Version gate for mobile clients')}
            <div style={{ padding: '20px 24px' }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
                <div style={{ maxWidth: '200px' }}>
                  <label style={fieldLabel}>Min App Version</label>
                  <p style={fieldHint}>Minimum required client version (e.g. 1.2.0).</p>
                  <input
                    type="text"
                    value={minAppVersion}
                    onChange={(e) => setMinAppVersion(e.target.value)}
                    placeholder="1.0.0"
                    style={moInput}
                  />
                </div>
                <div>
                  <label style={fieldLabel}>API Base URL</label>
                  <p style={fieldHint}>Override the bootstrap URL on mobile clients. Leave blank to use the app&apos;s built-in default (from .env).</p>
                  <input
                    type="text"
                    value={apiBaseUrl}
                    onChange={(e) => setApiBaseUrl(e.target.value)}
                    placeholder="https://api.yourdomain.com/api"
                    style={monoInput}
                  />
                </div>
              </div>

              {/* Save feedback */}
              {saveMsg && (
                <div style={{
                  marginTop: '16px',
                  padding: '12px 16px',
                  borderRadius: '12px',
                  fontSize: '13px',
                  fontWeight: 500,
                  background: saveMsg.includes('Failed') ? 'rgba(254,226,226,0.85)' : 'rgba(209,250,229,0.85)',
                  border: `1px solid ${saveMsg.includes('Failed') ? 'rgba(239,68,68,0.22)' : 'rgba(16,185,129,0.22)'}`,
                  color: saveMsg.includes('Failed') ? '#b91c1c' : '#065f46',
                }}>
                  {saveMsg}
                </div>
              )}

              {/* Save button */}
              <div style={{ marginTop: '20px' }}>
                <button
                  onClick={handleSave}
                  disabled={saving}
                  style={{
                    padding: '11px 28px',
                    background: 'linear-gradient(135deg, #8B5CF6, #EC4899)',
                    color: '#fff',
                    border: 'none',
                    borderRadius: '12px',
                    fontWeight: 700,
                    fontSize: '14px',
                    cursor: saving ? 'not-allowed' : 'pointer',
                    opacity: saving ? 0.65 : 1,
                    boxShadow: '0 4px 16px rgba(139,92,246,0.35)',
                    transition: 'all 0.15s',
                  }}
                >
                  {saving ? 'Saving…' : 'Save Settings'}
                </button>
              </div>
            </div>
          </div>

          {/* ══ SECTION 4 — Supported Languages ══ */}
          <div className="cfg-s4" style={glass}>
            {sectionHead('linear-gradient(180deg,#10B981,#06B6D4)', 'Supported Languages', 'Available in the mobile app\'s Settings screen')}
            <div style={{ padding: '20px 24px' }}>
              <p style={{ margin: '0 0 16px', fontSize: '13px', color: '#aaa', lineHeight: 1.6 }}>
                Code must be a valid locale (e.g.{' '}
                <code style={{ fontFamily: 'monospace', background: 'rgba(0,0,0,0.05)', padding: '1px 6px', borderRadius: '5px', fontSize: '12px' }}>en</code>,{' '}
                <code style={{ fontFamily: 'monospace', background: 'rgba(0,0,0,0.05)', padding: '1px 6px', borderRadius: '5px', fontSize: '12px' }}>th</code>,{' '}
                <code style={{ fontFamily: 'monospace', background: 'rgba(0,0,0,0.05)', padding: '1px 6px', borderRadius: '5px', fontSize: '12px' }}>ja</code>).
              </p>

              {/* Language chip cards */}
              {supportedLanguages.length === 0 ? (
                <p style={{ color: '#ccc', fontSize: '13px', margin: '0 0 16px' }}>No languages configured yet.</p>
              ) : (
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px', marginBottom: '20px' }}>
                  {supportedLanguages.map((lang) => (
                    <div
                      key={lang.code}
                      style={{
                        display: 'inline-flex',
                        alignItems: 'center',
                        gap: '8px',
                        padding: '8px 14px',
                        background: 'rgba(16,185,129,0.06)',
                        border: '1px solid rgba(16,185,129,0.18)',
                        borderRadius: '12px',
                        transition: 'background 0.12s',
                      }}
                    >
                      <span style={{ fontFamily: 'monospace', fontSize: '12px', fontWeight: 700, color: '#059669', background: 'rgba(16,185,129,0.12)', padding: '2px 7px', borderRadius: '6px' }}>
                        {lang.code}
                      </span>
                      <span style={{ fontSize: '13.5px', color: '#1a1a2e', fontWeight: 500 }}>{lang.label}</span>
                      <button
                        onClick={() => removeLanguage(lang.code)}
                        style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#ccc', fontSize: '14px', lineHeight: 1, padding: '0 2px' }}
                        title="Remove"
                      >×</button>
                    </div>
                  ))}
                </div>
              )}

              {/* Add language row */}
              <div style={{ display: 'flex', gap: '10px', alignItems: 'flex-end', flexWrap: 'wrap' }}>
                <div>
                  <label style={fieldLabel}>Code</label>
                  <input
                    style={{ ...moInput, width: '80px' }}
                    value={newLangCode}
                    onChange={(e) => setNewLangCode(e.target.value)}
                    placeholder="en"
                    maxLength={10}
                    onKeyDown={(e) => e.key === 'Enter' && addLanguage()}
                  />
                </div>
                <div>
                  <label style={fieldLabel}>Label</label>
                  <input
                    style={{ ...moInput, width: '200px' }}
                    value={newLangLabel}
                    onChange={(e) => setNewLangLabel(e.target.value)}
                    placeholder="English"
                    onKeyDown={(e) => e.key === 'Enter' && addLanguage()}
                  />
                </div>
                <button
                  onClick={addLanguage}
                  disabled={!newLangCode.trim() || !newLangLabel.trim()}
                  style={{
                    padding: '9px 18px',
                    background: 'linear-gradient(135deg, #10B981, #06B6D4)',
                    color: '#fff',
                    border: 'none',
                    borderRadius: '12px',
                    fontWeight: 700,
                    fontSize: '13px',
                    cursor: !newLangCode.trim() || !newLangLabel.trim() ? 'not-allowed' : 'pointer',
                    opacity: !newLangCode.trim() || !newLangLabel.trim() ? 0.5 : 1,
                    boxShadow: '0 3px 10px rgba(16,185,129,0.28)',
                    transition: 'all 0.15s',
                  }}
                >+ Add</button>
              </div>
              <p style={{ margin: '12px 0 0', fontSize: '12px', color: '#bbb' }}>
                Click <strong style={{ color: '#888' }}>Save Settings</strong> above to persist language changes.
              </p>
            </div>
          </div>

          {/* ══ SECTION 5 — Content Publish ══ */}
          <div className="cfg-s4" style={glass}>
            {sectionHead('linear-gradient(180deg,#F59E0B,#EC4899)', 'Content Version', `Current: v${config?.contentVersion ?? '—'}`)}
            <div style={{ padding: '20px 24px' }}>
              <p style={{ margin: '0 0 16px', fontSize: '13px', color: '#888', lineHeight: 1.7 }}>
                Publishing marks all <strong style={{ color: '#555' }}>review</strong>-status cards as published and bumps the content version.
                The mobile app uses this version to know when to refresh its local cache.
              </p>
              {publishMsg && (
                <div style={{
                  marginBottom: '16px',
                  padding: '12px 16px',
                  borderRadius: '12px',
                  fontSize: '13px',
                  fontWeight: 500,
                  background: publishMsg.includes('failed') ? 'rgba(254,226,226,0.85)' : 'rgba(209,250,229,0.85)',
                  border: `1px solid ${publishMsg.includes('failed') ? 'rgba(239,68,68,0.22)' : 'rgba(16,185,129,0.22)'}`,
                  color: publishMsg.includes('failed') ? '#b91c1c' : '#065f46',
                }}>
                  {publishMsg}
                </div>
              )}
              <button
                onClick={handlePublish}
                disabled={publishing}
                style={{
                  padding: '11px 26px',
                  background: 'linear-gradient(135deg, #1a1a2e, #374151)',
                  color: '#fff',
                  border: 'none',
                  borderRadius: '12px',
                  fontWeight: 700,
                  fontSize: '14px',
                  cursor: publishing ? 'not-allowed' : 'pointer',
                  opacity: publishing ? 0.65 : 1,
                  boxShadow: '0 4px 16px rgba(0,0,0,0.18)',
                  transition: 'all 0.15s',
                }}
              >
                {publishing ? 'Publishing…' : '🚀 Publish All Content'}
              </button>
            </div>
          </div>

          {/* ══ SECTION 6 — Config Summary ══ */}
          <div className="cfg-s5" style={glass}>
            {sectionHead('linear-gradient(180deg,#06B6D4,#8B5CF6)', 'Config Summary')}
            <div style={{ padding: '4px 24px 8px' }}>
              {([
                ['Ads Enabled',      config?.adsEnabled ? 'Yes' : 'No'],
                ['Content Version',  `v${config?.contentVersion ?? '—'}`],
                ['Min App Version',  config?.minAppVersion ?? '—'],
                ['API Base URL',     config?.apiBaseUrl || '(default from .env)'],
                ['Last Updated',     config?.updatedAt ? new Date(config.updatedAt).toLocaleString() : '—'],
              ] as [string, string][]).map(([key, val]) => (
                <div key={key} style={{ display: 'flex', alignItems: 'center', padding: '13px 0', borderBottom: '1px solid rgba(0,0,0,0.05)' }}>
                  <span style={{ width: '200px', fontSize: '13px', color: '#aaa', fontWeight: 600 }}>{key}</span>
                  <span style={{ fontSize: '13.5px', color: '#1a1a2e', fontWeight: 500 }}>{val}</span>
                </div>
              ))}
            </div>
          </div>
        </>
      )}
    </>
  );
}
