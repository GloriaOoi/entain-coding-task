# entain-coding-task
Coding task for Entain Interview

## 1. Intro
This project implements a “Next to Go” race list using the Neds API. It displays the next 5 races with live countdowns, supports category filtering, and ensures the list remains populated as races expire over time.

## 2. Setup
1. Clone the repository
2. Open the project in Xcode
3. Run on iOS simulator or device

No additional setup is required.

## 3. Architecture
The app is structured into four main layers:
1. UI (SwiftUI views)
2. ViewModel (state + orchestration)
3. Business Logic (pure derivation rules)
4. Data Layer (API client + decoding)

## 4. Key Implementation Decisions
### Fetch Strategy
The app uses a progressive fetch strategy to maintain a sufficient pool of races:

- Initial fetch: 30 races count.
- If visible races for any single category is less than 6 → increase fetch count (60 → 90 → 120).
- Maximum cap: 120 races.
- If the API returns the same raw item count on consecutive fetches, stop fetching early and treat the API result set as exhausted.
- If still insufficient, display available races without fulfilling 5 for all categories.

The UI always displays a maximum of 5 races for any combination of filter.


Several approaches were considered:
#### Option A — Progressive Fetch (Chosen)
- Adaptive
- Works well with uneven category distribution  
- Ensures best effort for filtered views  

#### Option B — Large Upfront Fetch
- Simpler implementation  
- Assumes API supports large counts  
- Potentially wasteful  

#### Option C — Per-Category Fetching
- Predictable results per category  
- Not supported by the API  

#### Option D — Lazy Fetch on Demand
- Minimal initial work  
- Poor UX due to delays after user interaction  

**Decision:**  
Progressive fetching was chosen as it balances responsiveness, correctness, and API constraints.


### Replenishment Strategy
The system monitors the visible race list and triggers additional fetches when the number of visible races for any category drops below 6.
This provides a buffer to avoid the UI dropping below the required 5 races.

Periodic refresh was considered but omitted to keep the implementation simple and aligned with the task requirements.

### Expiry Handling
Races remain visible until 60 seconds after their advertised start time and are then removed.
Countdown and expiry are calculated locally using the device’s current time.

### Deduplication and Data Stability
Races are deduplicated using `race_id` when merging results from multiple fetches. If the same race appears in subsequent responses, the data from the latest fetch will be maintained.

### Sorting Assumption
Races are displayed in ascending order of their advertised start time. When multiple races share the same advertised start time, they are further ordered by race number.

### Caching
No caching between sessions is implemented. Each app launch fetches fresh data.

### Accessibility
1. VoiceOver and Dynamic Type are supported.
2. The production app does not currently support dark mode, so dark mode is intentionally excluded to focus on core functionality.

### Linting
SwiftLint is not include, but would definitely be required in production code to ensure consistency across development work.

### Localisation
SwiftGen is not included, but would definitely be required in production code to ensure consistency across development work. Currently all hardcoded strings are localised in Strings.swift.

### Error Handling
If an error occurs, a simple message is shown prompting the user to try again later. Retry logic is not implemented at this stage.

### Logging
Logging is not currently implemented. A Logger should be introduced to support structured logging across different levels (e.g. debug, info, error). Debug-level logs should be excluded from release builds to prevent exposing internal implementation details and reduce unnecessary overhead.

### Future enhancements
To request additional API documentation (e.g. Swagger) to better understand available parameters.
To confirm whether category-based filtering or pagination is supported by the API.
