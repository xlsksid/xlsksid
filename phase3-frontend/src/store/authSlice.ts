import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface AuthState {
  token: string | null;
  username: string | null;
  role: string | null;
  userId: number | null;
  membershipLevel: string | null;
}

const initialState: AuthState = {
  token: localStorage.getItem('token'),
  username: localStorage.getItem('username'),
  role: localStorage.getItem('role'),
  userId: localStorage.getItem('userId') ? Number(localStorage.getItem('userId')) : null,
  membershipLevel: localStorage.getItem('membershipLevel') || 'bronze',
};

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    loginSuccess(state, action: PayloadAction<{
      token: string; username: string; role: string; userId: number; membershipLevel?: string;
    }>) {
      const { token, username, role, userId, membershipLevel } = action.payload;
      state.token = token;
      state.username = username;
      state.role = role;
      state.userId = userId;
      state.membershipLevel = membershipLevel || 'bronze';
      localStorage.setItem('token', token);
      localStorage.setItem('username', username);
      localStorage.setItem('role', role);
      localStorage.setItem('userId', String(userId));
      localStorage.setItem('membershipLevel', membershipLevel || 'bronze');
    },
    logout(state) {
      state.token = null;
      state.username = null;
      state.role = null;
      state.userId = null;
      state.membershipLevel = 'bronze';
      localStorage.removeItem('token');
      localStorage.removeItem('username');
      localStorage.removeItem('role');
      localStorage.removeItem('userId');
      localStorage.removeItem('membershipLevel');
    },
  },
});

export const { loginSuccess, logout } = authSlice.actions;
export default authSlice.reducer;
