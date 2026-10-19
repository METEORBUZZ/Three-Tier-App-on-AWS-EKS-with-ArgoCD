export default function FilterTabs({ currentFilter, onFilterChange, counts }) {
  const filters = [
    { id: 'all', label: 'All', count: counts.all },
    { id: 'active', label: 'Active', count: counts.active },
    { id: 'completed', label: 'Completed', count: counts.completed }
  ];

  return (
    <div className="filter-tabs">
      {filters.map((filter) => (
        <button
          key={filter.id}
          className={`filter-btn ${currentFilter === filter.id ? 'active' : ''}`}
          onClick={() => onFilterChange(filter.id)}
        >
          {filter.label}
          <span className="filter-badge">{filter.count}</span>
        </button>
      ))}
    </div>
  );
}
