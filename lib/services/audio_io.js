const isWeb = typeof window !== 'undefined' && typeof document !== 'undefined';
const isNative = typeof process !== 'undefined' && process.versions && process.versions.node;

let audioModule;

if (isWeb) {
  audioModule = require('./audio_io_web');
} else if (isNative) {
  audioModule = require('./audio_io_native');
} else {
  audioModule = require('./audio_io_stub');
}

module.exports = audioModule;
