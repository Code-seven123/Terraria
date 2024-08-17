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
    npm \
    mono-complete \
    dos2unix

# Install Terraria server
RUN wget https://terraria.org/api/download/pc-dedicated-server/terraria-server-1444.zip -O terraria-server.zip \
    && unzip terraria-server.zip -d /app/terraria-server \
    && rm terraria-server.zip

# Give execution permission to the Terraria server executable
RUN chmod +x /app/terraria-server/1444/Linux/TerrariaServer.bin.x86_64

# Expose Terraria server port
EXPOSE 7777

# Initialize a Node.js project
RUN npm init -y

# Install Express.js and required modules
RUN npm install express express-fileupload serve-index

# Create a simple Node.js file management server
RUN echo "const express = require('express');" > server.js \
    && echo "const fileUpload = require('express-fileupload');" >> server.js \
    && echo "const serveIndex = require('serve-index');" >> server.js \
    && echo "const app = express();" >> server.js \
    && echo "const PORT = 3000;" >> server.js \
    && echo "const UPLOAD_DIR = '/app/upload';" >> server.js \
    && echo "app.use(express.static(UPLOAD_DIR));" >> server.js \
    && echo "app.use('/files', serveIndex(UPLOAD_DIR, {'icons': true}));" >> server.js \
    && echo "app.use(fileUpload());" >> server.js \
    && echo "app.post('/upload', (req, res) => {" >> server.js \
    && echo "  if (!req.files || Object.keys(req.files).length === 0) {" >> server.js \
    && echo "    return res.status(400).send('No files were uploaded.');" >> server.js \
    && echo "  }" >> server.js \
    && echo "  let uploadedFile = req.files.file;" >> server.js \
    && echo "  uploadedFile.mv(\`\${UPLOAD_DIR}/\${uploadedFile.name}\`, function(err) {" >> server.js \
    && echo "    if (err) return res.status(500).send(err);" >> server.js \
    && echo "    res.send('File uploaded!');" >> server.js \
    && echo "  });" >> server.js \
    && echo "});" >> server.js \
    && echo "app.get('/', (req, res) => res.send('Hello from Node.js web server! Go to /files to manage files.'));" >> server.js \
    && echo "app.listen(PORT, () => console.log(\`Server running on port \${PORT}\`));" >> server.js

# Create upload directory
RUN mkdir -p /app/upload

# Expose web server port
EXPOSE 3000

# Start both Terraria server and Node.js file management server
CMD mono /app/terraria-server/1444/Linux/TerrariaServer.bin.x86_64 & node server.js