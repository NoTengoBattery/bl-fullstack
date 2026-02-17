import { Link, usePage } from '@inertiajs/react';
import { type ReactNode } from 'react';
import type { SharedProps } from '@/types';
import FlashMessage from './FlashMessage';

type LayoutProps = {
  children: ReactNode;
};

export default function Layout({ children }: LayoutProps) {
  const { auth, flash } = usePage<SharedProps>().props;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navigation */}
      <nav className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            {/* Left side */}
            <div className="flex items-center space-x-8">
              <Link href="/" className="text-xl font-bold text-indigo-600 hover:text-indigo-700">
                Template
              </Link>

              <div className="hidden sm:flex space-x-4">
                <Link
                  href="/"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Home
                </Link>
                <Link
                  href="/about"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  About
                </Link>
              </div>
            </div>

            {/* Right side */}
            <div className="flex items-center space-x-4">
              {auth ? (
                <>
                  <span className="text-sm text-gray-600">{auth.email_address}</span>
                  <Link
                    href="/logout"
                    method="delete"
                    as="button"
                    className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                  >
                    Logout
                  </Link>
                </>
              ) : (
                <>
                  <Link
                    href="/login"
                    className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                  >
                    Login
                  </Link>
                  <Link
                    href="/register"
                    className="bg-indigo-600 text-white hover:bg-indigo-700 px-4 py-2 rounded-md text-sm font-medium"
                  >
                    Register
                  </Link>
                </>
              )}
            </div>
          </div>
        </div>
      </nav>

      {/* Flash Messages */}
      <FlashMessage flash={flash} />

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">{children}</main>
    </div>
  );
}
