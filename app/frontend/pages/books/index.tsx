import { Head, Link, router, usePage } from '@inertiajs/react';
import { type FormEvent, useState } from 'react';
import type { Book, Pagination as PaginationType, SharedProps } from '@/types';
import Pagination from '@/components/Pagination';
import StatusBadge from '@/components/StatusBadge';
import { BookOpen, Plus } from 'lucide-react';

type BooksIndexProps = {
  books: Book[];
  pagination: PaginationType;
  query?: string;
};

export default function BooksIndex({ books, pagination, query }: BooksIndexProps) {
  const { auth } = usePage<SharedProps>().props;
  const [searchQuery, setSearchQuery] = useState(query || '');

  const handleSearch = (e: FormEvent) => {
    e.preventDefault();
    router.get('/books', { query: searchQuery || undefined }, { preserveState: true });
  };

  return (
    <>
      <Head title="Books" />

      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <h1 className="text-2xl font-bold text-gray-900">Books</h1>

          {auth?.role === 'librarian' && (
            <Link
              href="/books/new"
              className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              <Plus className="h-5 w-5 mr-2" aria-hidden />
              Add Book
            </Link>
          )}
        </div>

        {/* Search Form */}
        <form onSubmit={handleSearch} className="flex gap-2">
          <div className="flex-1">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by title, author, or genre..."
              className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
            />
          </div>
          <button
            type="submit"
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Search
          </button>
          {query && (
            <Link
              href="/books"
              className="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Clear
            </Link>
          )}
        </form>

        {/* Results info */}
        {query && (
          <p className="text-sm text-gray-600">
            Showing results for &quot;<span className="font-medium">{query}</span>&quot;
          </p>
        )}

        {/* Books Grid */}
        {books.length > 0 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {books.map((book) => (
              <BookCard key={book.id} book={book} />
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <BookOpen className="mx-auto h-12 w-12 text-gray-400" aria-hidden />
            <h3 className="mt-2 text-sm font-semibold text-gray-900">No books found</h3>
            <p className="mt-1 text-sm text-gray-500">
              {query ? 'Try adjusting your search terms.' : 'Get started by adding a new book.'}
            </p>
          </div>
        )}

        {/* Pagination */}
        <Pagination pagination={pagination} baseUrl="/books" queryParams={{ query }} />
      </div>
    </>
  );
}

function BookCard({ book }: { book: Book }) {
  return (
    <Link
      href={`/books/${book.id}`}
      className="group bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow"
    >
      {/* Cover placeholder */}
      <div className="aspect-[3/4] bg-gradient-to-br from-indigo-100 to-indigo-200 flex items-center justify-center">
        <BookOpen className="h-16 w-16 text-indigo-400" aria-hidden />
      </div>

      {/* Content */}
      <div className="p-4">
        <h3 className="font-medium text-gray-900 group-hover:text-indigo-600 line-clamp-1">
          {book.title}
        </h3>
        <p className="text-sm text-gray-500 line-clamp-1">{book.author}</p>

        <div className="mt-3 flex items-center justify-between">
          <StatusBadge status={book.available ? 'available' : 'unavailable'} size="sm" />
          <span className="text-xs text-gray-400">
            {book.available_copies}/{book.total_copies} copies
          </span>
        </div>
      </div>
    </Link>
  );
}
