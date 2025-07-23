# ─── Stage 1: 前端打包 ───
FROM node:20 AS build-frontend
WORKDIR /app

# 只複製依賴檔，加速快取
COPY package*.json ./
RUN npm install

# 複製全部原始碼並執行前端打包
COPY . .
RUN npm run build

# ─── Stage 2: 生產環境運行 ───
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# 從 build-frontend 階段取出打包好的靜態檔（位於 /app/dist）
COPY --from=build-frontend /app/dist ./public

# 複製後端程式與依賴
COPY server/ ./server
COPY package*.json ./
RUN npm install --only=production

# 與程式內 process.env.PORT 保持一致
EXPOSE 4008

# 啟動點
CMD ["node", "server/index.js"]
