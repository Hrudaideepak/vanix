# VANIX - Production Deployment Manual

This document details the configuration for deploying the VANIX OTT Streaming Platform on production Linux servers (Ubuntu/Debian) using Docker Compose or PM2 alongside Nginx reverse proxies.

---

## 🐋 Option A: Docker Deployment (Recommended)

Docker Compose orchestrates the MongoDB Atlas connection, Express backend server, Nginx configurations, and React Admin bundle automatically.

### 1. Configure Production Environment
Create a production `.env` file inside the `backend/` directory following the template in `.env.example`.

### 2. Run Containers
Run the compose stack from the project root directory:
```bash
cd deployment
docker-compose -f docker-compose.yml up -d --build
```
This command builds the multi-stage static React container, pulls Node runtime containers, maps ports, and spins up the environment in the background.

---

## 🚀 Option B: Bare-Metal Ubuntu Deploy (PM2 + Nginx)

For developers deploying directly to VPS instances (AWS EC2, DigitalOcean, Linode) without Docker virtualization.

### 1. Install Node.js & PM2
Install Node.js (v18+) and install PM2 globally:
```bash
sudo apt update
sudo apt install nodejs npm -y
sudo npm install -y pm2 -g
```

### 2. Start Backend with PM2
Install backend packages and register Express inside the PM2 supervisor:
```bash
cd backend
npm install --only=production
pm2 start src/app.js --name "vanix-backend" --update-env
pm2 save
pm2 startup
```

### 3. Build Web Admin Panel
Build the React production bundle:
```bash
cd ../admin_panel
npm install
npm run build
```
This builds static SPA bundles inside `admin_panel/dist`. We will point Nginx to serve this folder.

### 4. Configure Nginx
Install and configure Nginx:
```bash
sudo apt install nginx -y
sudo nano /etc/nginx/sites-available/vanix
```
Paste the server block pointing to `dist` and forwarding requests to localhost PM2:
```nginx
server {
    listen 80;
    server_name vanix-ott.com www.vanix-ott.com;

    # Serve React Admin static files
    location / {
        root /var/www/vanix/admin_panel/dist;
        index index.html;
        try_files $uri /index.html;
    }

    # Proxy API requests
    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```
Enable the site block and restart Nginx:
```bash
sudo ln -s /etc/nginx/sites-available/vanix /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

### 5. Secure with Let's Encrypt SSL
Install Certbot and request SSL certificates to enforce HTTPS:
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d vanix-ott.com -d www.vanix-ott.com
```
Follow the prompts to enable automatic HTTP-to-HTTPS redirection.

---

## 📱 Mobile App (Flutter) App Store Bundles

Ensure the API base path inside `lib/core/constants/app_constants.dart` points to your production backend URL (e.g. `https://vanix-ott.com/api`).

### 1. Android Release (.aab)
```bash
cd mobile_app
flutter build appbundle --release
```
Locate the generated bundle at `build/app/outputs/bundle/release/app-release.aab` and upload it to the Google Play Console.

### 2. iOS Release (IPA / Archive)
Ensure you have Xcode configured on macOS with correct signing certificates, then run:
```bash
cd mobile_app
flutter build ipa
```
Upload the archive to TestFlight or Apple App Store Connect via Xcode Organizer.
