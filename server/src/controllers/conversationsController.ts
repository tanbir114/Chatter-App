import { Request, Response } from 'express';
import mongoose from 'mongoose';
import { Conversation } from '../models/conversationModel';
import winston from 'winston';

export const fetchAllConversationsByUserId = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      res.status(400).json({ error: 'User ID is required' });
      return;
    }

    const conversations = await Conversation.aggregate([
      {
        $match: {
          $or: [
            { participant_one: mongoose.Types.ObjectId.createFromHexString(userId) },
            { participant_two: mongoose.Types.ObjectId.createFromHexString(userId) },
          ],
        },
      },
      {
        $lookup: {
          from: 'users',
          localField: 'participant_one',
          foreignField: '_id',
          as: 'participant_one_details',
        },
      },
      {
        $lookup: {
          from: 'users',
          localField: 'participant_two',
          foreignField: '_id',
          as: 'participant_two_details',
        },
      },
      {
        $lookup: {
          from: 'messages',
          let: { conversationId: '$_id' },
          pipeline: [
            { $match: { $expr: { $eq: ['$conversation_id', '$$conversationId'] } } },
            { $sort: { createdAt: -1 } },
            { $limit: 1 },
          ],
          as: 'last_message',
        },
      },
      {
        $project: {
          participant_name: {
            $cond: {
              if: { $eq: ['$participant_one', mongoose.Types.ObjectId.createFromHexString(userId)] },
              then: { $arrayElemAt: ['$participant_two_details.username', 0] },
              else: { $arrayElemAt: ['$participant_one_details.username', 0] },
            },
          },
          last_message: { $arrayElemAt: ['$last_message.content', 0] },
          last_message_time: { $arrayElemAt: ['$last_message.createdAt', 0] },
        },
      },
      { $sort: { last_message_time: -1 } },
    ]);

    res.json(conversations);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

export const checkOrCreateConversation = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;
    const { contactId } = req.body;

    if (!userId || !contactId) {
      res.status(400).json({ error: 'Missing user ID or contact ID' });
      return;
    }

    // Check if the conversation already exists
    const existingConversation = await Conversation.findOne({
      $or: [
        { participant_one: userId, participant_two: contactId },
        { participant_one: contactId, participant_two: userId },
      ],
    }).exec();

    if (existingConversation) {
      res.json({ conversationId: existingConversation._id });
      return;
    }

    // Create a new conversation
    const newConversation = new Conversation({
      participant_one: userId,
      participant_two: contactId,
    });

    await newConversation.save();
    res.json({ conversationId: newConversation._id });
  } catch (error) {
    winston.error('Error checking or creating conversation:', error);
    res.status(500).json({ error: 'Failed to check or create conversation' });
  }
};

