# TanStack Start

TanStack Start is a full-stack React framework powered by TanStack Router and Vite. It enables building modern web applications with server-side rendering, streaming, type-safe server functions, and universal deployment capabilities. The framework provides both server and client execution environments with explicit control over where code runs, making it ideal for applications requiring SEO optimization, progressive enhancement, and end-to-end type safety.

Built on two core dependencies—TanStack Router for routing and Vite for bundling—Start delivers enterprise-grade features including full-document SSR, middleware composition, server routes alongside frontend code, and deployment flexibility to any Vite-compatible hosting provider. The framework adopts an isomorphic-by-default approach where code runs in both environments unless explicitly constrained, giving developers precise control over execution boundaries while maintaining a unified codebase.

## Installation and Setup

Quick project creation using CLI with customizable options.

```bash
# Create new project with interactive prompts
npm create @tanstack/start@latest

# Clone basic example
npx gitpick TanStack/router/tree/main/examples/react/start-basic my-project
cd my-project
npm install
npm run dev

# Install core dependencies manually
npm i @tanstack/react-start @tanstack/react-router vite
npm i react react-dom @vitejs/plugin-react
npm i -D typescript @types/react @types/react-dom vite-tsconfig-paths
```

## Project Configuration

Configure Vite with TanStack Start plugin and TypeScript settings.

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'
import tsConfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
  server: { port: 3000 },
  plugins: [
    tsConfigPaths(),
    tanstackStart(),
    viteReact(), // Must come after tanstackStart()
  ],
})

// tsconfig.json
{
  "compilerOptions": {
    "jsx": "react-jsx",
    "moduleResolution": "Bundler",
    "module": "ESNext",
    "target": "ES2022",
    "skipLibCheck": true,
    "strictNullChecks": true
  }
}

// package.json
{
  "type": "module",
  "scripts": {
    "dev": "vite dev",
    "build": "vite build",
    "start": "node .output/server/index.mjs"
  }
}
```

## Router Configuration

Configure router instance with route tree and behavior settings.

```typescript
// src/router.tsx
import { createRouter } from '@tanstack/react-router';
import { routeTree } from './routeTree.gen';

export function getRouter() {
  const router = createRouter({
    routeTree,
    scrollRestoration: true,
    defaultPreload: 'intent',
    defaultStaleTime: 5000,
  });
  return router;
}
```

## Root Route Setup

Define application shell with document structure and global layout.

```tsx
// src/routes/__root.tsx
import {
  Outlet,
  createRootRoute,
  Scripts,
  ScrollRestoration,
} from '@tanstack/react-router';

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { title: 'My TanStack Start App' },
    ],
  }),
  component: RootComponent,
});

function RootComponent() {
  return (
    <html lang="en">
      <head>
        <meta charSet="UTF-8" />
      </head>
      <body>
        <nav>
          <a href="/">Home</a>
          <a href="/about">About</a>
        </nav>
        <main>
          <Outlet />
        </main>
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}
```

## File-Based Routing

Define routes using file naming conventions with dynamic segments.

```tsx
// src/routes/index.tsx - matches "/"
import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/')({
  component: HomeComponent,
});

function HomeComponent() {
  return <h1>Welcome Home</h1>;
}

// src/routes/posts/$postId.tsx - matches "/posts/:postId"
export const Route = createFileRoute('/posts/$postId')({
  loader: async ({ params }) => {
    const response = await fetch(`/api/posts/${params.postId}`);
    return response.json();
  },
  component: PostComponent,
});

function PostComponent() {
  const post = Route.useLoaderData();
  return <article>{post.title}</article>;
}

// src/routes/api/file/$.ts - wildcard route matches "/api/file/*"
export const Route = createFileRoute('/api/file/$')({
  server: {
    handlers: {
      GET: async ({ params }) => {
        // params._splat contains everything after /api/file/
        return new Response(`File: ${params._splat}`);
      },
    },
  },
});
```

## Server Functions

Create type-safe RPC functions callable from client with validation.

```tsx
// src/server/users.ts
import { createServerFn } from '@tanstack/react-start';
import { z } from 'zod';

// GET request with no input
export const getUsers = createServerFn().handler(async () => {
  const db = await connectDB();
  return db.users.findMany();
});

// POST request with Zod validation
const CreateUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().min(0).max(120),
});

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(CreateUserSchema)
  .handler(async ({ data }) => {
    // data is typed and validated: { name: string, email: string, age: number }
    const db = await connectDB();
    const user = await db.users.create(data);
    return { success: true, userId: user.id };
  });

// Usage in component
import { useServerFn } from '@tanstack/react-start';

function UserForm() {
  const createUserFn = useServerFn(createUser);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const result = await createUserFn({
        data: { name: 'John', email: 'john@example.com', age: 30 },
      });
      console.log('User created:', result.userId);
    } catch (error) {
      console.error('Validation failed:', error.message);
    }
  };

  return <form onSubmit={handleSubmit}>...</form>;
}
```

## Environment Functions

Control code execution across client and server boundaries.

```tsx
import {
  createIsomorphicFn,
  createServerOnlyFn,
  createClientOnlyFn,
} from '@tanstack/react-start';

// Runs on both environments with different implementations
const getDeviceInfo = createIsomorphicFn()
  .server(() => ({
    type: 'server',
    platform: process.platform,
    memory: process.memoryUsage().heapUsed,
  }))
  .client(() => ({
    type: 'client',
    userAgent: navigator.userAgent,
    language: navigator.language,
  }));

const info = getDeviceInfo(); // Returns different data based on environment

// Server-only function - crashes if called from client
const getSecret = createServerOnlyFn(() => {
  return process.env.DATABASE_URL; // Safe from client exposure
});

// Usage in server function
export const connectToDb = createServerFn().handler(async () => {
  const dbUrl = getSecret();
  return connectDatabase(dbUrl);
});

// Client-only function - crashes if called from server
const saveToStorage = createClientOnlyFn((key: string, value: any) => {
  localStorage.setItem(key, JSON.stringify(value));
  return true;
});

// Usage in component
function SaveButton({ data }: { data: object }) {
  const handleSave = () => {
    saveToStorage('userData', data);
  };
  return <button onClick={handleSave}>Save Locally</button>;
}
```

## Server Routes

Define HTTP endpoints alongside frontend routes with middleware.

```tsx
// routes/api/users.ts - API route at GET /api/users
import { createFileRoute } from '@tanstack/react-router';
import { json } from '@tanstack/react-start';

export const Route = createFileRoute('/api/users')({
  server: {
    handlers: {
      GET: async ({ request }) => {
        const users = await db.users.findMany();
        return json({ users, total: users.length });
      },
      POST: async ({ request }) => {
        const body = await request.json();
        const user = await db.users.create(body);
        return json(user, { status: 201 });
      },
    },
  },
});

// routes/api/users/$id.ts - Dynamic route at /api/users/:id
export const Route = createFileRoute('/api/users/$id')({
  server: {
    handlers: {
      GET: async ({ params }) => {
        const user = await db.users.findById(params.id);
        if (!user) {
          return new Response('User not found', { status: 404 });
        }
        return json(user);
      },
      DELETE: async ({ params }) => {
        await db.users.delete(params.id);
        return new Response(null, { status: 204 });
      },
    },
  },
});

// Combining server route with component in same file
export const Route = createFileRoute('/dashboard')({
  server: {
    handlers: {
      POST: async ({ request }) => {
        const data = await request.json();
        await processData(data);
        return json({ success: true });
      },
    },
  },
  component: DashboardComponent,
});

function DashboardComponent() {
  return <div>Dashboard UI</div>;
}
```

## Middleware Composition

Create reusable middleware for authentication, logging, and context.

```tsx
// middleware/auth.ts
import { createMiddleware } from '@tanstack/react-start';

// Request middleware applies to all server requests
export const authMiddleware = createMiddleware().server(
  async ({ next, request }) => {
    const token = request.headers.get('Authorization')?.replace('Bearer ', '');

    if (!token) {
      throw new Error('Unauthorized');
    }

    const user = await verifyToken(token);

    return next({
      context: { user }, // Pass to nested middleware
    });
  },
);

// Server function middleware with client + server hooks
export const loggingMiddleware = createMiddleware({ type: 'function' })
  .client(async ({ next }) => {
    console.log('[CLIENT] Request started');
    const result = await next();
    console.log('[CLIENT] Request completed');
    return result;
  })
  .server(async ({ next, context }) => {
    const startTime = Date.now();
    console.log('[SERVER] Processing request');
    const result = await next();
    console.log(`[SERVER] Completed in ${Date.now() - startTime}ms`);
    return result;
  });

// Apply to specific server function
import { createServerFn } from '@tanstack/react-start';

export const getProtectedData = createServerFn()
  .middleware([authMiddleware, loggingMiddleware])
  .handler(async ({ context }) => {
    // context.user is typed and available
    return { message: `Hello ${context.user.name}` };
  });

// Apply to all handlers in a route
export const Route = createFileRoute('/protected')({
  server: {
    middleware: [authMiddleware],
    handlers: {
      GET: async ({ context }) => {
        return json({ user: context.user });
      },
      POST: async ({ context }) => {
        return json({ updated: true });
      },
    },
  },
});

// Global middleware in src/start.ts
import { createStart } from '@tanstack/react-start';

export const startInstance = createStart(() => ({
  requestMiddleware: [authMiddleware], // Runs for all requests
  functionMiddleware: [loggingMiddleware], // Runs for all server functions
}));
```

## Context Management

Pass data between middleware layers with type safety.

```tsx
import { createMiddleware, createServerFn } from '@tanstack/react-start';

// Middleware providing workspace context
const workspaceMiddleware = createMiddleware({ type: 'function' })
  .client(async ({ next, context }) => {
    const workspaceId = getWorkspaceFromUrl();
    return next({
      sendContext: { workspaceId }, // Send to server
    });
  })
  .server(async ({ next, context }) => {
    // Validate client-sent context
    const workspaceId = z.string().uuid().parse(context.workspaceId);
    const workspace = await db.workspaces.findById(workspaceId);

    return next({
      context: { workspace }, // Pass to nested middleware
      sendContext: { workspaceName: workspace.name }, // Send back to client
    });
  });

// Middleware sending server data to client
const serverTimeMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    return next({
      sendContext: { serverTime: new Date().toISOString() },
    });
  })
  .client(async ({ next }) => {
    const result = await next();
    console.log('Server time:', result.context.serverTime); // Typed
    return result;
  });

// Using context in server function
export const updateProject = createServerFn({ method: 'POST' })
  .middleware([workspaceMiddleware, serverTimeMiddleware])
  .handler(async ({ data, context }) => {
    // context.workspace is typed and available
    const project = await db.projects.create({
      ...data,
      workspaceId: context.workspace.id,
    });
    return project;
  });
```

## Form Handling

Process form submissions with validation and progressive enhancement.

```tsx
// Server function handling FormData
import { createServerFn } from '@tanstack/react-start';
import { redirect } from '@tanstack/react-router';

export const submitContactForm = createServerFn({ method: 'POST' })
  .inputValidator((input) => {
    if (!(input instanceof FormData)) {
      throw new Error('Expected FormData');
    }
    return {
      name: input.get('name')?.toString() || '',
      email: input.get('email')?.toString() || '',
      message: input.get('message')?.toString() || '',
    };
  })
  .handler(async ({ data }) => {
    // Validate
    if (!data.email.includes('@')) {
      throw new Error('Invalid email');
    }

    // Process
    await sendEmail({
      to: 'contact@example.com',
      subject: `Message from ${data.name}`,
      body: data.message,
    });

    // Redirect on success
    throw redirect({ to: '/thank-you' });
  });

// Component with progressive enhancement
import { useServerFn } from '@tanstack/react-start';

function ContactForm() {
  const submitForm = useServerFn(submitContactForm);
  const [status, setStatus] = useState<'idle' | 'submitting' | 'error'>('idle');
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setStatus('submitting');
    setError(null);

    try {
      const formData = new FormData(e.currentTarget);
      await submitForm({ data: formData });
      // Redirect happens automatically
    } catch (err) {
      setStatus('error');
      setError(err.message);
    }
  };

  return (
    <form onSubmit={handleSubmit} action="/api/contact" method="post">
      <input name="name" required />
      <input name="email" type="email" required />
      <textarea name="message" required />
      <button type="submit" disabled={status === 'submitting'}>
        {status === 'submitting' ? 'Sending...' : 'Send Message'}
      </button>
      {error && <p className="error">{error}</p>}
    </form>
  );
}
```

## Deployment to Cloudflare Workers

Configure and deploy to Cloudflare's edge network.

```bash
# Install dependencies
pnpm add -D @cloudflare/vite-plugin wrangler
```

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import { tanstackStart } from '@tanstack/react-start/plugin/vite';
import { cloudflare } from '@cloudflare/vite-plugin';
import viteReact from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [
    cloudflare({ viteEnvironment: { name: 'ssr' } }),
    tanstackStart(),
    viteReact(),
  ],
});
```

```json
// wrangler.jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "my-tanstack-app",
  "compatibility_date": "2025-09-02",
  "compatibility_flags": ["nodejs_compat"],
  "main": "@tanstack/react-start/server-entry"
}

// package.json scripts
{
  "scripts": {
    "dev": "vite dev",
    "build": "vite build && tsc --noEmit",
    "preview": "vite preview",
    "deploy": "wrangler deploy",
    "cf-typegen": "wrangler types"
  }
}
```

```bash
# Build and deploy
pnpm run build && pnpm run deploy
```

## Deployment to Netlify

Configure and deploy to Netlify's platform.

```bash
# Install plugin
npm install -D @netlify/vite-plugin-tanstack-start
```

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import { tanstackStart } from '@tanstack/react-start/plugin/vite';
import netlify from '@netlify/vite-plugin-tanstack-start';
import viteReact from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [tanstackStart(), netlify(), viteReact()],
});
```

```toml
# netlify.toml
[build]
  command = "vite build"
  publish = "dist/client"
```

```bash
# Deploy via Netlify CLI or connect Git repository
netlify deploy --prod
```

## Summary

TanStack Start provides a comprehensive full-stack React framework that unifies server and client development with end-to-end type safety. The framework's primary use cases include building SEO-optimized web applications with server-side rendering, creating type-safe APIs alongside frontend routes, implementing authentication and authorization with composable middleware, handling form submissions with progressive enhancement, and deploying to various hosting platforms including edge networks. Server functions enable seamless RPC calls between client and server while maintaining type safety across the network boundary, making it ideal for applications requiring both rich interactivity and server capabilities.

The framework's integration patterns center around file-based routing with co-located server and client code, middleware composition for cross-cutting concerns, and explicit environment control for security-critical operations. TanStack Router provides the routing foundation with advanced features like type-safe navigation, nested layouts, and data loading, while Vite handles bundling and development experience. The isomorphic-by-default execution model with explicit APIs for server-only and client-only code ensures developers maintain full control over where code runs, preventing security vulnerabilities while enabling code reuse where appropriate. This architectural approach makes TanStack Start suitable for everything from simple websites to complex enterprise applications requiring advanced authentication, database integration, and scalable deployment strategies.
