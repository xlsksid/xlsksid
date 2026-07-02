import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { Layout, Menu, Button, Badge, Space, Dropdown, Typography } from 'antd';
import { ShopOutlined, ShoppingCartOutlined, UserOutlined, SettingOutlined, LogoutOutlined, GiftOutlined, OrderedListOutlined } from '@ant-design/icons';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '@/store';
import { logout } from '@/store/authSlice';
import AnnouncementBanner from './AnnouncementBanner';

const { Header, Content, Footer } = Layout;

export default function AppLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const dispatch = useDispatch();
  const { token, username, role, membershipLevel } = useSelector((s: RootState) => s.auth);
  const cartCount = useSelector((s: RootState) => s.cart.items.reduce((a, b) => a + b.quantity, 0));
  const isAdmin = role === 'admin' || role === 'staff';

  const levelBadge: Record<string, { emoji: string; color: string; name: string }> = {
    platinum: { emoji: '💎', color: '#9c27b0', name: '铂金' },
    gold:     { emoji: '🥇', color: '#faad14', name: '金牌' },
    silver:   { emoji: '🥈', color: '#8c8c8c', name: '银牌' },
    bronze:   { emoji: '🥉', color: '#d48806', name: '铜牌' },
  };
  const badge = levelBadge[membershipLevel || 'bronze'];

  const userMenu = {
    items: [
      { key: 'orders', icon: <OrderedListOutlined />, label: '我的订单', onClick: () => navigate('/orders') },
      { key: 'coupons', icon: <GiftOutlined />, label: '优惠券与会员', onClick: () => navigate('/coupons') },
      { type: 'divider' as const },
      { key: 'logout', icon: <LogoutOutlined />, label: '退出登录', onClick: () => { dispatch(logout()); navigate('/login'); } },
    ],
  };

  const menuItems = [
    { key: '/', icon: <ShopOutlined />, label: '首页' },
    ...(isAdmin ? [{ key: '/admin', icon: <SettingOutlined />, label: '后台管理' }] : []),
  ];

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Header style={{
        display: 'flex', alignItems: 'center', padding: '0 24px',
        background: 'linear-gradient(135deg, #e65100, #ff8f00)',
        position: 'relative'
      }}>
        {/* Logo center */}
        <div style={{
          position: 'absolute', left: '50%', transform: 'translateX(-50%)',
          color: '#fff', fontSize: 22, fontWeight: 800, letterSpacing: 3,
          cursor: 'pointer', whiteSpace: 'nowrap'
        }} onClick={() => navigate('/')}>
          🌶 香辣卤味
        </div>
        {/* Left menu */}
        <Menu theme="dark" mode="horizontal"
          selectedKeys={[location.pathname.startsWith('/admin') ? '/admin' : '/']}
          items={menuItems}
          onClick={({ key }) => navigate(key)}
          style={{ flex: 1, background: 'transparent', borderBottom: 'none' }}
        />
        {/* Right */}
        <Space size="middle">
          {token ? (
            <>
              <Badge count={cartCount} size="small">
                <Button type="text" icon={<ShoppingCartOutlined style={{ color: '#fff', fontSize: 20 }} />}
                  onClick={() => navigate('/cart')} />
              </Badge>
              <Dropdown menu={userMenu} placement="bottomRight">
                <Button type="text" style={{ color: '#fff' }}>
                  <span style={{ marginRight: 6, fontSize: 16 }}>{badge.emoji}</span>
                  {username}
                  <span style={{ fontSize: 10, marginLeft: 6, padding: '1px 6px', borderRadius: 10, background: badge.color, color: '#fff', fontWeight: 600 }}>
                    {badge.name}
                  </span>
                </Button>
              </Dropdown>
            </>
          ) : (
            <Button ghost onClick={() => navigate('/login')}>登录</Button>
          )}
        </Space>
      </Header>
      <Content style={{ padding: 24, background: 'linear-gradient(180deg, #fff8e1 0%, #fff3e0 50%, #fafafa 100%)', minHeight: 'calc(100vh - 64px - 50px)' }}>
        <AnnouncementBanner />
        <Outlet />
      </Content>
      <Footer className="app-footer">
        <div style={{ fontSize: 28, marginBottom: 8 }}>🌶</div>
        香辣卤味管理系统 © 2026 · 用心做好每一份卤味
      </Footer>
    </Layout>
  );
}
