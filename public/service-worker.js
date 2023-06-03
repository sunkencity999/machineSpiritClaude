self.addEventListener('install', (event) => {
  console.log('Service worker installed');
});

self.addEventListener('fetch', (event) => {
  console.log('Fetch intercepted for:', event.request.url);
});

