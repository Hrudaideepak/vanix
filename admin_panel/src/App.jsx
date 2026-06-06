import React, { useState, useEffect } from 'react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { 
  Play, Tv, Users, DollarSign, Plus, Trash2, 
  Settings, LogOut, UploadCloud, Shield, CheckCircle, 
  Video, Layers, Ticket, TrendingUp, Search
} from 'lucide-react';

const API_URL = 'http://localhost:5000/api';

const initialPayments = [
  { id: 'tx_101', user: 'user@vanix.com', amount: 499, status: 'Success', date: '2026-06-01' },
  { id: 'tx_102', user: 'test_dev@vanix.com', amount: 999, status: 'Success', date: '2026-05-28' },
  { id: 'tx_103', user: 'guest@vanix.com', amount: 199, status: 'Failed', date: '2026-05-20' },
];

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [token, setToken] = useState(localStorage.getItem('admin_token') || '');
  const [contents, setContents] = useState([]);
  const [users, setUsers] = useState([]);
  const [payments, setPayments] = useState(initialPayments);
  const [analytics, setAnalytics] = useState({
    totalUsers: 0,
    activeUsers: 0,
    moviesUploaded: 0,
    monthlyRevenue: 0,
    mostWatched: [],
    mostSearched: [],
  });

  // Content Upload Form States
  const [newTitle, setNewTitle] = useState('');
  const [newType, setNewType] = useState('Movie');
  const [newGenre, setNewGenre] = useState('Sci-Fi');
  const [newRating, setNewRating] = useState('8.0');
  const [newYear, setNewYear] = useState('2024');
  const [newUrl, setNewUrl] = useState('');
  const [isPremium, setIsPremium] = useState(true);
  const [isFeatured, setIsFeatured] = useState(false);
  const [newDescription, setNewDescription] = useState('Premium streaming cinema experience.');
  const [newDuration, setNewDuration] = useState('2h 15m');
  const [newCast, setNewCast] = useState('Alexander Vance, Elena Rostova');
  const [newCrew, setNewCrew] = useState('Marcus Sterling (Director)');
  const [isUploading, setIsUploading] = useState(false);

  // Coupon Generator State
  const [coupons, setCoupons] = useState(['WELCOME50', 'VANIXFREE']);
  const [newCoupon, setNewCoupon] = useState('');

  // Auto admin login
  useEffect(() => {
    const autoLoginAdmin = async () => {
      if (!token) {
        try {
          const res = await fetch(`${API_URL}/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: 'admin@vanix.com', password: 'adminpassword123' })
          });
          const data = await res.json();
          if (data.success) {
            localStorage.setItem('admin_token', data.accessToken);
            setToken(data.accessToken);
          }
        } catch (err) {
          console.error('Auto login admin failed:', err);
        }
      }
    };
    autoLoginAdmin();
  }, [token]);

  // Fetch data
  useEffect(() => {
    if (!token) return;

    const fetchAnalytics = async () => {
      try {
        const res = await fetch(`${API_URL}/analytics`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        const data = await res.json();
        if (data.success) {
          setAnalytics(data.data);
        }
      } catch (err) {
        console.error('Failed to fetch analytics:', err);
      }
    };

    const fetchContents = async () => {
      try {
        const res = await fetch(`${API_URL}/movies`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        const data = await res.json();
        if (data.success) {
          setContents(data.data);
        }
      } catch (err) {
        console.error('Failed to fetch contents:', err);
      }
    };

    const fetchUsers = async () => {
      try {
        const res = await fetch(`${API_URL}/users`, {
          headers: { 'Authorization': `Bearer ${token}` }
        });
        const data = await res.json();
        if (data.success) {
          setUsers(data.data);
        }
      } catch (err) {
        console.error('Failed to fetch users:', err);
      }
    };

    if (activeTab === 'dashboard') {
      fetchAnalytics();
      fetchContents();
    } else if (activeTab === 'content') {
      fetchContents();
    } else if (activeTab === 'users') {
      fetchUsers();
    }
  }, [activeTab, token]);

  const handleAddContent = async (e) => {
    e.preventDefault();
    if (!newTitle.trim() || !newUrl.trim()) return;

    setIsUploading(true);
    try {
      const endpoint = newType.toLowerCase() === 'series' ? '/uploadSeries' : '/uploadMovie';
      const res = await fetch(`${API_URL}${endpoint}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          title: newTitle,
          description: newDescription,
          thumbnailUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=500',
          bannerUrl: 'https://images.unsplash.com/photo-1506318137071-a8e063b4bec0?w=1000',
          videoUrl: newUrl,
          rating: parseFloat(newRating) || 8.0,
          releaseYear: parseInt(newYear) || 2024,
          duration: newDuration,
          genres: [newGenre],
          isPremium: isPremium,
          isFeatured: isFeatured,
          cast: newCast.split(',').map(c => c.trim()),
          crew: newCrew.split(',').map(c => c.trim()),
        })
      });
      const data = await res.json();
      if (data.success) {
        setContents([data.data, ...contents]);
        setNewTitle('');
        setNewUrl('');
        alert(`🎉 Successfully uploaded: ${newTitle} and initialized HLS transcoding pipeline.`);
      } else {
        alert(`Upload failed: ${data.message}`);
      }
    } catch (err) {
      console.error(err);
      alert('Error connecting to upload pipeline server.');
    } finally {
      setIsUploading(false);
    }
  };

  const handleDeleteContent = async (id) => {
    if (!confirm('Are you sure you want to remove this content?')) return;

    try {
      const res = await fetch(`${API_URL}/movie/${id}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const data = await res.json();
      if (data.success) {
        setContents(contents.filter(item => (item._id || item.id) !== id));
      } else {
        alert(data.message);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleToggleUserBan = async (id) => {
    try {
      const res = await fetch(`${API_URL}/users/${id}/ban`, {
        method: 'PUT',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const data = await res.json();
      if (data.success) {
        setUsers(users.map(u => (u._id || u.id) === id ? { ...u, isBanned: data.data.isBanned } : u));
      } else {
        alert(data.message);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleAddCoupon = (e) => {
    e.preventDefault();
    if (!newCoupon.trim()) return;
    setCoupons([...coupons, newCoupon.toUpperCase()]);
    setNewCoupon('');
  };

  // Construct chart data dynamically from monthlyRevenue
  const revenueData = [
    { name: 'Jan', revenue: Math.max(12000, analytics.monthlyRevenue * 0.4) },
    { name: 'Feb', revenue: Math.max(19000, analytics.monthlyRevenue * 0.6) },
    { name: 'Mar', revenue: Math.max(26000, analytics.monthlyRevenue * 0.7) },
    { name: 'Apr', revenue: Math.max(32000, analytics.monthlyRevenue * 0.8) },
    { name: 'May', revenue: Math.max(38000, analytics.monthlyRevenue * 0.9) },
    { name: 'Jun', revenue: analytics.monthlyRevenue || 45820 },
  ];

  return (
    <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#050505', color: '#F8FAFC' }}>
      
      {/* Sidebar Command Console */}
      <aside className="glass-panel" style={{ width: '280px', margin: '1rem', padding: '2rem', display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
        <div style={{ fontSize: '1.5rem', fontWeight: 800, letterSpacing: '2px', display: 'flex', alignItems: 'center', gap: '10px' }}>
          <span style={{ fontSize: '1.8rem' }}>🌌</span> VANIX
          <span style={{ fontSize: '0.65rem', backgroundColor: '#7C3AED', padding: '3px 8px', borderRadius: '6px', fontWeight: 'bold' }}>HQ</span>
        </div>

        <nav style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem', marginTop: '1.5rem' }}>
          <button 
            className="btn-glass" 
            style={{ display: 'flex', alignItems: 'center', gap: '12px', textAlign: 'left', width: '100%', background: activeTab === 'dashboard' ? 'rgba(124, 58, 237, 0.15)' : '', borderColor: activeTab === 'dashboard' ? '#7C3AED' : '' }}
            onClick={() => setActiveTab('dashboard')}
          >
            <TrendingUp size={18} color="#7C3AED" /> Dashboard
          </button>
          
          <button 
            className="btn-glass" 
            style={{ display: 'flex', alignItems: 'center', gap: '12px', textAlign: 'left', width: '100%', background: activeTab === 'content' ? 'rgba(124, 58, 237, 0.15)' : '', borderColor: activeTab === 'content' ? '#7C3AED' : '' }}
            onClick={() => setActiveTab('content')}
          >
            <Video size={18} color="#7C3AED" /> Content Manager
          </button>
          
          <button 
            className="btn-glass" 
            style={{ display: 'flex', alignItems: 'center', gap: '12px', textAlign: 'left', width: '100%', background: activeTab === 'users' ? 'rgba(124, 58, 237, 0.15)' : '', borderColor: activeTab === 'users' ? '#7C3AED' : '' }}
            onClick={() => setActiveTab('users')}
          >
            <Users size={18} color="#7C3AED" /> User Controls
          </button>
          
          <button 
            className="btn-glass" 
            style={{ display: 'flex', alignItems: 'center', gap: '12px', textAlign: 'left', width: '100%', background: activeTab === 'billing' ? 'rgba(124, 58, 237, 0.15)' : '', borderColor: activeTab === 'billing' ? '#7C3AED' : '' }}
            onClick={() => setActiveTab('billing')}
          >
            <Ticket size={18} color="#7C3AED" /> Billing & Plans
          </button>
        </nav>

        <div style={{ marginTop: 'auto', display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '10px', borderRadius: '12px', background: 'rgba(255, 255, 255, 0.02)' }}>
            <Shield size={18} color="#2563EB" />
            <div>
              <p style={{ fontSize: '0.8rem', margin: 0, fontWeight: 'bold' }}>Secured Terminal</p>
              <p style={{ fontSize: '0.65rem', margin: 0, color: '#CBD5E1' }}>JWT / Role Bind Active</p>
            </div>
          </div>
          <button className="btn-glass" style={{ color: '#EF4444', display: 'flex', alignItems: 'center', gap: '8px', justifyContent: 'center' }}>
            <LogOut size={16} /> Exit Terminal
          </button>
        </div>
      </aside>

      {/* Main Terminal Screen */}
      <main style={{ flex: 1, padding: '2rem 1.5rem', overflowY: 'auto' }}>
        
        {/* Tab 1: Dashboard Analytics */}
        {activeTab === 'dashboard' && (
          <div className="fade-in">
            <h2 style={{ fontSize: '2.2rem', fontWeight: 800, marginBottom: '0.5rem' }}>Global Command Overview</h2>
            <p style={{ color: '#CBD5E1', marginBottom: '2rem' }}>Audit and monitor system bandwidth, revenues, and active media nodes.</p>

            {/* Stats Cards */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '1.5rem', marginBottom: '2.5rem' }}>
              <div className="glass-panel" style={{ padding: '1.5rem', display: 'flex', alignItems: 'center', gap: '1.25rem' }}>
                <div style={{ padding: '12px', borderRadius: '12px', background: 'rgba(37, 99, 235, 0.15)', color: '#2563EB' }}>
                  <Play size={24} />
                </div>
                <div>
                  <p style={{ fontSize: '0.85rem', color: '#CBD5E1', margin: 0 }}>Active Streams</p>
                  <p style={{ fontSize: '1.6rem', fontWeight: 800, margin: '2px 0 0 0', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    {analytics.activeUsers || 0}
                    <span style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: '#22C55E', display: 'inline-block', boxShadow: '0 0 8px #22C55E' }}></span>
                  </p>
                </div>
              </div>

              <div className="glass-panel" style={{ padding: '1.5rem', display: 'flex', alignItems: 'center', gap: '1.25rem' }}>
                <div style={{ padding: '12px', borderRadius: '12px', background: 'rgba(124, 58, 237, 0.15)', color: '#7C3AED' }}>
                  <Tv size={24} />
                </div>
                <div>
                  <p style={{ fontSize: '0.85rem', color: '#CBD5E1', margin: 0 }}>Content Titles</p>
                  <p style={{ fontSize: '1.6rem', fontWeight: 800, margin: '2px 0 0 0' }}>{analytics.moviesUploaded || contents.length}</p>
                </div>
              </div>

              <div className="glass-panel" style={{ padding: '1.5rem', display: 'flex', alignItems: 'center', gap: '1.25rem' }}>
                <div style={{ padding: '12px', borderRadius: '12px', background: 'rgba(37, 99, 235, 0.15)', color: '#2563EB' }}>
                  <Users size={24} />
                </div>
                <div>
                  <p style={{ fontSize: '0.85rem', color: '#CBD5E1', margin: 0 }}>Subscribers</p>
                  <p style={{ fontSize: '1.6rem', fontWeight: 800, margin: '2px 0 0 0' }}>{analytics.totalUsers || 0}</p>
                </div>
              </div>

              <div className="glass-panel" style={{ padding: '1.5rem', display: 'flex', alignItems: 'center', gap: '1.25rem' }}>
                <div style={{ padding: '12px', borderRadius: '12px', background: 'rgba(124, 58, 237, 0.15)', color: '#7C3AED' }}>
                  <DollarSign size={24} />
                </div>
                <div>
                  <p style={{ fontSize: '0.85rem', color: '#CBD5E1', margin: 0 }}>Monthly Earnings</p>
                  <p style={{ fontSize: '1.6rem', fontWeight: 800, margin: '2px 0 0 0' }}>${analytics.monthlyRevenue || 0}</p>
                </div>
              </div>
            </div>

            {/* Recharts Area Chart */}
            <div className="glass-panel" style={{ padding: '2rem', height: '400px' }}>
              <h3 style={{ marginBottom: '1.5rem', fontSize: '1.2rem', fontWeight: 700 }}>Monthly Revenue Operations</h3>
              <ResponsiveContainer width="100%" height="85%">
                <AreaChart data={revenueData}>
                  <defs>
                    <linearGradient id="colorRev" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#7C3AED" stopOpacity={0.4}/>
                      <stop offset="95%" stopColor="#2563EB" stopOpacity={0.0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(248, 250, 252, 0.05)" />
                  <XAxis dataKey="name" stroke="#CBD5E1" />
                  <YAxis stroke="#CBD5E1" />
                  <Tooltip contentStyle={{ backgroundColor: '#121214', border: '1px solid rgba(248,250,252,0.1)' }} />
                  <Area type="monotone" dataKey="revenue" stroke="#7C3AED" strokeWidth={3} fillOpacity={1} fill="url(#colorRev)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>
        )}

        {/* Tab 2: Content Manager */}
        {activeTab === 'content' && (
          <div className="fade-in" style={{ display: 'grid', gridTemplateColumns: '1fr 1.5fr', gap: '2rem' }}>
            
            {/* Left side: Upload Form */}
            <div className="glass-panel" style={{ padding: '2rem', height: 'fit-content' }}>
              <h3 style={{ fontSize: '1.3rem', fontWeight: 700, marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <UploadCloud size={20} color="#7C3AED" /> Content Studio
              </h3>
              
              <form onSubmit={handleAddContent} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
                <div>
                  <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Title</label>
                  <input 
                    type="text" 
                    value={newTitle} 
                    onChange={e => setNewTitle(e.target.value)} 
                    style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}
                    placeholder="e.g. Alien Horizon" 
                    required 
                  />
                </div>

                <div>
                  <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Description</label>
                  <textarea 
                    value={newDescription} 
                    onChange={e => setNewDescription(e.target.value)} 
                    rows="2"
                    style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF', resize: 'none' }}
                  />
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                  <div>
                    <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Type</label>
                    <select value={newType} onChange={e => setNewType(e.target.value)} style={{ width: '100%', padding: '10px', background: '#121214', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}>
                      <option>Movie</option>
                      <option>Series</option>
                    </select>
                  </div>
                  <div>
                    <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Genre</label>
                    <select value={newGenre} onChange={e => setNewGenre(e.target.value)} style={{ width: '100%', padding: '10px', background: '#121214', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}>
                      <option>Sci-Fi</option>
                      <option>Cyberpunk</option>
                      <option>Action</option>
                      <option>Thriller</option>
                      <option>Fantasy</option>
                      <option>Kids</option>
                    </select>
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                  <div>
                    <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>IMDb Score</label>
                    <input type="number" step="0.1" min="1" max="10" value={newRating} onChange={e => setNewRating(e.target.value)} style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }} />
                  </div>
                  <div>
                    <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Release Year</label>
                    <input type="number" value={newYear} onChange={e => setNewYear(e.target.value)} style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }} />
                  </div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                  <div>
                    <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Duration</label>
                    <input type="text" value={newDuration} onChange={e => setNewDuration(e.target.value)} style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }} placeholder="e.g. 2h 10m" />
                  </div>
                  <div>
                    <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Cast</label>
                    <input type="text" value={newCast} onChange={e => setNewCast(e.target.value)} style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }} />
                  </div>
                </div>

                <div>
                  <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Video Source URL (HLS / MP4)</label>
                  <input 
                    type="url" 
                    value={newUrl} 
                    onChange={e => setNewUrl(e.target.value)} 
                    style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}
                    placeholder="https://commondatastorage.googleapis.com/..." 
                    required
                  />
                </div>

                <div style={{ display: 'flex', gap: '15px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <input type="checkbox" checked={isPremium} onChange={e => setIsPremium(e.target.checked)} id="premCheck" style={{ width: '16px', height: '16px' }} />
                    <label htmlFor="premCheck" style={{ fontSize: '0.8rem', color: '#CBD5E1', cursor: 'pointer' }}>Premium VIP</label>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <input type="checkbox" checked={isFeatured} onChange={e => setIsFeatured(e.target.checked)} id="featCheck" style={{ width: '16px', height: '16px' }} />
                    <label htmlFor="featCheck" style={{ fontSize: '0.8rem', color: '#CBD5E1', cursor: 'pointer' }}>Feature Banner</label>
                  </div>
                </div>

                <button
                  className="btn-premium"
                  type="submit"
                  disabled={isUploading}
                  style={{
                    justifyContent: 'center',
                    opacity: isUploading ? 0.7 : 1,
                    cursor: isUploading ? 'not-allowed' : 'pointer'
                  }}
                >
                  {isUploading ? 'Transcoding...' : 'Transcode & Register Video'}
                </button>
              </form>
            </div>

            {/* Right side: Media List */}
            <div className="glass-panel" style={{ padding: '2rem' }}>
              <h3 style={{ fontSize: '1.3rem', fontWeight: 700, marginBottom: '1.5rem' }}>Active Media Database</h3>
              
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
                  <thead>
                    <tr style={{ borderBottom: '1px solid rgba(248,250,252,0.1)', color: '#CBD5E1', fontSize: '0.85rem' }}>
                      <th style={{ paddingBottom: '10px' }}>Media Details</th>
                      <th style={{ paddingBottom: '10px' }}>Classification</th>
                      <th style={{ paddingBottom: '10px' }}>Rating</th>
                      <th style={{ paddingBottom: '10px' }}>Release</th>
                      <th style={{ paddingBottom: '10px', textAlign: 'right' }}>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {contents.map((item) => (
                      <tr key={item._id || item.id} style={{ borderBottom: '1px solid rgba(248,250,252,0.05)', fontSize: '0.9rem' }}>
                        <td style={{ padding: '14px 0', fontWeight: 'bold' }}>
                          {item.title} 
                          {(item.isPremium || item.premium) && <span style={{ marginLeft: '8px', fontSize: '0.65rem', backgroundColor: '#F59E0B', color: '#000', padding: '2px 6px', borderRadius: '4px', fontWeight: 'bold' }}>PREMIUM</span>}
                          {item.isFeatured && <span style={{ marginLeft: '4px', fontSize: '0.65rem', backgroundColor: '#7C3AED', color: '#FFF', padding: '2px 6px', borderRadius: '4px', fontWeight: 'bold' }}>FEATURED</span>}
                        </td>
                        <td>{item.type} ({item.genres ? item.genres.join(', ') : item.genre})</td>
                        <td>⭐ {item.rating}</td>
                        <td>{item.releaseYear}</td>
                        <td style={{ padding: '14px 0', textAlign: 'right' }}>
                          <button
                            onClick={() => handleDeleteContent(item._id || item.id)}
                            style={{ background: 'none', border: 'none', color: '#EF4444', cursor: 'pointer' }}
                            aria-label="Delete content"
                            title="Delete content"
                          >
                            <Trash2 size={16} />
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

          </div>
        )}

        {/* Tab 3: User Controls */}
        {activeTab === 'users' && (
          <div className="fade-in glass-panel" style={{ padding: '2rem' }}>
            <h2 style={{ fontSize: '1.8rem', fontWeight: 800, marginBottom: '0.5rem' }}>User Control Registry</h2>
            <p style={{ color: '#CBD5E1', marginBottom: '2rem' }}>Review accounts, modify access levels, and suspend active sessions.</p>

            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid rgba(248,250,252,0.1)', color: '#CBD5E1', fontSize: '0.85rem' }}>
                  <th style={{ paddingBottom: '12px' }}>Email Address</th>
                  <th style={{ paddingBottom: '12px' }}>Access Rank</th>
                  <th style={{ paddingBottom: '12px' }}>Subscription Plan</th>
                  <th style={{ paddingBottom: '12px' }}>System Status</th>
                  <th style={{ paddingBottom: '12px', textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.map(u => (
                  <tr key={u._id || u.id} style={{ borderBottom: '1px solid rgba(248,250,252,0.05)', fontSize: '0.9rem' }}>
                    <td style={{ padding: '16px 0', fontWeight: 'bold' }}>{u.email}</td>
                    <td>{u.role}</td>
                    <td>
                      <span style={{ padding: '3px 8px', borderRadius: '4px', fontSize: '0.75rem', backgroundColor: (u.subscriptionPlan || u.plan) === 'premium' ? 'rgba(124, 58, 237, 0.2)' : 'rgba(255,255,255,0.05)', color: (u.subscriptionPlan || u.plan) === 'premium' ? '#7C3AED' : '#F8FAFC' }}>
                        {(u.subscriptionPlan || u.plan || 'free').toUpperCase()}
                      </span>
                    </td>
                    <td>
                      <span style={{ color: u.isBanned ? '#EF4444' : '#22C55E', fontWeight: 'bold' }}>
                        {u.isBanned ? 'BANNED' : 'ACTIVE'}
                      </span>
                    </td>
                    <td style={{ padding: '16px 0', textAlign: 'right' }}>
                      <button 
                        onClick={() => handleToggleUserBan(u._id || u.id)} 
                        className="btn-glass" 
                        style={{ padding: '6px 12px', fontSize: '0.8rem', color: u.isBanned ? '#22C55E' : '#EF4444', borderColor: u.isBanned ? 'rgba(34,197,94,0.2)' : 'rgba(239,68,68,0.2)' }}
                      >
                        {u.isBanned ? 'Revoke Ban' : 'Ban User'}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Tab 4: Billing & Plans */}
        {activeTab === 'billing' && (
          <div className="fade-in" style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '2rem' }}>
            
            {/* Audit log */}
            <div className="glass-panel" style={{ padding: '2rem' }}>
              <h3 style={{ fontSize: '1.3rem', fontWeight: 700, marginBottom: '1.5rem' }}>Transaction Audit Ledger</h3>
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
                <thead>
                  <tr style={{ borderBottom: '1px solid rgba(248,250,252,0.1)', color: '#CBD5E1', fontSize: '0.85rem' }}>
                    <th style={{ paddingBottom: '12px' }}>Tx ID</th>
                    <th style={{ paddingBottom: '12px' }}>Account</th>
                    <th style={{ paddingBottom: '12px' }}>Amount</th>
                    <th style={{ paddingBottom: '12px' }}>Timestamp</th>
                    <th style={{ paddingBottom: '12px', textAlign: 'right' }}>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {payments.map(p => (
                    <tr key={p.id} style={{ borderBottom: '1px solid rgba(248,250,252,0.05)', fontSize: '0.9rem' }}>
                      <td style={{ padding: '14px 0', fontFamily: 'monospace' }}>{p.id}</td>
                      <td>{p.user}</td>
                      <td>${(p.amount / 100).toFixed(2)}</td>
                      <td>{p.date}</td>
                      <td style={{ padding: '14px 0', textAlign: 'right' }}>
                        <span style={{ fontSize: '0.75rem', padding: '3px 8px', borderRadius: '4px', backgroundColor: p.status === 'Success' ? 'rgba(34,197,94,0.15)' : 'rgba(239,68,68,0.15)', color: p.status === 'Success' ? '#22C55E' : '#EF4444' }}>
                          {p.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Coupons manager */}
            <div className="glass-panel" style={{ padding: '2rem', height: 'fit-content' }}>
              <h3 style={{ fontSize: '1.3rem', fontWeight: 700, marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Ticket size={20} color="#7C3AED" /> Promotions Desk
              </h3>
              
              <form onSubmit={handleAddCoupon} style={{ display: 'flex', gap: '8px', marginBottom: '1.5rem' }}>
                <input 
                  type="text" 
                  value={newCoupon} 
                  onChange={e => setNewCoupon(e.target.value)} 
                  style={{ flex: 1, padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}
                  placeholder="e.g. VANIX50" 
                  required 
                />
                <button
                  className="btn-premium"
                  type="submit"
                  style={{ padding: '10px 14px' }}
                  aria-label="Add coupon"
                  title="Add coupon"
                >
                  <Plus size={16} />
                </button>
              </form>

              <p style={{ fontSize: '0.8rem', color: '#CBD5E1', marginBottom: '10px', fontWeight: 'bold' }}>Active Promo Keys</p>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                {coupons.map((code, idx) => (
                  <div key={idx} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 14px', borderRadius: '8px', backgroundColor: 'rgba(255, 255, 255, 0.03)', border: '1px solid rgba(248, 250, 252, 0.05)' }}>
                    <span style={{ fontSize: '0.9rem', fontWeight: 'bold', fontFamily: 'monospace', color: '#7C3AED' }}>{code}</span>
                    <span style={{ fontSize: '0.7rem', backgroundColor: 'rgba(34,197,94,0.15)', color: '#22C55E', padding: '2px 6px', borderRadius: '4px' }}>ACTIVE</span>
                  </div>
                ))}
              </div>
            </div>

          </div>
        )}

      </main>
    </div>
  );
}
