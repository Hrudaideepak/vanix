import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function ProtectedRoute({ children }) {
  const { admin, loading } = useAuth();
  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', backgroundColor: '#050505', color: '#F8FAFC' }}>
        <p style={{ fontWeight: 'bold', fontSize: '1.2rem' }}>Securing Session Connection...</p>
      </div>
    );
  }
  return admin ? children : <Navigate to="/login" replace />;
}
