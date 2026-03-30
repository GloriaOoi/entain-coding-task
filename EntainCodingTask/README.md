# entain-coding-task
Coding task for Entain Interview

Assumption:
1. Checked production app and dark mode is not supported, hence I'm not going to include it in. 
2. No caching in between sessions for now.
3. We fetch in increments of 30 until we get 6 for each category, or until a cap of 120 count. The UI only always display 5. In the event we reach count 120 and there is not enough, we display less.
4. MergeRaces caters to updated timing in subsequent fetches.

