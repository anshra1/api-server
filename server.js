const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;
const DB_FILE = path.join(__dirname, 'database.json');

// Middleware
app.use(cors());
app.use(bodyParser.json());

// --- Database Helper Functions ---

// Read data from file
const readDatabase = () => {
    try {
        if (!fs.existsSync(DB_FILE)) {
            // If file doesn't exist, create it with empty array
            fs.writeFileSync(DB_FILE, '[]'); 
            return [];
        }
        const fileData = fs.readFileSync(DB_FILE, 'utf8');
        return JSON.parse(fileData);
    } catch (error) {
        console.error("Database Read Error:", error);
        return [];
    }
};

// Write data to file
const writeDatabase = (data) => {
    try {
        fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2));
    } catch (error) {
        console.error("Database Write Error:", error);
    }
};

// --- Routes ---

// 1. Get All Tasks
app.get('/tasks', (req, res) => {
    const tasks = readDatabase();
    res.json(tasks);
});

// 2. Create a Task
app.post('/tasks', (req, res) => {
    const { title, subtitle } = req.body;
    
    if (!title) {
        return res.status(400).json({ error: "Title is required" });
    }

    const tasks = readDatabase();

    const newTask = {
        id: uuidv4(),
        title,
        subtitle: subtitle || "",
        isCompleted: false,
        createdAt: new Date().toISOString()
    };

    tasks.push(newTask);
    writeDatabase(tasks); // Save to file

    console.log(`[Created] ${title}`);
    res.status(201).json(newTask);
});

// 3. Update a Task
app.put('/tasks/:id', (req, res) => {
    const { id } = req.params;
    const { title, subtitle, isCompleted } = req.body;

    let tasks = readDatabase();
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
    writeDatabase(tasks); // Save to file

    console.log(`[Updated] ID: ${id}`);
    res.json(updatedTask);
});

// 4. Delete a Task
app.delete('/tasks/:id', (req, res) => {
    const { id } = req.params;
    let tasks = readDatabase();
    const initialLength = tasks.length;
    
    tasks = tasks.filter(t => t.id !== id);

    if (tasks.length === initialLength) {
        return res.status(404).json({ error: "Task not found" });
    }

    writeDatabase(tasks); // Save to file

    console.log(`[Deleted] ID: ${id}`);
    res.status(204).send();
});

// Start Server
app.listen(PORT, () => {
    console.log(`\n🚀 Real Server running on http://localhost:${PORT}`);
    console.log(`💾 Data is being saved to: ${DB_FILE}`);
});