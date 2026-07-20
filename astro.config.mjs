// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

// Static output (the default) → plain files for S3 + CloudFront. No SSR, no server.
// `site` is used for canonical URLs / sitemap; update if the final domain differs.
export default defineConfig({
  site: 'https://progressvisible.com',
  vite: {
    plugins: [tailwindcss()],
  },
});
