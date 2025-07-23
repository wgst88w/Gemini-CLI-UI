FROM node:20 AS runtime
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN npm install --only=production

COPY server/ ./server
COPY --from=build-frontend /app/dist ./public

EXPOSE 4008
CMD ["node", "server/index.js"]
