import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, Row, Col, Tag, Select, Spin, Typography } from 'antd';
import { ShoppingCartOutlined, FireOutlined } from '@ant-design/icons';
import { listProducts, listCategories } from '@/api/productApi';
import type { Product, Category } from '@/types';

const { Meta } = Card;

export default function HomePage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedCat, setSelectedCat] = useState<number | undefined>();
  const navigate = useNavigate();

  useEffect(() => {
    listCategories().then(setCategories);
  }, []);

  useEffect(() => {
    setLoading(true);
    listProducts(selectedCat).then(setProducts).finally(() => setLoading(false));
  }, [selectedCat]);

  const spiceColor = (level: number) => {
    const colors = ['#52c41a', '#73d13d', '#faad14', '#ff7a45', '#f5222d'];
    return colors[Math.min(level, 5) - 1] || '#ccc';
  };

  return (
    <div>
      <Select
        allowClear
        placeholder="全部分类"
        style={{ width: 200, marginBottom: 16 }}
        value={selectedCat}
        onChange={(v) => setSelectedCat(v)}
        options={categories.map(c => ({ value: c.id, label: c.name }))}
      />
      <Spin spinning={loading}>
        <Row gutter={[16, 16]}>
          {products.map(p => (
            <Col key={p.id} xs={24} sm={12} md={8} lg={6}>
              <Card
                hoverable
                cover={
                  <img src={p.imageUrl} alt={p.name}
                    style={{ height: 160, width: '100%', objectFit: 'cover' }}
                    onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }}
                  />
                }
                actions={[
                  <ShoppingCartOutlined key="cart" onClick={(e) => { e.stopPropagation(); navigate(`/products/${p.id}`); }} />,
                ]}
                onClick={() => navigate(`/products/${p.id}`)}
              >
                <Meta
                  title={
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <span style={{ fontSize: 15, fontWeight: 600 }}>{p.name}</span>
                      <span style={{ color: '#e65100', fontWeight: 700, fontSize: 18 }}>¥{p.price.toFixed(0)}</span>
                    </div>
                  }
                  description={
                    <div style={{ fontSize: 12, color: '#888', lineHeight: '20px' }}>
                      {p.description && <div style={{ marginBottom: 4 }}>{p.description.length > 20 ? p.description.slice(0, 20) + '...' : p.description}</div>}
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <Tag color={spiceColor(p.spiciness)} style={{ margin: 0, fontSize: 11 }}>
                          <FireOutlined /> {p.spiciness > 0 ? '🌶'.repeat(p.spiciness) : '不辣'}
                        </Tag>
                        <span>库存 {p.stock}</span>
                      </div>
                    </div>
                  }
                />
              </Card>
            </Col>
          ))}
        </Row>
      </Spin>
    </div>
  );
}
