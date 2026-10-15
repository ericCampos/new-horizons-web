import { defineConfig } from '@playwright/test'

// End-to-end tests (day 9). Browsers are installed then with `pnpm exec playwright install chromium`.
export default defineConfig({
  testDir: './e2e',
  use: { baseURL: 'http://127.0.0.1:8941' },
})
