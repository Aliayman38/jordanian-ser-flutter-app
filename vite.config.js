import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  base: './',
  plugins: [react()],
  server: {
    host: true, // يتيح الاستماع لجميع الشبكات
    port: 5173,
    allowedHosts: true, // يسمح بروابط Cloudflare الخارجية
  },
});