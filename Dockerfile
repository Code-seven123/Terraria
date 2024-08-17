# Base image
FROM ubuntu:latest

# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    nodejs \
    npm

# Install Terraria server
RUN wget https://terraria.org/api/download/pc-dedicated-server/terraria-server-1444.zip -O terraria-server.zip \
    && unzip terraria-server.zip -d /app/terraria-server \
    && rm terraria-server.zip

# Expose Terraria server port
EXPOSE 7777

# Create a simple Node.js web server
RUN npm init -y
RUN npm install express

# Create a simple Node.js server file
RUN echo "const express = require('express');" > server.js \
    && echo "const app = express();" >> server.js \
    && echo "const PORT = 3000;" >> server.js \
    && echo "app.get('/', (req, res) => res.send('Hello from Node.js web server!'));" >> server.js \
    && echo "app.listen(PORT, () => console.log(\`Server running on port \${PORT}\`));" >> server.js

# Expose web server port
EXPOSE 3000

# Start both Terraria server and Node.js web server
CMD ./terraria-server/Linux/TerrariaServer.bin.x86_64 -config /app/terraria-server/serverconfig.txt & node server.js
