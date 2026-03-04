# Skill: Form Validation Patterns

**Used by:** Frontend Next.js agent, Code Reviewer.

---

## Stack: React Hook Form + Zod

```bash
pnpm add react-hook-form @hookform/resolvers zod
```

---

## Schema Definition (Zod)

```typescript
// lib/schemas/user.schema.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  email: z.string().email('Please enter a valid email'),
  name: z.string().min(2, 'Name must be at least 2 characters').max(100),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  confirmPassword: z.string(),
  role: z.enum(['admin', 'user']).default('user'),
}).refine(
  (data) => data.password === data.confirmPassword,
  { message: 'Passwords do not match', path: ['confirmPassword'] }
);

export type CreateUserInput = z.infer<typeof CreateUserSchema>;
```

---

## Form Component Pattern

```typescript
'use client';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { CreateUserSchema, type CreateUserInput } from '@/lib/schemas/user.schema';

interface CreateUserFormProps {
  onSuccess?: () => void;
}

export function CreateUserForm({ onSuccess }: CreateUserFormProps) {
  const createUser = useCreateUser();

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    setError,
    reset,
  } = useForm<CreateUserInput>({
    resolver: zodResolver(CreateUserSchema),
    defaultValues: { role: 'user' },
  });

  const onSubmit = async (data: CreateUserInput) => {
    try {
      await createUser.mutateAsync(data);
      reset();
      onSuccess?.();
    } catch (error) {
      // Map API field errors back to form
      if (isAxiosError(error) && error.response?.data?.error?.details) {
        error.response.data.error.details.forEach(({ field, message }) => {
          setError(field as keyof CreateUserInput, { message });
        });
      }
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          {...register('email')}
          aria-describedby={errors.email ? 'email-error' : undefined}
          aria-invalid={!!errors.email}
        />
        {errors.email && (
          <p id="email-error" role="alert">{errors.email.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="name">Name</label>
        <input id="name" {...register('name')} aria-invalid={!!errors.name} />
        {errors.name && <p role="alert">{errors.name.message}</p>}
      </div>

      {/* Root-level errors (cross-field) */}
      {errors.root && <p role="alert">{errors.root.message}</p>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create User'}
      </button>
    </form>
  );
}
```

---

## Async Validation (Server-Side Check)

```typescript
const schema = z.object({
  username: z.string().min(3),
});

// For async validation, use refine in useForm validate option
const form = useForm<FormInput>({
  resolver: zodResolver(schema),
});

// Or use setError after API response:
const onSubmit = async (data: FormInput) => {
  const result = await checkUsername(data.username);
  if (!result.available) {
    form.setError('username', { message: 'Username is already taken' });
    return;
  }
  // proceed
};
```

---

## Shadcn/UI Integration

```typescript
// Using Shadcn Form component (wraps RHF context)
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';

export function CreateUserForm() {
  const form = useForm<CreateUserInput>({ resolver: zodResolver(CreateUserSchema) });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input type="email" {...field} />
              </FormControl>
              <FormMessage /> {/* automatically shows error */}
            </FormItem>
          )}
        />
        <Button type="submit" disabled={form.formState.isSubmitting}>
          Create
        </Button>
      </form>
    </Form>
  );
}
```

---

## Controlled Selects and Checkboxes

```typescript
// Select — use Controller
<FormField
  control={form.control}
  name="role"
  render={({ field }) => (
    <FormItem>
      <FormLabel>Role</FormLabel>
      <Select onValueChange={field.onChange} defaultValue={field.value}>
        <SelectTrigger><SelectValue placeholder="Select role" /></SelectTrigger>
        <SelectContent>
          <SelectItem value="admin">Admin</SelectItem>
          <SelectItem value="user">User</SelectItem>
        </SelectContent>
      </Select>
      <FormMessage />
    </FormItem>
  )}
/>

// Checkbox
<FormField
  control={form.control}
  name="acceptTerms"
  render={({ field }) => (
    <FormItem>
      <FormControl>
        <Checkbox checked={field.value} onCheckedChange={field.onChange} />
      </FormControl>
      <FormLabel>Accept terms</FormLabel>
      <FormMessage />
    </FormItem>
  )}
/>
```

---

## Submit Guard Pattern

Prevent double-submit and accidental navigation:

```typescript
const form = useForm<FormInput>();
const isDirty = form.formState.isDirty;
const isSubmitting = form.formState.isSubmitting;

// Warn before leaving with unsaved changes
useEffect(() => {
  const handleBeforeUnload = (e: BeforeUnloadEvent) => {
    if (isDirty) e.preventDefault();
  };
  window.addEventListener('beforeunload', handleBeforeUnload);
  return () => window.removeEventListener('beforeunload', handleBeforeUnload);
}, [isDirty]);
```

---

## Code Review: Form Validation Checklist

```
[ ] Zod schema defined in lib/schemas/ (not inline in component)
[ ] zodResolver wired to useForm
[ ] aria-invalid and aria-describedby on inputs with errors
[ ] role="alert" on error messages
[ ] isSubmitting disables submit button
[ ] API field errors mapped back via setError
[ ] noValidate on <form> (let RHF handle validation, not browser)
[ ] Cross-field validation uses .refine() with path specified
```
