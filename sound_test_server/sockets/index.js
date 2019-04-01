import SocketIO from 'socket.io';
import { Channel } from './channel';
import konsole from '../utils'

export const createSocketListener = (http) => {
  const io = SocketIO(http);

  io.on('connection', (socket) => {
    const address = socket.handshake.address;
    konsole.log(`[socket.io] New connection from : ${address}`);
  });

  let activeChannels = [];
  return {
    addChannel: (name) => {
      const newChannel = new Channel(io, name);
      activeChannels.push(newChannel);
      return newChannel;
    },
    removeChannel: (id) => activeChannels = activeChannels
      .filter(item => item.id === id),
    getChannels: () => activeChannels,
  }
}