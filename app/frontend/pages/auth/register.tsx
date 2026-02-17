import { Head, useForm } from '@inertiajs/react';
import type { FormEvent } from 'react';

export default function Register() {
  const { data, setData, post, processing, errors } = useForm({
    email_address: '',
    password: '',
    password_confirmation: '',
  });

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    post('/register');
  };

  return (
    <>
      <Head title="Register" />

      <div className="flex min-h-[80vh] items-center justify-center">
        <div className="w-full max-w-md">
          <div className="bg-white rounded-lg shadow-md px-8 py-10">
            <h1 className="text-2xl font-bold text-center text-gray-900 mb-8">
              Create your account
            </h1>

            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <label htmlFor="email_address" className="block text-sm font-medium text-gray-700">
                  Email address
                </label>
                <input
                  id="email_address"
                  type="email"
                  value={data.email_address}
                  onChange={(e) => setData('email_address', e.target.value)}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  required
                  autoFocus
                />
                {errors.email_address && (
                  <p className="mt-1 text-sm text-red-600">{errors.email_address}</p>
                )}
              </div>

              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                  Password
                </label>
                <input
                  id="password"
                  type="password"
                  value={data.password}
                  onChange={(e) => setData('password', e.target.value)}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  required
                  minLength={6}
                />
                {errors.password && <p className="mt-1 text-sm text-red-600">{errors.password}</p>}
                <p className="mt-1 text-xs text-gray-500">Minimum 6 characters</p>
              </div>

              <div>
                <label
                  htmlFor="password_confirmation"
                  className="block text-sm font-medium text-gray-700"
                >
                  Confirm password
                </label>
                <input
                  id="password_confirmation"
                  type="password"
                  value={data.password_confirmation}
                  onChange={(e) => setData('password_confirmation', e.target.value)}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  required
                />
                {errors.password_confirmation && (
                  <p className="mt-1 text-sm text-red-600">{errors.password_confirmation}</p>
                )}
              </div>

              <button
                type="submit"
                disabled={processing}
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {processing ? 'Creating account...' : 'Create account'}
              </button>
            </form>

            <p className="mt-6 text-center text-sm text-gray-600">
              Already have an account?{' '}
              <a href="/login" className="font-medium text-indigo-600 hover:text-indigo-500">
                Sign in
              </a>
            </p>
          </div>
        </div>
      </div>
    </>
  );
}
