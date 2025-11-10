# Repository Guidelines for AI

This file provides guidance to AI Code Agent when working with code in this repository.

## Project Structure & Module Organization

Source lives in `src/`. Global routing is defined in `src/router.tsx`, with route modules in `src/routes` (`__root.tsx` for layout, `index.tsx` for the landing page). Shared UI composites belong in `src/components`, design primitives in `src/ui`. Styling overrides sit in `src/styles.css`. Static files stay in `public/`, and production artifacts are written to `dist/` and `.output/`. Colocate new feature assets with the component or route that consumes them to keep dependencies obvious.

- UI: Mantine v8. See `.ai/mantine.md`. Routing: TanStack Start/Router. See `.ai/tanstack-start.md` `.ai/tanstack-router.md`.
- Generated files like `routeTree.gen.ts` are auto-created; do not edit.

## Build, Test & Development Commands

Use pnpm for everything. `pnpm dev` starts the Vite dev server on port 3000 with hot reload. `pnpm build` emits the optimized bundle into `dist/`, while `pnpm serve` runs the Nitro server from `.output/` to sanity-check SSR. `pnpm check:types` runs `tsc --noEmit`. `pnpm lint` applies the TanStack + React ESLint rules, and `pnpm format` runs Prettier then auto-fixes lint errors. `pnpm test` executes the Vitest suite in run mode; append `--watch` while iterating.

Before declaring any Agent task complete, re-run `pnpm check:types` and `pnpm format` and ensure both commands pass cleanly.

## Coding Style & Naming Conventions

Write TypeScript React function components. Prettier enforces 2-space indents, semicolons, single quotes, and trailing commas—never hand-format around it.

Use PascalCase for components (`DashboardCard.tsx`), camelCase for hooks/utilities. Mantine styles should live beside their component, leveraging Mantine's theming utilities before reaching for raw CSS. ESLint errors such as `react/button-has-type` and `react/self-closing-comp` are considered blocking; fix them prior to review.

## Testing Guidelines

Vitest plus @testing-library/react is available. Store specs near the unit they cover as `ComponentName.test.tsx`. Focus on hooks logic, conditional rendering, and TanStack route loaders. Use fixtures from `src/data` (or inline mocks) to keep assertions deterministic. Run `pnpm test --watch` locally, and add snapshot or accessibility assertions whenever Mantine styling or routing structure changes.

## Commit & Pull Request Guidelines

Commits should mirror the existing short, imperative pattern (`use mantine components for index page`). Keep changes scoped and meaningful. PRs must include: a concise summary, linked issue/ticket, before/after screenshots for UI work, and confirmation that `pnpm lint`, `pnpm check:types`, and `pnpm test` passed. Mention any config or env changes up front so reviewers can reproduce.

## Security & Configuration Tips

Secrets belong in `.env.local` (gitignored); reference them through Vite's `import.meta.env`. Run `lefthook install` once so git hooks catch lint/test regressions pre-push. Document any third-party scripts or analytics additions in the PR, including CSP or token requirements.

## Notes

1. Prefer Mantine components and styles; avoid unnecessary custom CSS.
2. Extract custom components into the `src/components/` directory (and then you can import them with `~components/`); use CSS Modules for each component's styles.
3. Always use English when writing code, comments, and documentation.

## Dependencies / Tools

### Mantine

The project uses [Mantine](https://mantine.dev/) v8 for UI components. Read .ai/mantine.md for its documentation.

### Tanstack Start

The project uses [Tanstack Start](https://tanstack.com/start/latest/docs/) for routing. Read .ai/tanstack-start.md for its documentation.

And you can use the context7 mcp tool with the library id `/websites/tanstack_com-start-latest` to load (or search) docs.

### Tanstack Router

Tanstack Start uses the Tanstack Router under the hood. Read .ai/tanstack-router.md for its documentation.

And you can use the context7 mcp tool with the library id `/websites/tanstack_router` to load (or search) docs.

### Context7

If you need to get some other documentations that you don't know exactly, you can use the context7 mcp tool.
