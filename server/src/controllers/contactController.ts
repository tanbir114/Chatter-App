import { Request, Response } from "express";
import { Conversation } from "../models/conversationModel";
import winston from "winston";
import { User } from "../models/userModel";
import { Contact } from "../models/contactModel";

export const fetchContacts = async (req: Request, res: Response) =>{
    let userId = null;

  if (req.user) {
    userId = req.user.id;
  }
  try {
    if (!userId) {
      res.status(400).json({ message: 'User ID is required.' });
      return;
    }

    const contacts = await Contact.find({ user_id: userId })
      .populate<{ contact_id: { _id: string; username: string; email: string } }>('contact_id', 'username email')
      .sort({ 'contact_id.username': 1 });

    const formattedContacts = contacts.map(contact => ({
      contact_id: contact.contact_id._id,
      username: contact.contact_id.username,
      email: contact.contact_id.email,
    }));

    console.log("Fetched contacts: ", formattedContacts);

    res.json(formattedContacts);
    return;
  } catch (error) {
        winston.error('Error fetching conversations:', error);
        res.status(500).json({ message: 'Internal Server Error' });
        return;
    }
}

export const addContact = async (req: Request, res: Response) => {
    let userId: string | null = null;
  
    if (req.user) {
      userId = req.user.id;
    }
  
    const { contactEmail } = req.body;
  
    if (!userId || !contactEmail) {
      res.status(400).json({ error: 'User ID and Contact Email are required.' });
      return;
    }
  
    try {
      // Find the contact user by email
      const contactUser = await User.findOne({ email: contactEmail });
  
      if (!contactUser) {
        res.status(404).json({ error: 'Contact not found' });
        return;
      }
  
      const contactId = contactUser._id; // Get the ObjectId of the contact user
  
      // Upsert the contact (insert if not exists)
      const contact = await Contact.findOneAndUpdate(
        { user_id: userId, contact_id: contactId },
        { user_id: userId, contact_id: contactId },
        { upsert: true, new: true }
      );
  
      res.status(201).json({ message: 'Contact added successfully', contact });
    } catch (error) {
      winston.error('Error adding contact:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  };
  