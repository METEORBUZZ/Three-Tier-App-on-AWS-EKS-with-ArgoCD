const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/app');
const Task = require('../src/models/Task');

// Mock Mongoose Task model for isolated unit testing
jest.mock('../src/models/Task');

describe('To-Do Backend API Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('GET /health', () => {
    it('should return 200 OK and status: ok', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
      expect(response.body).toEqual({ status: 'ok' });
    });
  });

  describe('GET /metrics', () => {
    it('should return Prometheus metrics text', async () => {
      const response = await request(app).get('/metrics');
      expect(response.status).toBe(200);
      expect(response.text).toContain('nodejs_');
    });
  });

  describe('GET /api/tasks', () => {
    it('should return all tasks', async () => {
      const mockTasks = [
        { _id: '64d1f2e9f8a3c1a2b3c4d5e6', title: 'Task 1', completed: false, createdAt: new Date() },
        { _id: '64d1f2e9f8a3c1a2b3c4d5e7', title: 'Task 2', completed: true, createdAt: new Date() }
      ];

      Task.find.mockReturnValue({
        sort: jest.fn().mockResolvedValue(mockTasks)
      });

      const response = await request(app).get('/api/tasks');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.count).toBe(2);
      expect(response.body.data.length).toBe(2);
      expect(response.body.data[0].title).toBe('Task 1');
    });

    it('should handle database error when fetching tasks', async () => {
      Task.find.mockReturnValue({
        sort: jest.fn().mockRejectedValue(new Error('Database query failure'))
      });

      const response = await request(app).get('/api/tasks');

      expect(response.status).toBe(500);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Database query failure');
    });
  });

  describe('POST /api/tasks', () => {
    it('should create a new task successfully', async () => {
      const newTask = {
        _id: '64d1f2e9f8a3c1a2b3c4d5e8',
        title: 'New Integration Test Task',
        completed: false,
        createdAt: new Date().toISOString()
      };

      Task.create.mockResolvedValue(newTask);

      const response = await request(app)
        .post('/api/tasks')
        .send({ title: 'New Integration Test Task' });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.title).toBe('New Integration Test Task');
      expect(response.body.data.completed).toBe(false);
    });

    it('should reject task creation when title is missing or empty', async () => {
      const response = await request(app)
        .post('/api/tasks')
        .send({ title: '   ' });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Task title is required');
    });
  });

  describe('PUT /api/tasks/:id', () => {
    const validId = new mongoose.Types.ObjectId().toString();

    it('should update an existing task title and completion status', async () => {
      const updatedTask = {
        _id: validId,
        title: 'Updated Task Title',
        completed: true,
        createdAt: new Date().toISOString()
      };

      Task.findByIdAndUpdate.mockResolvedValue(updatedTask);

      const response = await request(app)
        .put(`/api/tasks/${validId}`)
        .send({ title: 'Updated Task Title', completed: true });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.completed).toBe(true);
      expect(response.body.data.title).toBe('Updated Task Title');
    });

    it('should return 400 for invalid ObjectId format', async () => {
      const response = await request(app)
        .put('/api/tasks/invalid-id-format')
        .send({ title: 'Should Fail' });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Invalid task ID');
    });

    it('should return 404 when task to update is not found', async () => {
      Task.findByIdAndUpdate.mockResolvedValue(null);

      const response = await request(app)
        .put(`/api/tasks/${validId}`)
        .send({ title: 'Non-existent Task' });

      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Task not found');
    });

    it('should return 400 when title is an empty string', async () => {
      const response = await request(app)
        .put(`/api/tasks/${validId}`)
        .send({ title: '  ' });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Task title cannot be empty');
    });
  });

  describe('DELETE /api/tasks/:id', () => {
    const validId = new mongoose.Types.ObjectId().toString();

    it('should delete an existing task successfully', async () => {
      Task.findByIdAndDelete.mockResolvedValue({ _id: validId });

      const response = await request(app).delete(`/api/tasks/${validId}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Task deleted successfully');
    });

    it('should return 400 for invalid ObjectId on delete', async () => {
      const response = await request(app).delete('/api/tasks/bad-id');

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Invalid task ID');
    });

    it('should return 404 when deleting a non-existent task', async () => {
      Task.findByIdAndDelete.mockResolvedValue(null);

      const response = await request(app).delete(`/api/tasks/${validId}`);

      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Task not found');
    });
  });

  describe('Unmatched routes (404)', () => {
    it('should return 404 for unknown endpoint', async () => {
      const response = await request(app).get('/api/unknown-endpoint');
      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
    });
  });
});
