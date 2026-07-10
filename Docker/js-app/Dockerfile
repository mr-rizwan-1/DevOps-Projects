FROM node:19-alpine
# Use the official Node.js 19 image based on Alpine Linux as the base image for the container

COPY package*.json /usr/app/
# Copy package.json, wildcard used so both package.json 
# AND package-lock.json are copied into container /usr/app directory

COPY src /usr/app/
# Copy app directory from src directory into container /usr/app directory

WORKDIR /usr/app 
# Create app directory & 
# set default dir so that next commands executes in /usr/app dir

RUN npm install 
# Install app dependencies

CMD ["node", "server.js"]
# Start the application