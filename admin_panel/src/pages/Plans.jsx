import React, { useState, useEffect } from 'react';
import { getPlans, createPlan, updatePlan, deletePlan } from '../services/api';
import { 
  Ticket, Plus, Trash2, Shield, CreditCard, DollarSign, 
  Percent, Calendar, Key, AlertCircle, CheckCircle, RefreshCw 
} from 'lucide-react';

const mockTransactions = [
  { id: 'tx_981', user: 'alex.vance@net.com', amount: 999, tier: 'Premium Tier', status: 'Success', date: '2026-06-07' },
  { id: 'tx_982', user: 'elena.rostova@sci.org', amount: 499, tier: 'Gold Tier', status: 'Success', date: '2026-06-06' },
  { id: 'tx_983', user: 'marcus.sterling@dir.com', amount: 199, tier: 'Silver Tier', status: 'Success', date: '2026-06-05' },
  { id: 'tx_984', user: 'guest_beta@vanix.com', amount: 999, tier: 'Premium Tier', status: 'Failed', date: '2026-06-04' },
  { id: 'tx_985', user: 'operator@terminal.io', amount: 499, tier: 'Gold Tier', status: 'Success', date: '2026-06-02' },
];

export default function Plans() {
  const [plans, setPlans] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  
  // Promo / Coupon Manager
  const [coupons, setCoupons] = useState([
    { code: 'VANIXHQ50', discount: 50, expiry: '2026-12-31', status: 'Active' },
    { code: 'STREAMFREE', discount: 100, expiry: '2026-08-30', status: 'Active' },
  ]);
  const [newCoupon, setNewCoupon] = useState({ code: '', discount: 20, expiry: '2026-12-31' });

  // Plan Modals / Forms
  const [modalOpen, setModalOpen] = useState(false);
  const [editingPlan, setEditingPlan] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    price: '',
    durationDays: '',
    description: '',
  });

  useEffect(() => {
    loadPlans();
  }, []);

  const loadPlans = async () => {
    try {
      setLoading(true);
      setError('');
      const res = await getPlans();
      if (res.data.success) {
        setPlans(res.data.data);
      }
    } catch (err) {
      console.error(err);
      setError('Could not download active billing structures from the payments endpoint.');
    } finally {
      setLoading(false);
    }
  };

  const handleOpenAdd = () => {
    setEditingPlan(null);
    setFormData({ name: '', price: '', durationDays: '30', description: '' });
    setModalOpen(true);
  };

  const handleEdit = (plan) => {
    setEditingPlan(plan);
    setFormData({
      name: plan.name,
      price: (plan.price / 100).toString(),
      durationDays: plan.durationDays.toString(),
      description: plan.description || 'Access level matching plan criteria.',
    });
    setModalOpen(true);
  };

  const handleDeletePlan = async (id, name) => {
    if (!confirm(`Are you sure you want to deactivate and remove billing plan: ${name}?`)) return;
    try {
      const res = await deletePlan(id);
      if (res.data.success) {
        setPlans(prev => prev.filter(p => p.id !== id));
        alert(`${name} has been purged from system memory.`);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleSubmitPlan = async (e) => {
    e.preventDefault();
    if (!formData.name || !formData.price || !formData.durationDays) return;

    try {
      const planPayload = {
        id: editingPlan ? editingPlan.id : formData.name.toLowerCase().replace(/\s+/g, '_'),
        name: formData.name,
        price: Math.round(parseFloat(formData.price) * 100), // convert to cents
        durationDays: parseInt(formData.durationDays),
        description: formData.description,
      };

      if (editingPlan) {
        await updatePlan(editingPlan.id, planPayload);
        setPlans(prev => prev.map(p => p.id === editingPlan.id ? { ...p, ...planPayload } : p));
        alert('Plan updated successfully (Mock database updated).');
      } else {
        await createPlan(planPayload);
        setPlans(prev => [...prev, planPayload]);
        alert('Plan registered successfully (Mock database updated).');
      }
      setModalOpen(false);
    } catch (err) {
      console.error(err);
    }
  };

  const handleAddCoupon = (e) => {
    e.preventDefault();
    if (!newCoupon.code) return;
    
    const uppercaseCode = newCoupon.code.toUpperCase().replace(/\s+/g, '');
    const newCouponObj = {
      code: uppercaseCode,
      discount: parseInt(newCoupon.discount) || 20,
      expiry: newCoupon.expiry || '2026-12-31',
      status: 'Active'
    };

    setCoupons(prev => [newCouponObj, ...prev]);
    setNewCoupon({ code: '', discount: 20, expiry: '2026-12-31' });
    alert(`🎉 Promotion Code ${uppercaseCode} activated!`);
  };

  const handleRemoveCoupon = (code) => {
    setCoupons(prev => prev.filter(c => c.code !== code));
  };

  return (
    <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h2 style={{ fontSize: '2.2rem', fontWeight: 800, marginBottom: '0.5rem', background: 'linear-gradient(to right, #F8FAFC, #CBD5E1)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
            Billing & Plans Center
          </h2>
          <p style={{ color: '#CBD5E1', margin: 0 }}>Configure subscription tiers, generate promotional vouchers, and view transactions.</p>
        </div>
        <button onClick={handleOpenAdd} className="btn-premium">
          <Plus size={18} /> Add Billing Tier
        </button>
      </div>

      {error && (
        <div style={{ padding: '1rem', backgroundColor: 'rgba(239, 68, 68, 0.15)', border: '1px solid #EF4444', borderRadius: '8px', color: '#FCA5A5', fontSize: '0.9rem' }}>
          {error}
        </div>
      )}

      {/* Plans Pricing Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1.5rem' }}>
        {loading ? (
          <div style={{ display: 'flex', justifyContent: 'center', gridColumn: '1/-1', padding: '2rem' }}>
            <p style={{ color: '#7C3AED', fontWeight: 'bold' }}>Loading subscription models...</p>
          </div>
        ) : (
          plans.map(plan => (
            <div className="glass-panel" key={plan.id} style={{ padding: '2rem', display: 'flex', flexDirection: 'column', gap: '1rem', border: plan.id === 'premium' ? '1.5px solid #7C3AED' : '1px solid var(--border-glass)', position: 'relative', overflow: 'hidden' }}>
              {plan.id === 'premium' && (
                <span style={{ position: 'absolute', top: '12px', right: '-32px', transform: 'rotate(45deg)', backgroundColor: '#7C3AED', color: '#FFF', fontSize: '0.6rem', padding: '4px 30px', fontWeight: 'bold', letterSpacing: '1px' }}>
                  BEST VALUE
                </span>
              )}
              
              <div>
                <h3 style={{ fontSize: '1.25rem', fontWeight: 800, margin: 0 }}>{plan.name}</h3>
                <p style={{ fontSize: '0.75rem', color: '#CBD5E1', marginTop: '4px' }}>Valid for {plan.durationDays} days</p>
              </div>

              <div style={{ display: 'flex', alignItems: 'baseline', gap: '4px', margin: '0.5rem 0' }}>
                <span style={{ fontSize: '2rem', fontWeight: 900, color: '#7C3AED' }}>₹{(plan.price / 100).toFixed(0)}</span>
                <span style={{ fontSize: '0.8rem', color: '#CBD5E1' }}>/ total duration</span>
              </div>

              <p style={{ fontSize: '0.8rem', color: '#CBD5E1', lineHeight: '1.4', flex: 1 }}>
                {plan.description || `Provides complete access to the ${plan.name} and OTT servers.`}
              </p>

              <div style={{ display: 'flex', gap: '10px', marginTop: '1rem' }}>
                <button onClick={() => handleEdit(plan)} className="btn-glass" style={{ flex: 1, padding: '6px 0', fontSize: '0.8rem' }}>
                  Modify
                </button>
                {plan.id !== 'free' && plan.id !== 'premium' && (
                  <button onClick={() => handleDeletePlan(plan.id, plan.name)} className="btn-glass" style={{ padding: '6px 10px', color: '#EF4444', borderColor: 'rgba(239, 68, 68, 0.2)' }} aria-label="Delete plan" title="Delete plan">
                    <Trash2 size={14} />
                  </button>
                )}
              </div>
            </div>
          ))
        )}
      </div>

      {/* Main Grid: Promo Center & Audit Log */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1.5fr', gap: '2rem' }}>
        
        {/* Promotion Center */}
        <div className="glass-panel" style={{ padding: '2rem', display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
          <h3 style={{ fontSize: '1.25rem', fontWeight: 700, margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Ticket size={20} color="#7C3AED" /> Promotions Desk
          </h3>

          <form onSubmit={handleAddCoupon} style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div>
              <label style={{ fontSize: '0.75rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Promo Code *</label>
              <input 
                type="text" 
                value={newCoupon.code}
                onChange={e => setNewCoupon({ ...newCoupon, code: e.target.value })}
                placeholder="e.g. VANIX50"
                style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF', textTransform: 'uppercase' }}
                required 
              />
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1.25fr', gap: '1rem' }}>
              <div>
                <label style={{ fontSize: '0.75rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Discount % *</label>
                <div style={{ display: 'flex', alignItems: 'center', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', paddingRight: '10px' }}>
                  <input 
                    type="number" 
                    min="1" 
                    max="100"
                    value={newCoupon.discount}
                    onChange={e => setNewCoupon({ ...newCoupon, discount: e.target.value })}
                    style={{ width: '100%', padding: '10px', background: 'transparent', border: 'none', color: '#FFF', outline: 'none' }}
                    required 
                  />
                  <Percent size={14} color="#CBD5E1" />
                </div>
              </div>
              <div>
                <label style={{ fontSize: '0.75rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Expires *</label>
                <input 
                  type="date" 
                  value={newCoupon.expiry}
                  onChange={e => setNewCoupon({ ...newCoupon, expiry: e.target.value })}
                  style={{ width: '100%', padding: '9px 10px', background: '#121214', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}
                  required 
                />
              </div>
            </div>

            <button type="submit" className="btn-premium" style={{ justifyContent: 'center' }}>
              Generate Promo Key
            </button>
          </form>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem', marginTop: '0.5rem' }}>
            <h4 style={{ fontSize: '0.85rem', fontWeight: 800, margin: 0, textTransform: 'uppercase', color: '#CBD5E1' }}>Active Promotions</h4>
            {coupons.length === 0 ? (
              <p style={{ fontSize: '0.8rem', color: '#CBD5E1', textAlign: 'center' }}>No active coupon configurations.</p>
            ) : (
              coupons.map(coupon => (
                <div key={coupon.code} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 14px', borderRadius: '8px', backgroundColor: 'rgba(255, 255, 255, 0.02)', border: '1px solid rgba(248, 250, 252, 0.05)' }}>
                  <div>
                    <span style={{ fontSize: '0.9rem', fontWeight: 'bold', fontFamily: 'monospace', color: '#7C3AED' }}>{coupon.code}</span>
                    <span style={{ fontSize: '0.75rem', color: '#CBD5E1', marginLeft: '10px' }}>({coupon.discount}% Off)</span>
                    <p style={{ margin: '2px 0 0 0', fontSize: '0.65rem', color: '#CBD5E1' }}>Expires: {coupon.expiry}</p>
                  </div>
                  <button onClick={() => handleRemoveCoupon(coupon.code)} style={{ background: 'none', border: 'none', color: '#EF4444', cursor: 'pointer' }} aria-label="Delete coupon" title="Delete coupon">
                    <Trash2 size={14} />
                  </button>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Transaction Audit Ledger */}
        <div className="glass-panel" style={{ padding: '2rem' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
            <h3 style={{ fontSize: '1.25rem', fontWeight: 700, margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
              <CreditCard size={20} color="#7C3AED" /> Transaction Audit Ledger
            </h3>
            <span style={{ fontSize: '0.7rem', color: '#22C55E', fontWeight: 'bold', backgroundColor: 'rgba(34, 197, 94, 0.15)', padding: '2px 6px', borderRadius: '4px' }}>
              Live Connections
            </span>
          </div>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid rgba(248,250,252,0.1)', color: '#CBD5E1', fontSize: '0.85rem' }}>
                  <th style={{ paddingBottom: '12px' }}>Tx ID</th>
                  <th style={{ paddingBottom: '12px' }}>Account</th>
                  <th style={{ paddingBottom: '12px' }}>Billing Tier</th>
                  <th style={{ paddingBottom: '12px' }}>Amount</th>
                  <th style={{ paddingBottom: '12px', textAlign: 'right' }}>Status</th>
                </tr>
              </thead>
              <tbody>
                {mockTransactions.map(tx => (
                  <tr key={tx.id} style={{ borderBottom: '1px solid rgba(248, 250, 252, 0.05)', fontSize: '0.9rem' }}>
                    <td style={{ padding: '14px 0', fontFamily: 'monospace', color: '#7C3AED' }}>{tx.id}</td>
                    <td style={{ fontWeight: '500' }}>
                      <div>
                        <span>{tx.user}</span>
                        <span style={{ display: 'block', fontSize: '0.7rem', color: '#CBD5E1', fontWeight: 'normal' }}>{tx.date}</span>
                      </div>
                    </td>
                    <td>{tx.tier}</td>
                    <td>₹{(tx.amount / 100).toFixed(2)}</td>
                    <td style={{ padding: '14px 0', textAlign: 'right' }}>
                      <span style={{ 
                        fontSize: '0.75rem', 
                        padding: '3px 8px', 
                        borderRadius: '4px', 
                        fontWeight: 'bold',
                        backgroundColor: tx.status === 'Success' ? 'rgba(34,197,94,0.15)' : 'rgba(239,68,68,0.15)', 
                        color: tx.status === 'Success' ? '#22C55E' : '#EF4444' 
                      }}>
                        {tx.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

      </div>

      {/* Plan edit modal */}
      {modalOpen && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.7)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 100, backdropFilter: 'blur(4px)' }}>
          <div className="glass-panel" style={{ width: '450px', padding: '2.5rem', display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
            <h3 style={{ fontSize: '1.5rem', fontWeight: 800, margin: 0 }}>
              {editingPlan ? 'Modify Billing Structure' : 'Deploy New Billing Model'}
            </h3>
            
            <form onSubmit={handleSubmitPlan} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
              <div>
                <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Plan Name *</label>
                <input 
                  type="text" 
                  value={formData.name} 
                  onChange={e => setFormData({ ...formData, name: e.target.value })} 
                  style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}
                  placeholder="e.g. Diamond Special"
                  required 
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                <div>
                  <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Price (INR) *</label>
                  <input 
                    type="number" 
                    step="0.01"
                    value={formData.price} 
                    onChange={e => setFormData({ ...formData, price: e.target.value })} 
                    style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}
                    placeholder="e.g. 299"
                    required 
                  />
                </div>
                <div>
                  <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Duration (Days) *</label>
                  <input 
                    type="number" 
                    value={formData.durationDays} 
                    onChange={e => setFormData({ ...formData, durationDays: e.target.value })} 
                    style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF' }}
                    required 
                  />
                </div>
              </div>

              <div>
                <label style={{ fontSize: '0.8rem', color: '#CBD5E1', display: 'block', marginBottom: '6px' }}>Description</label>
                <textarea 
                  value={formData.description} 
                  onChange={e => setFormData({ ...formData, description: e.target.value })} 
                  rows={3}
                  placeholder="Enter details about plan benefits and restrictions..."
                  style={{ width: '100%', padding: '10px', background: 'rgba(255,255,255,0.04)', border: '1px solid rgba(248,250,252,0.1)', borderRadius: '8px', color: '#FFF', resize: 'none' }}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '1rem', marginTop: '0.5rem' }}>
                <button type="button" onClick={() => setModalOpen(false)} className="btn-glass">
                  Cancel
                </button>
                <button type="submit" className="btn-premium">
                  Deploy Plan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
