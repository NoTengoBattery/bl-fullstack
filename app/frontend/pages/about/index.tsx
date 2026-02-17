import { Head } from '@inertiajs/react';

export default function About() {
  return (
    <>
      <Head title="About" />

      <div className="max-w-2xl mx-auto">
        <div className="bg-white rounded-lg shadow-md px-8 py-10">
          <h1 className="text-3xl font-bold text-gray-900 mb-6">About This Template</h1>

          <div className="prose prose-indigo max-w-none">
            <p className="text-gray-600 mb-4">
              This is a full-stack application template built with modern technologies and best
              practices. It provides a solid foundation for building web applications.
            </p>

            <h2 className="text-xl font-semibold text-gray-800 mt-6 mb-3">Tech Stack</h2>
            <ul className="list-disc list-inside text-gray-600 space-y-2">
              <li>
                <strong>Backend:</strong> Ruby on Rails 8
              </li>
              <li>
                <strong>Frontend:</strong> React + TypeScript via Inertia.js
              </li>
              <li>
                <strong>Styling:</strong> Tailwind CSS
              </li>
              <li>
                <strong>Database:</strong> PostgreSQL 18
              </li>
              <li>
                <strong>Bundler:</strong> Vite
              </li>
              <li>
                <strong>Infrastructure:</strong> Docker (rootless)
              </li>
            </ul>

            <h2 className="text-xl font-semibold text-gray-800 mt-6 mb-3">Features</h2>
            <ul className="list-disc list-inside text-gray-600 space-y-2">
              <li>Session-based authentication</li>
              <li>Inertia.js for SPA-like navigation</li>
              <li>Pundit for authorization</li>
              <li>Blueprinter for JSON serialization</li>
              <li>RSpec test suite with FactoryBot</li>
              <li>UUID primary keys</li>
            </ul>
          </div>
        </div>
      </div>
    </>
  );
}
