const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '../../data');
const USERS_FILE = path.join(DATA_DIR, 'users.json');
const TASKS_FILE = path.join(DATA_DIR, 'tasks.json');
const REFRESH_TOKENS_FILE = path.join(DATA_DIR, 'refresh_tokens.json');

// Ensure data directory exists
if (!fs.existsSync(DATA_DIR)) {
 fs.mkdirSync(DATA_DIR, { recursive: true });
}

// Initialize files if they don't exist
const initFile = (filePath, defaultData) => {
 if (!fs.existsSync(filePath)) {
  fs.writeFileSync(filePath, JSON.stringify(defaultData, null, 2));
 }
};

initFile(USERS_FILE, []);
initFile(TASKS_FILE, []);
initFile(REFRESH_TOKENS_FILE, []);

// Helper functions
const readData = (filePath) => {
 try {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
 } catch (error) {
  console.error(`Error reading ${filePath}:`, error);
  return [];
 }
};

const writeData = (filePath, data) => {
 try {
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
 } catch (error) {
  console.error(`Error writing ${filePath}:`, error);
 }
};

// Users
const getUsers = () => readData(USERS_FILE);
const saveUsers = (users) => writeData(USERS_FILE, users);
const findUserByEmail = (email) => getUsers().find((u) => u.email === email);
const findUserById = (id) => getUsers().find((u) => u.id === id);
const createUser = (user) => {
 const users = getUsers();
 users.push(user);
 saveUsers(users);
 return user;
};

// Tasks
const getTasks = () => readData(TASKS_FILE);
const saveTasks = (tasks) => writeData(TASKS_FILE, tasks);
const getTasksByUserId = (userId) => getTasks().filter((t) => t.userId === userId);
const findTaskById = (id) => getTasks().find((t) => t.id === id);
const createTask = (task) => {
 const tasks = getTasks();
 tasks.push(task);
 saveTasks(tasks);
 return task;
};
const updateTask = (id, updates) => {
 const tasks = getTasks();
 const index = tasks.findIndex((t) => t.id === id);
 if (index !== -1) {
  tasks[index] = { ...tasks[index], ...updates };
  saveTasks(tasks);
  return tasks[index];
 }
 return null;
};
const deleteTask = (id) => {
 const tasks = getTasks();
 const filtered = tasks.filter((t) => t.id !== id);
 saveTasks(filtered);
 return filtered.length !== tasks.length;
};

// Refresh Tokens
const getRefreshTokens = () => readData(REFRESH_TOKENS_FILE);
const saveRefreshTokens = (tokens) => writeData(REFRESH_TOKENS_FILE, tokens);
const storeRefreshToken = (userId, token) => {
 const tokens = getRefreshTokens();
 // Remove old tokens for this user
 const filtered = tokens.filter((t) => t.userId !== userId);
 filtered.push({ userId, token, createdAt: new Date().toISOString() });
 saveRefreshTokens(filtered);
};
const findRefreshToken = (token) => getRefreshTokens().find((t) => t.token === token);
const removeRefreshToken = (token) => {
 const tokens = getRefreshTokens();
 const filtered = tokens.filter((t) => t.token !== token);
 saveRefreshTokens(filtered);
};

module.exports = {
 findUserByEmail,
 findUserById,
 createUser,
 getTasksByUserId,
 findTaskById,
 createTask,
 updateTask,
 deleteTask,
 storeRefreshToken,
 findRefreshToken,
 removeRefreshToken,
};
