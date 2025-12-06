import { createInertiaApp, type ResolvedComponent } from '@inertiajs/react';
import { StrictMode, type ReactNode } from 'react';
import { createRoot } from 'react-dom/client';
import Layout from '@/components/Layout';

void createInertiaApp({
  // Set default page title
  // see https://inertia-rails.dev/guide/title-and-meta
  title: (title) => (title ? `${title} - Library` : 'Library'),

  // Disable progress bar
  //
  // see https://inertia-rails.dev/guide/progress-indicators
  // progress: false,

  resolve: (name) => {
    const pages = import.meta.glob<{ default: ResolvedComponent }>('../pages/**/*.tsx', {
      eager: true,
    });
    const page = pages[`../pages/${name}.tsx`];
    if (!page) {
      // eslint-disable-next-line no-console
      console.error(`Missing Inertia page component: '${name}.tsx'`);
    }

    // Use the Layout component as default layout
    // see https://inertia-rails.dev/guide/pages#default-layouts
    page.default.layout ||= (pageContent: ReactNode) => <Layout>{pageContent}</Layout>;

    return page;
  },

  setup({ el, App, props }) {
    createRoot(el).render(
      <StrictMode>
        <App {...props} />
      </StrictMode>
    );
  },

  defaults: {
    form: {
      forceIndicesArrayFormatInFormData: false,
    },
    future: {
      useDataInertiaHeadAttribute: true,
      useDialogForErrorModal: true,
      preserveEqualProps: true,
    },
  },
}).catch((error) => {
  // This ensures this entrypoint is only loaded on Inertia pages
  // by checking for the presence of the root element (#app by default).
  // Feel free to remove this `catch` if you don't need it.
  if (document.getElementById('app')) {
    throw error;
  } else {
    // eslint-disable-next-line no-console
    console.error(
      'Missing root element.\n\n' +
        'If you see this error, it probably means you loaded Inertia.js on non-Inertia pages.\n' +
        'Consider moving <%= vite_typescript_tag "inertia.tsx" %> to the Inertia-specific layout instead.'
    );
  }
});
