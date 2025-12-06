import { Head, Link, router, usePage } from '@inertiajs/react';
import type { Book, SharedProps } from '@/types';
import StatusBadge from '@/components/StatusBadge';
import { BookOpen, ChevronLeft, Edit3, Plus, Trash2 } from 'lucide-react';

type BookShowProps = {
  book: Book;
  user_has_active_borrowing: boolean;
};

// Format date for display using native Intl
function formatDate(dateString: string | undefined): string {
  if (!dateString) return 'N/A';
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  }).format(new Date(dateString));
}

export default function BookShow({ book, user_has_active_borrowing }: BookShowProps) {
  const { auth } = usePage<SharedProps>().props;

  const handleBorrow = () => {
    router.post('/borrowings', { book_id: book.id });
  };

  const handleDelete = () => {
    if (confirm('Are you sure you want to remove this book?')) {
      router.delete(`/books/${book.id}`);
    }
  };

  const canBorrow = auth?.role === 'member' && book.available && !user_has_active_borrowing;
  const isLibrarian = auth?.role === 'librarian';

  return (
    <>
      <Head title={book.title} />

      <div className="max-w-3xl mx-auto">
        {/* Back link */}
        <Link
          href="/books"
          className="inline-flex items-center text-sm text-gray-500 hover:text-gray-700 mb-6"
        >
          <ChevronLeft className="h-5 w-5 mr-1" aria-hidden />
          Back to Books
        </Link>

        <div className="bg-white shadow rounded-lg overflow-hidden">
          <div className="md:flex">
            {/* Cover placeholder */}
            <div className="md:flex-shrink-0">
              <div className="h-64 md:h-full md:w-48 bg-gradient-to-br from-indigo-100 to-indigo-200 flex items-center justify-center">
                <BookOpen className="h-20 w-20 text-indigo-400" aria-hidden />
              </div>
            </div>

            {/* Content */}
            <div className="p-8 flex-1">
              <div className="flex items-start justify-between">
                <div>
                  <h1 className="text-2xl font-bold text-gray-900">{book.title}</h1>
                  <p className="text-lg text-gray-600 mt-1">by {book.author}</p>
                </div>
                <StatusBadge status={book.available ? 'available' : 'unavailable'} />
              </div>

              <dl className="mt-6 grid grid-cols-1 gap-x-4 gap-y-4 sm:grid-cols-2">
                {book.genre && (
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Genre</dt>
                    <dd className="mt-1 text-sm text-gray-900">{book.genre}</dd>
                  </div>
                )}

                {book.isbn && (
                  <div>
                    <dt className="text-sm font-medium text-gray-500">ISBN</dt>
                    <dd className="mt-1 text-sm text-gray-900">{book.isbn}</dd>
                  </div>
                )}

                <div>
                  <dt className="text-sm font-medium text-gray-500">Total Copies</dt>
                  <dd className="mt-1 text-sm text-gray-900">{book.total_copies}</dd>
                </div>

                <div>
                  <dt className="text-sm font-medium text-gray-500">Available Copies</dt>
                  <dd className="mt-1 text-sm text-gray-900">{book.available_copies}</dd>
                </div>

                {book.created_at && (
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Added</dt>
                    <dd className="mt-1 text-sm text-gray-900">{formatDate(book.created_at)}</dd>
                  </div>
                )}

                {isLibrarian && book.discarded && (
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Status</dt>
                    <dd className="mt-1">
                      <StatusBadge status="unavailable" />
                      <span className="ml-2 text-sm text-gray-500">
                        (Removed on {formatDate(book.discarded_at)})
                      </span>
                    </dd>
                  </div>
                )}
              </dl>

              {/* Actions */}
              <div className="mt-8 flex flex-wrap gap-3">
                {canBorrow && (
                  <button
                    onClick={handleBorrow}
                    className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                  >
                    <Plus className="h-5 w-5 mr-2" aria-hidden />
                    Borrow Book
                  </button>
                )}

                {auth?.role === 'member' && user_has_active_borrowing && (
                  <p className="text-sm text-amber-600 py-2">
                    You already have an active borrowing for this book.
                  </p>
                )}

                {auth?.role === 'member' && !book.available && !user_has_active_borrowing && (
                  <p className="text-sm text-gray-500 py-2">
                    This book is currently unavailable for borrowing.
                  </p>
                )}

                {isLibrarian && (
                  <>
                    <Link
                      href={`/books/${book.id}/edit`}
                      className="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                    >
                      <Edit3 className="h-5 w-5 mr-2" aria-hidden />
                      Edit
                    </Link>

                    {!book.discarded && (
                      <button
                        onClick={handleDelete}
                        className="inline-flex items-center px-4 py-2 border border-red-300 text-sm font-medium rounded-md shadow-sm text-red-700 bg-white hover:bg-red-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                      >
                        <Trash2 className="h-5 w-5 mr-2" aria-hidden />
                        Remove
                      </button>
                    )}
                  </>
                )}

                {!auth && (
                  <Link
                    href="/login"
                    className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                  >
                    Login to Borrow
                  </Link>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
