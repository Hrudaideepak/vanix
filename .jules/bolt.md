## 2024-05-18 - Avoid Mongoose Cumulative I/O Blocking in Controllers
**Learning:** In backend analytics controllers, multiple independent database aggregation and count queries are frequently implemented as sequential `await` calls. This causes cumulative I/O blocking, where the total execution time is the sum of all individual query times, unnecessarily slowing down the endpoint response.
**Action:** When calculating dashboard or analytics data, wrap independent `Mongoose.aggregate` and `countDocuments` operations in a single `Promise.all()` to ensure concurrent execution.
