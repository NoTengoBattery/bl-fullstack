import { Head, Link, router } from '@inertiajs/react';
import type { Borrowing, LibrarianStats, User } from '@/types';
import StatusBadge from '@/components/StatusBadge';
import {
  AlertTriangle,
  BookOpen,
  CalendarDays,
  CheckCircle,
  Repeat2,
  type LucideIcon,
} from 'lucide-react';

type LibrarianDashboardProps = {
  stats: LibrarianStats;
  overdue_borrowings: Borrowing[];
  due_today_borrowings: Borrowing[];
  members_with_overdue: User[];
};

// Format date for display using native Intl
function formatDate(dateString: string): string {
  return new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(new Date(dateString));
}

export default function LibrarianDashboard({
  stats,
  overdue_borrowings,
  due_today_borrowings,
  members_with_overdue,
}: LibrarianDashboardProps) {
  const handleReturn = (borrowingId: string) => {
    router.patch(`/borrowings/${borrowingId}`);
  };

  return (
    <>
      <Head title="Librarian Dashboard" />

      <div className="space-y-8">
        <h1 className="text-2xl font-bold text-gray-900">Librarian Dashboard</h1>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
          <StatCard title="Total Books" value={stats.total_books} icon="book" color="indigo" />
          <StatCard
            title="Active Loans"
            value={stats.total_borrowed}
            icon="borrowing"
            color="blue"
          />
          <StatCard title="Overdue" value={stats.overdue_count} icon="alert" color="red" />
          <StatCard
            title="Due Today"
            value={stats.due_today_count}
            icon="calendar"
            color="yellow"
          />
        </div>

        {/* Due Today Section */}
        {due_today_borrowings.length > 0 && (
          <div className="bg-white shadow rounded-lg overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-medium text-gray-900">Books Due Today</h2>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Book
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Member
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {due_today_borrowings.map((borrowing) => (
                    <tr key={borrowing.id}>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">
                          {borrowing.book?.title}
                        </div>
                        <div className="text-sm text-gray-500">{borrowing.book?.author}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {borrowing.user?.email_address}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <StatusBadge status="due_soon" size="sm" />
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        <button
                          onClick={() => handleReturn(borrowing.id)}
                          className="text-indigo-600 hover:text-indigo-900"
                        >
                          Mark Returned
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* Overdue Borrowings Section */}
        <div className="bg-white shadow rounded-lg overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-medium text-gray-900">Overdue Books</h2>
          </div>
          {overdue_borrowings.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Book
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Member
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Due Date
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Days Overdue
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {overdue_borrowings.map((borrowing) => (
                    <tr key={borrowing.id} className="bg-red-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <Link
                          href={`/books/${borrowing.book?.id}`}
                          className="text-sm font-medium text-indigo-600 hover:text-indigo-900"
                        >
                          {borrowing.book?.title}
                        </Link>
                        <div className="text-sm text-gray-500">{borrowing.book?.author}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {borrowing.user?.email_address}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {formatDate(borrowing.due_on)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="text-sm font-medium text-red-600">
                          {Math.abs(borrowing.days_until_due)} days
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        <button
                          onClick={() => handleReturn(borrowing.id)}
                          className="text-indigo-600 hover:text-indigo-900"
                        >
                          Mark Returned
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="px-6 py-12 text-center text-gray-500">
              <CheckCircle className="mx-auto h-12 w-12 text-gray-400" aria-hidden />
              <p className="mt-2">No overdue books. Great job!</p>
            </div>
          )}
        </div>

        {/* Members with Overdue Books */}
        {members_with_overdue.length > 0 && (
          <div className="bg-white shadow rounded-lg overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-medium text-gray-900">Members with Overdue Books</h2>
            </div>
            <ul className="divide-y divide-gray-200">
              {members_with_overdue.map((member) => (
                <li key={member.id} className="px-6 py-4 flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-900">{member.email_address}</p>
                    <p className="text-sm text-gray-500">
                      {member.borrowings_count} active borrowing(s)
                    </p>
                  </div>
                  <StatusBadge status="overdue" size="sm" />
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </>
  );
}

type StatCardProps = {
  title: string;
  value: number;
  icon: 'book' | 'borrowing' | 'alert' | 'calendar';
  color: 'indigo' | 'blue' | 'red' | 'yellow';
};

const iconComponents: Record<StatCardProps['icon'], LucideIcon> = {
  book: BookOpen,
  borrowing: Repeat2,
  alert: AlertTriangle,
  calendar: CalendarDays,
};

function StatCard({ title, value, icon, color }: StatCardProps) {
  const colorClasses = {
    indigo: 'bg-indigo-100 text-indigo-600',
    blue: 'bg-blue-100 text-blue-600',
    red: 'bg-red-100 text-red-600',
    yellow: 'bg-yellow-100 text-yellow-600',
  };

  const IconComponent = iconComponents[icon];

  return (
    <div className="bg-white overflow-hidden shadow rounded-lg">
      <div className="p-5">
        <div className="flex items-center">
          <div className={`flex-shrink-0 p-3 rounded-md ${colorClasses[color]}`}>
            <IconComponent className="h-6 w-6" aria-hidden />
          </div>
          <div className="ml-5 w-0 flex-1">
            <dl>
              <dt className="text-sm font-medium text-gray-500 truncate">{title}</dt>
              <dd className="text-2xl font-semibold text-gray-900">{value}</dd>
            </dl>
          </div>
        </div>
      </div>
    </div>
  );
}
