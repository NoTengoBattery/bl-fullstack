import { Head, Link, router, usePage } from '@inertiajs/react';
import type { Borrowing, Pagination as PaginationType, SharedProps } from '@/types';
import Pagination from '@/components/Pagination';
import StatusBadge from '@/components/StatusBadge';
import { BookOpen } from 'lucide-react';

type BorrowingsIndexProps = {
  borrowings: Borrowing[];
  pagination: PaginationType;
};

// Format date for display using native Intl
function formatDate(dateString: string): string {
  return new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(new Date(dateString));
}

export default function BorrowingsIndex({ borrowings, pagination }: BorrowingsIndexProps) {
  const { auth } = usePage<SharedProps>().props;

  const handleReturn = (borrowingId: string) => {
    router.patch(`/borrowings/${borrowingId}`);
  };

  return (
    <>
      <Head title="Borrowings" />

      <div className="space-y-6">
        <h1 className="text-2xl font-bold text-gray-900">
          {auth?.role === 'librarian' ? 'All Borrowings' : 'My Borrowings'}
        </h1>

        {borrowings.length > 0 ? (
          <>
            <div className="bg-white shadow overflow-hidden rounded-lg">
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Book
                      </th>
                      {auth?.role === 'librarian' && (
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Member
                        </th>
                      )}
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Borrowed
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Due Date
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Status
                      </th>
                      {auth?.role === 'librarian' && (
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Actions
                        </th>
                      )}
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {borrowings.map((borrowing) => (
                      <tr
                        key={borrowing.id}
                        className={
                          borrowing.overdue && borrowing.status === 'active' ? 'bg-red-50' : ''
                        }
                      >
                        <td className="px-6 py-4 whitespace-nowrap">
                          <Link
                            href={`/books/${borrowing.book?.id}`}
                            className="text-sm font-medium text-indigo-600 hover:text-indigo-900"
                          >
                            {borrowing.book?.title}
                          </Link>
                          <div className="text-sm text-gray-500">{borrowing.book?.author}</div>
                        </td>
                        {auth?.role === 'librarian' && (
                          <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            {borrowing.user?.email_address}
                          </td>
                        )}
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {formatDate(borrowing.borrowed_at)}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {formatDate(borrowing.due_on)}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          {borrowing.status === 'returned' ? (
                            <StatusBadge status="returned" size="sm" />
                          ) : borrowing.overdue ? (
                            <StatusBadge status="overdue" size="sm" />
                          ) : (
                            <StatusBadge status="active" size="sm" />
                          )}
                        </td>
                        {auth?.role === 'librarian' && (
                          <td className="px-6 py-4 whitespace-nowrap text-sm">
                            {borrowing.status === 'active' && (
                              <button
                                onClick={() => handleReturn(borrowing.id)}
                                className="text-indigo-600 hover:text-indigo-900"
                              >
                                Mark Returned
                              </button>
                            )}
                            {borrowing.status === 'returned' && borrowing.returned_at && (
                              <span className="text-gray-400">
                                Returned {formatDate(borrowing.returned_at)}
                              </span>
                            )}
                          </td>
                        )}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <Pagination pagination={pagination} baseUrl="/borrowings" />
          </>
        ) : (
          <div className="bg-white shadow rounded-lg px-6 py-12 text-center">
            <BookOpen className="mx-auto h-12 w-12 text-gray-400" aria-hidden />
            <h3 className="mt-2 text-sm font-semibold text-gray-900">No borrowings found</h3>
            <p className="mt-1 text-sm text-gray-500">
              {auth?.role === 'librarian'
                ? 'No books have been borrowed yet.'
                : "You haven't borrowed any books yet."}
            </p>
          </div>
        )}
      </div>
    </>
  );
}
