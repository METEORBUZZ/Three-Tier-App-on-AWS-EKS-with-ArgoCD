import { useState, useEffect, useMemo } from 'react';
import TaskForm from './components/TaskForm';
import TaskList from './components/TaskList';
import FilterTabs from './components/FilterTabs';
import { fetchTasks, createTask, updateTask, deleteTask } from './services/api';
import './App.css';

export default function App() {
  const [tasks, setTasks] = useState([]);
  const [filter, setFilter] = useState('all');
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState(null);

  const loadTasks = async () => {
    try {
      setIsLoading(true);
      setError(null);
      const data = await fetchTasks();
      setTasks(data);
    } catch (err) {
      setError(err.message || 'Failed to load tasks from server');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadTasks();
  }, []);

  const handleAddTask = async (title) => {
    try {
      setIsSubmitting(true);
      setError(null);
      const newTask = await createTask(title);
      setTasks((prev) => [newTask, ...prev]);
    } catch (err) {
      setError(err.message || 'Failed to create task');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleToggleComplete = async (id, completed) => {
    try {
      setError(null);
      // Optimistic update
      setTasks((prev) =>
        prev.map((t) => (t._id === id ? { ...t, completed } : t))
      );
      await updateTask(id, { completed });
    } catch (err) {
      setError(err.message || 'Failed to update task status');
      // Revert on error
      loadTasks();
    }
  };

  const handleEditTask = async (id, updates) => {
    try {
      setError(null);
      const updated = await updateTask(id, updates);
      setTasks((prev) =>
        prev.map((t) => (t._id === id ? updated : t))
      );
    } catch (err) {
      setError(err.message || 'Failed to edit task');
      loadTasks();
    }
  };

  const handleDeleteTask = async (id) => {
    try {
      setError(null);
      // Optimistic delete
      setTasks((prev) => prev.filter((t) => t._id !== id));
      await deleteTask(id);
    } catch (err) {
      setError(err.message || 'Failed to delete task');
      loadTasks();
    }
  };

  // Filter and counts calculation
  const counts = useMemo(() => {
    const total = tasks.length;
    const completed = tasks.filter((t) => t.completed).length;
    const active = total - completed;
    return { all: total, active, completed };
  }, [tasks]);

  const filteredTasks = useMemo(() => {
    if (filter === 'active') return tasks.filter((t) => !t.completed);
    if (filter === 'completed') return tasks.filter((t) => t.completed);
    return tasks;
  }, [tasks, filter]);

  return (
    <div className="app-container">
      <header className="app-header">
        <div className="brand">
          <div className="brand-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="m9 11 3 3L22 4" />
              <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11" />
            </svg>
          </div>
          <div>
            <h1>DevOps Task Manager</h1>
            <p className="app-subtitle">CI/CD & Kubernetes Ready Sample App</p>
          </div>
        </div>
        <div className="badge-group">
          <span className="badge badge-docker">Docker</span>
          <span className="badge badge-k8s">K8s (EKS)</span>
          <span className="badge badge-prom">Prometheus</span>
        </div>
      </header>

      <main className="app-main">
        {error && (
          <div className="alert alert-error" role="alert">
            <div className="alert-content">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <circle cx="12" cy="12" r="10" />
                <line x1="12" y1="8" x2="12" y2="12" />
                <line x1="12" y1="16" x2="12.01" y2="16" />
              </svg>
              <span>{error}</span>
            </div>
            <button className="btn-retry" onClick={loadTasks}>
              Retry
            </button>
          </div>
        )}

        <section className="card form-section">
          <TaskForm onAddTask={handleAddTask} isLoading={isSubmitting} />
        </section>

        <section className="card list-section">
          <div className="list-toolbar">
            <FilterTabs
              currentFilter={filter}
              onFilterChange={setFilter}
              counts={counts}
            />
          </div>

          {isLoading ? (
            <div className="loading-state">
              <div className="spinner"></div>
              <p>Connecting to backend API...</p>
            </div>
          ) : (
            <TaskList
              tasks={filteredTasks}
              currentFilter={filter}
              onToggleComplete={handleToggleComplete}
              onEditTask={handleEditTask}
              onDeleteTask={handleDeleteTask}
            />
          )}
        </section>
      </main>

      <footer className="app-footer">
        <p>
          Production DevOps Sample Stack &bull; Node.js + Express &bull; MongoDB &bull; React Vite
        </p>
      </footer>
    </div>
  );
}
