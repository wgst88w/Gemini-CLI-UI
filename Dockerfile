# ───── Stage1: Build 前端 ─────
FROM node:20 AS build-frontend
WORKDIR /app

COPY package*.json ./
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*
# 這裡明確指定 python 路徑
RUN npm config set python /usr/bin/python3
RUN npm install --only=production

COPY . .
RUN npm run build

# ───── Stage2: Runtime ─────
FROM node:20-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         python3 \
         make \
         g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && npm config set python /usr/bin/python3 \
    && npm install --omit=dev \
    && apt-get purge -y python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build-frontend /app/dist ./public
COPY server/ ./server

EXPOSE 4008
CMD ["node", "server/index.js"]
