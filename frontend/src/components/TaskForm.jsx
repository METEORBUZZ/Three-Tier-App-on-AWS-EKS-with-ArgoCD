import { useState } from 'react';

export default function TaskForm({ onAddTask, isLoading }) {
  const [title, setTitle] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!title.trim() || isLoading) return;
    onAddTask(title.trim());
    setTitle('');
  };

  return (
    <form className="task-form" onSubmit={handleSubmit}>
      <input
        type="text"
        className="task-input"
        placeholder="What needs to be done?"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        disabled={isLoading}
        maxLength={200}
        autoFocus
      />
      <button
        type="submit"
        className="btn btn-primary"
        disabled={!title.trim() || isLoading}
      >
        {isLoading ? 'Adding...' : 'Add Task'}
      </button>
    </form>
  );
}
