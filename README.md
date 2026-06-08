# 🌌 VANIX OTT Platform
> **Unlimited Entertainment. One Universe.** A futuristic, premium OTT streaming platform.

VANIX is a complete, production-ready, next-generation OTT (Over-The-Top) streaming system. It includes a cross-platform Flutter mobile application (Android/iOS), a highly scalable Node.js/Express.js backend, and a modern Web Admin Panel for catalog management.

---

## 📱 Quick Android Installation (Download APK)

You can download and run the pre-built Android application package directly from this repository without needing to build the project from source.

### 📥 Step 1: Download the APK File
Click the link below to download the latest build directly to your device:

👉 **[📲 Download VANIX APK (vanix.apk)](apk/vanix.apk)**

*(Alternatively, you can browse to the `apk/` directory in this repository and download `vanix.apk` manually.)*

### ⚙️ Step 2: Install on Android
1. **Transfer the APK**: If you downloaded it on a PC, transfer the `vanix.apk` file to your Android phone via USB, email, or a cloud service.
2. **Enable Unknown Sources**:
   - Go to **Settings** ➔ **Security** (or **Privacy**).
   - Enable **Allow installation of apps from unknown sources** (or grant permission to your browser/file manager to install APKs).
3. **Install**: Open your file manager, navigate to your Downloads folder, tap on `vanix.apk`, and confirm the installation.
4. **Launch**: Open the newly installed **VANIX** app from your app drawer!

---

## 🚀 Key Features

### 1. Cross-Platform Mobile App (Flutter)
* **Auth Provider**: Complete registration and login system with persistent session management, device tracking, and refresh token interceptors.
* **Trailers Reel Feed**: TikTok/Instagram-style vertical video scroll for quick trailer previews with high-performance playback and smooth transitions.
* **Futuristic Video Player**: Full gesture-controlled player (volume, brightness, seek), quality selectors, subtitle support, and automatic orientation locking.
* **Watchlist & Favourites**: Real-time bookmarking synced across all devices.
* **Offline Download Manager**: Pause/resume support for downloads, chunked downloading, offline playback capability, and device storage tracker.
* **Premium Theme**: Glassmorphism aesthetic, sleek gradients, Outfit typography, and micro-animations using `flutter_animate`.

### 2. Node.js & Express REST Backend
* **Scalable Routing**: Specialized endpoints for media catalog, user account management, watch history, and playlists.
* **Database Management**: Integrated with MongoDB Atlas using Mongoose models.
* **Authentication**: Robust JWT authentication paired with refresh-token rotations.
* **Security & Optimization**: Custom middleware for CORS, rate-limiting, request validation, and password encryption (bcrypt).

### 3. React + Vite Admin Control Panel
* **Media Catalog Desk**: Seamless additions, modifications, and deletions of movies, series, trailers, and categories.
* **Dashboard Analytics**: Visualize user registrations, most-watched media, active streams, and subscription rates.
* **Role-Based Controls**: Secure dashboard access for content moderators and system admins.

---

## 📂 Project Structure

```
vanix-main/
├── apk/                  # 📲 Pre-built Android APK releases for users
│   └── vanix.apk         # Latest debug/release APK (tracked via Git LFS)
├── mobile_app/           # 📱 Cross-platform Flutter Mobile Application
│   ├── lib/              # Dart source files (Auth, Home, Player, Downloads, etc.)
│   └── android/          # Native Android configuration files
├── backend/              # ⚙️ Node.js Express REST API Backend
│   ├── controllers/      # Route request logic handlers
│   ├── models/           # Mongoose schemas for MongoDB
│   └── routes/           # Express endpoint definitions
├── admin_panel/          # 🖥️ Admin Dashboard SPA (React + Vite)
├── deployment/           # 📦 Production setups (Docker, PM2, Nginx)
└── docs/                 # 📄 API specifications and architectural sheets
```

---

## 🛠️ Developer Setup & Execution

### 1. Backend Server Setup
Ensure [Node.js](https://nodejs.org/) and MongoDB are installed, then run:
```bash
cd backend
npm install
# Configure your .env file with your PORT, MONGODB_URI, and JWT_SECRET
npm run dev
```

### 2. Web Admin Panel Setup
```bash
cd admin_panel
npm install
npm run dev
```
Open your browser and navigate to `http://localhost:5173` (or the port specified in console).

### 3. Flutter App Compilation
Ensure the Flutter SDK is installed and configured. Then:
```bash
cd mobile_app
flutter pub get
flutter run
```

To build a fresh release/debug APK locally:
```bash
# To build debug APK
flutter build apk --debug
# To build optimized production release APK
flutter build apk --release
```

---

## 🔒 Security & Performance
* Signed media assets URL generators to protect raw streams from unauthorized usage.
* Chunked media player buffering for zero-lag streaming on low bandwidth.
* Advanced database query index optimizations for quick content loading.
