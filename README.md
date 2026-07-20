# Progress Visible Studio — website

The marketing site for **Progress Visible Studio** ([progressvisible.com](https://progressvisible.com)).
Static [Astro](https://astro.build) + Tailwind v4, self-hosted fonts, no client framework, no tracking.

This site doubles as a **deployment rehearsal** for `discbound.app`: it uses the same
S3 + CloudFront pipeline, so anything learned here (bucket policy, cache headers,
invalidation, DNS/HTTPS) transfers directly to the real launch.

## Stack

| | |
| --- | --- |
| Framework | Astro 5 (static output — plain HTML/CSS/JS) |
| Styling | Tailwind CSS v4 via `@tailwindcss/vite` |
| Fonts | EB Garamond + Inter, self-hosted via `@fontsource` (no external requests) |
| Theme | Light/dark with a system-following toggle |
| Hosting | Amazon S3 (origin) + CloudFront (CDN + HTTPS) |

## Develop

```bash
npm install
npm run dev        # http://localhost:4321
```

Site-wide copy, nav, and product list live in [`src/consts.ts`](src/consts.ts) — edit there,
not in the components.

```bash
npm run build      # → dist/  (what gets deployed)
npm run preview    # serve the built dist/ locally to sanity-check
```

## Deploy (S3 + CloudFront)

### One-time AWS setup

1. **Create the bucket** (private; CloudFront reads it via Origin Access Control — do *not*
   enable public "static website hosting"):
   ```bash
   aws s3 mb s3://progressvisible-com
   ```
2. **Create a CloudFront distribution** with that bucket as the origin:
   - Origin access: **Origin Access Control (OAC)**, then apply the generated bucket policy.
   - Default root object: `index.html`.
   - Viewer protocol policy: **Redirect HTTP → HTTPS**.
   - Attach an ACM certificate (in `us-east-1`) for `progressvisible.com` and add the
     alternate domain name.
   - Custom error response: map **403** and **404** → `/404.html` (or `/index.html`) with
     response code 404/200 as you prefer.
3. **DNS**: point `progressvisible.com` (and `www`) at the distribution via Route 53 alias
   records (or a CNAME at your registrar).

### Configure this repo

```bash
cp .env.example .env
# fill in PV_S3_BUCKET and PV_CLOUDFRONT_DISTRIBUTION_ID
```

### Ship it

```bash
npm run deploy
```

[`scripts/deploy.sh`](scripts/deploy.sh) builds, syncs fingerprinted assets with a 1-year
immutable cache, syncs HTML with `no-cache`, then invalidates the CloudFront distribution so
the edge serves the new files immediately.

> **Windows note:** `npm run deploy` runs the bash script — use Git Bash, or run the steps
> from `scripts/deploy.sh` by hand in PowerShell. The AWS CLI itself is cross-platform.

## Notes

- No analytics, no cookies, no external network requests at runtime.
- The palette and fonts are shared with Discbound so the studio and its products read as one
  family. Studio tokens live in [`src/styles/global.css`](src/styles/global.css).
