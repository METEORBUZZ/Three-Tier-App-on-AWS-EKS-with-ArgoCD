import TaskItem from './TaskItem';

export default function TaskList({ tasks, currentFilter, onToggleComplete, onEditTask, onDeleteTask }) {
  if (tasks.length === 0) {
    let emptyMessage = 'No tasks found. Add a task above!';
    if (currentFilter === 'active') {
      emptyMessage = 'No active tasks! Everything is completed 🎉';
    } else if (currentFilter === 'completed') {
      emptyMessage = 'No completed tasks yet.';
    }

    return (
      <div className="empty-state">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" className="empty-icon">
          <circle cx="12" cy="12" r="10" />
          <path d="m9 12 2 2 4-4" />
        </svg>
        <p>{emptyMessage}</p>
      </div>
    );
  }

  return (
    <ul className="task-list">
      {tasks.map((task) => (
        <TaskItem
          key={task._id}
          task={task}
          onToggleComplete={onToggleComplete}
          onEditTask={onEditTask}
          onDeleteTask={onDeleteTask}
        />
      ))}
    </ul>
  );
}
