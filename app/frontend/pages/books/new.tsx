import { Head, Link, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';
import { ChevronLeft } from 'lucide-react';

export default function BookNew() {
  const { data, setData, post, processing, errors } = useForm({
    title: '',
    author: '',
    genre: '',
    isbn: '',
    total_copies: 1,
  });

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    post('/books');
  };

  return (
    <>
      <Head title="Add Book" />

      <div className="max-w-2xl mx-auto">
        {/* Back link */}
        <Link
          href="/books"
          className="inline-flex items-center text-sm text-gray-500 hover:text-gray-700 mb-6"
        >
          <ChevronLeft className="h-5 w-5 mr-1" aria-hidden />
          Back to Books
        </Link>

        <div className="bg-white shadow rounded-lg">
          <div className="px-8 py-6 border-b border-gray-200">
            <h1 className="text-xl font-semibold text-gray-900">Add New Book</h1>
          </div>

          <form onSubmit={handleSubmit} className="px-8 py-6 space-y-6">
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-700">
                Title <span className="text-red-500">*</span>
              </label>
              <input
                id="title"
                type="text"
                value={data.title}
                onChange={(e) => setData('title', e.target.value)}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                required
                autoFocus
              />
              {errors.title && <p className="mt-1 text-sm text-red-600">{errors.title}</p>}
            </div>

            <div>
              <label htmlFor="author" className="block text-sm font-medium text-gray-700">
                Author <span className="text-red-500">*</span>
              </label>
              <input
                id="author"
                type="text"
                value={data.author}
                onChange={(e) => setData('author', e.target.value)}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                required
              />
              {errors.author && <p className="mt-1 text-sm text-red-600">{errors.author}</p>}
            </div>

            <div>
              <label htmlFor="genre" className="block text-sm font-medium text-gray-700">
                Genre
              </label>
              <input
                id="genre"
                type="text"
                value={data.genre}
                onChange={(e) => setData('genre', e.target.value)}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
              {errors.genre && <p className="mt-1 text-sm text-red-600">{errors.genre}</p>}
            </div>

            <div>
              <label htmlFor="isbn" className="block text-sm font-medium text-gray-700">
                ISBN
              </label>
              <input
                id="isbn"
                type="text"
                value={data.isbn}
                onChange={(e) => setData('isbn', e.target.value)}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              />
              {errors.isbn && <p className="mt-1 text-sm text-red-600">{errors.isbn}</p>}
            </div>

            <div>
              <label htmlFor="total_copies" className="block text-sm font-medium text-gray-700">
                Total Copies <span className="text-red-500">*</span>
              </label>
              <input
                id="total_copies"
                type="number"
                min="0"
                value={data.total_copies}
                onChange={(e) => setData('total_copies', parseInt(e.target.value, 10) || 0)}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                required
              />
              {errors.total_copies && (
                <p className="mt-1 text-sm text-red-600">{errors.total_copies}</p>
              )}
            </div>

            <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
              <Link
                href="/books"
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              >
                Cancel
              </Link>
              <button
                type="submit"
                disabled={processing}
                className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {processing ? 'Creating...' : 'Create Book'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </>
  );
}
