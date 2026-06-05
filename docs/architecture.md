# VANIX OTT Streaming Platform - Architecture Documentation

VANIX is designed to support high scalability, security, and developer efficiency. The project uses a **Clean Architecture** model with a **Feature-First** structure.

---

## 📱 Mobile App (Flutter)

The mobile application is structured around Clean Architecture layers:

```
lib/
├── core/                  # Core modules shared across all features
│   ├── constants/         # API paths, storage keys, billing configurations
│   ├── theme/             # Premium dark design systems, glassmorphism templates
│   ├── network/           # API Client with token refresh interceptors
│   ├── utils/             # Loggers, formatters
│   ├── services/          # Low-level interfaces (local databases, device connectivity)
│   └── widgets/           # Global reusable UI widgets (buttons, cards, inputs)
├── features/              # Feature modules (Feature-First approach)
│   ├── auth/              # Handles register, login, profile setup
│   ├── home/              # Carousel, Continue Watching, Categories
│   ├── movies/            # Detailed views, lists, reviews
│   ├── player/            # Chewie custom controls, sync status
│   └── [feature_name]/
│       ├── data/          # Network sources, Local cache, Data models
│       ├── domain/        # Business logic, Repositories definitions, Entities
│       └── presentation/  # UI Views, Screens, and State Providers (MVVM)
└── main.dart              # Entrypoint and Provider injection point
```

### State Management
State is managed using the `provider` library. Providers serve as the ViewModels (MVVM) bridging user events to repository calls, notifying views to redraw when data updates.

---

## 📡 Backend Server (Node.js & Express)

The backend follows a service-repository pattern to separate DB logic from router controller layers.

```
src/
├── config/                # Environment, Mongoose database connectors, Cloudinary bindings
├── routes/                # Express router mapping to controller handles
├── controllers/           # HTTP controllers handling input parsing and responses
├── services/              # Core business rules (authentications, recommendation formulas)
├── repositories/          # Mongoose database query operations (Users, Content)
├── models/                # MongoDB Schema declarations
├── middlewares/           # JWT authentications, request rate limiting, error handlers
├── validators/            # Joi/Express-validator request body assertion schemas
└── utils/                 # Token signing, custom exception logs
```

---

## 🎨 Admin Web Panel (React + Vite)

A modern web SPA containing:
- **Dashboard:** Revenue reporting, active streamers counter, system status tracker.
- **Content Studio:** Dynamic forms to upload movies, episodes, and stream links.
- **Subscribers:** Plan controls, payment audits, profile reports.
- **Moderator:** Reviews review lists and user bans.
