import { Request, Response } from 'express';
import mongoose from 'mongoose';
import { Conversation } from '../models/conversationModel';

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
