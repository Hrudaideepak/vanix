import React, { createContext, useState, useContext, useEffect } from 'react';
import { adminLogin } from '../services/api';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
  const [admin, setAdmin] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('adminToken');
    const adminData = localStorage.getItem('adminData');
    if (token && adminData) {
      setAdmin(JSON.parse(adminData));
    }
    setLoading(false);
  }, []);

  const login = async (email, password) => {
    const response = await adminLogin(email, password);
    const { success, accessToken, user } = response.data;
    if (success && accessToken && user) {
      if (user.role !== 'admin' && user.role !== 'super-admin') {
        throw new Error('Access denied. Admin role required.');
      }
      localStorage.setItem('adminToken', accessToken);
      localStorage.setItem('adminData', JSON.stringify(user));
      setAdmin(user);
      return user;
    } else {
      throw new Error(response.data.message || 'Login failed');
    }
  };

  const logout = () => {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminData');
    setAdmin(null);
  };

  return (
    <AuthContext.Provider value={{ admin, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};
