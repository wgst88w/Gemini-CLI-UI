FROM node:20-alpine AS build-frontend
WORKDIR /app

COPY package*.json ./
RUN apk add --no-cache python3 make g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && npm config set python /usr/bin/python3

RUN npm install
COPY . .
RUN npm run build

FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
ENV PYTHON=/usr/bin/python3

COPY package*.json ./
RUN apk add --no-cache python3 make g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && npm config set python /usr/bin/python3

RUN npm install --omit=dev
RUN apk del python3 make g++

COPY --from=build-frontend /app/dist ./public
COPY server/ ./server

EXPOSE 4008
CMD ["node", "server/index.js"]
