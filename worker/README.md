# issacvfx-media Worker

Referer-gate in front of the public R2 bucket. Only requests from
`issacvfx.com` / `www.issacvfx.com` / `issacvfx.pages.dev` get through.
Everything else returns 403.

## Deploy via Cloudflare dashboard (easiest, no CLI)

1. Go to **Cloudflare dashboard** → **Workers & Pages** → **Create** → **Create Worker**.
2. Name it `issacvfx-media`. Click **Deploy** (default Hello World — we'll replace it).
3. Click **Edit code**. Delete the template, paste the contents of `src/index.js`, click **Deploy**.
4. Still in the Worker page → **Settings** → **Variables and Secrets** → **Add variable**:
   - Name: `R2_PUBLIC_BASE`
   - Value: `https://pub-2bc2cab855a64c1d81823ac676d15d52.r2.dev`
   - Type: Text (not secret)
   - **Save**.
5. **Settings** → **Domains & Routes** → **Add** → **Custom domain** → enter `media.issacvfx.com` → **Add domain**. Cloudflare creates the DNS record + SSL cert automatically (~1 min).
6. Test: open `https://media.issacvfx.com/showreel_v1.mp4` in a new tab — should show **403 Forbidden** (good, because there's no Referer). Then visit `https://issacvfx.com/` — the showreel should play.

## Deploy via CLI (if you have wrangler set up)

```
cd worker
npx wrangler deploy
```

Wrangler reads `wrangler.toml`, creates the custom domain, and sets `R2_PUBLIC_BASE` as a var.
