FROM node:14-alpine3.10 AS builder
RUN apk add --no-cache python2 make g++

WORKDIR /app

COPY package*.json ./
RUN npm install
RUN npm install -g typescript@4.9.5

COPY . .
RUN cp .env.example .env

RUN tsc --skipLibCheck --noEmitOnError false || true
RUN npm run build-sass && npm run copy-static-assets

FROM node:14-alpine3.10
WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/views ./views
COPY --from=builder /app/src/public ./public

ENV NODE_ENV=production
EXPOSE 3000

CMD ["npm", "run", "serve"]
