import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5000/api',
});

// Request interceptor to add admin token
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor to handle 401
API.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('adminToken');
      localStorage.removeItem('adminData');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Admin Auth
export const adminLogin = (email, password) =>
  API.post('/login', { email, password });

// Movies
export const getMovies = () => API.get('/movies');
export const createMovie = (data) => API.post('/uploadMovie', data);
export const createSeries = (data) => API.post('/uploadSeries', data);
export const deleteMovie = (id) => API.delete(`/movie/${id}`);
export const uploadVideo = (formData, onProgress) =>
  API.post('/videos/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
    onUploadProgress: (progressEvent) => {
      const total = progressEvent.total || 1;
      const percent = Math.round((progressEvent.loaded * 100) / total);
      onProgress?.(percent);
    },
  });
export const getTranscodingStatus = (videoId) =>
  API.get(`/videos/status/${videoId}`);

// Users
export const getUsers = () => API.get('/users');
export const toggleUserBan = (id) => API.put(`/users/${id}/ban`);

// Subscription Plans
export const getPlans = () => API.get('/plans');
export const createPlan = (data) => Promise.resolve({ data: { success: true, data } });
export const updatePlan = (id, data) => Promise.resolve({ data: { success: true, data } });
export const deletePlan = (id) => Promise.resolve({ data: { success: true } });

// Dashboard Analytics
export const getDashboardStats = () => API.get('/analytics');

export default API;
