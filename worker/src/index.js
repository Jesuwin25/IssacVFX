// Gatekeeps R2 video downloads: only requests that come from the portfolio
// site (Referer or Origin matches) are proxied; everything else gets 403.
// This stops the "copy URL from DevTools / paste in new tab" path.
// Does NOT stop a determined user with DevTools + curl --referer.

const ALLOWED_ORIGINS = new Set([
  "https://issacvfx.com",
  "https://www.issacvfx.com",
  "https://issacvfx.pages.dev",
]);

export default {
  async fetch(request, env) {
    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("Method not allowed", { status: 405 });
    }

    const referer = request.headers.get("Referer");
    const origin = request.headers.get("Origin");
    let refOrigin = null;
    if (referer) {
      try { refOrigin = new URL(referer).origin; } catch { /* malformed */ }
    }

    const allowed =
      ALLOWED_ORIGINS.has(refOrigin) || ALLOWED_ORIGINS.has(origin);

    if (!allowed) {
      return new Response("Forbidden", { status: 403 });
    }

    const url = new URL(request.url);
    const upstreamUrl = env.R2_PUBLIC_BASE + url.pathname;

    const upstreamHeaders = new Headers();
    const range = request.headers.get("Range");
    if (range) upstreamHeaders.set("Range", range);

    const upstream = await fetch(upstreamUrl, {
      method: request.method,
      headers: upstreamHeaders,
      cf: { cacheEverything: true, cacheTtl: 3600 },
    });

    const responseHeaders = new Headers(upstream.headers);
    responseHeaders.delete("Set-Cookie");
    responseHeaders.set("Cache-Control", "private, max-age=3600");
    responseHeaders.set("X-Content-Type-Options", "nosniff");
    responseHeaders.set("Accept-Ranges", "bytes");

    return new Response(upstream.body, {
      status: upstream.status,
      statusText: upstream.statusText,
      headers: responseHeaders,
    });
  },
};
