// validate_quotes.js

const fs = require('fs');

const INPUT_FILE = './quotes_seed.json';
const OUTPUT_VALID = './quotes_valid.json';
const OUTPUT_INVALID = './quotes_invalid.json';

// Read and parse the seed file
let quotes = [];
try {
  quotes = JSON.parse(fs.readFileSync(INPUT_FILE, 'utf-8'));
} catch (e) {
  console.error('Failed to read or parse quotes_seed.json:', e);
  process.exit(1);
}

const validQuotes = [];
const invalidQuotes = [];

quotes.forEach((q, i) => {
  let missingFields = [];
  if (!q.kQuote) missingFields.push('kQuote');
  if (!q.kAuthor) missingFields.push('kAuthor');
  if (!q.kCategory) missingFields.push('kCategory');
  if (missingFields.length === 0) {
    validQuotes.push(q);
  } else {
    invalidQuotes.push({
      ...q,
      _reason: `Missing: ${missingFields.join(', ')}`,
      _index: i
    });
  }
});

fs.writeFileSync(OUTPUT_VALID, JSON.stringify(validQuotes, null, 2), 'utf-8');
fs.writeFileSync(OUTPUT_INVALID, JSON.stringify(invalidQuotes, null, 2), 'utf-8');

console.log(`✅ Valid quotes: ${validQuotes.length}`);
console.log(`⚠️  Invalid/skipped quotes: ${invalidQuotes.length} (see ${OUTPUT_INVALID})`);
