# VANIX OTT Streaming Platform - Phase 0 Local Setup Guide

Welcome to the local development setup guide for **VANIX**, a premium OTT streaming platform containing an Express backend, a React admin panel, and a Flutter mobile application.
Welcome to the local development setup guide for **VANIX**, a premium OTT streaming platform containing an Express backend, a React admin panel, and a Flutter mobile application. 

This document serves as a day-by-day playbook to get all components of the system cloned, configured, tested, and integrated locally on Windows (using PowerShell or CMD).

---

## 📅 Playbook Overview
* **Day 1**: Repository Inspection & Express Backend Setup (Node + MongoDB)
* **Day 2**: React Admin Dashboard Setup (Vite + React Router)
* **Day 3**: Flutter Mobile App Setup (Flutter + Emulator/Simulator)
* **Day 4**: End-to-End Integration Testing & Codebase Assessment

---

## 🚀 Prerequisites Check
Ensure you have the following installed on your Windows machine:
1. **Node.js** (v18.0.0+) & **npm**
2. **MongoDB** (Local Community Edition or a MongoDB Atlas Cluster connection string)
3. **Flutter SDK** (Stable channel)
4. **Git**
5. **VS Code** (or Android Studio)
6. *Optional*: **FFmpeg** (added to Windows system `PATH` for video transcoding; otherwise, the backend will auto-fallback to mock streaming metadata)

---

## 🌅 Day 1: Repository Inspection & Backend Setup

### 🎯 Goal
Clone the codebase, analyze the package dependencies, run a local/Atlas MongoDB database, configure environment parameters, seed test data, and launch the server.

### 📋 Step-by-Step Instructions

#### 1. Clone & Inspect Structure
Open **PowerShell** and run:
```powershell
# Clone the repository (skip if already cloned locally)
git clone https://github.com/Hrudaideepak/vanix.git
cd vanix

# Inspect top-level directory structure
Get-ChildItem
```
**Expected Folders:**
* `backend/` - Node.js + Express API
* `admin_panel/` - Vite + React web application
* `mobile_app/` - Flutter client app
* `deployment/` - Docker compose and Nginx configuration templates
* `docs/` - Architecture and guide files

#### 2. Install Backend Dependencies
```powershell
cd backend
npm install
```

#### 3. Setup Environment Variables
Create a file named `.env` in the root of the `backend/` directory:
```powershell
New-Item -Path . -Name ".env" -ItemType "file"
```
Open it in your editor and paste the following configuration. Since this is local setup, we will use default/dummy credentials:
```env
# Server Settings
PORT=5000
NODE_ENV=development

# Database Settings (change if using MongoDB Atlas)
MONGO_URI=mongodb://localhost:27017/vanix

# JWT Authentication Secrets
JWT_SECRET=vanix_super_secret_jwt_key_change_in_production_123!
JWT_REFRESH_SECRET=vanix_super_secret_refresh_jwt_key_change_in_production_321!
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# Cloudinary Storage (Optional - Dummy credentials will fallback to mock links)
CLOUDINARY_CLOUD_NAME=vanix-cloud
CLOUDINARY_API_KEY=cloudinary_key
CLOUDINARY_API_SECRET=cloudinary_secret

# Razorpay Settings (Optional - Dummy test keys)
RAZORPAY_KEY_ID=rzp_test_your_key_id
RAZORPAY_KEY_SECRET=rzp_test_your_key_secret
```

#### 4. Run & Seed MongoDB
* **Option A: Local MongoDB**: Ensure the MongoDB service is running on your computer. If installed as a service, it starts automatically. If running manually, start it:
  ```powershell
  # Start mongod (default path for Community Edition)
  & "C:\Program Files\MongoDB\Server\X.Y\bin\mongod.exe" --dbpath "C:\data\db"
  ```
* **Option B: MongoDB Atlas**: Replace `MONGO_URI` in `.env` with your cloud connection string:
  ```env
  MONGO_URI=mongodb+srv://<username>:<password>@cluster0.mongodb.net/vanix?retryWrites=true&w=majority
  ```

Once database connection is verified, run the seed script to populate movies, categories, and pre-configured accounts:
```powershell
npm run seed
```
**Expected Output:**
```text
📡 Connected to MongoDB for seeding...
🗑️ Existing tables cleared.
🎬 Seeded 6 movies/shows.
👥 Seeded Admin Account: admin@vanix.com / adminpassword123
👥 Seeded User Account: user@vanix.com / userpassword123
🎉 Database seeding complete!
```

#### 5. Start the Express API
```powershell
# Start the development server with live reload (Nodemon)
npm run dev
```
**Expected Output:**
```text
[nodemon] starting `node src/app.js`
Server running in development mode on port 5000
Connected to MongoDB
```

#### 6. Verify API Running
Open your browser or run in a new terminal window:
```powershell
Invoke-RestMethod -Uri "http://localhost:5000/api/movies" -Method Get
```
*(Expected: A JSON payload containing the 6 seeded movies.)*

---

### 🛠️ Troubleshooting Day 1
* **Error: `MongooseError: Operation ... buffered out after 30000ms`**
  * *Reason*: The server cannot reach the MongoDB instance.
  * *Fix*: Make sure `mongod` is running locally on port `27017` or verify that MongoDB Atlas allows your IP in its Network Access settings.
* **Error: `nodemon is not recognized`**
  * *Reason*: Nodemon not installed or paths mismatch.
  * *Fix*: Run `npm install -g nodemon` or start the server using `npm start` instead of `npm run dev`.

---

## 🎨 Day 2: Admin Panel Setup & Basic Check

### 🎯 Goal
Install and launch the React Admin Dashboard (powered by Vite) and establish connectivity with the running Day 1 backend API.

### 📋 Step-by-Step Instructions

#### 1. Navigate & Install Dependencies
Open a new terminal window, navigate to the `admin_panel` directory, and install its packages:
```powershell
cd admin_panel
npm install
```

#### 2. Check API Integration Configuration
Inspect `admin_panel/src/App.jsx` line 9. It has the following API config hardcoded:
```javascript
const API_URL = 'http://localhost:5000/api';
```
* Note: If your backend runs on a different port (e.g., `8080`), open `App.jsx` and update `API_URL` to point to `'http://localhost:8080/api'`.

#### 3. Start React Admin Console
```powershell
# Launch Vite dev server
npm run dev
```
**Expected Output:**
```text
  VITE v5.1.3  ready in 430 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
```

#### 4. Open and Verify the Dashboard
1. Open your browser and navigate to `http://localhost:5173/`.
2. The UI automatically attempts an auto-login handshake using the pre-seeded admin credentials (`admin@vanix.com` / `adminpassword123`) inside `App.jsx`.
3. Check the browser console (**F12** -> **Console**):
   - You should see successful API queries requesting `/api/analytics`, `/api/movies`, and `/api/users`.
   - The dashboard stats (Active Streams, Content Titles, Subscribers) should populate correctly instead of displaying `0`.

#### 5. Verify Pages and Controls
* **Dashboard Tab**: Displays simulated monthly revenue line charts (Recharts) and global statistics.
* **Content Manager**: Displays table of movies. Try creating a new test movie:
  * Title: `Test Cosmos`
  * Video URL: `https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4`
  * Click **Transcode & Register Video**. A popup should notify you of success.
* **User Controls**: Check that the pre-seeded user (`user@vanix.com`) is present. Test the ban toggle and verify that status switches between `ACTIVE` and `BANNED`.

---

### 🛠️ Troubleshooting Day 2
* **Error: `CORS Policy Blocked` in browser console**
  * *Reason*: The backend does not allow requests from `localhost:5173`.
  * *Fix*: The Express app in `backend/src/app.js` is already configured to allow CORS, but verify that your CORS configurations in backend match your client origins.
* **Blank screen on page load**:
  * *Reason*: Missing or failed compilation of React packages.
  * *Fix*: Clear Vite cache using `npm run dev -- --force` or check the F12 console for syntax errors.

---

## 📱 Day 3: Mobile App Setup & Initial Tests

### 🎯 Goal
Configure the Flutter SDK, build and launch the application on an Android/iOS emulator, establish connectivity with the backend, and manually test the critical features.

### 📋 Step-by-Step Instructions

#### 1. Fetch Flutter Packages
Open a terminal, navigate to the `mobile_app` folder, and update packages:
```powershell
cd mobile_app
flutter pub get
```

#### 2. Verify API URL Configuration
The app retrieves the backend address dynamically inside `lib/core/constants/app_constants.dart`:
```dart
static String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://localhost:5000/api';
  }
  return Platform.isAndroid ? 'http://10.0.2.2:5000/api' : 'http://localhost:5000/api';
}
```
* **Emulator Rules**:
  * **Android Emulator**: Resolves `10.0.2.2:5000`, which correctly maps to your PC loopback IP.
  * **iOS Simulator**: Resolves `localhost:5000`, which functions natively.
  * **Physical Device**: Replace these endpoints with your computer's local Wi-Fi IP address (e.g. `http://192.168.1.104:5000/api`). Ensure your device and PC are on the same Wi-Fi network and any local firewalls are disabled.

#### 3. Boot Emulator and Run
```powershell
# Check connected devices (ensure an emulator is open and ready)
flutter devices

# Run the project on the active emulator
flutter run
```

#### 4. Manual Testing Walkthrough & Validation Checklist

Use this checklist during manual validation. Record outcomes:

| Feature / Flow | Steps to Execute | Expected Success Indicator | Status |
|---|---|---|---|
| **Registration** | Tap "Sign Up". Register a new account (`newuser@vanix.com` / `pass123`). | Navigates to Profile Selection screen. | [ ] |
| **Login** | Log out and sign in with the new credentials. | Loads profile selection. | [ ] |
| **Profile Selection**| Create/select a profile. | Accesses the home catalogue dashboard. | [ ] |
| **Home Catalogue** | Scroll through movies. Check if images load. | Movie categories render with Unsplash artwork. | [ ] |
| **Search** | Go to Search, type "Nebula". | "Nebula Genesis" is filtered and displayed. | [ ] |
| **Movie Details** | Tap a movie card. | Detail page displays description, cast, and crew. | [ ] |
| **Video Playback** | Tap "Play" on a movie. | Opens native video player and streams HLS content. | [ ] |
| **Subscription Billing**| Try starting a subscription on the Premium plan. | Opens a payment sheet (Razorpay test UI). | [ ] |

---

### 🛠️ Troubleshooting Day 3
* **Error: `Target of URI doesn't exist` (import issues)**
  * *Fix*: Execute `flutter clean` followed by `flutter pub get`. Restart your IDE's Dart analysis server if errors persist.
* **Failed to connect to backend on Android Emulator**:
  * *Reason*: The backend is not running, or running on a port other than `5000`.
  * *Fix*: Verify the backend is listening on port `5000` via browser. Ensure you did not change `10.0.2.2` in `AppConstants.dart`.

---

## 🔗 Day 4: Integration Test & Codebase Assessment

### 🎯 Goal
Run all three system layers concurrently, run cross-system integration scenarios, inspect code patterns for scaling, and record findings.

### 📋 Setup Configuration
Ensure all services are running side-by-side in separate terminal tabs:
1. **Backend**: `http://localhost:5000` (`npm run dev` in `backend/`)
2. **Admin Web**: `http://localhost:5173` (`npm run dev` in `admin_panel/`)
3. **Mobile App**: Active Android Emulator or iOS Simulator (`flutter run` in `mobile_app/`)

---

### 🔍 Integration Test Cases

#### Scenario A: Content Lifecycle (Admin-to-User)
1. **Admin Panel**: Go to the **Content Manager** tab. Add a movie:
   - Title: `Deep Space Nebula`
   - Description: `A journey through outer regions of space.`
   - Video URL: `https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4`
   - Classify as **Premium** and **Featured**. Click **Transcode & Register Video**.
2. **Backend Console**: Check stdout logs. You should see:
   - `🚀 Starting FFmpeg transcoding for Deep Space Nebula...` (or a mock pipeline fallback message if FFmpeg is missing).
3. **Mobile App**: Tap the **Home** icon to refresh. Scroll to the "Featured" or "Sci-Fi" category.
   - **Verification**: `Deep Space Nebula` should appear in the mobile app list automatically. Tap it to inspect metadata.

#### Scenario B: User Access & Ban Actions
1. **Mobile App**: Log in as `user@vanix.com` / `userpassword123`.
2. **Admin Panel**: Go to **User Controls**. Locate `user@vanix.com` and click **Ban User**.
3. **Mobile App**: Navigate or try fetching details.
   - **Verification**: The mobile app should reject requests with unauthorized responses, and sign out or present a locked banner.

---

### 🏗️ Technical Assessment Checklist

Check the codebase to identify the platform's architectural maturity:

1. **Video Transcoding / Processing Pipeline**:
   - Locate [ffmpeg.service.js](file:///c:/Users/PC/Desktop/vanix/vanix/backend/src/services/ffmpeg.service.js).
   - *Observation*: The backend contains a local subprocess exec pipeline utilizing raw `ffmpeg` CLI calls. It does NOT use a background task manager (like BullMQ, Celery, or AWS Elastic Transcoder). Video transcoding blockages block the event loop or node subprocess limits.

2. **Adaptive Bitrate Streaming (HLS)**:
   - *Observation*: The transcoding script outputs multiple resolutions (240p, 360p, 480p, 720p, 1080p) and links them inside a `master.m3u8` manifest file. The mobile player (`video_player`) consumes HLS.

   
2. **Adaptive Bitrate Streaming (HLS)**:
   - *Observation*: The transcoding script outputs multiple resolutions (240p, 360p, 480p, 720p, 1080p) and links them inside a `master.m3u8` manifest file. The mobile player (`video_player`) consumes HLS.
   
3. **Razorpay Payments**:
   - Locate [playback_provider.dart](file:///c:/Users/PC/Desktop/vanix/vanix/mobile_app/lib/features/player/providers/playback_provider.dart).
   - *Observation*: Payments are integrated on the mobile side, but verify how web hooks notify the backend server of successful payments for subscription state changes.
