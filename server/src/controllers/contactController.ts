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

    // Fetch contacts for the user with populated contact_id
    const contacts = await Contact.find({ user_id: userId })
      .populate<{ contact_id: { _id: string; username: string; email: string } }>('contact_id', 'username email')
      .sort({ 'contact_id.username': 1 });

    const formattedContacts = contacts.map(contact => ({
      contact_id: contact.contact_id._id,
      username: contact.contact_id.username,
      email: contact.contact_id.email,
    }));

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
        res.status(400).json({ error: 'User ID and Contact ID are required.' });
        return;
    }
  
    try {
        const contactExists = await User.find({ email: contactEmail });
  
      if (contactExists.length === 0) {
        res.status(404).json({ error: 'Contact not found' });
        return;
      }

      const contractId = contactExists[0]._id;
  
      const contact = await Contact.findOneAndUpdate(
        { user_id: userId, contact_id: contactEmail },
        { user_id: userId, contact_id: contactEmail },
        { upsert: true, new: true }
      );
  
        res.status(201).json({ message: 'Contact added successfully', contact });
    } catch (error) {
      winston.error('Error adding contact:', error);
       res.status(500).json({ error: 'Internal Server Error' });
    }
  };