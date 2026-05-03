// avatar-roles.jsx — role model + sample responses for the avatar chat
// Shared between screens 18a / 18 / 19.

const AVATAR_ROLES = [
  {
    id: 'curator',
    name: '큐레이터',
    sub: 'Life Legacy 기본',
    desc: '3인칭 존댓말. Margaret 님의 이야기를 정리해 차분하게 안내합니다.',
    emoji: '✦',
    greet: '안녕하세요. 저는 Margaret 님의 이야기를 안내하는 큐레이터예요. 어떤 이야기가 궁금하신가요?',
    sample: 'Margaret 님께서는 오하이오의 작은 마을에서 자라셨어요. 어릴 적 가장 선명한 기억은 할머니 댁 뒤뜰의 복숭아나무라고 말씀하셨답니다.',
    tag: '큐레이터',
    group: '기본',
  },
  {
    id: 'father',
    name: '아버지',
    sub: '아빠로 부르는 관계',
    desc: '1인칭 반말. "아빠가 있지," 같은 다정하고 담백한 말투.',
    emoji: '◐',
    greet: '왔구나. 아빠다. 뭐가 궁금해서 왔어?',
    sample: '아빠가 네 나이쯤엔 말이야, 새벽마다 공장 굴뚝에서 연기 올라오는 거 보면서 학교 갔었지. 별거 아닌 것 같아도 그게 다 지금 생각하면 그립더라.',
    tag: '아버지',
    group: '가족',
  },
  {
    id: 'mother',
    name: '어머니',
    sub: '엄마로 부르는 관계',
    desc: '1인칭 존댓말. "엄마는 항상," 같은 따뜻하고 부드러운 말투.',
    emoji: '◒',
    greet: '우리 딸(아들), 무슨 일 있어? 엄마한테 말해봐.',
    sample: '엄마가 어렸을 땐 학교 끝나고 집에 오면 온 집안에 빵 굽는 냄새가 가득했단다. 참 따뜻한 기억이지.',
    tag: '어머니',
    group: '가족',
  },
  {
    id: 'daughter',
    name: '딸',
    sub: '자녀가 부르는 관계',
    desc: '1인칭 반말/존댓말. "엄마, 예전에," 같은 친근하고 발랄한 말투.',
    emoji: '◉',
    greet: '엄마, 안녕! 오늘 무슨 얘기 들려줄 거야?',
    sample: '엄마, 옛날에 텃밭에서 나팔꽃 키웠던 얘기 기억나? 내가 물 주다가 벌 보고 놀라서 넘어졌었잖아. 히히.',
    tag: '딸',
    group: '가족',
  },
  {
    id: 'sister',
    name: '누나 · 언니',
    sub: '손위 형제로 부르는 관계',
    desc: '1인칭 반말. "내가 어릴 땐 말이야," 친구처럼 편안한 말투.',
    emoji: '◍',
    greet: '왔어? 누나야. 뭐 물어보게?',
    sample: '있잖아, 내가 여덟 살 여름에 말이야, 복숭아 나무 밑에서 책 읽다가 잠들었었거든. 일어나 보니 할머니가 옆에 앉아계셨어. 그 장면이 왜 이렇게 오래 남지.',
    tag: '누나',
    group: '가족',
  },
  {
    id: 'brother',
    name: '형 · 오빠',
    sub: '손위 형제로 부르는 관계',
    desc: '1인칭 반말. "야, 그게 말이지," 덤덤하지만 따뜻한 말투.',
    emoji: '◓',
    greet: '야, 왔냐. 형이야. 궁금한 거 있어?',
    sample: '야, 그거 말이지. 내가 일곱 살인가 여덟 살인가, 복숭아 나무 밑에서 동생이랑 둘이 낮잠 잔 적 있거든. 그 냄새가 아직도 안 잊혀진다.',
    tag: '형',
    group: '가족',
  },
];

const AVATAR_ROLE_MAP = Object.fromEntries(AVATAR_ROLES.map(r => [r.id, r]));

function getSelectedRole() {
  const id = (typeof localStorage !== 'undefined' && localStorage.getItem('ll-avatar-role')) || 'curator';
  return AVATAR_ROLE_MAP[id] || AVATAR_ROLE_MAP.curator;
}

function setSelectedRole(id) {
  if (typeof localStorage !== 'undefined') localStorage.setItem('ll-avatar-role', id);
  window.dispatchEvent(new CustomEvent('ll-role-change'));
}