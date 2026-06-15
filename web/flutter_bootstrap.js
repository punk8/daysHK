{{flutter_js}}
{{flutter_build_config}}

(async function bootstrapDaysInHk() {
  const reloadFlag = 'daysInHkServiceWorkerCleared';
  let hadFlutterServiceWorker = false;

  if ('serviceWorker' in navigator) {
    const registrations = await navigator.serviceWorker.getRegistrations();
    await Promise.all(
      registrations.map((registration) => {
        const scriptURL =
          registration.active?.scriptURL ??
          registration.waiting?.scriptURL ??
          registration.installing?.scriptURL ??
          '';
        if (scriptURL.includes('flutter_service_worker.js')) {
          hadFlutterServiceWorker = true;
          return registration.unregister();
        }
        return Promise.resolve(false);
      }),
    );
  }

  if ('caches' in window) {
    const keys = await caches.keys();
    await Promise.all(keys.map((key) => caches.delete(key)));
  }

  if (
    hadFlutterServiceWorker &&
    navigator.serviceWorker?.controller &&
    sessionStorage.getItem(reloadFlag) !== 'true'
  ) {
    sessionStorage.setItem(reloadFlag, 'true');
    window.location.reload();
    return;
  }
  sessionStorage.removeItem(reloadFlag);

  const cacheBust = Date.now().toString();
  for (const build of _flutter.buildConfig.builds) {
    if (build.mainJsPath) {
      build.mainJsPath = `${build.mainJsPath}?v=${cacheBust}`;
    }
  }

  _flutter.loader.load();
})();
