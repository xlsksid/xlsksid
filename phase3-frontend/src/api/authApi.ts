import api from './axios';
import type { LoginResponse } from '@/types';

export async function login(username: string, password: string): Promise<LoginResponse> {
  const res = await api.post('/auth/login', { username, password });
  return res.data.data;
}

export async function register(username: string, password: string, email: string) {
  const res = await api.post('/auth/register', { username, password, email });
  return res.data.data;
}
