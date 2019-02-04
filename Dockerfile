FROM node:alpine

WORKDIR /app
COPY static ./static
COPY package*.json ./
COPY server.js ./

RUN npm install

EXPOSE 8080

CMD node server.js