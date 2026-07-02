import { useEffect, useState } from 'react';
import { Card, Table, Button, Modal, Form, Input, InputNumber, Select, Switch, message, Popconfirm, Space } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import { listProducts, createProduct, updateProduct, deleteProduct, listCategories } from '@/api/productApi';
import type { Product, Category } from '@/types';

export default function ProductManagePage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<Product | null>(null);
  const [form] = Form.useForm();

  const load = async () => {
    setLoading(true);
    const [p, c] = await Promise.all([listProducts(), listCategories()]);
    setProducts(p);
    setCategories(c);
    setLoading(false);
  };

  useEffect(() => { load(); }, []);

  const openCreate = () => { setEditing(null); form.resetFields(); setModalOpen(true); };
  const openEdit = (p: Product) => { setEditing(p); form.setFieldsValue(p); setModalOpen(true); };

  const handleSave = async () => {
    const values = await form.validateFields();
    if (editing) {
      await updateProduct(editing.id, values);
      message.success('已更新');
    } else {
      await createProduct(values);
      message.success('已创建');
    }
    setModalOpen(false);
    load();
  };

  const handleDelete = async (id: number) => {
    await deleteProduct(id);
    message.success('已删除');
    load();
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', width: 60 },
    { title: '名称', dataIndex: 'name' },
    { title: '单价', dataIndex: 'price', render: (v: number) => `¥${v}` },
    { title: '库存', dataIndex: 'stock' },
    { title: '辣度', dataIndex: 'spiciness', render: (v: number) => '🌶'.repeat(v) },
    { title: '上架', dataIndex: 'isAvailable', render: (v: boolean) => v ? '✅' : '❌' },
    {
      title: '操作', key: 'actions',
      render: (_: unknown, r: Product) => (
        <Space>
          <Button icon={<EditOutlined />} size="small" onClick={() => openEdit(r)}>编辑</Button>
          <Popconfirm title="确定删除?" onConfirm={() => handleDelete(r.id)}>
            <Button icon={<DeleteOutlined />} size="small" danger>删除</Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <Card title="商品管理" extra={<Button type="primary" icon={<PlusOutlined />} onClick={openCreate}
      style={{ background: '#e65100', borderColor: '#e65100' }}>新增商品</Button>}>
      <Table dataSource={products} columns={columns} rowKey="id" loading={loading} pagination={{ pageSize: 10 }} />
      <Modal title={editing ? '编辑商品' : '新增商品'} open={modalOpen}
             onOk={handleSave} onCancel={() => setModalOpen(false)}>
        <Form form={form} layout="vertical">
          <Form.Item name="name" label="名称" rules={[{ required: true, message: '请输入名称' }]}>
            <Input />
          </Form.Item>
          <Form.Item name="price" label="单价" rules={[{ required: true, message: '请输入单价' }]}>
            <InputNumber min={0} precision={2} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="costPrice" label="成本价">
            <InputNumber min={0} precision={2} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="stock" label="库存" rules={[{ required: true, message: '请输入库存' }]}>
            <InputNumber min={0} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="unit" label="单位" initialValue="份">
            <Input />
          </Form.Item>
          <Form.Item name="categoryId" label="分类" rules={[{ required: true, message: '请选择分类' }]}>
            <Select options={categories.map(c => ({ value: c.id, label: c.name }))} />
          </Form.Item>
          <Form.Item name="spiciness" label="辣度 (1-5)" initialValue={1}>
            <InputNumber min={1} max={5} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item name="isAvailable" label="上架" valuePropName="checked" initialValue={true}>
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </Card>
  );
}
