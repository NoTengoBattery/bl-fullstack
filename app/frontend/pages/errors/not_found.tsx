import { Head, Link } from '@inertiajs/react';
import { Home, AlertTriangle } from 'lucide-react';

export default function NotFound() {
  return (
    <>
      <Head title="404 - Page Not Found" />

      <div className="min-h-screen bg-gradient-to-br from-indigo-50 to-indigo-100 flex items-center justify-center px-6">
        <div className="text-center">
          <div className="flex justify-center mb-6">
            <div className="p-4 bg-red-100 rounded-full">
              <AlertTriangle className="h-12 w-12 text-red-600" aria-hidden />
            </div>
          </div>

          <h1 className="text-6xl font-bold text-gray-900 mb-2">404</h1>
          <h2 className="text-2xl font-semibold text-gray-700 mb-4">Page Not Found</h2>

          <p className="text-lg text-gray-600 mb-8 max-w-md mx-auto">
            Sorry, the page you are looking for does not exist. It may have been moved or deleted.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/"
              className="inline-flex items-center justify-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              <Home className="h-5 w-5 mr-2" aria-hidden />
              Go to Dashboard
            </Link>
            <button
              onClick={() => window.history.back()}
              className="inline-flex items-center justify-center px-6 py-3 border border-gray-300 text-base font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Go Back
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
