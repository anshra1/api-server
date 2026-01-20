# Mock Auth Server

A production-like Node.js server for testing Flutter app authentication.

## Quick Start

```bash
cd mock_server
npm install
npm start
```

## Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/auth/login` | Simple login (testing) | ❌ |
| POST | `/auth/google` | Google ID Token login | ❌ |
| POST | `/auth/refresh-token` | Refresh access token | ❌ |
| POST | `/auth/logout` | Logout | ❌ |
| GET | `/tasks` | Get user's tasks | ✅ |
| POST | `/tasks` | Create task | ✅ |
| PUT | `/tasks/:id` | Update task | ✅ |
| DELETE | `/tasks/:id` | Delete task | ✅ |

## Configuration

Edit `.env` to change:
- `ACCESS_TOKEN_EXPIRY`: Set to `10s` for refresh testing, `15m` for normal use.
- `GOOGLE_CLIENT_ID`: Your Google Cloud OAuth Client ID.

## File Structure

```
mock_server/
├── src/
│   ├── config/          # Environment config
│   ├── controllers/     # Business logic
│   ├── middleware/      # Auth & error handling
│   ├── models/          # File-based database
│   ├── routes/          # API routes
│   └── server.js        # Entry point
├── data/                # JSON storage (auto-created)
└── .env                 # Secrets (do not commit)
```
