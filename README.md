# Library Management System (Rails 8 + Inertia + React)

A modern, Dockerized Library Management System built with Ruby on Rails 8 and React (via Inertia.js). This project adheres to Clean Architecture principles, utilizing Service Objects, Pundit for authorization, and Optimistic Locking for concurrency control.

## System dependencies

Any computer that can run Docker will work. VS Code is the preferred IDE.

| Dependency | Version |
|---|---|
| GIT VCS | any modern version |
| Docker | v20.10.10+ |
| Docker Rootless Plugin | installed |
| Ruby (Container) | 3.4 |
| PostgreSQL (Container) | 18 |
| Redis (Container) | 8 |

Note: This project uses dotenv for configuration. The necessary secrets (like `RAILS_MASTER_KEY`) should be placed in `.env.local` or `.env.development.local`.

## Instructions

In this project, we utilize rootless Docker to ensure optimal performance and correct file permissions (avoiding root-owned files on Linux/Mac). You must pass your current user's `UID` and `GID` to the Docker commands.

### Clone this repository locally:

```bash
git clone git@github.com:NoTengoBattery/bl-full-demo.git
cd bl-full-demo
```

### Prepare environment variables:
Copy the example environment file (if available) or create `.env.development.local`.

```bash
cp .env.example .env.development.local
cp .env.example .env.test.local
```

> Note: The master key is needed even if not used. I understand the implications of providing it plain-text in the repository, however, this is the best way to share it for a simple demo project. I totally understand that this is unacceptable for production software.

### Build the Docker images:

```bash
UID=${UID} GID=${GID} docker compose --progress=plain build project-base project-test-base
```

### Run the Application:
This command launches the Rails server and the Vite dev server automatically.

```bash
DROP_TO_SHELL=false UID=${UID} GID=${GID} docker compose run --rm --service-ports project-rails-server
```

Success: If you see `* Listening on http://0.0.0.0:3000`, open http://localhost:3000 in your browser.

### Seeding Data:
The application requires data to function correctly. The seeds will create a Librarian and a Member for testing purposes, along with a catalog of books, other members and librarians, and borrows.

```bash
UID=${UID} GID=${GID} docker compose run --rm project-rails-server rails db:seed
```

> Note: The project will seed automatically. You don't need to run this command, it is for reference only.

### Demo Credentials:

- Librarian: librarian@library.com / password
- Member: member@library.com / password

## Running the Test Suite

This project uses RSpec with a heavy focus on TDD, including Request Specs for Inertia and Service Object unit tests.

To run the full test suite:

```bash
DROP_TO_SHELL=false UID=${UID} GID=${GID} docker compose run --rm project-test-local
```

## Architecture Highlights

- **Backend:** Ruby on Rails 8 (Native Auth)
- **Frontend:** React + TailwindCSS served via Inertia.js (Vite)
- **Database:** PostgreSQL 18 with citext, pgcrypto (UUIDs), and unaccent extensions enabled
- **Concurrency:** Optimistic Locking implemented on Book availability logic to prevent race conditions during borrowing
- **Pattern:** Service Objects (BorrowBookService, ReturnBookService) handle all business logic; Controllers are thin

## Recommended VS Code extensions

- Docker
- Ruby LSP
- ESLint / Prettier
- Tailwind CSS IntelliSense
