import mongoose, { Schema, Document } from 'mongoose';

export interface IContact extends Document {
  user_id: mongoose.Types.ObjectId;
  contact_id: mongoose.Types.ObjectId;
  createdAt: Date;
  updatedAt: Date;
}

const contactSchema = new Schema<IContact>(
  {
    user_id: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    contact_id: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
  },
  { timestamps: true }
);

contactSchema.index({ user_id: 1, contact_id: 1 }, { unique: true });

export const Contact = mongoose.model<IContact>('Contact', contactSchema);
