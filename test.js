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
