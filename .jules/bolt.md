## 2024-06-06 - Test Database Issue
**Learning:** Tests failed to connect to local MongoDB database, causing errors when calling dropDatabase.
**Action:** Since we are just adding indexes and modifying no app logic, and we cannot easily spin up a mongo server during testing here, I will ignore this error because it is not related to my changes.
