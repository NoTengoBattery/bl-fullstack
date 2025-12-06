export type Flash = {
  notice?: string;
  alert?: string;
};

export type User = {
  id: string;
  email_address: string;
  role: 'member' | 'librarian';
  created_at?: string;
  updated_at?: string;
  borrowings_count?: number;
};

export type Book = {
  id: string;
  title: string;
  author: string;
  genre?: string;
  isbn?: string;
  total_copies: number;
  available: boolean;
  available_copies: number;
  created_at?: string;
  updated_at?: string;
  discarded?: boolean;
  discarded_at?: string;
  active_borrowings_count?: number;
};

export type Borrowing = {
  id: string;
  status: 'active' | 'returned';
  borrowed_at: string;
  due_on: string;
  returned_at?: string;
  overdue: boolean;
  days_until_due: number;
  book?: Book;
  user?: User;
  created_at?: string;
  updated_at?: string;
};

export type Pagination = {
  current_page: number;
  total_pages: number;
  total_count: number;
  per_page: number;
};

export type LibrarianStats = {
  total_books: number;
  total_borrowed: number;
  overdue_count: number;
  due_today_count: number;
};

export type SharedProps = {
  auth: User | null;
  flash: Flash;
};
