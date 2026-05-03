// primitives.jsx — Life Legacy design tokens + shared UI primitives
// Uses the Notion-inspired palette.

const LL = {
  bg: '#FFFFFF',
  bgAlt: '#F7F7F5',
  text: '#37352F',
  textSec: '#6B6B6B',
  textPh: '#9B9A97',
  border: '#E9E9E7',
  cta: '#2F3437',
  success: '#4DAB9A',
  warning: '#CB912F',
  error: '#D44C47',
  warnBg: '#FFFBF0',
  warnBorder: '#FDE68A',
  successBg: '#F0FAF8',
  highlight: '#FEF9C3',

  font: '"Inter", -apple-system, BlinkMacSystemFont, system-ui, "Segoe UI", sans-serif',
  W: 390,
  H: 844,
};

// Global stylesheet for screen styles inside
if (typeof document !== 'undefined' && !document.getElementById('ll-styles')) {
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = '[https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap](https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap)';
  document.head.appendChild(link);

  const style = document.createElement('style');
  style.id = 'll-styles';
  style.innerHTML = `
    .ll-border { border-color: #E9E9E7; }
    .ll-surface-alt { background: #F7F7F5; }
    .ll-text-primary { color: #37352F; }
    .ll-text-sec { color: #6B6B6B; }
    .ll-text-ph { color: #9B9A97; }
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(12px); }
      to { opacity: 1; transform: translateY(0); }
    }
    .ll-fade-in { animation: fadeIn 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
    .ll-pressable:active { opacity: 0.84; }
  `;
  document.head.appendChild(style);
}

const T = {
  sectionLabel: {
    fontFamily: LL.font,
    fontSize: 11,
    fontWeight: 600,
    textTransform: 'uppercase',
    letterSpacing: '0.03em',
    color: LL.textPh,
  },
  caption: {
    fontFamily: LL.font,
    fontSize: 11,
    color: LL.textPh,
  }
};

const Icon = {
  lock: (size, color) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <rect x="3" y="11" width="18" height="11" rx="2" />
      <path d="M7 11V7a5 5 0 0110 0v4" />
    </svg>
  ),
  bookOpen: (size, color) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2zM22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z" />
    </svg>
  ),
  bookMarked: (size, color) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2z" />
    </svg>
  ),
  search: (size, color) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="11" cy="11" r="8" />
      <path d="M21 21l-4.35-4.35" />
    </svg>
  ),
  chevRight: (size) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={LL.textPh} strokeWidth="2">
      <path d="M9 18l6-6-6-6" />
    </svg>
  ),
  download: (size, color) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M7 10l5 5 5-5M12 15V3" />
    </svg>
  ),
  arrow: (size) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={LL.text} strokeWidth="2">
      <path d="M19 12H5M12 19l-7-7 7-7" />
    </svg>
  ),
  key: (size, color) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <path d="M21 2l-6 6M21 8l-6-6M8 12a4 4 0 100-8 4 4 0 000 8zM2 20a16 16 0 0116-16" />
    </svg>
  ),
  pencil: (size, color) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2">
      <path d="M12 20h9M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z" />
    </svg>
  ),
  volume: (size) => (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={LL.textSec} strokeWidth="2">
      <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
      <path d="M15.54 8.46a5 5 0 010 7.07M19.07 4.93a10 10 0 010 14.14" />
    </svg>
  ),
};

function AIBubble({ children, time }) {
  return (
    <div style={{ maxWidth: '76%', alignSelf: 'flex-start', marginBottom: 2 }}>
      <div className="ll-surface-alt" style={{
        background: LL.bgAlt, borderRadius: 12, padding: '10px 12px',
        fontSize: 15, color: LL.text, lineHeight: 1.5,
      }}>{children}</div>
      {time && <div style={{ ...T.caption, marginTop: 4, marginLeft: 4 }}>{time}</div>}
    </div>
  );
}

function UserBubble({ children, time }) {
  return (
    <div style={{ maxWidth: '76%', alignSelf: 'flex-end', marginBottom: 2 }}>
      <div style={{
        background: LL.cta, color: '#fff', borderRadius: 12, padding: '10px 12px',
        fontSize: 15, lineHeight: 1.5,
      }}>{children}</div>
      {time && <div style={{ ...T.caption, textAlign: 'right', marginTop: 4, marginRight: 4 }}>{time}</div>}
    </div>
  );
}