import { Link } from '@inertiajs/react';
import type { Pagination as PaginationType } from '@/types';
import { ChevronLeft, ChevronRight } from 'lucide-react';

type PaginationProps = {
  pagination: PaginationType;
  baseUrl: string;
  queryParams?: Record<string, string | undefined>;
};

export default function Pagination({ pagination, baseUrl, queryParams = {} }: PaginationProps) {
  const { current_page, total_pages, total_count, per_page } = pagination;

  if (total_pages <= 1) {
    return null;
  }

  const buildUrl = (page: number) => {
    const params = new URLSearchParams();
    params.set('page', String(page));

    Object.entries(queryParams).forEach(([key, value]) => {
      if (value) params.set(key, value);
    });

    return `${baseUrl}?${params.toString()}`;
  };

  const startItem = (current_page - 1) * per_page + 1;
  const endItem = Math.min(current_page * per_page, total_count);

  // Generate page numbers to display
  const getPageNumbers = () => {
    const pages: (number | 'ellipsis')[] = [];
    const maxVisible = 7;

    if (total_pages <= maxVisible) {
      for (let i = 1; i <= total_pages; i++) {
        pages.push(i);
      }
    } else {
      // Always show first page
      pages.push(1);

      if (current_page > 3) {
        pages.push('ellipsis');
      }

      // Show pages around current
      const start = Math.max(2, current_page - 1);
      const end = Math.min(total_pages - 1, current_page + 1);

      for (let i = start; i <= end; i++) {
        pages.push(i);
      }

      if (current_page < total_pages - 2) {
        pages.push('ellipsis');
      }

      // Always show last page
      pages.push(total_pages);
    }

    return pages;
  };

  return (
    <div className="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6">
      {/* Mobile view */}
      <div className="flex flex-1 justify-between sm:hidden">
        {current_page > 1 ? (
          <Link
            href={buildUrl(current_page - 1)}
            className="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            Previous
          </Link>
        ) : (
          <span className="relative inline-flex items-center rounded-md border border-gray-300 bg-gray-100 px-4 py-2 text-sm font-medium text-gray-400 cursor-not-allowed">
            Previous
          </span>
        )}
        {current_page < total_pages ? (
          <Link
            href={buildUrl(current_page + 1)}
            className="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            Next
          </Link>
        ) : (
          <span className="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-gray-100 px-4 py-2 text-sm font-medium text-gray-400 cursor-not-allowed">
            Next
          </span>
        )}
      </div>

      {/* Desktop view */}
      <div className="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
        <div>
          <p className="text-sm text-gray-700">
            Showing <span className="font-medium">{startItem}</span> to{' '}
            <span className="font-medium">{endItem}</span> of{' '}
            <span className="font-medium">{total_count}</span> results
          </p>
        </div>
        <div>
          <nav
            className="isolate inline-flex -space-x-px rounded-md shadow-sm"
            aria-label="Pagination"
          >
            {/* Previous button */}
            {current_page > 1 ? (
              <Link
                href={buildUrl(current_page - 1)}
                className="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
              >
                <span className="sr-only">Previous</span>
                <ChevronLeft className="h-5 w-5" aria-hidden />
              </Link>
            ) : (
              <span className="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-300 ring-1 ring-inset ring-gray-300 cursor-not-allowed">
                <span className="sr-only">Previous</span>
                <ChevronLeft className="h-5 w-5" aria-hidden />
              </span>
            )}

            {/* Page numbers */}
            {getPageNumbers().map((page, index) =>
              page === 'ellipsis' ? (
                <span
                  key={`ellipsis-${index}`}
                  className="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-inset ring-gray-300"
                >
                  ...
                </span>
              ) : page === current_page ? (
                <span
                  key={page}
                  aria-current="page"
                  className="relative z-10 inline-flex items-center bg-indigo-600 px-4 py-2 text-sm font-semibold text-white focus:z-20 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
                >
                  {page}
                </span>
              ) : (
                <Link
                  key={page}
                  href={buildUrl(page)}
                  className="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
                >
                  {page}
                </Link>
              )
            )}

            {/* Next button */}
            {current_page < total_pages ? (
              <Link
                href={buildUrl(current_page + 1)}
                className="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
              >
                <span className="sr-only">Next</span>
                <ChevronRight className="h-5 w-5" aria-hidden />
              </Link>
            ) : (
              <span className="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-300 ring-1 ring-inset ring-gray-300 cursor-not-allowed">
                <span className="sr-only">Next</span>
                <ChevronRight className="h-5 w-5" aria-hidden />
              </span>
            )}
          </nav>
        </div>
      </div>
    </div>
  );
}
