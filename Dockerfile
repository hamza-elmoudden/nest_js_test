FROM node:alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci 


COPY . .
RUN npx prisma generate
RUN npm run build


FROM node:alpine AS final

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY --from=build --chown=node:node /app/dist ./dist
COPY --from=build --chown=node:node /app/prisma ./prisma
COPY --from=build --chown=node:node /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build --chown=node:node /app/node_modules/@prisma ./node_modules/@prisma


EXPOSE 3000

CMD [ "node","dist/main.js" ]