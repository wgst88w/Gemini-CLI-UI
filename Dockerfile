# ─── Stage 2: 生產環境映像 ───
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

# 複製 package.json 並安裝 build-time 依賴
COPY package*.json ./
RUN apk add --no-cache --virtual .build-deps \
      python3 \
      make \
      g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && npm install --only=production \
    && apk del .build-deps

# 複製前端產出與後端原始碼
COPY --from=build-frontend /app/dist ./public
COPY server/ ./server

EXPOSE 4008
CMD ["node", "server/index.js"]
