# ───── 第一階段：建置前端 ─────
FROM node:20-slim AS build-frontend
WORKDIR /app

# 複製 package.json 及 lock 檔案
COPY package*.json ./

# 安裝 Python3 與編譯工具，確保 node-gyp 可用
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 make g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && npm config set python /usr/bin/python3

# 安裝前端依賴
RUN npm install

# 複製原始碼
COPY . .

# 編譯前端
RUN npm run build

# ───── 第二階段：運行時 ─────
FROM node:20-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production

# 複製 package.json 與 lock 檔案
COPY package*.json ./

# 安裝 Python3 與編譯工具，並建立 python 連結
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 make g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && npm config set python /usr/bin/python3

# 安裝 production 依賴
RUN npm install --omit=dev

# 清理不必要的編譯工具
RUN apt-get purge -y python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

# 複製前端編譯結果
COPY --from=build-frontend /app/dist ./public

# 複製後端程式
COPY server/ ./server

EXPOSE 4008
CMD ["node", "server/index.js"]
