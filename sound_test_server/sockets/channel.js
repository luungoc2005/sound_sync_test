import Uuid from 'uuid';
import nanoid from 'nanoid';
import actionTypes from './actionTypes';
import { MEDIA_STATUS, MEDIA_ACTIONS } from './media';

export const toHHMMSS = function (input) {
  let sec_num = parseInt(input, 10); // don't forget the second param
  let hours   = Math.floor(sec_num / 3600);
  let minutes = Math.floor((sec_num - (hours * 3600)) / 60);
  let seconds = sec_num - (hours * 3600) - (minutes * 60);

  if (hours   < 10) {hours   = "0"+hours;}
  if (minutes < 10) {minutes = "0"+minutes;}
  if (seconds < 10) {seconds = "0"+seconds;}
  return hours+':'+minutes+':'+seconds;
}

export const eventTypes = {
  action: 'action',
}

export class Channel {
  connectedClients = [];
  io = null;
  namespace = null;

  constructor(io, name) {
    const id = Uuid.v4();

    this.id = id;
    this.name = name;
    this.io = io;
    this.namespace = io.of(`/${id}`);
    this.masterNamespace = io.of(`/${id}-master`);

    this.token = nanoid();
  
    this.masterNamespace.on('connection', this.handleMasterConnection)

    this.namespace.on('connection', this.handleClientConnection)
  }

  handleMasterConnection = (socket) => {
    const address = socket.handshake.address;
    console.log(`[socket.io] New connection to channel ${this.id} from : ${address}`);

    socket.on(eventTypes.action, data => {
      try {
        if (data.token && data.token === this.token) {
          this.handleMasterMessage(data);
        }
      }
      catch (err) {
        this.handleError(err);
      }
    })
  }

  handleMasterMessage = (action) => {
    if (this.namespace) {
      const { token, ...data } = action;
      console.log(`Master action`, action);

      if (this.media) {
        this.media.handleMessage(action);
        this.namespace.emit(eventTypes.action, {
          ...data,
          position: this.media.getPosition(),
        });
      }
    }
  }

  setMedia = (media) => {
    this.media = media;
    this.handleMasterMessage({
      type: actionTypes.SET_MEDIA,

      fileName: this.media.fileName,
      duration: this.media.duration,
    })
  }

  handleClientConnection = (socket) => {
    const address = socket.handshake.address;
    console.log(`[socket.io] New client connected to channel ${this.id} from : ${address}`);
    
    if (this.media) {
      if (this.media.status === MEDIA_STATUS.PLAYING) {
        socket.emit(eventTypes.action, {
          type: MEDIA_ACTIONS.ONPLAY,
          position: this.media.getPosition(),
        })
      }
    }
  }

  getStatus = () => {
    if (!this.media) {
      return 'Idle';
    }
    else {
      if (this.media.status === MEDIA_STATUS.PLAYING) {
        return `Now Showing: ${this.media.fileName} (${toHHMMSS(this.media.getPosition() / 1000)})`;
      }
      else {
        return `[ON HALT] Now Showing: ${this.media.fileName}`;
      }
    }
  }

  handleError = (err) => console.error(`[socket.io] Error in channel ${this.id}: ${err}`);
}