"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const body_parser_1 = require("body-parser");
const authRoutes_1 = __importDefault(require("./routes/authRoutes"));
const mongoose_1 = __importDefault(require("mongoose"));
const dotenv_1 = __importDefault(require("dotenv"));
const winston_1 = __importDefault(require("winston"));
const morgan_1 = __importDefault(require("morgan"));
dotenv_1.default.config({ path: './.env' });
const app = (0, express_1.default)();
app.use((0, body_parser_1.json)());
// Configure Winston logger
const logger = winston_1.default.createLogger({
    level: 'info',
    format: winston_1.default.format.combine(winston_1.default.format.timestamp(), winston_1.default.format.printf(({ timestamp, level, message }) => {
        return `[${timestamp}] ${level.toUpperCase()}: ${message}`;
    })),
    transports: [
        new winston_1.default.transports.Console(),
        new winston_1.default.transports.File({ filename: 'logs/app.log' }),
    ],
});
// Use Morgan for HTTP request logging
app.use((0, morgan_1.default)('combined', {
    stream: {
        write: (message) => logger.info(message.trim()),
    },
}));
app.use('/auth', authRoutes_1.default);
app.use('/conversations', conversationsRoutes);
const PORT = process.env.PORT || 6000;
const MONGODB_API = process.env.MONGODB_API;
if (!MONGODB_API) {
    logger.error("Environment variable MONGODB_API is not defined");
    throw new Error("Environment variable MONGODB_API is not defined");
}
mongoose_1.default
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
