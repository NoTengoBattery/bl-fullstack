import { Head, Link } from '@inertiajs/react';
import { AlertTriangle, BookOpen, CheckCircle } from 'lucide-react';
import type { Borrowing } from '@/types';
import StatusBadge from '@/components/StatusBadge';

type MemberDashboardProps = {
  borrowings: Borrowing[];
};

// Format date for display using native Intl
function formatDate(dateString: string): string {
  return new Intl.DateTimeFormat('en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(new Date(dateString));
}

export default function MemberDashboard({ borrowings }: MemberDashboardProps) {
  const overdueCount = borrowings.filter((b) => b.overdue).length;

  return (
    <>
      <Head title="My Dashboard" />

      <div className="space-y-8">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-gray-900">My Dashboard</h1>
          <Link
            href="/books"
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Browse Books
          </Link>
        </div>

        {/* Summary */}
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2">
          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0 p-3 rounded-md bg-blue-100 text-blue-600">
                  <BookOpen className="h-6 w-6" aria-hidden />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">
                      Currently Borrowed
                    </dt>
                    <dd className="text-2xl font-semibold text-gray-900">{borrowings.length}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div
                  className={`flex-shrink-0 p-3 rounded-md ${overdueCount > 0 ? 'bg-red-100 text-red-600' : 'bg-green-100 text-green-600'}`}
                >
                  {overdueCount > 0 ? (
                    <AlertTriangle className="h-6 w-6" aria-hidden />
                  ) : (
                    <CheckCircle className="h-6 w-6" aria-hidden />
                  )}
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">Overdue Books</dt>
                    <dd className="text-2xl font-semibold text-gray-900">{overdueCount}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Active Loans */}
        <div className="bg-white shadow rounded-lg overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-medium text-gray-900">My Active Loans</h2>
          </div>

          {borrowings.length > 0 ? (
            <ul className="divide-y divide-gray-200">
              {borrowings.map((borrowing) => (
                <li key={borrowing.id} className={borrowing.overdue ? 'bg-red-50' : ''}>
                  <div className="px-6 py-4 flex items-center justify-between">
                    <div className="flex-1 min-w-0">
                      <Link
                        href={`/books/${borrowing.book?.id}`}
                        className="text-sm font-medium text-indigo-600 hover:text-indigo-900 truncate block"
                      >
                        {borrowing.book?.title}
                      </Link>
                      <p className="text-sm text-gray-500">{borrowing.book?.author}</p>
                      <div className="mt-2 flex items-center gap-2">
                        <span className="text-xs text-gray-500">
                          Borrowed: {formatDate(borrowing.borrowed_at)}
                        </span>
                      </div>
                    </div>

                    <div className="ml-4 flex flex-col items-end gap-2">
                      <StatusBadge
                        status={
                          borrowing.overdue
                            ? 'overdue'
                            : borrowing.days_until_due <= 3
                              ? 'due_soon'
                              : 'active'
                        }
                        size="sm"
                      />
                      <div
                        className={`text-sm ${borrowing.overdue ? 'text-red-600 font-medium' : 'text-gray-500'}`}
                      >
                        {borrowing.overdue ? (
                          <>
                            <span className="font-medium">
                              {Math.abs(borrowing.days_until_due)} days overdue
                            </span>
                          </>
                        ) : (
                          <>
                            Due: {formatDate(borrowing.due_on)}
                            {borrowing.days_until_due <= 3 && borrowing.days_until_due >= 0 && (
                              <span className="text-yellow-600 ml-1">
                                ({borrowing.days_until_due} days left)
                              </span>
                            )}
                          </>
                        )}
                      </div>
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          ) : (
            <div className="px-6 py-12 text-center">
              <BookOpen className="mx-auto h-12 w-12 text-gray-400" aria-hidden />
              <h3 className="mt-2 text-sm font-semibold text-gray-900">No active loans</h3>
              <p className="mt-1 text-sm text-gray-500">You haven&apos;t borrowed any books yet.</p>
              <div className="mt-6">
                <Link
                  href="/books"
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  Browse Books
                </Link>
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
