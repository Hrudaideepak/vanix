# 🌌 VANIX OTT Platform

> Unlimited Entertainment. One Universe.

VANIX is a complete, production-ready, futuristic OTT streaming platform containing a Flutter-based mobile application (Android/iOS), a scalable Node.js backend, and a modern Web Admin Panel.

---

## 📂 Project Modules

- [mobile_app/](file:///c:/Users/PC/Desktop/vanix/mobile_app) - Cross-platform Flutter App (Material 3, Provider, Clean Architecture)
- [backend/](file:///c:/Users/PC/Desktop/vanix/backend) - Express.js REST server using Mongoose & MongoDB Atlas
- [admin_panel/](file:///c:/Users/PC/Desktop/vanix/admin_panel) - Admin Control Desk SPA in React + Vite
- [docs/](file:///c:/Users/PC/Desktop/vanix/docs) - Architectural outlines and API schemas
- [deployment/](file:///c:/Users/PC/Desktop/vanix/deployment) - Docker configurations & PM2/Nginx orchestration scripts

---

## ⚡ Quick Start

### 1. Run Node.js Server
Ensure Node.js and MongoDB are running, then run:
```bash
cd backend
npm install
npm run dev
```

### 2. Run Web Admin Panel
Ensure Node.js is installed, then run:
```bash
cd admin_panel
npm install
npm run dev
```

### 3. Run Flutter Mobile App
Ensure Flutter SDK is configured in your system path, then run:
```bash
cd mobile_app
flutter pub get
flutter run
```

---

## 🔒 Security Measures
- JWT and refresh tokens mechanism with transparent API Client token interceptors
- Secure encrypted password hashing (bcrypt)
- Signed Cloudinary URL generations for piracy protection
- Endpoint request limits and Cors settings
