# Mock Auth Server - Developer Guide

## Overview
A production-like Node.js server for testing Flutter app authentication flows, including JWT token generation, token refresh, and protected endpoints.

---

## Quick Start

```bash
cd mock_server
npm install   # First time only
npm start     # Start server on port 3000
```

---

## Configuration (.env)

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Server port |
| `ACCESS_TOKEN_EXPIRY` | `10s` | Access token lifetime. Use `10s` for testing, `15m` for realistic behavior |
| `REFRESH_TOKEN_EXPIRY` | `7d` | Refresh token lifetime |
| `GOOGLE_CLIENT_ID` | - | Your Google OAuth Client ID (for real Google login) |
| `ACCESS_TOKEN_SECRET` | - | Secret for signing access tokens |
| `REFRESH_TOKEN_SECRET` | - | Secret for signing refresh tokens |

---

## API Endpoints

### Authentication (No Auth Required)

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/auth/login` | `{ "username": "email" }` | `{ accessToken, refreshToken }` |
| POST | `/auth/google` | `{ "idToken": "google_id_token" }` | `{ accessToken, refreshToken, user }` |
| POST | `/auth/refresh-token` | `{ "refreshToken": "..." }` | `{ accessToken }` |
| POST | `/auth/logout` | `{ "refreshToken": "..." }` | `{ message }` |

### Tasks (Auth Required)

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| GET | `/tasks` | - | `[{ id, title, ... }]` |
| POST | `/tasks` | `{ "title": "...", "description": "..." }` | `{ id, title, ... }` |
| PUT | `/tasks/:id` | `{ "title": "...", "isCompleted": true }` | `{ id, title, ... }` |
| DELETE | `/tasks/:id` | - | `204 No Content` |

**Auth Header**: `Authorization: Bearer <accessToken>`

---

## Testing Token Refresh

1. Login → Get `accessToken` (valid for 10s)
2. Wait 10+ seconds
3. Make any `/tasks` request → Server returns `401`
4. Your app's `TokenRefreshInterceptor` should:
   - Call `/auth/refresh-token`
   - Get new `accessToken`
   - Retry the original request

**Console Output**:
```
⏰ Token expired
🔄 Access token refreshed for: user@example.com
```

---

## Project Structure

```
mock_server/
├── src/
│   ├── server.js           # Entry point
│   ├── config/index.js     # Environment config
│   ├── middleware/
│   │   ├── authMiddleware.js    # JWT verification
│   │   └── errorHandler.js      # Global error handler
│   ├── controllers/
│   │   ├── authController.js    # Login, refresh, logout
│   │   └── taskController.js    # CRUD operations
│   ├── models/
│   │   └── database.js          # File-based storage
│   └── routes/
│       ├── authRoutes.js
│       └── taskRoutes.js
├── data/                   # Auto-created JSON storage
│   ├── users.json
│   ├── tasks.json
│   └── refresh_tokens.json
├── .env                    # Secrets (DO NOT COMMIT)
└── package.json
```

---

## Extending the Server

### Add a New Protected Endpoint

1. **Create Controller** (`src/controllers/newController.js`):
   ```javascript
   const doSomething = (req, res) => {
     const userId = req.user.userId; // From auth middleware
     res.json({ result: 'success' });
   };
   module.exports = { doSomething };
   ```

2. **Create Route** (`src/routes/newRoutes.js`):
   ```javascript
   const express = require('express');
   const authMiddleware = require('../middleware/authMiddleware');
   const controller = require('../controllers/newController');
   const router = express.Router();
   router.use(authMiddleware);
   router.get('/', controller.doSomething);
   module.exports = router;
   ```

3. **Register in server.js**:
   ```javascript
   const newRoutes = require('./routes/newRoutes');
   app.use('/new-endpoint', newRoutes);
   ```

---

## Common Issues

| Issue | Solution |
|-------|----------|
| `EADDRINUSE` (port in use) | Kill existing process or change `PORT` in `.env` |
| Token always valid | Ensure `ACCESS_TOKEN_EXPIRY=10s` in `.env` |
| Google login fails | Set `GOOGLE_CLIENT_ID` or use `/auth/login` for testing |
| Data not persisting | Check `data/` folder permissions |

---

## Security Notes

⚠️ **For Development Only**
- Uses HTTP (not HTTPS)
- Simple file-based "database"
- Tokens are signed, not encrypted
- No rate limiting

For production, use a real backend with PostgreSQL/MongoDB, HTTPS, and proper security measures.
