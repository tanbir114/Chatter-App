import express, { Request, Response, NextFunction } from 'express';
import { json } from 'body-parser';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import winston from 'winston';
import morgan from 'morgan';
import http from 'http';
import {Server} from 'socket.io'

import authRoutes from './routes/authRoutes';
import conversationsRoutes from './routes/conversationsRoutes';
import messagesRoutes from './routes/messagesRoutes';
import {logger} from './utils/logger';
import { saveMessage } from './controllers/messagesController';
import contactsRoutes from './routes/contactsRoutes';

dotenv.config({ path: './.env' });

const app = express();
const server = http.createServer(app);
app.use(json());
const io = new Server(server, {
  cors: {
    origin: '*'
  }
})

app.use(
  morgan('combined', {
    stream: {
      write: (message: string) => logger.info(message.trim()),
    },
  })
);

app.use('/auth', authRoutes);
app.use('/conversations', conversationsRoutes);
app.use('/messages', messagesRoutes);
app.use('/contact', contactsRoutes);

io.on('connection', (socket) => {
  logger.info(`A user connected: ${socket.id}`);

  socket.on('joinConversation', (conversationId)=>{
    socket.join(conversationId);
    logger.info(`User joined conversation: ${conversationId}`);
  })

  socket.on('sendMessage', async(message)=>{
    const {conversationId, senderId, content} = message;

    try{
      const savedMessage = await saveMessage(conversationId, senderId, content);
      logger.info(`SendMessage: ${savedMessage}`);
      io.to(conversationId).emit('newMessage', savedMessage);

      io.emit('conversationUpdated', {
        conversationId,
        lastMessage: savedMessage.content,
        lastMessageTime: savedMessage.created_at
      })
    }catch(error){
      logger.error(`Failed to save message ${error}`);
    }
  })

  socket.on('disconnect', () =>{
    console.log('User disconnected', socket.id);
  })

})

const PORT = process.env.PORT || 6000;
const MONGODB_API = process.env.MONGODB_API;

if (!MONGODB_API) {
  logger.error("Environment variable MONGODB_API is not defined");
  throw new Error("Environment variable MONGODB_API is not defined");
}

mongoose
  .connect(MONGODB_API)
  .then(() => {
    app.listen(PORT, () => {
      logger.info(`Server listening on http://localhost:${PORT}`);
    });
    logger.info('Connected to MongoDB');
  })
  .catch((err) => {
    logger.error(`Error connecting to MongoDB: ${err.message}`);
    throw err;
  });
