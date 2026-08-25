// Harisree Warehouse Service Worker
// Network-first for Flutter app shell (main.dart.js) so deploys are not stuck
// behind a stale cache-first blob. Cache-first only for images/fonts/icons.
// Bump CACHE_NAME on every release that changes main.dart.js.

const CACHE_NAME = 'harisree-v3';
const PRECACHE_URLS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(PRECACHE_URLS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((names) =>
      Promise.all(
        names
          .filter((name) => name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      )
    ).then(() => self.clients.claim())
  );
});

function isFlutterAppShell(pathname) {
  return (
    pathname === '/main.dart.js' ||
    pathname.endsWith('/main.dart.js') ||
    pathname === '/flutter.js' ||
    pathname === '/flutter_bootstrap.js' ||
    pathname.endsWith('.mjs') ||
    pathname.includes('main.dart.js')
  );
}

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  if (event.request.method !== 'GET') return;
  if (url.origin !== self.location.origin) return;

  // Always network-first for HTML and Flutter JS shell.
  if (
    url.pathname === '/' ||
    url.pathname.endsWith('.html') ||
    url.pathname === '/index.html' ||
    isFlutterAppShell(url.pathname)
  ) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          if (response && response.status === 200) {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
          }
          return response;
        })
        .catch(() => caches.match(event.request))
    );
    return;
  }

  // Cache-first for static images/fonts/icons only.
  event.respondWith(
    caches.match(event.request).then((cached) => {
      if (cached) return cached;
      return fetch(event.request).then((response) => {
        if (!response || response.status !== 200) return response;
        const clone = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
        return response;
      });
    })
  );
});
