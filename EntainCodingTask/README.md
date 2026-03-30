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

- Initial fetch: 30 races count  
- If visible races for any single category is less than 6 → increase fetch count (60 → 90 → 120)  
- Maximum cap: 120 races  
- If still insufficient, display available races without fulfilling 5 for all categories

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
The system monitors the visible race list and triggers additional fetches when the number of visible races drops below 6.
This provides a buffer to avoid the UI dropping below the required 5 races.

Periodic refresh was considered but omitted to keep the implementation simple and aligned with the task requirements.

### Expiry Handling
Races remain visible until 60 seconds after their advertised start time and are then removed.
Countdown and expiry are calculated locally using the device’s current time.

### Deduplication and Data Stability
Races are deduplicated using `race_id` when merging results from multiple fetches. If the same race appears in subsequent responses, the data from the latest fetch will be maintained.

### Caching
No caching between sessions is implemented. Each app launch fetches fresh data


### Accessibility
1. VoiceOver and Dynamic Type are supported  
2. The production app does not currently support dark mode, so dark mode is intentionally excluded to focus on core functionality  


### Limitations
1. Due to uneven distribution of race categories, it is possible that fewer than 5 races are available for a selected filter, even after reaching the maximum fetch cap. 
2. Countdown and expiry are calculated using the device’s local time. Minor discrepancies may occur due to network latency or differences between device and server time. 
3. No persistent caching is implemented. Data is fetched fresh on each app launch. 
4. No periodic background refresh is implemented. The system only fetches more data when the visible race list drops below the defined threshold.
