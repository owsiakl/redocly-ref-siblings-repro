// Reads the rendered page of POST /items from stdin and reports where each
// field of the request body shows up.
import { readFileSync } from 'node:fs';

const text = readFileSync(0, 'utf8')
    .replace(/<(script|style)\b[\s\S]*?<\/\1>/g, '')
    .replace(/<[^>]+>/g, '')
    .replace(/&quot;|&#34;|&#x22;/g, '"');

const descriptions = {
    name: 'Name of the item.',
    status: 'Publication status assigned when you create the item.',
};

for (const [field, description] of Object.entries(descriptions)) {
    const listed = text.includes(description) ? 'yes' : 'no';
    const sampled = new RegExp(`"${field}"\\s*:`).test(text) ? 'yes' : 'no';
    console.log(`${field.padEnd(6)}  field list: ${listed.padEnd(3)}  request sample: ${sampled}`);
}
