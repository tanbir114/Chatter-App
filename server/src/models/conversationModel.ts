import mongoose, { Schema, Document } from 'mongoose';

export interface IConversation extends Document {
  participant_one: mongoose.Types.ObjectId;
  participant_two: mongoose.Types.ObjectId;
  createdAt?: Date;
  updatedAt?: Date;
}

const conversationSchema = new Schema<IConversation>(
  {
    participant_one: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    participant_two: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
  },
  { timestamps: true } // Adds createdAt and updatedAt fields automatically
);

export const Conversation = mongoose.model<IConversation>('Conversation', conversationSchema);