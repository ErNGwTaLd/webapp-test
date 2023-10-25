# stage 1 - dev
FROM node:18-bullseye-slim AS development

ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV

ENV GATSBY_TELEMETRY_DISABLED 1

ENV GATSBY_API_URL https://api.example.local
ENV SITE_URL https://example.local

RUN env | while IFS= read -r line; do echo "$line" >> ".env.$NODE_ENV"; done

WORKDIR /app
COPY ["package.json", "package-lock.json", "./"]
RUN npm install
COPY . ./
EXPOSE 8000

CMD ["npm", "run", "dev"]

# stage 2 - build
FROM development AS builder

RUN npm run build

# stage 3 - production env
FROM nginx:mainline-alpine-slim AS production

COPY --from=builder /app/public /usr/share/nginx/html
# COPY ./nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
