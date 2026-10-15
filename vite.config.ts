import react from '@vitejs/plugin-react'
import { defineConfig } from 'vitest/config'

// Vite (dev server + build) and Vitest (unit tests) share this file.
export default defineConfig({
  plugins: [react()],
  server: {
    // Only on localhost: Eric reaches it through the Cloudflare tunnel (behind Access), never directly.
    host: '127.0.0.1',
    port: 8941,
    strictPort: true,
    allowedHosts: ['nh-dev.jarvis-os.uk'],
    // API calls go to /api and Vite forwards them to Spring Boot: same origin, no CORS to fight with.
    proxy: { '/api': { target: 'http://127.0.0.1:8940', rewrite: (p) => p.replace(/^\/api/, '') } },
  },
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    include: ['src/**/*.test.{ts,tsx}'],
    passWithNoTests: true,
  },
})
