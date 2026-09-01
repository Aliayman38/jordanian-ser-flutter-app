import { AudioIOWeb } from './audio_io_web.js';

export function getAudioIO() {
  return new AudioIOWeb();
}

export const audio_io = {
  getTempAudioPath: async () => 'recording_temp.wav',
  saveAudioBytes: async () => true,
};

export function getTempAudioPath() {
  return 'recording_temp.wav';
}

export { AudioIOWeb };
export default getAudioIO;