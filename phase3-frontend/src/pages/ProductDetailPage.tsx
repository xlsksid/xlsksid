import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Card, Button, InputNumber, Descriptions, Tag, message, Spin } from 'antd';
import { ShoppingCartOutlined, FireOutlined } from '@ant-design/icons';
import { getProduct } from '@/api/productApi';
import { listProductReviews } from '@/api/feedbackApi';
import { useDispatch } from 'react-redux';
import { addToCart } from '@/store/cartSlice';
import type { Product, Feedback } from '@/types';

export default function ProductDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [product, setProduct] = useState<Product | null>(null);
  const [reviews, setReviews] = useState<Feedback[]>([]);
  const [qty, setQty] = useState(1);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const dispatch = useDispatch();

  useEffect(() => {
    if (!id) return;
    setLoading(true);
    Promise.all([
      getProduct(Number(id)),
      listProductReviews(Number(id)),
    ]).then(([p, r]) => {
      setProduct(p);
      setReviews(r);
    }).finally(() => setLoading(false));
  }, [id]);

  if (loading) return <Spin style={{ display: 'block', margin: '100px auto' }} />;
  if (!product) return <div>商品不存在</div>;

  const handleAddToCart = () => {
    dispatch(addToCart({
      productId: product.id,
      name: product.name,
      price: product.price,
      quantity: qty,
    }));
    message.success(`已添加 ${qty} x ${product.name} 到购物车`);
    navigate('/cart');
  };

  return (
    <Card>
      <div style={{ textAlign: 'center', marginBottom: 16 }}>
        <img src={product.imageUrl} alt={product.name}
          style={{ maxWidth: 300, maxHeight: 200, objectFit: 'contain', borderRadius: 8 }} />
      </div>
      <Descriptions title={product.name} column={2} bordered>
        <Descriptions.Item label="单价">¥{product.price} / {product.unit}</Descriptions.Item>
        <Descriptions.Item label="库存">{product.stock}</Descriptions.Item>
        <Descriptions.Item label="辣度">
          <Tag color={['green','lime','gold','orange','red'][Math.min(product.spiciness, 5) - 1] || 'green'}>
            <FireOutlined /> {'🌶'.repeat(product.spiciness)}
          </Tag>
        </Descriptions.Item>
        <Descriptions.Item label="描述">{product.description || '-'}</Descriptions.Item>
      </Descriptions>

      <div style={{ marginTop: 24, display: 'flex', gap: 12, alignItems: 'center' }}>
        <span>数量:</span>
        <InputNumber min={1} max={product.stock} value={qty} onChange={v => v && setQty(v)} />
        <Button type="primary" icon={<ShoppingCartOutlined />}
                style={{ background: '#e65100', borderColor: '#e65100' }}
                onClick={handleAddToCart}>
          加入购物车
        </Button>
      </div>

      {reviews.length > 0 && (
        <Card title="用户评价" style={{ marginTop: 24 }}>
          {reviews.map(r => (
            <div key={r.id} style={{ marginBottom: 8 }}>
              <Tag color="gold">{'⭐'.repeat(r.rating)}</Tag>
              <span>{r.comment}</span>
            </div>
          ))}
        </Card>
      )}
    </Card>
  );
}
