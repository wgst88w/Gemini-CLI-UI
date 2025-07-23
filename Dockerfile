# ─── Stage 1: Build 前端 ───
FROM node:20 AS build-frontend
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# ─── Stage 2: 安裝生產環境依賴並運行 ───
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

# 先複製 package.json 並安裝原生模組編譯所需工具，
# 再安裝 production 依賴，最後移除編譯工具以瘦身映像
COPY package*.json ./
RUN apk add --no-cache \
      python3 \
      make \
      g++ \
    && npm install --only=production \
    && apk del python3 make g++

# 複製前端打包結果與後端原始碼
COPY --from=build-frontend /app/dist ./public
COPY server/ ./server

EXPOSE 4008
CMD ["node", "server/index.js"]
