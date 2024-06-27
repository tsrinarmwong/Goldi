'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  '/': 'index.html',
  'main.dart.js': 'main.dart.js',
  'manifest.json': 'manifest.json',
  'icons/icon-192.png': 'icons/icon-192.png',
  'icons/icon-512.png': 'icons/icon-512.png',
  // Add all other assets you want to cache
};

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  event.respondWith(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.match(event.request).then((response) => {
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      });
    })
  );
});