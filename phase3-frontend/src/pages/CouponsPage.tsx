import { useEffect, useState } from 'react';
import { Card, Table, Tag, Button, message, Row, Col, Statistic, Progress, Descriptions, Divider, Typography } from 'antd';
import { GiftOutlined, TrophyOutlined, CrownOutlined } from '@ant-design/icons';
import { listMyCoupons, listTemplates, claimCoupon } from '@/api/couponApi';
import { useSelector } from 'react-redux';
import { RootState } from '@/store';
import type { CouponTemplate, UserCoupon } from '@/types';

const statusLabels: Record<string, string> = { unused: '未使用', used: '已使用', expired: '已过期' };
const statusColors: Record<string, string> = { unused: 'blue', used: 'default', expired: 'red' };

const memberConfig = {
  bronze:  { name: '铜牌会员', emoji: '🥉', color: '#d48806', min: 0,     rate: 100, desc: '基础会员，100积分抵扣1元' },
  silver:  { name: '银牌会员', emoji: '🥈', color: '#8c8c8c', min: 500,   rate: 90,  desc: '90积分抵扣1元 · 享银牌专属优惠券' },
  gold:    { name: '金牌会员', emoji: '🥇', color: '#faad14', min: 2000,  rate: 80,  desc: '80积分抵扣1元 · 享金牌专属优惠券' },
  platinum:{ name: '铂金会员', emoji: '💎', color: '#9c27b0', min: 5000,  rate: 70,  desc: '70积分抵扣1元 · 享铂金7折券' },
};

export default function CouponsPage() {
  const [myCoupons, setMyCoupons] = useState<UserCoupon[]>([]);
  const [templates, setTemplates] = useState<CouponTemplate[]>([]);
  const [loading, setLoading] = useState(true);

  const membershipLevel = useSelector((s: RootState) => s.auth.membershipLevel) || 'bronze';
  const currentLevel = memberConfig[membershipLevel];

  const load = async () => {
    setLoading(true);
    const [mine, all] = await Promise.all([listMyCoupons(), listTemplates()]);
    setMyCoupons(mine);
    setTemplates(all);
    setLoading(false);
  };

  useEffect(() => { load(); }, []);

  const handleClaim = async (tid: number) => {
    try {
      await claimCoupon(tid);
      message.success('领取成功!');
      load();
    } catch { /* handled */ }
  };

  const [points, setPoints] = useState(0);
  useEffect(() => {
    fetch('/api/users/me', {
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    }).then(r => r.json()).then(d => {
      if (d?.data?.points !== undefined) setPoints(d.data.points);
    }).catch(() => {});
  }, []);

  const nextLevel = Object.values(memberConfig).find(l => l.min > currentLevel.min);
  const progress = nextLevel
    ? Math.min(100, Math.round((points - currentLevel.min) / (nextLevel.min - currentLevel.min) * 100))
    : 100;

  return (
    <div>
      {/* ========== 会员信息卡片 ========== */}
      <Card style={{ marginBottom: 16, borderRadius: 16, background: `linear-gradient(135deg, ${currentLevel.color}15, ${currentLevel.color}05)` }}>
        <Row gutter={24} align="middle">
          <Col xs={24} md={8} style={{ textAlign: 'center' }}>
            <div style={{ fontSize: 64, lineHeight: 1 }}>{currentLevel.emoji}</div>
            <Typography.Title level={3} style={{ margin: '8px 0 0', color: currentLevel.color }}>
              {currentLevel.name}
            </Typography.Title>
          </Col>
          <Col xs={24} md={8} style={{ textAlign: 'center' }}>
            <Statistic title="当前积分" value={points} suffix="分"
              valueStyle={{ color: '#e65100', fontSize: 36, fontWeight: 700 }} />
            <Typography.Text type="secondary">积分汇率：{currentLevel.rate}分 = ¥1</Typography.Text>
          </Col>
          <Col xs={24} md={8}>
            {nextLevel ? (
              <div>
                <Typography.Text>距离{nextLevel.emoji} {nextLevel.name}</Typography.Text>
                <Progress percent={progress} strokeColor={nextLevel.color}
                  format={() => `${points} / ${nextLevel.min} 分`} />
                <Typography.Text type="secondary" style={{ fontSize: 12 }}>
                  还需 {nextLevel.min - points} 积分升级
                </Typography.Text>
              </div>
            ) : (
              <div style={{ textAlign: 'center' }}>
                <CrownOutlined style={{ fontSize: 40, color: currentLevel.color }} />
                <Typography.Title level={4} style={{ color: currentLevel.color, marginTop: 8 }}>
                  已是最高等级！
                </Typography.Title>
              </div>
            )}
          </Col>
        </Row>
      </Card>

      {/* ========== 会员权益说明 ========== */}
      <Card title="🏆 会员权益说明" style={{ marginBottom: 16, borderRadius: 16 }}>
        <Row gutter={[16, 16]}>
          {Object.entries(memberConfig).map(([key, cfg]) => (
            <Col xs={24} sm={12} md={6} key={key}>
              <Card size="small" style={{
                background: membershipLevel === key ? `${cfg.color}15` : '#fff',
                border: membershipLevel === key ? `1px solid ${cfg.color}` : '1px solid #f0f0f0',
                borderRadius: 12, textAlign: 'center',
              }}>
                <div style={{ fontSize: 32 }}>{cfg.emoji}</div>
                <Typography.Text strong style={{ color: cfg.color }}>{cfg.name}</Typography.Text>
                <div style={{ fontSize: 12, color: '#888', marginTop: 4 }}>
                  {cfg.min > 0 ? `≥${cfg.min}积分` : '注册即享'}<br />
                  {cfg.desc}
                </div>
              </Card>
            </Col>
          ))}
        </Row>
      </Card>

      {/* ========== 可领优惠券 ========== */}
      <Card title="🎫 可领优惠券" style={{ marginBottom: 16, borderRadius: 16 }}>
        {templates.map(ct => (
          <div key={ct.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12, padding: '8px 0', borderBottom: '1px solid #f0f0f0' }}>
            <div>
              <strong>{ct.name}</strong>
              <div style={{ color: '#888', fontSize: 13 }}>
                {ct.type === 'discount' ? `${((1 - (ct.discountRate || 1)) * 100).toFixed(0)}% 折扣` : `满减 ¥${ct.reductionAmount}`}
                {' · '}最低消费 ¥{ct.minOrderAmount}
                {' · '}{ct.validDays}天有效
              </div>
            </div>
            <Button type="primary" size="small" style={{ background: '#e65100', borderColor: '#e65100' }}
                    onClick={() => handleClaim(ct.id)}>领取</Button>
          </div>
        ))}
      </Card>

      {/* ========== 我的优惠券 ========== */}
      <Card title="🎟️ 我的优惠券" style={{ borderRadius: 16 }}>
        <Table dataSource={myCoupons} rowKey="id" loading={loading} columns={[
          { title: '优惠券名称', dataIndex: 'templateName', render: (v: string) => v || '-', ellipsis: true },
          { title: '状态', dataIndex: 'status', render: (s: string) => <Tag color={statusColors[s]}>{statusLabels[s]}</Tag> },
          { title: '有效期起', dataIndex: 'validFrom', render: (v: string) => new Date(v).toLocaleDateString() },
          { title: '有效期止', dataIndex: 'validTo', render: (v: string) => new Date(v).toLocaleDateString() },
        ]} />
      </Card>
    </div>
  );
}
