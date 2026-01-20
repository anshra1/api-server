const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const app = express();
const PORT = 3000;
const DB_FILE = path.join(__dirname, 'database.json');
const USERS_FILE = path.join(__dirname, 'users.json');

// Middleware
app.use(cors());
app.use(bodyParser.json());

// --- Simple JWT Implementation (since we can't install packages) ---
const SECRET_KEY = "my-super-secret-key-for-development-only";
const REFRESH_SECRET_KEY = "my-super-secret-refresh-key";

function base64UrlEncode(str) {
    return Buffer.from(str)
        .toString('base64')
        .replace(/=/g, '')
        .replace(/\+/g, '-')
        .replace(/\//g, '_');
}

function signJwt(payload, secret, expiresInSeconds) {
    const header = { alg: 'HS256', typ: 'JWT' };
    const now = Math.floor(Date.now() / 1000);
    const body = { ...payload, iat: now, exp: now + expiresInSeconds };
    
    const encodedHeader = base64UrlEncode(JSON.stringify(header));
    const encodedBody = base64UrlEncode(JSON.stringify(body));
    
    const signatureInput = `${encodedHeader}.${encodedBody}`;
    const signature = crypto.createHmac('sha256', secret).update(signatureInput).digest('base64')
        .replace(/=/g, '')
        .replace(/\+/g, '-')
        .replace(/\//g, '_');
        
    return `${signatureInput}.${signature}`;
}

function verifyJwt(token, secret) {
    try {
        const parts = token.split('.');
        if (parts.length !== 3) return null;
        
        const [encodedHeader, encodedBody, signature] = parts;
        const signatureInput = `${encodedHeader}.${encodedBody}`;
        const expectedSignature = crypto.createHmac('sha256', secret).update(signatureInput).digest('base64')
            .replace(/=/g, '')
            .replace(/\+/g, '-')
            .replace(/\//g, '_');
            
        if (signature !== expectedSignature) return null;
        
        const body = JSON.parse(Buffer.from(encodedBody, 'base64').toString());
        const now = Math.floor(Date.now() / 1000);
        
        if (body.exp < now) return null; // Expired
        
        return body;
    } catch (e) {
        return null;
    }
}

// --- Database Helper Functions ---

const readJsonFile = (filePath, defaultData = []) => {
    try {
        if (!fs.existsSync(filePath)) {
            fs.writeFileSync(filePath, JSON.stringify(defaultData));
            return defaultData;
        }
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (error) {
        console.error(`Read Error (${filePath}):`, error);
        return defaultData;
    }
};

const writeJsonFile = (filePath, data) => {
    try {
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
    } catch (error) {
        console.error(`Write Error (${filePath}):`, error);
    }
};

// --- Auth Middleware ---

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) return res.status(401).json({ error: "Access Token Required" });

    const user = verifyJwt(token, SECRET_KEY);
    if (!user) return res.status(403).json({ error: "Invalid or Expired Token" });

    req.user = user;
    next();
};

// --- Routes ---

// 1. Login (Get Tokens)
app.post('/auth/login', (req, res) => {
    // For demo, accept any username/password
    const { username } = req.body;
    if (!username) return res.status(400).json({ error: "Username required" });

    const user = { id: uuidv4(), username };
    
    // Access Token: Valid for ONLY 60 seconds (to test refresh logic frequently) 
    const accessToken = signJwt(user, SECRET_KEY, 60); 
    
    // Refresh Token: Valid for 7 days
    const refreshToken = signJwt(user, REFRESH_SECRET_KEY, 7 * 24 * 60 * 60);

    console.log(`[Login] User: ${username}`);
    res.json({ accessToken, refreshToken });
});

// 2. Refresh Token
app.post('/auth/refresh-token', (req, res) => {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(401).json({ error: "Refresh Token Required" });

    const user = verifyJwt(refreshToken, REFRESH_SECRET_KEY);
    if (!user) return res.status(403).json({ error: "Invalid Refresh Token" });

    // Issue new Access Token
    const newAccessToken = signJwt({ id: user.id, username: user.username }, SECRET_KEY, 60);
    
    console.log(`[Refresh] New Access Token Issued for ${user.username}`);
    res.json({ accessToken: newAccessToken });
});

// 3. Get All Tasks (PROTECTED)
app.get('/tasks', authenticateToken, (req, res) => {
    const tasks = readJsonFile(DB_FILE);
    res.json(tasks);
});

// 4. Create a Task (PROTECTED)
app.post('/tasks', authenticateToken, (req, res) => {
    const { title, subtitle } = req.body;
    
    if (!title) {
        return res.status(400).json({ error: "Title is required" });
    }

    const tasks = readJsonFile(DB_FILE);

    const newTask = {
        id: uuidv4(),
        title,
        subtitle: subtitle || "",
        isCompleted: false,
        createdAt: new Date().toISOString(),
        userId: req.user.id // Link task to user
    };

    tasks.push(newTask);
    writeJsonFile(DB_FILE, tasks);

    console.log(`[Created] ${title} by ${req.user.username}`);
    res.status(201).json(newTask);
});

// 5. Update a Task (PROTECTED)
app.put('/tasks/:id', authenticateToken, (req, res) => {
    const { id } = req.params;
    const { title, subtitle, isCompleted } = req.body;

    let tasks = readJsonFile(DB_FILE);
    const taskIndex = tasks.findIndex(t => t.id === id);

    if (taskIndex === -1) {
        return res.status(404).json({ error: "Task not found" });
    }

    const updatedTask = {
        ...tasks[taskIndex],
        title: title !== undefined ? title : tasks[taskIndex].title,
        subtitle: subtitle !== undefined ? subtitle : tasks[taskIndex].subtitle,
        isCompleted: isCompleted !== undefined ? isCompleted : tasks[taskIndex].isCompleted
    };

    tasks[taskIndex] = updatedTask;
    writeJsonFile(DB_FILE, tasks);

    console.log(`[Updated] ID: ${id}`);
    res.json(updatedTask);
});

// 6. Delete a Task (PROTECTED)
app.delete('/tasks/:id', authenticateToken, (req, res) => {
    const { id } = req.params;
    let tasks = readJsonFile(DB_FILE);
    const initialLength = tasks.length;
    
    tasks = tasks.filter(t => t.id !== id);

    if (tasks.length === initialLength) {
        return res.status(404).json({ error: "Task not found" });
    }

    writeJsonFile(DB_FILE, tasks);

    console.log(`[Deleted] ID: ${id}`);
    res.status(204).send();
});

// Start Server
app.listen(PORT, () => {
    console.log(`\n🚀 Secure Server running on http://localhost:${PORT}`);
    console.log(`🔑 Auth: /auth/login, /auth/refresh-token`);
    console.log(`🔒 Tasks API is now PROTECTED.`);
});
