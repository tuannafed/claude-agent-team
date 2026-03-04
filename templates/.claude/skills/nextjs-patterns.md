# Skill: Next.js Patterns

**Used by:** Frontend Next.js agent, Integrator, Code Reviewer.

---

## App Router Structure

```
app/
  layout.tsx               # Root layout (HTML shell, providers)
  page.tsx                 # / route
  (auth)/                  # Route group — no URL segment
    login/page.tsx
    register/page.tsx
  (dashboard)/
    layout.tsx             # Dashboard layout with auth check
    dashboard/page.tsx
    users/
      page.tsx             # /users — server component (list)
      [id]/page.tsx        # /users/[id] — server component (detail)
      new/page.tsx         # /users/new — client component (form)
components/
  ui/                      # Shadcn/Radix base components
  features/                # Domain-specific components
lib/
  api/                     # API client (axios/fetch wrappers)
  hooks/                   # Custom hooks
  schemas/                 # Zod schemas
  utils.ts
```

---

## Server vs Client Components

```typescript
// Server Component (default) — no 'use client'
// ✅ Data fetching at render, no bundle overhead
// ✅ Access DB directly if needed
// ❌ No hooks, no browser APIs, no event handlers

// app/users/page.tsx
export default async function UsersPage() {
  const users = await fetchUsers(); // direct fetch, no useEffect
  return <UserList users={users} />;
}

// Client Component — needs 'use client'
// ✅ Hooks, state, event handlers
// ❌ Cannot be async, cannot call DB directly

'use client';
export function UserForm({ onSubmit }: Props) {
  const [loading, setLoading] = useState(false);
  // ...
}
```

**Rule:** Default to Server Components. Add `'use client'` only for: interactivity, hooks, browser APIs.

---

## Data Fetching (Server Components)

```typescript
// app/users/[id]/page.tsx
interface Props {
  params: Promise<{ id: string }>;
}

export default async function UserPage({ params }: Props) {
  const { id } = await params; // Next.js 15: params is a Promise
  const user = await getUser(id);

  if (!user) notFound(); // renders 404

  return <UserDetail user={user} />;
}

// With error boundary
export default async function UserPage({ params }: Props) {
  const { id } = await params;
  // Errors propagate to nearest error.tsx boundary
  const user = await getUser(id);
  return <UserDetail user={user} />;
}
```

---

## Loading and Error States

```
app/users/
  page.tsx
  loading.tsx       # Shown while page.tsx suspends
  error.tsx         # Shown when page.tsx throws
  not-found.tsx     # Shown when notFound() called
```

```typescript
// loading.tsx
export default function Loading() {
  return <SkeletonList />;
}

// error.tsx — must be client component
'use client';
export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div>
      <p>Something went wrong: {error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

---

## Server Actions

```typescript
// lib/actions/users.ts
'use server';

import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2),
});

export async function createUser(formData: FormData) {
  const parsed = CreateUserSchema.safeParse({
    email: formData.get('email'),
    name: formData.get('name'),
  });

  if (!parsed.success) {
    return { success: false, errors: parsed.error.flatten().fieldErrors };
  }

  await db.users.create({ data: parsed.data });
  revalidatePath('/users');
  return { success: true };
}
```

---

## Route Handlers (API Routes)

```typescript
// app/api/v1/users/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const { searchParams } = request.nextUrl;
  const page = Number(searchParams.get('page') ?? '1');

  const users = await getUsers({ page });
  return NextResponse.json({ success: true, data: users });
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const parsed = CreateUserSchema.safeParse(body);

  if (!parsed.success) {
    return NextResponse.json(
      { success: false, error: { code: 'VALIDATION_ERROR', message: 'Invalid input' } },
      { status: 400 }
    );
  }

  const user = await createUser(parsed.data);
  return NextResponse.json({ success: true, data: user }, { status: 201 });
}
```

---

## Metadata

```typescript
// Static metadata
export const metadata: Metadata = {
  title: 'Users | MyApp',
  description: 'Manage users',
};

// Dynamic metadata
export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const user = await getUser((await params).id);
  return { title: `${user.name} | MyApp` };
}
```

---

## Auth Pattern (middleware-based)

```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  const token = request.cookies.get('token')?.value;

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/v1/:path*'],
};
```

---

## Code Review: Next.js Checklist

```
[ ] params awaited in Next.js 15 (params is a Promise)
[ ] No 'use client' on components that don't need it
[ ] loading.tsx / error.tsx / not-found.tsx present for major routes
[ ] Server Actions validate with Zod before DB operations
[ ] Route handlers return consistent response envelope
[ ] Dynamic routes use generateMetadata
[ ] Auth checked in middleware, not page-by-page
[ ] No sensitive data in client components
```
