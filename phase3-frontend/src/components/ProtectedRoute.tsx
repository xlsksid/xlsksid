import { Navigate, Outlet } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { RootState } from '@/store';

interface Props {
  roles: string[];
}

export default function ProtectedRoute({ roles }: Props) {
  const { token, role } = useSelector((s: RootState) => s.auth);

  if (!token) return <Navigate to="/login" replace />;
  if (role && !roles.includes(role)) return <Navigate to="/" replace />;

  return <Outlet />;
}
