// DesignCanvas.jsx — Figma-ish design canvas wrapper
// Warm gray grid bg + Sections + Artboards + PostIt notes.
// Artboards are reorderable (grip-drag), labels/titles are inline-editable,
// and any artboard can be opened in a fullscreen focus overlay (←/→/Esc).
// State persists to a .design-canvas.state.json sidecar via the host
// bridge. No assets, no deps.
//
// Usage:
//   <DesignCanvas>
//     <DCSection id="onboarding" title="Onboarding" subtitle="First-run variants">
//       <DCArtboard id="a" label="A · Dusk" width={260} height={480}>…</DCArtboard>
//       <DCArtboard id="b" label="B · Minimal" width={260} height={480}>…</DCArtboard>
//     </DCSection>
//   </DesignCanvas>

const DC = {
  bg: '#f0eee9',
  grid: 'rgba(0,0,0,0.06)',
  label: 'rgba(60,50,40,0.7)',
  title: 'rgba(40,30,20,0.85)',
  subtitle: 'rgba(60,50,40,0.6)',
  postitBg: '#fef4a8',
  postitText: '#5a4a2a',
  font: '-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif',
};

// One-time CSS injection (classes are dc-prefixed so they don't collide)
if (typeof document !== 'undefined' && !document.getElementById('dc-styles')) {
  const style = document.createElement('style');
  style.id = 'dc-styles';
  style.innerHTML = `
    .dc-root { box-sizing: border-box; }
    .dc-root * { box-sizing: border-box; }
    .dc-artboard {
      background: #fff;
      box-shadow: 0 4px 16px rgba(0,0,0,0.04), 0 0 1px rgba(0,0,0,0.1);
      border-radius: 2px;
      display: flex;
      flex-direction: column;
      position: relative;
      overflow: hidden;
    }
    .dc-artboard-header {
      height: 32px;
      background: #fdfdfc;
      border-bottom: 1px solid rgba(0,0,0,0.06);
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 10px;
      font-family: -apple-system, BlinkMacSystemFont, sans-serif;
      font-size: 11px;
      color: rgba(0,0,0,0.4);
      cursor: grab;
    }
    .dc-artboard-header:active { cursor: grabbing; }
    .dc-editable {
      border: none;
      background: transparent;
      outline: none;
      font: inherit;
      color: inherit;
      cursor: text;
    }
    .dc-editable:focus {
      background: rgba(0,0,0,0.04);
      border-radius: 2px;
    }
    .dc-hover-only { opacity: 0; }
    *:hover > .dc-hover-only { opacity: 1; }
  `;
  document.head.appendChild(style);
}

// ─────────────────────────────────────────────────────────────
// Design Canvas Context
// ─────────────────────────────────────────────────────────────
const DesignContext = React.createContext(null);

function DesignCanvas({ children }) {
  const [focus, setFocus] = React.useState(null); // 'sectionId/artboardId'
  const [artboardOrder, setArtboardOrder] = React.useState({});
  const [artboardLabels, setArtboardLabels] = React.useState({});

  const ctxValue = {
    focus, setFocus,
    artboardOrder, setArtboardOrder,
    artboardLabels, setArtboardLabels,
  };

  return (
    <DesignContext.Provider value={ctxValue}>
      <div className="dc-root" style={{
        minHeight: '100vh', background: DC.bg,
        backgroundImage: 'radial-gradient(' + DC.grid + ' 1px, transparent 1px)',
        backgroundSize: '20px 20px', padding: '32px 40px',
        fontFamily: DC.font,
      }}>
        {children}
        <FocusOverlay />
      </div>
    </DesignContext.Provider>
  );
}

function DCSection({ id, title, subtitle, children }) {
  const ctx = React.useContext(DesignContext);
  const childrenArray = React.Children.toArray(children);

  // order array per section
  const orderKey = `section-${id}`;
  const orderedChildren = React.useMemo(() => {
    if (!ctx.artboardOrder[orderKey]) return childrenArray;
    const order = ctx.artboardOrder[orderKey];
    return [...childrenArray].sort((a, b) => {
      return order.indexOf(a.props.id) - order.indexOf(b.props.id);
    });
  }, [childrenArray, ctx.artboardOrder[orderKey]]);

  // drag state
  const onDragStart = (e, idx) => {
    e.dataTransfer.setData('text/plain', JSON.stringify({ sectionId: id, fromIdx: idx }));
  };

  const onDragOver = (e) => e.preventDefault();
  
  const onDrop = (e, toIdx) => {
    e.preventDefault();
    const data = JSON.parse(e.dataTransfer.getData('text/plain'));
    if (data.sectionId !== id) return;
    const newOrder = [...childrenArray.map(c => c.props.id)];
    const [removed] = newOrder.splice(data.fromIdx, 1);
    newOrder.splice(toIdx, 0, removed);
    ctx.setArtboardOrder(prev => ({ ...prev, [orderKey]: newOrder }));
  };

  return (
    <div style={{ marginBottom: 48 }}>
      <div style={{ marginBottom: 16 }}>
        <div style={{ fontSize: 16, fontWeight: 600, color: DC.title, marginBottom: 2 }}>{title}</div>
        {subtitle && <div style={{ fontSize: 12, color: DC.subtitle }}>{subtitle}</div>}
      </div>
      <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap', alignItems: 'flex-start' }}>
        {orderedChildren.map((child, index) => (
          <div key={child.props.id}
            draggable
            onDragStart={(e) => onDragStart(e, index)}
            onDragOver={onDragOver}
            onDrop={(e) => onDrop(e, index)}>
            {child}
          </div>
        ))}
      </div>
    </div>
  );
}

function DCArtboard({ id, label, width = 390, height = 844, children }) {
  const ctx = React.useContext(DesignContext);

  // custom label tracking
  const labelKey = `${id}-label`;
  const [artLabel, setArtLabel] = React.useState(label);

  const openFullScreen = () => {
    ctx.setFocus(`${id}`);
  };

  return (
    <div className="dc-artboard" style={{ width, height }}>
      <div className="dc-artboard-header" title="Drag to reorder">
        <input
          className="dc-editable"
          value={artLabel}
          onChange={(e) => setArtLabel(e.target.value)}
          onClick={(e) => e.stopPropagation()}
          style={{ fontWeight: 500, width: '70%' }}
        />
        <div style={{ display: 'flex', gap: 8 }} className="dc-hover-only">
          <button onClick={openFullScreen} style={{ border: 'none', background: 'rgba(0,0,0,0.06)', borderRadius: 2, padding: '2px 6px', cursor: 'pointer', fontSize: 10, color: 'inherit' }}>확대</button>
        </div>
      </div>
      <div style={{ flex: 1, position: 'relative', overflow: 'hidden', background: '#fff' }}>
        {children}
      </div>
    </div>
  );
}

function FocusOverlay() {
  const ctx = React.useContext(DesignContext);
  const [idx, setIdx] = React.useState(0);

  if (!ctx.focus) return null;

  // collect all DCArtboard instances for cycle navigation inside
  // For now we render a single mock panel
  const handleClose = () => ctx.setFocus(null);

  return ReactDOM.createPortal(
    <div onClick={handleClose} style={{
      position: 'fixed', inset: 0, background: 'rgba(240,238,233,0.85)',
      backdropFilter: 'blur(4px)', zIndex: 99999,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      cursor: 'zoom-out',
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        background: '#fff', border: '1px solid rgba(0,0,0,0.08)',
        boxShadow: '0 24px 64px -12px rgba(0,0,0,0.18)',
        borderRadius: 8, overflow: 'hidden', cursor: 'default',
      }}>
        {/* Fullscreen header */}
        <div style={{ height: 44, borderBottom: '1px solid #E9E9E7', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 20px', background: '#fdfdfc' }}>
          <div style={{ fontSize: 12, fontWeight: 500, color: DC.title }}>화면 보기 모드</div>
          <button onClick={handleClose} style={{ border: 'none', background: 'rgba(0,0,0,0.05)', borderRadius: 4, padding: '4px 10px', cursor: 'pointer', fontSize: 11 }}>닫기 (Esc)</button>
        </div>
        <div style={{ padding: 20 }}>
          {/* Active Artboard preview goes here or rendering current focus */}
        </div>
      </div>
    </div>,
    document.body
  );
}

// ─── Focus/Swiper Component ───
function DCAVFullScreen({ sectionId, activeArtId, onClose }) {
  const peers = ['onboarding', 'a', 'b'];
  const idx = peers.indexOf(activeArtId);

  const go = (d) => {
    // wrap-around
  };

  return ReactDOM.createPortal(
    <div onClick={onClose} style={{
      position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)',
      zIndex: 10000, display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      <div style={{
        background: '#000', width: 390, height: 844,
        position: 'relative',
      }} onClick={e => e.stopPropagation()}>
        {/* Content goes here */}
        <div style={{ position: 'absolute', bottom: 16, width: '100%', textAlign: 'center' }}>
          <span style={{ fontSize: 12, color: '#fff', fontVariantNumeric: 'tabular-nums' }}>{idx + 1} / {peers.length}</span>
        </div>
      </div>

      <Arrow dir="left" onClick={() => go(-1)} />
      <Arrow dir="right" onClick={() => go(1)} />

      {/* dots */}
      <div onClick={(e) => e.stopPropagation()}
        style={{ position: 'absolute', bottom: 20, left: '50%', transform: 'translateX(-50%)', display: 'flex', gap: 8 }}>
        {peers.map((p, i) => (
          <button key={p} onClick={() => ctx.setFocus(`${sectionId}/${p}`)}
            style={{ border: 'none', padding: 0, cursor: 'pointer', width: 6, height: 6, borderRadius: 3,
              background: i === idx ? '#fff' : 'rgba(255,255,255,.3)' }} />
        ))}
      </div>
    </div>,
    document.body,
  );
}

// ─────────────────────────────────────────────────────────────
// Post-it — absolute-positioned sticky note
// ─────────────────────────────────────────────────────────────
function DCPostIt({ children, top, left, right, bottom, rotate = -2, width = 180 }) {
  return (
    <div style={{
      position: 'absolute', top, left, right, bottom, width,
      background: DC.postitBg, padding: '14px 16px',
      fontFamily: '"Comic Sans MS", "Marker Felt", "Segoe Print", cursive',
      fontSize: 14, lineHeight: 1.4, color: DC.postitText,
      transform: `rotate(${rotate}deg)`,
      boxShadow: '0 3px 10px rgba(0,0,0,0.06), 0 1px 3px rgba(0,0,0,0.04)',
      border: '1px solid rgba(0,0,0,0.04)',
    }}>
      {children}
    </div>
  );
}

Object.assign(window, { DesignCanvas, DCSection, DCArtboard, DCPostIt });