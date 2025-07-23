# ───── Stage 1: Build React 前端 ─────
FROM node:20 AS build-frontend

WORKDIR /app
# 複製 package 並安裝依賴，加速重覆 build 時的快取
COPY package*.json ./
RUN npm install

# 複製原始碼並執行前端建置
COPY . .
RUN npm run build

# ───── Stage 2: 準備生產環境的 Express 伺服器 ─────
FROM node:20-alpine

WORKDIR /app
ENV NODE_ENV=production

# 複製第一階段產出的前端靜態檔到 public
COPY --from=build-frontend /app/dist ./public

# 複製後端原始碼與 package.json，並安裝生產環境依賴
COPY server/ ./server
COPY package*.json ./
RUN npm install --only=production

# 容器對外暴露的埠號，與程式內 process.env.PORT 一致
EXPOSE 4008

# 啟動 Express 伺服器
CMD ["node", "server/index.js"]
