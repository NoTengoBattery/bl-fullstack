import type { SharedProps } from '@/types';

declare module '@inertiajs/core' {
  type PageProps = SharedProps;
}

declare module '@inertiajs/react' {
  export function usePage<T = SharedProps>(): { props: T & SharedProps };
}
