# PMS — Property Management System

A mobile application built with Flutter for managing rental properties, tenants, and payments. Developed as an assessment submission demonstrating Clean Architecture, BLoC state management, and Material 3 design.

---

## Features

### Properties

- Add, edit, and delete rental properties
- Track occupancy status (Vacant / Occupied) — auto-updated on tenant assignment
- View property details with monthly rent

### Tenants

- Add, edit, and delete tenants
- Assign tenants to vacant properties at creation or later
- Unassign tenants (property reverts to Vacant automatically)
- Swipe-to-delete with property cleanup

### Payments

- Record rent payments with due date, optional paid date, and notes
- Monthly rent amount auto-filled from the assigned property
- Payment status auto-derived:
  - **Paid** — paid date provided
  - **Overdue** — due date in the past and unpaid
  - **Pending** — due date in the future and unpaid
- Filter payments by All / Paid / Pending / Overdue
- Swipe right to **Mark as Paid**, swipe left to **Delete**

### Dashboard

- Live statistics: total properties, occupied count, overdue payments, this month's rent collected
- Occupancy pie chart (fl_chart)
- Overdue payment alert banner
- Recent payments list (last 5)
- Pull-to-refresh
- Auto-refreshes whenever properties, tenants, or payments change

---

## Tech Stack

| Layer                | Technology                                     |
| -------------------- | ---------------------------------------------- |
| Framework            | Flutter 3.38 / Dart 3.10                       |
| State Management     | flutter_bloc 9.x (BLoC pattern)                |
| Local Database       | SQLite via sqflite                             |
| Dependency Injection | get_it (manual registration)                   |
| Charts               | fl_chart                                       |
| UI                   | Material 3 — Google Inter font                 |
| Navigation           | Named routes via `MaterialApp.onGenerateRoute` |

---

## Architecture

Clean Architecture with three layers per feature:

```
lib/
├── core/                        # Shared utilities, errors, theme, DB
│   ├── constants/               # App strings, DB column names
│   ├── database/                # DatabaseHelper (SQLite singleton)
│   ├── errors/                  # Failure (sealed class), exceptions
│   ├── theme/                   # Material 3 light + dark theme
│   ├── usecases/                # UseCase<T, P> base class + NoParams
│   └── utils/                   # UUID generator, formatters, validators
│
├── features/
│   ├── dashboard/
│   │   ├── domain/              # DashboardStats entity + GetDashboardStats use case
│   │   └── presentation/        # DashboardBloc + DashboardScreen
│   │
│   ├── properties/
│   │   ├── data/                # PropertyModel, datasource, repository impl
│   │   ├── domain/              # Property entity, repository interface, 5 use cases
│   │   └── presentation/        # PropertyBloc, list / form / detail screens
│   │
│   ├── tenants/
│   │   ├── data/                # TenantModel, datasource, repository impl
│   │   ├── domain/              # Tenant entity, repository interface, 6 use cases
│   │   └── presentation/        # TenantBloc, list / form / detail screens
│   │
│   └── payments/
│       ├── data/                # PaymentModel, datasource, repository impl
│       ├── domain/              # Payment entity, repository interface, 6 use cases
│       └── presentation/        # PaymentBloc, list + record screens
│
├── router/
│   └── app_router.dart          # AppRoutes constants (named routes)
│
├── shell/
│   └── main_shell.dart          # IndexedStack + NavigationBar + cross-sync BlocListeners
│
├── injection.dart               # Manual get_it DI registration
└── main.dart                    # App entry point, MultiBlocProvider, onGenerateRoute
```

### Data Flow

```
SQLite row (Map<String, dynamic>)
  → XModel.fromMap()          [data layer — DB schema knowledge]
  → XModel (extends entity)   [IS-A entity, no toEntity() needed]
  → XRepositoryImpl           [implements domain interface]
  → XRepository (abstract)    [domain boundary]
  → Use Case                  [single responsibility, domain logic]
  → XBloc                     [sealed events + states]
  → Screen / BlocBuilder      [UI]
```

### Key Design Decisions

| Decision                                            | Reason                                                                                               |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `XModel extends XEntity`                            | Avoids redundant `.toEntity()` conversion — the model IS the entity with persistence knowledge added |
| `sealed class` for events, states, failures         | Exhaustive pattern matching; compiler-enforced; idiomatic Dart 3                                     |
| Manual get_it (no injectable code gen)              | Explicit, readable, zero build step complexity                                                       |
| Named routes via `onGenerateRoute`                  | No extra package; typed arguments via `settings.arguments`                                           |
| `IndexedStack` + `MultiBlocProvider` at root        | Tabs maintain state; BLoCs live for the app lifetime                                                 |
| Cross-sync `BlocListener`s in `MainShell`           | Property ↔ Tenant ↔ Dashboard stay in sync after any mutation; flag guards prevent infinite loops    |
| SQLite `PRAGMA foreign_keys = ON`                   | Enables `ON DELETE SET NULL` cascade on `tenants.property_id` when a property is deleted             |
| Optimistic `_dismissedIds` set in PaymentListScreen | Prevents "dismissed Dismissible still in tree" error during async BLoC update                        |
| `String? propertyId` in `AddTenantParams`           | Allows assigning a property at tenant creation time                                                  |

---

## SQLite Schema

```sql
CREATE TABLE properties (
  id          TEXT PRIMARY KEY,   -- timestamp-based UUID
  name        TEXT NOT NULL,
  address     TEXT NOT NULL,
  rent_amount REAL NOT NULL,
  status      TEXT NOT NULL,      -- 'vacant' | 'occupied'
  created_at  TEXT NOT NULL       -- ISO-8601
);

CREATE TABLE tenants (
  id           TEXT PRIMARY KEY,
  name         TEXT NOT NULL,
  email        TEXT NOT NULL,
  phone        TEXT NOT NULL,
  property_id  TEXT,              -- nullable FK → properties.id
  move_in_date TEXT,
  created_at   TEXT NOT NULL,
  FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE SET NULL
);

CREATE TABLE payments (
  id          TEXT PRIMARY KEY,
  tenant_id   TEXT NOT NULL,
  property_id TEXT NOT NULL,
  amount      REAL NOT NULL,
  due_date    TEXT NOT NULL,
  paid_date   TEXT,               -- null = unpaid
  status      TEXT NOT NULL,      -- 'paid' | 'pending' | 'overdue'
  notes       TEXT,
  created_at  TEXT NOT NULL
);
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.38`
- Dart SDK `>=3.10`
- Xcode (for iOS) or Android Studio (for Android)

### Run

```bash
# Install dependencies
flutter pub get

# Run on connected device / simulator
flutter run

# Analyze
flutter analyze
```

### No build step required

This project uses manual `get_it` registration — there is no `build_runner` or code generation step needed.

---

## Project Structure Highlights

- **`core/database/database_helper.dart`** — Singleton SQLite helper, creates all three tables on first open, enables foreign key enforcement
- **`features/dashboard/domain/usecases/get_dashboard_stats.dart`** — Cross-domain use case that reads from both `PropertyRepository` and `PaymentRepository` to compute live stats
- **`features/tenants/domain/usecases/assign_tenant_to_property.dart`** — Cross-domain use case that atomically updates both the tenant record and the property occupancy status
- **`shell/main_shell.dart`** — `MultiBlocListener` coordinates cross-feature data sync without introducing coupling between individual feature BLoCs
