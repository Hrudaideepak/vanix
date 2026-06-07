import React, { useState, useEffect } from 'react';
import { getUsers, toggleUserBan } from '../services/api';
import { Search, Shield, ShieldAlert, UserCheck, UserX, Loader2, RefreshCw } from 'lucide-react';

export default function Users() {
  const [users, setUsers] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      setLoading(true);
      setError('');
      const res = await getUsers();
      if (res.data.success) {
        setUsers(res.data.data);
      }
    } catch (err) {
      console.error(err);
      setError('Could not establish contact with security node or user directory.');
    } finally {
      setLoading(false);
    }
  };

  const handleToggleBan = async (id, email) => {
    if (!confirm(`Are you sure you want to alter security level/ban status of user: ${email}?`)) return;
    try {
      const res = await toggleUserBan(id);
      if (res.data.success) {
        setUsers(prev => 
          prev.map(u => (u._id || u.id) === id ? { ...u, isBanned: res.data.data.isBanned } : u)
        );
        alert(`Successfully toggled account status for ${email}`);
      }
    } catch (err) {
      console.error(err);
      alert('Action blocked by system security rules.');
    }
  };

  const filteredUsers = users.filter(user => 
    user.email.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h2 style={{ fontSize: '2.2rem', fontWeight: 800, marginBottom: '0.5rem', background: 'linear-gradient(to right, #F8FAFC, #CBD5E1)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
            User Controls Registry
          </h2>
          <p style={{ color: '#CBD5E1', margin: 0 }}>Manage subscriber accounts, restrict security tiers, and monitor active profiles.</p>
        </div>
        <button onClick={loadUsers} className="btn-glass" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <RefreshCw size={16} /> Sync Profiles
        </button>
      </div>

      {error && (
        <div style={{ padding: '1rem', backgroundColor: 'rgba(239, 68, 68, 0.15)', border: '1px solid #EF4444', borderRadius: '8px', color: '#FCA5A5', fontSize: '0.9rem' }}>
          {error}
        </div>
      )}

      {/* Control Console Search */}
      <div className="glass-panel" style={{ padding: '1.25rem 1.5rem', display: 'flex', alignItems: 'center', gap: '12px' }}>
        <Search size={20} color="#7C3AED" />
        <input 
          type="text" 
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          placeholder="Filter terminal directory by user identity email..."
          style={{ flex: 1, background: 'transparent', border: 'none', outline: 'none', color: '#FFF', fontSize: '0.95rem' }}
        />
        <span style={{ fontSize: '0.8rem', color: '#CBD5E1', padding: '4px 8px', borderRadius: '4px', backgroundColor: 'rgba(255,255,255,0.05)' }}>
          {filteredUsers.length} accounts found
        </span>
      </div>

      {/* Users Database Grid */}
      <div className="glass-panel" style={{ padding: '2rem' }}>
        {loading ? (
          <div style={{ display: 'flex', justifyContent: 'center', padding: '4rem' }}>
            <Loader2 className="animate-spin" size={32} color="#7C3AED" style={{ animation: 'spin 1s linear infinite' }} />
          </div>
        ) : filteredUsers.length === 0 ? (
          <div style={{ textTransform: 'capitalize', color: '#CBD5E1', textAlign: 'center', padding: '3rem' }}>
            No user matching search parameters exists in directory.
          </div>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid rgba(248,250,252,0.1)', color: '#CBD5E1', fontSize: '0.85rem' }}>
                  <th style={{ paddingBottom: '12px' }}>Identity Email</th>
                  <th style={{ paddingBottom: '12px' }}>Access Rank</th>
                  <th style={{ paddingBottom: '12px' }}>Subscription Plan</th>
                  <th style={{ paddingBottom: '12px' }}>Security Status</th>
                  <th style={{ paddingBottom: '12px', textAlign: 'right' }}>Security Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map(user => (
                  <tr key={user._id || user.id} style={{ borderBottom: '1px solid rgba(248, 250, 252, 0.05)', fontSize: '0.9rem' }}>
                    <td style={{ padding: '16px 0', fontWeight: 'bold' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        <div style={{ width: '32px', height: '32px', borderRadius: '50%', background: user.isBanned ? 'rgba(239, 68, 68, 0.15)' : 'rgba(124, 58, 237, 0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: user.isBanned ? '#EF4444' : '#7C3AED', fontWeight: 'bold', fontSize: '0.85rem' }}>
                          {user.email[0].toUpperCase()}
                        </div>
                        <div>
                          <p style={{ margin: 0 }}>{user.email}</p>
                          <p style={{ margin: 0, fontSize: '0.75rem', color: '#CBD5E1', fontWeight: 'normal' }}>Registered: {new Date(user.createdAt || Date.now()).toLocaleDateString()}</p>
                        </div>
                      </div>
                    </td>
                    <td style={{ textTransform: 'uppercase', fontSize: '0.8rem', letterSpacing: '1px', fontWeight: 'bold' }}>
                      {user.role || 'user'}
                    </td>
                    <td>
                      <span style={{ 
                        padding: '3px 8px', 
                        borderRadius: '4px', 
                        fontSize: '0.75rem', 
                        fontWeight: 'bold',
                        backgroundColor: (user.subscriptionPlan || user.plan) === 'premium' ? 'rgba(124, 58, 237, 0.2)' : 'rgba(255,255,255,0.05)', 
                        color: (user.subscriptionPlan || user.plan) === 'premium' ? '#7C3AED' : '#F8FAFC' 
                      }}>
                        {(user.subscriptionPlan || user.plan || 'free').toUpperCase()}
                      </span>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <span style={{ 
                          width: '8px', 
                          height: '8px', 
                          borderRadius: '50%', 
                          backgroundColor: user.isBanned ? '#EF4444' : '#22C55E', 
                          boxShadow: user.isBanned ? '0 0 8px #EF4444' : '0 0 8px #22C55E' 
                        }}></span>
                        <span style={{ color: user.isBanned ? '#EF4444' : '#22C55E', fontWeight: 'bold', fontSize: '0.8rem' }}>
                          {user.isBanned ? 'RESTRICTED' : 'OPERATIONAL'}
                        </span>
                      </div>
                    </td>
                    <td style={{ padding: '16px 0', textAlign: 'right' }}>
                      {user.role === 'super-admin' ? (
                        <span style={{ fontSize: '0.75rem', color: '#CBD5E1', fontStyle: 'italic' }}>Protected System Account</span>
                      ) : (
                        <button 
                          onClick={() => handleToggleBan(user._id || user.id, user.email)} 
                          className="btn-glass" 
                          style={{ 
                            padding: '6px 14px', 
                            fontSize: '0.8rem', 
                            color: user.isBanned ? '#22C55E' : '#EF4444', 
                            borderColor: user.isBanned ? 'rgba(34,197,94,0.2)' : 'rgba(239,68,68,0.2)',
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: '6px'
                          }}
                        >
                          {user.isBanned ? (
                            <>
                              <UserCheck size={14} /> Revoke Ban
                            </>
                          ) : (
                            <>
                              <UserX size={14} /> Restrict Account
                            </>
                          )}
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

    </div>
  );
}
