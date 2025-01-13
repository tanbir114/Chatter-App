import { Request, Response } from "express"
import { Message } from "../models/messageModel";

export const fetchAllMessagesByConversationId = async (req: Request, res: Response): Promise<void> => {
    const { conversationId } = req.params;
  
    if (!conversationId) {
      res.status(400).json({ error: 'Conversation ID is required.' });
      return;
    }
  
    try {
      const messages = await Message.find({ conversation_id: conversationId })
        .sort({ created_at: 1 })
        .exec();
      res.status(200).json(messages);
    } catch (err) {
      console.error('Error fetching messages:', err);
      res.status(500).json({ error: 'Failed to fetch messages.' });
    }
  };

  export const saveMessage = async (conversationId: string, senderId: string, content: string): Promise<any> => {
    try {
      const newMessage = new Message({
        conversation_id: conversationId,
        sender_id: senderId,
        content: content,
      });
  
      const savedMessage = await newMessage.save();
  
      return savedMessage;
    } catch (err) {
      console.error('Error saving message:', err);
      throw new Error('Failed to save message');
    }
  };