import React from 'react';
import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import {
  TrendingUp, Video, Users, Ticket, BarChart3, LogOut, Shield
} from 'lucide-react';

const navigation = [
  { name: 'Dashboard', href: '/', icon: TrendingUp },
  { name: 'Movies', href: '/movies', icon: Video },
  { name: 'Users', href: '/users', icon: Users },
  { name: 'Subscription Plans', href: '/plans', icon: Ticket },
  { name: 'Analytics', href: '/analytics', icon: BarChart3 },
];

export default function Layout() {
  const { logout, admin } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#000000', color: '#FFFFFF' }}>

      {/* Sidebar Command Console */}
      <aside className="glass-panel" style={{ width: '280px', margin: '1rem', padding: '2rem', display: 'flex', flexDirection: 'column', gap: '1.5rem', borderRight: '1px solid rgba(255, 0, 0, 0.1)' }}>
        <div style={{ fontSize: '1.5rem', fontWeight: 800, letterSpacing: '2px', display: 'flex', alignItems: 'center', gap: '10px' }}>
          <span style={{ fontSize: '1.8rem' }}>🌌</span> VANIX
          <span className="technical-tag" style={{ fontSize: '0.65rem', backgroundColor: '#FF0000', color: '#000000', padding: '3px 8px', fontWeight: 'bold' }}>HQ</span>
        </div>

        <nav style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem', marginTop: '1.5rem' }}>
          {navigation.map((item) => {
            const isActive = location.pathname === item.href;
            return (
              <Link
                key={item.name}
                to={item.href}
                className="btn-glass"
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  textAlign: 'left',
                  width: '100%',
                  textDecoration: 'none',
                  color: '#FFFFFF',
                  background: isActive ? 'rgba(255, 0, 0, 0.15)' : '',
                  borderColor: isActive ? '#FF0000' : ''
                }}
              >
                <item.icon size={18} color="#FF0000" /> {item.name}
              </Link>
            );
          })}
        </nav>

        <div style={{ marginTop: 'auto', display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '10px', background: 'rgba(255, 255, 255, 0.02)', border: '1px solid rgba(255, 0, 0, 0.1)' }}>
            <Shield size={18} color="#CC0000" />
            <div>
              <p style={{ fontSize: '0.8rem', margin: 0, fontWeight: 'bold' }}>Secured Terminal</p>
              <p style={{ fontSize: '0.65rem', margin: 0, color: '#E5E2E1' }}>Role: {(admin?.role || 'admin').toUpperCase()}</p>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="btn-glass"
            style={{ color: '#FFB4AB', display: 'flex', alignItems: 'center', gap: '8px', justifyContent: 'center', cursor: 'pointer', width: '100%' }}
          >
            <LogOut size={16} /> Exit Terminal
          </button>
        </div>
      </aside>

      {/* Main Terminal Screen */}
      <main style={{ flex: 1, padding: '2rem 1.5rem', overflowY: 'auto' }}>
        <Outlet />
      </main>
    </div>
  );
}
