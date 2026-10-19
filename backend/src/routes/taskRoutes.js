const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Task = require('../models/Task');

// GET /api/tasks - Retrieve all tasks (optionally filter by status)
router.get('/', async (req, res, next) => {
  try {
    const { status } = req.query;
    const filter = {};

    if (status === 'active') {
      filter.completed = false;
    } else if (status === 'completed') {
      filter.completed = true;
    }

    const tasks = await Task.find(filter).sort({ createdAt: -1 });
    res.status(200).json({
      success: true,
      count: tasks.length,
      data: tasks
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/tasks - Create a new task
router.post('/', async (req, res, next) => {
  try {
    const { title } = req.body;

    if (!title || typeof title !== 'string' || title.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Task title is required and cannot be empty'
      });
    }

    const task = await Task.create({
      title: title.trim(),
      completed: false
    });

    res.status(201).json({
      success: true,
      data: task
    });
  } catch (error) {
    next(error);
  }
});

// PUT /api/tasks/:id - Update an existing task
router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        message: `Invalid task ID: ${id}`
      });
    }

    const { title, completed } = req.body;
    const updates = {};

    if (title !== undefined) {
      if (typeof title !== 'string' || title.trim().length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Task title cannot be empty'
        });
      }
      updates.title = title.trim();
    }

    if (completed !== undefined) {
      if (typeof completed !== 'boolean') {
        return res.status(400).json({
          success: false,
          message: 'Completed status must be a boolean'
        });
      }
      updates.completed = completed;
    }

    const task = await Task.findByIdAndUpdate(id, updates, {
      new: true,
      runValidators: true
    });

    if (!task) {
      return res.status(404).json({
        success: false,
        message: `Task not found with ID: ${id}`
      });
    }

    res.status(200).json({
      success: true,
      data: task
    });
  } catch (error) {
    next(error);
  }
});

// DELETE /api/tasks/:id - Remove a task
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        message: `Invalid task ID: ${id}`
      });
    }

    const task = await Task.findByIdAndDelete(id);

    if (!task) {
      return res.status(404).json({
        success: false,
        message: `Task not found with ID: ${id}`
      });
    }

    res.status(200).json({
      success: true,
      message: 'Task deleted successfully',
      data: { id: task._id }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
