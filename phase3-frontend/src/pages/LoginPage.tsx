import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, Form, Input, Button, Tabs, message } from 'antd';
import { UserOutlined, LockOutlined, MailOutlined } from '@ant-design/icons';
import { useDispatch } from 'react-redux';
import { loginSuccess } from '@/store/authSlice';
import { login, register } from '@/api/authApi';

export default function LoginPage() {
  const [tab, setTab] = useState('login');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const dispatch = useDispatch();

  const onFinish = async (values: Record<string, string>) => {
    setLoading(true);
    try {
      const data = tab === 'login'
        ? await login(values.username, values.password)
        : await register(values.username, values.password, values.email);

      dispatch(loginSuccess({ token: data.token, username: data.username, role: data.role, userId: data.userId, membershipLevel: data.membershipLevel }));
      message.success(tab === 'login' ? '登录成功' : '注册成功');
      navigate('/');
    } catch {
      // error handled by interceptor
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh', background: '#f5f5f5' }}>
      <Card style={{ width: 400, boxShadow: '0 2px 8px rgba(0,0,0,0.1)' }}>
        <h1 style={{ textAlign: 'center', color: '#e65100', marginBottom: 24 }}>🌶 香辣卤味</h1>
        <Tabs activeKey={tab} onChange={setTab} centered items={[
          { key: 'login', label: '登录' },
          { key: 'register', label: '注册' },
        ]} />
        <Form onFinish={onFinish} size="large">
          <Form.Item name="username" rules={[{ required: true, message: '请输入用户名' }]}>
            <Input prefix={<UserOutlined />} placeholder="用户名" />
          </Form.Item>
          <Form.Item name="password" rules={[{ required: true, min: 6, message: '密码至少6位' }]}>
            <Input.Password prefix={<LockOutlined />} placeholder="密码" />
          </Form.Item>
          {tab === 'register' && (
            <Form.Item name="email" rules={[{ required: true, type: 'email', message: '请输入有效邮箱' }]}>
              <Input prefix={<MailOutlined />} placeholder="邮箱" />
            </Form.Item>
          )}
          <Form.Item>
            <Button type="primary" htmlType="submit" loading={loading} block
                    style={{ background: '#e65100', borderColor: '#e65100' }}>
              {tab === 'login' ? '登录' : '注册'}
            </Button>
          </Form.Item>
        </Form>
        <div style={{ textAlign: 'center', color: '#888', fontSize: 12 }}>
          演示账号: admin / customer01 / staff01 — 密码: test123
        </div>
      </Card>
    </div>
  );
}
