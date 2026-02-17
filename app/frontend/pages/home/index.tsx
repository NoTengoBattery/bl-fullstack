import { Head } from '@inertiajs/react';

type Visit = {
  id: string;
  ip_address: string;
  created_at: string;
};

type HomeProps = {
  message: string;
  visit_count: number;
  visits: Visit[];
};

export default function Home({ message, visit_count, visits }: HomeProps) {
  return (
    <>
      <Head title="Home" />

      <div className="max-w-2xl mx-auto">
        <div className="bg-white rounded-lg shadow-md px-8 py-10 text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">{message}</h1>
          {visit_count > 0 && (
            <p className="text-lg text-gray-600">
              You&apos;ve logged in{' '}
              <span className="font-semibold text-indigo-600">{visit_count}</span>{' '}
              {visit_count === 1 ? 'time' : 'times'}.
            </p>
          )}
        </div>

        {visits.length > 0 && (
          <div className="bg-white rounded-lg shadow-md overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900">Recent Logins</h2>
            </div>
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    IP Address
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Date
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {visits.map((visit) => (
                  <tr key={visit.id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {visit.ip_address}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {new Date(visit.created_at).toLocaleString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </>
  );
}
