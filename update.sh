#!/bin/bash

# Create necessary files
touch Dockerfile docker-compose.yaml test.js README.md

# Add code to the created files
cat > Dockerfile << 'EOF'
FROM node:18

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "node", "app.js" ]
EOF

cat > docker-compose.yaml << 'EOF'
version: '3.9'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - mongo
  mongo:
    image: mongo
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_DATABASE=autoban
EOF

cat > test.js << 'EOF'
const assert = require('assert');
const axios = require('axios');
const Banned = require('./models/banned');

const baseURL = 'http://localhost:3000';

describe('AutoBan API', () => {
  beforeEach(async () => {
    await Banned.deleteMany({});
  });

  it('should display the index page', async () => {
    const response = await axios.get(baseURL);
    assert.strictEqual(response.status, 200);
  });

  it('should ban a user if the input matches a banned phrase', async () => {
    const response = await axios.post(baseURL, 'input=badword1');
    assert.strictEqual(response.status, 200);
    const isBanned = await Banned.findOne({});
    assert(isBanned !== null);
  });

  it('should not ban a user if the input does not match a banned phrase', async () => {
    const response = await axios.post(baseURL, 'input=safe_word');
    assert.strictEqual(response.status, 200);
    const isBanned = await Banned.findOne({});
    assert(isBanned === null);
  });
});
EOF

cat > README.md << 'EOF'
# AutoBanJS

This project is a simple web application that demonstrates how to ban users based on specific input criteria. The application checks user input and saves the user's information to a MongoDB database if the input matches a banned phrase.

## Requirements
- Docker
- Docker Compose

## Installation

1. Clone this repository:
`git clone https://github.com/altninja/autobanjs.git`
2. Change the directory to the project root:
`cd autobanjs`
3. Build and run the project using Docker Compose:
`docker-compose up -d`

## Usage

1. Open a web browser and navigate to `http://localhost:3000`.
2. Enter a text input in the form and click the "Submit" button.
3. If the input matches a banned phrase, the user will be redirected to an error page and their information will be saved to the database.
4. If the input does not match a banned phrase, the user will be redirected to a success page.

## Running Tests

1. Install Node.js dependencies:
`npm install`
2. Run the tests:
`npm test`
EOF

# Install testing dependencies
npm install --save-dev mocha chai axios

# Add test script to package.json
jq '.scripts.test = "mocha test.js"' package.json > package.json.tmp && mv package.json.tmp package.json

# Build and run the project using Docker Compose
docker-compose up -d

# Run tests
npm test
