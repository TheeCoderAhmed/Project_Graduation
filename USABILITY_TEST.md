# DRAPO — Usability Testing Report (Day 4)

**Method:** System Usability Scale (SUS) + Structured Task Observation  
**Participants:** 6  
**Sessions:** In-person, think-aloud protocol  
**Device:** Physical Android device (Samsung Galaxy A54, Android 14)  
**App Build:** Debug build, pre-seeded Firestore data (10 doctors, 5 pharmacies, 42 reviews)  
**Evaluator:** DRAPO development team

---

## 1. Background

Usability testing was conducted to identify friction points in the app and gather a quantitative usability benchmark before final submission.  
The SUS (System Usability Scale) was chosen because:
- It is validated and widely cited in SE and HCI literature
- It produces a single 0–100 score comparable across studies
- 10 questions — fast to administer, minimal participant burden
- Industry average is ~68; scores above 80 indicate excellent usability

---

## 2. Participants

| ID | Age | Gender | Occupation | Tech Level | Relation to App |
|----|-----|--------|------------|------------|-----------------|
| P1 | 28  | Male   | Medical Student | High | Potential daily user |
| P2 | 45  | Female | School Teacher | Moderate | Would use to find specialist |
| P3 | 35  | Male   | Software Engineer | High | Familiar with healthcare apps |
| P4 | 22  | Female | University Student | High | Frequent app user |
| P5 | 55  | Male   | Retired Doctor | Low | Represents older demographic |
| P6 | 31  | Female | Nurse | Moderate | Healthcare professional |

All participants were Cairo residents with prior smartphone experience.  
None had used DRAPO before the session.

---

## 3. Task Scenarios

Each participant was given 5 tasks in order. No assistance was given after the task was read aloud. Success/failure and time were recorded.

| # | Task | Success Criteria |
|---|------|-----------------|
| T1 | "Find a cardiologist using the home screen specialties." | Taps Cardiologist chip → search results visible |
| T2 | "Open any doctor's profile and read their reviews." | Profile screen open, at least one review visible |
| T3 | "Search for a doctor named 'Ahmed' using the search bar." | Taps search bar → types query → results filtered |
| T4 | "Leave a 3-star review with a comment for a provider." | Review submitted (Firestore write confirmed) |
| T5 | "Bookmark a doctor so you can find them later." | Bookmark icon toggled, provider appears in Saved tab |

---

## 4. Task Completion Results

✓ = completed independently  ✗ = failed or required hint

| Task | P1 | P2 | P3 | P4 | P5 | P6 | Completion Rate |
|------|:--:|:--:|:--:|:--:|:--:|:--:|-----------------:|
| T1 — Find cardiologist | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | **100%** |
| T2 — Open profile & reviews | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | **100%** |
| T3 — Search by name | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | **83%** |
| T4 — Submit review | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | **83%** |
| T5 — Bookmark provider | ✓ | ✗ | ✓ | ✓ | ✗ | ✓ | **67%** |

**Overall task completion: 86.7%** (26 out of 30 task attempts)

### Observations

- **T1 (100%):** HomeQuickCategories chips were the first thing all participants noticed. The coloured icons made specialties immediately scannable.
- **T3 — P5 failure:** P5 did not recognise the fake search bar as tappable. Said "it looks like a label, not a button."
- **T4 — P5 failure:** After failing T3, P5 could not navigate to a provider profile independently. The task chain meant T4 also failed.
- **T5 — P2 failure:** P2 looked for a bookmark action inside the review, not on the provider profile card. The bookmark icon affordance was unclear without a label.
- **T5 — P5 failure:** Same as above.

---

## 5. SUS Questionnaire

Participants answered after completing (or attempting) all tasks.

### Questions (standard SUS wording)

| # | Question |
|---|---------|
| Q1 | I think that I would like to use this system frequently. |
| Q2 | I found the system unnecessarily complex. |
| Q3 | I thought the system was easy to use. |
| Q4 | I think that I would need the support of a technical person to be able to use this system. |
| Q5 | I found the various functions in this system were well integrated. |
| Q6 | I thought there was too much inconsistency in this system. |
| Q7 | I would imagine that most people would learn to use this system very quickly. |
| Q8 | I found the system very cumbersome to use. |
| Q9 | I felt very confident using the system. |
| Q10 | I needed to learn a lot of things before I could get going with this system. |

Scale: 1 = Strongly Disagree, 5 = Strongly Agree

### Raw Responses

| Q | P1 | P2 | P3 | P4 | P5 | P6 |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Q1 | 4 | 4 | 5 | 5 | 3 | 4 |
| Q2 | 2 | 3 | 2 | 1 | 3 | 2 |
| Q3 | 5 | 4 | 4 | 5 | 4 | 4 |
| Q4 | 1 | 2 | 1 | 1 | 3 | 2 |
| Q5 | 4 | 4 | 4 | 4 | 3 | 4 |
| Q6 | 2 | 2 | 2 | 1 | 3 | 2 |
| Q7 | 5 | 4 | 5 | 5 | 3 | 4 |
| Q8 | 1 | 2 | 1 | 1 | 3 | 2 |
| Q9 | 5 | 4 | 4 | 5 | 3 | 4 |
| Q10 | 1 | 2 | 2 | 1 | 3 | 2 |

---

## 6. SUS Score Calculation

### Formula

- **Odd items (Q1,Q3,Q5,Q7,Q9):** contribution = response − 1
- **Even items (Q2,Q4,Q6,Q8,Q10):** contribution = 5 − response
- **Score = sum of contributions × 2.5**

### Per-Participant Scores

| Participant | Odd sum | Even sum | Raw total | SUS Score | Grade |
|-------------|:-------:|:--------:|:---------:|:---------:|-------|
| P1 | 18 | 18 | 36 | **90.0** | A — Excellent |
| P2 | 15 | 14 | 29 | **72.5** | B — Good |
| P3 | 17 | 17 | 34 | **85.0** | A — Excellent |
| P4 | 19 | 20 | 39 | **97.5** | A — Excellent |
| P5 | 11 | 10 | 21 | **52.5** | C — OK |
| P6 | 15 | 15 | 30 | **75.0** | B — Good |

### Mean SUS Score

> **(90.0 + 72.5 + 85.0 + 97.5 + 52.5 + 75.0) ÷ 6 = 472.5 ÷ 6 = 78.75**

**Grade: B — Good** (industry average = 68; excellent threshold = 80.3)

The score was independently verified by the `SusCalculator.averageScore()` implementation tested in `test/unit/sus_calculator_test.dart`.

---

## 7. Analysis

### 7.1 Score Distribution

```
P4  ████████████████████████████████████████  97.5
P1  ████████████████████████████████████      90.0
P3  ██████████████████████████████████        85.0
P6  ██████████████████████████████            75.0
P2  █████████████████████████████             72.5
P5  █████████████████████                     52.5
         |         |         |         |
         25        50        75       100
```

### 7.2 Key Findings

| Finding | Severity | Affected Task | Recommended Fix |
|---------|----------|---------------|-----------------|
| Search bar not recognised as interactive | High | T3 | Add cursor/ripple visual, or change background to white with shadow |
| Bookmark icon has no label | Medium | T5 | Add "Save" text label below the bookmark icon |
| Older/low-tech users struggle after first navigation failure | Medium | T4, T5 | Add contextual onboarding tooltip on first launch |
| Specialty chip row immediately understood | Positive | T1 | Keep HomeQuickCategories design — works well |
| Provider profile layout scannable | Positive | T2 | No change needed |

### 7.3 P5 Deep Dive

P5's score of 52.5 ("C — OK") is an outlier driven by a cascade failure: not recognising the search bar in T3 caused task failures in T3, T4, and T5. The root cause is a **single affordance issue**, not systemic complexity. Fixing the search bar visual cue should bring P5's score into the 65–70 range, pushing the group mean above 80.

### 7.4 Comparison to Benchmarks

| Benchmark | SUS Score |
|-----------|-----------|
| Industry average (all software) | 68.0 |
| **DRAPO (this study)** | **78.75** |
| Healthcare apps average (published literature) | 71.4 |
| Excellent threshold | 80.3 |

DRAPO scores above the industry average and above the healthcare app average, placing it in the **"Good"** band, 1.55 points below Excellent.

---

## 8. Recommendations for Next Sprint

1. **Search bar affordance fix** (High priority): Add a white card background with drop shadow to `HomeSearchBar` so it looks tappable. Estimated 5-minute change in `home_search_bar.dart`.
2. **Bookmark label** (Medium priority): Add `"Save"` text below bookmark icon in `ProviderCard` or the provider profile screen.
3. **First-launch tooltip** (Low priority / future): Show a one-time overlay pointing to the search bar and bookmark icon on first app open.

---

## 9. SUS Implementation Note

The scoring algorithm is implemented as a tested Dart utility:

```
lib/utils/sus_calculator.dart     → SusCalculator class
test/unit/sus_calculator_test.dart → 21 unit tests
```

The test suite covers: boundary scores (0, 50, 100), item-level formula correctness, all six participant scores from this study, `averageScore()`, `grade()` bands, and error handling for invalid input.
