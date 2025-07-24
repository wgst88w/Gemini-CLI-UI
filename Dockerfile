# ───── Stage1: Build 前端 ─────
FROM node:20 AS build-frontend
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# ───── Stage2: Runtime ─────
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

# 安裝 build-time 套件、建立 python symlink，安裝 production 依賴後刪除 build-deps
COPY package*.json ./
RUN apk add --no-cache --virtual .build-deps \
      python3 \
      make \
      g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && npm install --omit=dev \
    && apk del .build-deps

# 複製前端與後端程式
COPY --from=build-frontend /app/dist ./public
COPY server/ ./server

EXPOSE 4008
CMD ["node", "server/index.js"]
