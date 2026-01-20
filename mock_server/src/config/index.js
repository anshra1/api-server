require('dotenv').config();

module.exports = {
 port: process.env.PORT || 3000,
 accessTokenSecret: process.env.ACCESS_TOKEN_SECRET,
 refreshTokenSecret: process.env.REFRESH_TOKEN_SECRET,
 accessTokenExpiry: process.env.ACCESS_TOKEN_EXPIRY || '15m',
 refreshTokenExpiry: process.env.REFRESH_TOKEN_EXPIRY || '7d',
 googleClientId: process.env.GOOGLE_CLIENT_ID,
};
