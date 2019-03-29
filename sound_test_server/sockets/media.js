import nanoid from 'nanoid';
import { PidController } from '../utils/pid';

export const MEDIA_STATUS = {
  DEFAULT: 'default',
  PLAYING: 'playing',
  PAUSED: 'paused',
}

// shared with client
export const MEDIA_ACTIONS = {
  ONPLAY: 0,
  PLAYING: 1,
  SEEKING: 2,
  SEEKED: 3,
  ONPAUSE: 4,
  SYNC: 10,
}

export class Media {
  constructor(name, metadata = { 
    duration: 0,
    fileName: '',
    fileSize: 0,
    path: '',
  }) {
    this.name = name;
    this.status = MEDIA_STATUS.DEFAULT;
    this.fileName = metadata.fileName;
    this.duration = metadata.duration;
    this.fileSize = metadata.fileSize;
    this.path = metadata.path;

    this.position = 0;
    this.startTime = new Date().getTime();
    this.controller = new PidController();
    this.controller.setTarget(0);
  }

  getPosition = () => {
    return this.position + (new Date().getTime() - this.startTime)
  }

  handleMessage = (action) => {
    switch (action.type) {
      case MEDIA_ACTIONS.ONPLAY:
        this.status = MEDIA_STATUS.PLAYING;
        this.controller.reset();
        this.startTime = new Date().getTime();
        this.position = action.position || 0;
        break;

      case MEDIA_ACTIONS.ONPAUSE:
        this.status = MEDIA_STATUS.PAUSED;
        this.controller.reset();
        this.startTime = new Date().getTime();
        this.position = action.position || 0;
        break;

      default:
        if (action.position) {
          const currentPosition = this.getPosition();
          this.position = currentPosition + this.controller.update(action.position - currentPosition);

          this.startTime = new Date().getTime();
        }
      break;
    }
  }
}