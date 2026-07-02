import { useState } from 'react';
import { SoundOutlined, CloseOutlined } from '@ant-design/icons';

const announcements = [
  { text: '🔥 端午特惠：全场卤味满100减25，酸梅汤买一送一！', color: '#e65100' },
  { text: '🎉 新用户专享：注册即送9折券+200积分，首单再享双倍积分', color: '#fa8c16' },
  { text: '💎 会员福利：累计消费满500元升级VIP，享全单8折', color: '#722ed1' },
];

export default function AnnouncementBanner() {
  const [index, setIndex] = useState(0);
  const [visible, setVisible] = useState(true);

  if (!visible) return null;

  const current = announcements[index];

  return (
    <div className="announcement-card" onClick={() => setIndex((index + 1) % announcements.length)}>
      <span className="announcement-icon" style={{ color: current.color }}>
        <SoundOutlined />
      </span>
      <span style={{ flex: 1 }}>{current.text}</span>
      <CloseOutlined
        style={{ color: '#999', fontSize: 12 }}
        onClick={(e) => { e.stopPropagation(); setVisible(false); }}
      />
    </div>
  );
}
