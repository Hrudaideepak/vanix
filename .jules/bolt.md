## 2024-05-24 - Mongoose Lean Queries and Selected Fields in O(N) Processing
**Learning:** Loading entire collections into memory as full Mongoose documents for post-processing (e.g., Levenshtein distance typo correction over titles in `search.controller.js`) causes massive memory bloat and CPU overhead due to document hydration.
**Action:** Use `.select('fields').lean()` when fetching bulk records for memory-bound algorithms, and only re-fetch the necessary full documents by ID if a match is found. Always use `.lean()` for read-only queries.
