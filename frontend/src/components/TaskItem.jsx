import { useState } from 'react';

export default function TaskItem({ task, onToggleComplete, onEditTask, onDeleteTask }) {
  const [isEditing, setIsEditing] = useState(false);
  const [editTitle, setEditTitle] = useState(task.title);

  const handleSave = () => {
    if (!editTitle.trim()) return;
    if (editTitle.trim() !== task.title) {
      onEditTask(task._id, { title: editTitle.trim() });
    }
    setIsEditing(false);
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      handleSave();
    } else if (e.key === 'Escape') {
      setEditTitle(task.title);
      setIsEditing(false);
    }
  };

  const formattedDate = new Date(task.createdAt).toLocaleDateString(undefined, {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });

  return (
    <li className={`task-item ${task.completed ? 'completed' : ''}`}>
      <div className="task-content">
        <input
          type="checkbox"
          className="task-checkbox"
          checked={task.completed}
          onChange={() => onToggleComplete(task._id, !task.completed)}
          aria-label={`Mark "${task.title}" as ${task.completed ? 'incomplete' : 'complete'}`}
        />

        {isEditing ? (
          <div className="edit-container">
            <input
              type="text"
              className="edit-input"
              value={editTitle}
              onChange={(e) => setEditTitle(e.target.value)}
              onKeyDown={handleKeyDown}
              maxLength={200}
              autoFocus
            />
            <button className="btn btn-sm btn-save" onClick={handleSave}>
              Save
            </button>
            <button
              className="btn btn-sm btn-cancel"
              onClick={() => {
                setEditTitle(task.title);
                setIsEditing(false);
              }}
            >
              Cancel
            </button>
          </div>
        ) : (
          <div className="task-details">
            <span
              className="task-title"
              onDoubleClick={() => setIsEditing(true)}
              title="Double click to edit"
            >
              {task.title}
            </span>
            <span className="task-date">{formattedDate}</span>
          </div>
        )}
      </div>

      {!isEditing && (
        <div className="task-actions">
          <button
            className="btn-icon btn-edit"
            onClick={() => setIsEditing(true)}
            title="Edit task"
            aria-label="Edit task"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
              <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
            </svg>
          </button>
          <button
            className="btn-icon btn-delete"
            onClick={() => onDeleteTask(task._id)}
            title="Delete task"
            aria-label="Delete task"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <polyline points="3 6 5 6 21 6" />
              <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
              <line x1="10" y1="11" x2="10" y2="17" />
              <line x1="14" y1="11" x2="14" y2="17" />
            </svg>
          </button>
        </div>
      )}
    </li>
  );
}
