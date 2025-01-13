"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.login = exports.register = void 0;
const bcrypt_1 = __importDefault(require("bcrypt"));
const userModel_1 = require("../models/userModel");
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const winston_1 = __importDefault(require("winston"));
const SALT_ROUNDS = 10;
const JWT_SECRET = process.env.JWT_SECRET || 'worisecretkey';
// Configure Winston logger
const logger = winston_1.default.createLogger({
    level: 'info',
    format: winston_1.default.format.combine(winston_1.default.format.timestamp(), winston_1.default.format.printf(({ timestamp, level, message }) => {
        return `[${timestamp}] ${level.toUpperCase()}: ${message}`;
    })),
    transports: [
        new winston_1.default.transports.Console(),
        new winston_1.default.transports.File({ filename: 'logs/auth.log' }),
    ],
});
const register = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    // 1. get username, email and password from req body
    // 2. insert those data into the db
    // 3. return message, user
    const { username, email, password } = req.body;
    try {
        logger.info(`Registering user: ${email}`);
        const hashedPassword = yield bcrypt_1.default.hash(password, SALT_ROUNDS);
        const createUser = new userModel_1.User({
            username: username,
            email: email,
            password: hashedPassword,
        });
        const newUser = yield createUser.save();
        logger.info(`User registered successfully: ${email}`);
        res.status(201).json({ message: 'User created successfully', newUser });
    }
    catch (e) {
        logger.error(`Failed to register user: ${email}, Error: ${e}`);
        res.status(500).json({ message: 'Failed to create user', e });
    }
});
exports.register = register;
const login = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    // 1. get email, password
    // 2. verify if email exist
    // 3. compare the password 
    // 4. return token
    const { email, password } = req.body;
    try {
        logger.info(`User login attempt: ${email}`);
        const user = yield userModel_1.User.findOne({ email: email });
        if (!user) {
            logger.warn(`Login failed - User not found: ${email}`);
            return res.status(404).json({ error: 'User not found' });
        }
        const isMatch = yield bcrypt_1.default.compare(password, user.password);
        if (!isMatch) {
            logger.warn(`Login failed - Invalid password: ${email}`);
            return res.status(400).json({ error: 'Invalid password' });
        }
        const token = jsonwebtoken_1.default.sign({ id: user.id }, JWT_SECRET, { expiresIn: '1h' });
        logger.info(`User logged in successfully: ${email}`);
        const userObject = user.toObject(); // convert mongoose document to plain object
        let finalResult = Object.assign(Object.assign({}, userObject), { token });
        console.log(finalResult);
        res.json({ user: finalResult });
    }
    catch (e) {
        logger.error(`Login failed for user: ${email}, Error: ${e}`);
        res.status(500).json({ error: 'Failed to login' });
    }
});
exports.login = login;
