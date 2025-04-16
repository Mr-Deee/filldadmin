
// flutter.js - Flutter Web Bootstrap Loader
(function() {
  "use strict";

  // Flutter namespace setup
  window._flutter = window._flutter || {};
  window._flutter.buildConfig = {
    // Default configuration
    engineVersion: 'auto',
    renderer: 'auto',
    entrypoint: 'main.dart.js',
    serviceWorker: {
      version: '{{flutter_service_worker_version}}',
      script: 'flutter_service_worker.js'
    }
  };

  // Main loader implementation
  _flutter.loader = {
    load: function(options) {
      return new Promise(function(resolve, reject) {
        try {
          // Merge user options with defaults
          const config = Object.assign({}, _flutter.buildConfig, options);

          // Initialize service worker if enabled
          if (config.serviceWorker) {
            _initializeServiceWorker(config);
          }

          // Load the Flutter engine
          const script = document.createElement('script');
          script.src = config.entrypoint;
          script.type = "application/javascript";
          script.defer = true;

          script.onload = function() {
            resolve({
              initializeEngine: async function(engineConfig) {
                return window._flutter.loader.initializeEngine(engineConfig);
              }
            });
          };

          script.onerror = reject;
          document.body.appendChild(script);
        } catch (error) {
          reject(error);
        }
      });
    },

    initializeEngine: function(config) {
      return new Promise(function(resolve) {
        // Merge with build config
        const engineConfig = Object.assign({}, _flutter.buildConfig, config);

        // Initialize Flutter app
        _flutter.entrypoint = {
          baseUri: document.baseURI,
          configuration: engineConfig
        };

        // Return app runner
        resolve({
          runApp: function() {
            return _flutter.runApp(engineConfig);
          }
        });
      });
    }
  };

  // Service worker initialization
  function _initializeServiceWorker(config) {
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', function() {
        navigator.serviceWorker.register(config.serviceWorker.script, {
          scope: config.serviceWorker.scope || '/',
          updateViaCache: 'none'
        }).then(function(reg) {
          console.debug('Service worker registered:', reg);
        }).catch(function(error) {
          console.warn('Service worker registration failed:', error);
        });
      });
    }
  }

  // Fallback for older Flutter versions
  if (!window._flutter.loader) {
    window._flutter.loader = {
      loadEntrypoint: function(options) {
        console.warn('Using deprecated loadEntrypoint()');
        return _flutter.loader.load(options);
      }
    };
  }
})();