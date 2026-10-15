# CLAUDE.md: new-horizons-web

Frontend of New Horizons (React 19, TypeScript, Vite, pnpm). It is a **learning project**: the tutor rules,
the plan and the lessons live in the parent study repo (`../CLAUDE.md`). If you were opened here directly,
read `../CLAUDE.md` first.

## Commands
- Dev: `pnpm dev` → http://127.0.0.1:8941 (Eric sees it at https://nh-dev.jarvis-os.uk). `/api/*` is proxied to Spring on 8940.
- Tests: `pnpm test` (Vitest + RTL) · `pnpm e2e` (Playwright, from day 9) · `pnpm typecheck` · `pnpm lint`
- Authorship KPI: `scripts/authorship.sh`

## Conventions
- Server state with TanStack Query (no `useEffect` fetching). Forms: react-hook-form + zod. Routing: React Router.
- Folders: `src/pages/<page>/`, `src/features/<feature>/`, `src/api/` (fetch client), `src/state/` (UI state).
- Code, comments and commits in **English**; UI texts in **Spanish**. Comments explain **why**.
- **Human zones** (`.claude/human-zones.txt`): Eric writes them; hooks block Claude there.
- The visual design comes later from Claude Design: keep styling minimal and semantic until then.
