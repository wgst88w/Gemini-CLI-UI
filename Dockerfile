# ───── Stage 1: build 前端 ─────
FROM node:20 AS build-frontend
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build      # 把前端打包輸出到 /app/dist

# ───── Stage 2: production runtime ─────
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# 把第一階段的打包結果複製過來
COPY --from=build-frontend /app/dist ./public

# 複製後端程式碼與依賴
COPY server/ ./server
COPY package*.json ./
RUN npm install --only=production

EXPOSE 4008
CMD ["node", "server/index.js"]
