import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import { ShieldAlert, Loader2 } from 'lucide-react';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await login(email, password);
      navigate('/');
    } catch (err) {
      setError(err.message || 'Authentication failed. Please verify credentials.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', alignItems: 'center', justifyContent: 'center', backgroundColor: '#050505', color: '#F8FAFC' }}>
      <div className="glass-panel" style={{ width: '420px', padding: '3rem 2.5rem', display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>

        <div style={{ textAlign: 'center' }}>
          <span style={{ fontSize: '3rem', display: 'block', marginBottom: '10px' }}>🌌</span>
          <h1 style={{ fontSize: '1.8rem', fontWeight: 900, letterSpacing: '2px', margin: 0 }}>VANIX HQ</h1>
          <p style={{ fontSize: '0.8rem', color: '#CBD5E1', marginTop: '6px' }}>Terminal Session Access Portal</p>
        </div>

        {error && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', backgroundColor: 'rgba(239, 68, 68, 0.15)', border: '1px solid #EF4444', padding: '12px', borderRadius: '8px', fontSize: '0.8rem', color: '#FCA5A5' }}>
            <ShieldAlert size={18} style={{ flexShrink: 0 }} />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
          <div>
            <label htmlFor="email" style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Identity Email</label>
            <input
              id="email"
              type="email"
              placeholder="admin@vanix.com"
              style={{ width: '100%', padding: '12px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div>
            <label htmlFor="password" style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Access Cryptokey</label>
            <input
              id="password"
              type="password"
              placeholder="••••••••"
              style={{ width: '100%', padding: '12px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          <button
            type="submit"
            className="btn-premium"
            disabled={loading}
            style={{ width: '100%', padding: '12px', justifyContent: 'center', marginTop: '10px', cursor: loading ? 'not-allowed' : 'pointer', display: 'flex', alignItems: 'center', gap: '8px' }}
          >
            {loading ? (
              <>
                <Loader2 className="animate-spin" size={18} style={{ animation: 'spin 1s linear infinite' }} /> Verifying Credentials...
              </>
            ) : 'Authenticate & Enter'}
          </button>
        </form>

        <div style={{ textAlign: 'center', fontSize: '0.75rem', color: '#CBD5E1', borderTop: '1px solid rgba(248, 250, 252, 0.05)', paddingTop: '15px' }}>
          For local development, use: <br/>
          <code style={{ color: '#7C3AED', fontWeight: 'bold' }}>admin@vanix.com</code> / <code style={{ color: '#7C3AED', fontWeight: 'bold' }}>adminpassword123</code>
        </div>
      </div>
    </div>
  );
}
