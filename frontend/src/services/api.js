const API_BASE_URL = (import.meta.env.VITE_API_URL || 'http://localhost:5000').replace(/\/$/, '');
const TASKS_ENDPOINT = `${API_BASE_URL}/api/tasks`;

export async function fetchTasks() {
  const response = await fetch(TASKS_ENDPOINT, {
    headers: { 'Accept': 'application/json' }
  });
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.message || `Failed to fetch tasks (${response.status})`);
  }
  const result = await response.json();
  return result.data || [];
}

export async function createTask(title) {
  const response = await fetch(TASKS_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({ title })
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.message || `Failed to create task (${response.status})`);
  }
  const result = await response.json();
  return result.data;
}

export async function updateTask(id, updates) {
  const response = await fetch(`${TASKS_ENDPOINT}/${id}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify(updates)
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.message || `Failed to update task (${response.status})`);
  }
  const result = await response.json();
  return result.data;
}

export async function deleteTask(id) {
  const response = await fetch(`${TASKS_ENDPOINT}/${id}`, {
    method: 'DELETE',
    headers: { 'Accept': 'application/json' }
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.message || `Failed to delete task (${response.status})`);
  }
  return true;
}
