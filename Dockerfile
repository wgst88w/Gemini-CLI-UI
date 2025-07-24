FROM node:20 AS runtime
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN apt-get update \
    && apt-get install -y python3 make g++ \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && npm install --only=production \
    && apt-get purge -y python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build-frontend /app/dist ./public
COPY server/ ./server

EXPOSE 4008
CMD ["node", "server/index.js"]
