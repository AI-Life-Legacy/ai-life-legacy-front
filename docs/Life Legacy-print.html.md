<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8"/>
<title>Life Legacy — Print</title>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<style>
  html, body {
    margin: 0; padding: 0;
    background: #f0eee9;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
  * { box-sizing: border-box; }
  :lang(ko), html { word-break: keep-all; line-break: strict; }

  .print-page {
    width: 210mm;
    height: 297mm;
    padding: 14mm 12mm 18mm;
    margin: 0 auto 8mm;
    background: #f0eee9;
    display: flex; flex-direction: column; align-items: center;
    page-break-after: always;
    break-after: page;
    position: relative;
  }
  .print-page:last-child { page-break-after: auto; break-after: auto; }
  .print-header {
    width: 100%;
    display: flex; justify-content: space-between; align-items: baseline;
    margin-bottom: 10mm;
    color: #37352F;
  }
  .print-header .title { font-size: 20pt; font-weight: 700; letter-spacing: -0.5px; }
  .print-header .subtitle { font-size: 11pt; color: #6B6B6B; margin-top: 2mm; }
  .print-header .index { font-size: 14pt; font-variant-tabular: lining-nums; }
  
  /* device */
  .phone {
    width: 390px; height: 844px;
    background: #fff;
    border: 1px solid #E9E9E7; border-radius: 36px;
    overflow: hidden;
    box-shadow: 0 10px 40px rgba(0,0,0,0.1);
  }

  .print-footer {
    position: absolute; bottom: 12mm; left: 12mm; right: 12mm;
    display: flex; justify-content: space-between;
    font-size: 9pt; color: #9B9A97;
    border-top: 1px solid #E9E9E7;
    padding-top: 3mm;
  }

  /* Cover page */
  .cover-page {
    width: 210mm; height: 297mm;
    padding: 30mm 20mm;
    display: flex; flex-direction: column; justify-content: space-between;
    page-break-after: always;
  }
  .cover-title { font-size: 38pt; font-weight: 800; color: #2F3437; margin-top: 10mm; }
  .cover-desc { font-size: 13pt; line-height: 1.6; color: #6B6B6B; max-width: 120mm; margin-top: 8mm; }
  .meta { display: flex; gap: 8mm; font-size: 10pt; color: #37352F; margin-top: 30mm; }
</style>
<script src="[https://unpkg.com/react@18/umd/react.development.js](https://unpkg.com/react@18/umd/react.development.js)" crossorigin></script>
<script src="[https://unpkg.com/react-dom@18/umd/react-dom.development.js](https://unpkg.com/react-dom@18/umd/react-dom.development.js)" crossorigin></script>
<script src="[https://unpkg.com/@babel/standalone/babel.min.js](https://unpkg.com/@babel/standalone/babel.min.js)"></script>
</head>
<body>

<div id="root"></div>

<script src="primitives.jsx" data-type="jsx"></script>
<script src="avatar-roles.jsx" data-type="jsx"></script>
<script src="screens-onboarding.jsx" data-type="jsx"></script>
<script src="screens-writing.jsx" data-type="jsx"></script>
<script src="screens-generation.jsx" data-type="jsx"></script>
<script src="screens-utility.jsx" data-type="jsx"></script>
<script src="screens-viewer.jsx" data-type="jsx"></script>

<script type="text/babel">
const SCREENS = [
  { id: '01_Main', title: 'Main', section: 'Onboarding', C: S01_Main },
  { id: '06_Home', title: 'Home', section: 'Writer', C: S06_Home },
  { id: '07_Chat', title: 'ChapterChat', section: 'Writer', C: S07_Chat },
  { id: '15_Search', title: 'Search', section: 'Utility', C: S15_Search },
  { id: '16_Settings', title: 'Settings', section: 'Utility', C: S16_Settings },
  { id: '17_ViewerEntry', title: 'Viewer Entry', section: 'Viewer', C: S17_ViewerEntry },
];

function Cover() {
  return (
    <div className="cover-page">
      <div>
        <div style={{ fontSize: 10pt, fontWeight: 600, color: '#2F3437', letterSpacing: '0.04em' }}>LIFE LEGACY</div>
        <div className="cover-title">AI 자서전 및<br/>기억 공유 프로토타입</div>
        <div className="cover-desc">
          Margaret Thompson님의 생애 주기별 인터뷰 질문을 통해 자서전을 작성하고,
          가족이 AI 아바타와 대화할 수 있게 하는 앱의 프로토타입입니다.
          총 {SCREENS.length}개 화면을 Writer 흐름과 Viewer 흐름으로 나누어 수록했습니다.
        </div>
      </div>
      <div className="meta">
        <div><b>{SCREENS.length}</b> screens</div>
        <div><b>2</b> flows · Writer · Viewer</div>
        <div><b>6</b> avatar roles</div>
        <div><b>2026</b></div>
      </div>
    </div>
  );
}

function Page({ idx, s }) {
  const C = s.C;
  return (
    <div className="print-page">
      <div className="print-header">
        <div>
          <div className="title">{s.title}</div>
          <div className="subtitle">{s.section}</div>
        </div>
        <div className="index">{String(idx + 1).padStart(2, '0')} / {SCREENS.length}</div>
      </div>
      <div className="phone">
        <C nav={() => {}}/>
      </div>
      <div className="print-footer">
        <span>Life Legacy · AI 자서전 앱</span>
        <span>{s.id}</span>
      </div>
    </div>
  );
}

function PrintBook() {
  return (
    <>
      <Cover/>
      {SCREENS.map((s, i) => <Page key={s.id} idx={i} s={s}/>)}
    </>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<PrintBook/>);

// Auto-print once fonts + Babel + React finish
window.onload = () => setTimeout(window.print, 1000);
</script>
</body>
</html>