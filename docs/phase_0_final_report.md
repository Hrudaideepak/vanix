# VANIX OTT Streaming Platform - Phase 0 Assessment Report

This report evaluates the current codebase state of the VANIX streaming platform, detailing working components, architectural limitations, security postures, and recommendations for moving towards a production MVP.

---

## 📊 Executive Summary
The current iteration of the VANIX platform represents a **high-fidelity functional prototype / early beta**.
The current iteration of the VANIX platform represents a **high-fidelity functional prototype / early beta**. 
* **Backend**: Structured Node/Express architecture with model-controller patterns, database seeding, token authentication, and a basic transcoding helper.
* **Admin Panel**: Single-page Vite/React app with functional panels to read database statistics, upload/delete catalog content, manage coupons, and suspend user accounts.
* **Mobile Client**: Feature-complete Flutter app with custom design patterns (Glassmorphism, dark themes) and clean navigation state providers.

While functional, several architectural patterns (specifically video transcoding and payment security) are simplified for local development and are **not production-ready**.

---

## ✅ Working Features

### 📡 Express Backend & Database
1. **User Authentication**: JWT-based registration, login, and silent refresh-token rotation.
2. **Profile System**: Dynamic profile management under single user accounts (including Kids profiles).
3. **Database Relationships**: Models for History tracking, Watchlists, Categories, Search Histories, and Movies/Series content.
4. **Media Transcoding**: An automated HLS transcoding service that splits video streams into adaptive playlists (240p to 1080p) using `ffmpeg` CLI calls.
5. **Auto-Fallback**: If `ffmpeg` is not installed on the system, the server auto-creates a mock HLS folder with placeholder manifests to prevent application failure.

### 🎨 React Admin Dashboard
1. **Command Console**: Shows real-time backend analytics (subscribers, monthly revenue, active media titles).
2. **Catalog Control**: Form to add new movies/series and button triggers to delete content from the MongoDB database.
3. **User Moderation**: List of accounts with immediate "Ban User" / "Revoke Ban" API triggers.
4. **Promotions Desk**: Active coupon code creator.

### 📱 Flutter Mobile Application
1. **Registration & Auth**: Multi-screen login/register flow.
2. **Profile Selection**: Splash screen routing to profile selector. Supports custom PIN codes for profiles.
3. **Rich UI Catalogue**: Home page grids, banner lists, category filters, and detail pages.
4. **Streaming Media Player**: Fully working player powered by `video_player` that streams HLS playlists (`.m3u8`).
5. **Feature Modules**: Dynamic search filtering, watchlist bookmarks, and download management mockups.

---

## 🟡 Partially Working Features

### 💳 Subscription Payments (Razorpay)
* **Status**: Local-only validation.
* **Observation**: The backend (`subscription.controller.js`) generates mock order IDs and skips cryptographic HMAC signature verification when client submits proof of payment.
* **Production Action Required**: Integrate the official Razorpay SDK (`@razorpay/dist`) on the backend and enforce verification of `razorpaySignature` using `crypto.createHmac`.

### 🎛️ Media Quality Selection
* **Status**: Auto-Adaptive only.
* **Observation**: The backend splits video files into multiple files (`240p.m3u8`, `720p.m3u8`, etc.) and lists them inside a master manifest. The Flutter client plays the master URL, letting the player auto-adjust based on client network bandwidth. However, there is no UI button for manual quality selection.
* **Production Action Required**: Add a quality selector overlay to the mobile video player.

---

## ❌ Missing Features (Critical for Production)

1. **Distributed Video Pipeline**:
   - The current transcoding runs directly inside the Express server via synchronous child process shells (`exec`). If multiple users upload movies, the server will block, CPU usage will hit 100%, and the API gateway will crash.
   - **Production Action**: Migrate transcoding to a background queue system (using Redis + BullMQ workers) or use a cloud transcoding service like AWS Elemental MediaConvert.
2. **Digital Rights Management (DRM)**:
   - Video streams are raw HLS streams (`.ts` chunks). Anyone inspecting network requests can download files directly.
   - **Production Action**: Implement Google Widevine / Apple FairPlay DRM wrapper encryption.
3. **Admin Video Uploader**:
   - The admin panel requires a manual link to a pre-uploaded MP4/HLS source file. There is no file upload input to push raw media files directly to the server or cloud storage.
   - **Production Action**: Add a multipart file uploader that streams files directly to an Amazon S3 staging bucket.

---

## 🛑 Blockers to Production Release
1. **Transcoding event loop blocking**: Transcoding locally blocks the server process.
2. **Mocked Payment Verification**: Bypassed signature validation exposes the app to fake subscription upgrades.
3. **Hardcoded API URLs**: The admin panel has `API_URL` hardcoded as `'http://localhost:5000/api'`.

---

## 🗺️ Recommended Next Steps

### 🛠️ Phase 1: Video Pipeline Refactoring (Weeks 1-2)
* Setup AWS S3 bucket for media uploads.
* Configure AWS MediaConvert to transcode MP4s to HLS automatically upon upload, or deploy a Redis server and create an isolated worker process to run `ffmpeg` asynchronously using BullMQ.

### 🔒 Phase 2: Security & Payments (Week 3)
* Connect a Razorpay web hook route to verify payments securely.
* Replace local media asset paths with cloud CDN URLs (e.g. Cloudflare / CloudFront) to handle media requests globally.

### 🚀 Phase 3: Client Expansion (Week 4)
* Add a manual quality selector widget to the Flutter video player.
* Modularize the React admin panel and manage API endpoints through environment variable configs.

---

## ⏱️ MVP Timeline Estimate
Given that the core Flutter UI, database models, and API routes are already functional and successfully integrated:
* **Time to MVP Release**: **4 to 6 weeks** (assuming 1 developer working on pipeline and security setup).
