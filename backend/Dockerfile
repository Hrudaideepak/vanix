# Use official Node.js runtime as parent image
FROM node:18-alpine

# Install FFmpeg for video processing pipeline
RUN apk update && apk add --no-cache ffmpeg

# Set working directory
WORKDIR /usr/src/app

# Copy dependency manifests
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application source code
COPY . .

# Expose server port
EXPOSE 5000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=5000

# Start server node
CMD [ "npm", "start" ]
