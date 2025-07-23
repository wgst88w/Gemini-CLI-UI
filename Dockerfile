FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

# 複製 package 檔
COPY package*.json ./

# 安裝編譯工具，執行 production install，再移除工具減少映像體積
RUN apk add --no-cache \
      python3 \
      make \
      g++ \
    && npm install --only=production \
    && apk del python3 make g++

# 複製後端程式碼
COPY server/ ./server

# 複製前端產物
COPY --from=build-frontend /app/dist ./public

EXPOSE 4008
CMD ["node", "server/index.js"]
