import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { User } from '../models/userModel';
import jwt from 'jsonwebtoken';
import winston from 'winston';

const SALT_ROUNDS = 10;
const JWT_SECRET = process.env.JWT_SECRET || 'worisecretkey';

// Configure Winston logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.printf(({ timestamp, level, message }) => {
      return `[${timestamp}] ${level.toUpperCase()}: ${message}`;
    })
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'logs/auth.log' }),
  ],
});

export const register = async (req: Request, res: Response) => {

    // 1. get username, email and password from req body
    // 2. insert those data into the db
    // 3. return message, user

  const { username, email, password } = req.body;

  try {
    logger.info(`Registering user: ${email}`);
    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
    const createUser = new User({
      username: username,
      email: email,
      password: hashedPassword,
    });
    const newUser = await createUser.save();
    logger.info(`User registered successfully: ${email}`);
    res.status(201).json({ message: 'User created successfully', newUser });
  } catch (e) {
    logger.error(`Failed to register user: ${email}, Error: ${e}`);
    res.status(500).json({ message: 'Failed to create user', e });
  }
};

export const login = async (req: Request, res: Response): Promise<any> => {

    // 1. get email, password
    // 2. verify if email exist
    // 3. compare the password 
    // 4. return token

  const { email, password } = req.body;

  try {
    logger.info(`User login attempt: ${email}`);
    const user = await User.findOne({ email: email });

    if (!user) {
      logger.warn(`Login failed - User not found: ${email}`);
      return res.status(404).json({ error: 'User not found' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      logger.warn(`Login failed - Invalid password: ${email}`);
      return res.status(400).json({ error: 'Invalid password' });
    }

    const token = jwt.sign({ id: user.id }, JWT_SECRET, { expiresIn: '1h' });
    logger.info(`User logged in successfully: ${email}`);

    const userObject = user.toObject(); // convert mongoose document to plain object
    let finalResult = {...userObject, token}
    console.log(finalResult);
    res.json({ user: finalResult });

  } catch (e) {
    logger.error(`Login failed for user: ${email}, Error: ${e}`);
    res.status(500).json({ error: 'Failed to login' });
  }
};
