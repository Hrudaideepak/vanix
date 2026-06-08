const fs = require('fs');
const file = 'backend/src/controllers/content.controller.js';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(
  "const { generateSignedStreamingUrl } = require('../utils/security');",
  "const { generateSignedStreamingUrl } = require('../utils/security');\nconst { escapeRegExp } = require('../utils/regex');"
);

content = content.replace(
  "    if (q) {\n      query.$or = [\n        { title: { $regex: q, $options: 'i' } },\n        { description: { $regex: q, $options: 'i' } },\n      ];\n    }",
  "    if (q) {\n      const safeQuery = escapeRegExp(q);\n      query.$or = [\n        { title: { $regex: safeQuery, $options: 'i' } },\n        { description: { $regex: safeQuery, $options: 'i' } },\n      ];\n    }"
);

fs.writeFileSync(file, content);
