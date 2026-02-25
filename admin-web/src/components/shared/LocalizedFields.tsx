'use client';

import React from 'react';
import { SupportedLanguage } from '@/types';

interface LocalizedFieldsProps {
  label: string;
  languages: SupportedLanguage[];
  values: Record<string, string>;
  onChange: (code: string, value: string) => void;
  multiline?: boolean;
  required?: boolean;
  fieldStyle: React.CSSProperties;
  labelStyle: React.CSSProperties;
}

export default function LocalizedFields({
  label,
  languages,
  values,
  onChange,
  multiline = false,
  required = false,
  fieldStyle,
  labelStyle,
}: LocalizedFieldsProps) {
  const langs = languages.length > 0 ? languages : [{ code: 'en', label: 'English' }];
  const colCount = Math.min(langs.length, 2);
  const gridStyle: React.CSSProperties = {
    display: 'grid',
    gridTemplateColumns: `repeat(${colCount}, 1fr)`,
    gap: '12px',
  };

  return (
    <div>
      <div style={{ ...labelStyle, marginBottom: '8px', fontSize: '12px', textTransform: 'uppercase', letterSpacing: '0.5px', color: '#999' }}>
        {label}
      </div>
      <div style={gridStyle}>
        {langs.map((lang) => (
          <div key={lang.code}>
            <label style={labelStyle}>
              {lang.label} <span style={{ fontFamily: 'monospace', fontSize: '11px', color: '#aaa' }}>({lang.code})</span>
              {required && ' *'}
            </label>
            {multiline ? (
              <textarea
                style={{ ...fieldStyle, minHeight: '72px', resize: 'vertical' }}
                value={values[lang.code] ?? ''}
                onChange={(e) => onChange(lang.code, e.target.value)}
                required={required}
              />
            ) : (
              <input
                style={fieldStyle}
                value={values[lang.code] ?? ''}
                onChange={(e) => onChange(lang.code, e.target.value)}
                required={required}
              />
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
