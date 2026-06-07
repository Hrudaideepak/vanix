import React, { useState, useEffect } from 'react';
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  BarChart, Bar, PieChart, Pie, Cell, Legend, LineChart, Line
} from 'recharts';
import { TrendingUp, BarChart3, Users, Play, Clock, Database, ArrowUpRight, ArrowDownRight } from 'lucide-react';
import { getDashboardStats } from '../services/api';

const COLORS = ['#7C3AED', '#2563EB', '#F59E0B', '#10B981', '#EF4444', '#EC4899'];

export default function Analytics() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    async function loadStats() {
      try {
        setLoading(true);
        setError('');
        const res = await getDashboardStats();
        if (res.data.success) {
          setStats(res.data.data);
        }
      } catch (err) {
        console.error(err);
        setError('Failed to fetch analytics metrics from the OTT logging node.');
      } finally {
        setLoading(false);
      }
    }
    loadStats();
  }, []);

  // Mock data for graphs
  const subGrowthData = [
    { name: 'Jan', subscribers: 1200, active: 800 },
    { name: 'Feb', subscribers: 1850, active: 1100 },
    { name: 'Mar', subscribers: 2400, active: 1600 },
    { name: 'Apr', subscribers: 3100, active: 2200 },
    { name: 'May', subscribers: 4300, active: 3100 },
    { name: 'Jun', subscribers: stats?.totalUsers || 5800, active: stats?.activeUsers || 4200 },
  ];

  const genreDistribution = [
    { name: 'Sci-Fi', value: 35 },
    { name: 'Cyberpunk', value: 25 },
    { name: 'Action', value: 20 },
    { name: 'Thriller', value: 12 },
    { name: 'Fantasy', value: 8 },
  ];

  const bandwidthUsage = [
    { name: '00:00', load: 120 },
    { name: '04:00', load: 80 },
    { name: '08:00', load: 150 },
    { name: '12:00', load: 310 },
    { name: '16:00', load: 450 },
    { name: '20:00', load: 680 },
  ];

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
        <p style={{ fontWeight: 'bold', fontSize: '1.2rem', color: '#7C3AED' }}>Downloading logging metrics...</p>
      </div>
    );
  }

  return (
    <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      
      <div>
        <h2 style={{ fontSize: '2.2rem', fontWeight: 800, marginBottom: '0.5rem', background: 'linear-gradient(to right, #F8FAFC, #CBD5E1)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
          Deep-Dive Data Analytics
        </h2>
        <p style={{ color: '#CBD5E1', margin: 0 }}>Review real-time watch telemetry, CDN server load, and subscription statistics.</p>
      </div>

      {error && (
        <div style={{ padding: '1rem', backgroundColor: 'rgba(239, 68, 68, 0.15)', border: '1px solid #EF4444', borderRadius: '8px', color: '#FCA5A5', fontSize: '0.9rem' }}>
          {error}
        </div>
      )}

      {/* Analytics KPI Row */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1.5rem' }}>
        
        <div className="glass-panel" style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '0.85rem', color: '#CBD5E1' }}>Avg. Session Duration</span>
            <Clock size={18} color="#7C3AED" />
          </div>
          <p style={{ fontSize: '1.8rem', fontWeight: 900, margin: 0 }}>42.6 mins</p>
          <span style={{ fontSize: '0.75rem', color: '#22C55E', display: 'flex', alignItems: 'center', gap: '4px' }}>
            <ArrowUpRight size={12} /> +12.4% vs last week
          </span>
        </div>

        <div className="glass-panel" style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '0.85rem', color: '#CBD5E1' }}>CDN Bandwidth Out</span>
            <Database size={18} color="#2563EB" />
          </div>
          <p style={{ fontSize: '1.8rem', fontWeight: 900, margin: 0 }}>2.48 TB</p>
          <span style={{ fontSize: '0.75rem', color: '#22C55E', display: 'flex', alignItems: 'center', gap: '4px' }}>
            <ArrowUpRight size={12} /> +8.6% vs last week
          </span>
        </div>

        <div className="glass-panel" style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '0.85rem', color: '#CBD5E1' }}>Watch Sessions Initiated</span>
            <Play size={18} color="#7C3AED" />
          </div>
          <p style={{ fontSize: '1.8rem', fontWeight: 900, margin: 0 }}>18.4K</p>
          <span style={{ fontSize: '0.75rem', color: '#EF4444', display: 'flex', alignItems: 'center', gap: '4px' }}>
            <ArrowDownRight size={12} /> -1.2% vs last week
          </span>
        </div>

        <div className="glass-panel" style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '0.85rem', color: '#CBD5E1' }}>Active Premium Ratio</span>
            <Users size={18} color="#2563EB" />
          </div>
          <p style={{ fontSize: '1.8rem', fontWeight: 900, margin: 0 }}>68.2%</p>
          <span style={{ fontSize: '0.75rem', color: '#22C55E', display: 'flex', alignItems: 'center', gap: '4px' }}>
            <ArrowUpRight size={12} /> +2.8% vs last week
          </span>
        </div>

      </div>

      {/* Main Analytics Graphs Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: '2rem' }}>
        
        {/* Subscriber Growth - Recharts Line Chart */}
        <div className="glass-panel" style={{ padding: '2rem', minHeight: '380px', display: 'flex', flexDirection: 'column' }}>
          <h3 style={{ fontSize: '1.2rem', fontWeight: 700, marginBottom: '1.5rem' }}>Subscriber Retention & Growth</h3>
          <div style={{ flex: 1, minHeight: '260px' }}>
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={subGrowthData}>
                <defs>
                  <linearGradient id="colorSubs" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#7C3AED" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#7C3AED" stopOpacity={0.0}/>
                  </linearGradient>
                  <linearGradient id="colorAct" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#2563EB" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#2563EB" stopOpacity={0.0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(248, 250, 252, 0.05)" />
                <XAxis dataKey="name" stroke="#CBD5E1" fontSize={11} />
                <YAxis stroke="#CBD5E1" fontSize={11} />
                <Tooltip contentStyle={{ backgroundColor: '#121214', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#F8FAFC' }} />
                <Legend verticalAlign="top" height={36} />
                <Area type="monotone" name="Total Registered" dataKey="subscribers" stroke="#7C3AED" strokeWidth={2.5} fillOpacity={1} fill="url(#colorSubs)" />
                <Area type="monotone" name="Active Watchers" dataKey="active" stroke="#2563EB" strokeWidth={2.5} fillOpacity={1} fill="url(#colorAct)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Content Category breakdown - Recharts Pie Chart */}
        <div className="glass-panel" style={{ padding: '2rem', display: 'flex', flexDirection: 'column' }}>
          <h3 style={{ fontSize: '1.2rem', fontWeight: 700, marginBottom: '1.5rem' }}>Content Genre Breakdown</h3>
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '260px' }}>
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={genreDistribution}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={90}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {genreDistribution.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip contentStyle={{ backgroundColor: '#121214', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#F8FAFC' }} />
                <Legend layout="vertical" verticalAlign="middle" align="right" />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

      </div>

      {/* Secondary Graphs Row */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '2rem' }}>
        
        {/* CDN Server Load Line Chart */}
        <div className="glass-panel" style={{ padding: '2rem', display: 'flex', flexDirection: 'column' }}>
          <h3 style={{ fontSize: '1.2rem', fontWeight: 700, marginBottom: '1.5rem' }}>CDN Gateway Load (Gbps)</h3>
          <div style={{ flex: 1, minHeight: '220px' }}>
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={bandwidthUsage}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(248, 250, 252, 0.05)" />
                <XAxis dataKey="name" stroke="#CBD5E1" fontSize={11} />
                <YAxis stroke="#CBD5E1" fontSize={11} />
                <Tooltip contentStyle={{ backgroundColor: '#121214', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#F8FAFC' }} />
                <Line type="monotone" name="Bandwidth Load" dataKey="load" stroke="#2563EB" strokeWidth={3} dot={{ fill: '#2563EB', r: 4 }} activeDot={{ r: 6 }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Most watched list from database */}
        <div className="glass-panel" style={{ padding: '2rem', display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          <h3 style={{ fontSize: '1.25rem', fontWeight: 700, margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
            <BarChart3 size={18} color="#7C3AED" /> Spotlight Leaderboard (Most Watched)
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', marginTop: '0.5rem' }}>
            {(!stats?.mostWatched || stats.mostWatched.length === 0) ? (
              <p style={{ fontSize: '0.85rem', color: '#CBD5E1', textAlign: 'center', margin: '2rem 0' }}>No telemetry data loaded.</p>
            ) : (
              stats.mostWatched.slice(0, 4).map((item, idx) => (
                <div key={item._id || idx} style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <span style={{ fontSize: '1.1rem', fontWeight: 900, color: '#7C3AED', width: '20px' }}>#{idx + 1}</span>
                  <div style={{ flex: 1 }}>
                    <p style={{ margin: 0, fontSize: '0.9rem', fontWeight: 'bold' }}>{item.title}</p>
                    <p style={{ margin: 0, fontSize: '0.75rem', color: '#CBD5E1' }}>Genres: {item.genres ? item.genres.join(', ') : item.genre || 'Sci-Fi'}</p>
                  </div>
                  <span style={{ fontSize: '0.8rem', color: '#7C3AED', fontWeight: 'bold' }}>{item.watchCount || 124} plays</span>
                </div>
              ))
            )}
          </div>
        </div>

      </div>

    </div>
  );
}
