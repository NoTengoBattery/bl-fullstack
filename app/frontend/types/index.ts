export type Flash = {
  notice?: string;
  alert?: string;
};

export type User = {
  id: string;
  email_address: string;
  created_at?: string;
  updated_at?: string;
};

export type Pagination = {
  current_page: number;
  total_pages: number;
  total_count: number;
  per_page: number;
};

export type SharedProps = {
  auth: User | null;
  flash: Flash;
};
