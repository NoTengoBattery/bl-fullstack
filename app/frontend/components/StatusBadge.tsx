type StatusBadgeProps = {
  status: 'available' | 'unavailable' | 'overdue' | 'active' | 'returned' | 'due_soon';
  size?: 'sm' | 'md';
};

const statusConfig = {
  available: {
    bg: 'bg-green-100',
    text: 'text-green-800',
    label: 'Available',
  },
  unavailable: {
    bg: 'bg-red-100',
    text: 'text-red-800',
    label: 'Unavailable',
  },
  overdue: {
    bg: 'bg-red-100',
    text: 'text-red-800',
    label: 'Overdue',
  },
  active: {
    bg: 'bg-blue-100',
    text: 'text-blue-800',
    label: 'Active',
  },
  returned: {
    bg: 'bg-gray-100',
    text: 'text-gray-800',
    label: 'Returned',
  },
  due_soon: {
    bg: 'bg-yellow-100',
    text: 'text-yellow-800',
    label: 'Due Soon',
  },
};

export default function StatusBadge({ status, size = 'md' }: StatusBadgeProps) {
  const config = statusConfig[status];
  const sizeClass = size === 'sm' ? 'px-2 py-0.5 text-xs' : 'px-2.5 py-0.5 text-sm';

  return (
    <span
      className={`inline-flex items-center rounded-full font-medium ${config.bg} ${config.text} ${sizeClass}`}
    >
      {config.label}
    </span>
  );
}
