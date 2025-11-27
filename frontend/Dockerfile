# Stage 1: Build
FROM node:16-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN rm -f package-lock.json && npm install
COPY . .
RUN npm run build

# Stage 2: Serve with http-server
FROM node:16-alpine
WORKDIR /app
RUN npm install -g http-server
COPY --from=build /app/dist ./dist
EXPOSE 80
CMD ["http-server", "./dist", "-p", "80"]
