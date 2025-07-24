# ───── Stage1: Build 前端 ─────
FROM node:20 AS build-frontend
WORKDIR /app

COPY package*.json ./
RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*
RUN npm install

COPY . .
RUN npm run build

# ───── Stage2: Runtime ─────
FROM node:20-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production

# 安裝 build-tools、設定 python，安裝依賴後清理
COPY package*.json ./
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         python3 \
         make \
         g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && npm install --omit=dev \
    && apt-get purge -y python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

# 複製前端與後端程式
COPY --from=build-frontend /app/dist ./public
COPY server/ ./server

EXPOSE 4008
CMD ["node", "server/index.js"]
