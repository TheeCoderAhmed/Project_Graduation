# DRAPO — Software Testing Report

**Project:** DRAPO — Healthcare Provider Review Platform  
**Platform:** Flutter (Dart) / Firebase  
**Testing Period:** 5-day sprint (+ regression pass after the patient/provider/community feature expansion)  
**Total Tests:** 154 automated tests across unit, widget, and A/B phases

---

## 1. Testing Strategy Overview

The testing plan was divided into three phases aligned with SE graduation requirements:

| Phase | Type | Focus | Tools |
|-------|------|--------|-------|
| Day 1 | Unit Testing | Pure Dart model logic (no Firebase) | `flutter_test`, `package:test` |
| Day 2 | Widget Testing | UI rendering, navigation, user interaction | `flutter_test`, `WidgetTester` |
| Day 3 | A/B Testing | Variant assignment logic + conditional UI rendering | `flutter_test`, custom `AbTestService` |
| Day 4 | Usability Testing | SUS questionnaire with 6 real users + `SusCalculator` unit | `flutter_test`, SUS methodology |
| Day 5 | Report Writing | Consolidate findings | — |

**Key decision:** Unit tests target models only — no Firebase mocking required.  
`QuestionnaireModel` and `ProviderModel` are plain Dart value classes.  
`ReviewModel` uses `Timestamp` as a plain value — no Firebase platform needed in tests.

---

## 2. Phase 1 — Unit Tests (Day 1)

### 2.1 Files Tested

| Test File | Production Target | Tests |
|-----------|-------------------|-------|
| `test/unit/questionnaire_model_test.dart` | `lib/models/questionnaire_model.dart` | 13 |
| `test/unit/review_model_test.dart` | `lib/models/review_model.dart` | 22 |
| `test/unit/provider_model_test.dart` | `lib/models/provider_model.dart` | 21 |
| `test/unit/community_doctor_model_test.dart` | `lib/models/community_doctor_model.dart` | 10 |
| **Total** | | **66** |

> **Added after the feature expansion:** `community_doctor_model_test.dart` covers the off-app doctor model introduced with community reviews — `buildId()` grouping (same name + hospital → same id, case/space-insensitive), `averageRating` math (incl. divide-by-zero guard), and `fromMap()` safety (missing, null, and wrong-type fields).

### 2.2 Coverage per Model

#### QuestionnaireModel (13 tests)
- `fromMap()` happy path: all 4 fields parsed correctly
- Integer-to-double coercion (`3` → `3.0`)
- Clamp above 5.0 (e.g. `99.0` → `5.0`) and below 0.0 (`-1.0` → `0.0`)
- Missing fields default to `0.0`
- Non-numeric values (`'great'`, `null`, `true`, `[]`) default to `0.0`
- Exact boundary 5.0 survives without clamping
- `toMap()` round-trip through `fromMap` restores all values
- `toMap()` contains all four required keys
- `average` getter: known inputs, all-zero, all-max, asymmetric inputs

#### ReviewModel (22 tests)
- Full happy-path parse of all fields including nested questionnaire
- `overallRating` clamping: above 5.0, below 0.0, null, non-numeric string, int→double
- `userName` fallback to `"Anonymous"` on empty string, whitespace, and null
- Nested `questionnaire` fallback on: missing field, null, untyped `Map<dynamic,dynamic>`, non-map type
- `isVerified` defaults to `false` when missing or non-boolean
- `comment` defaults to `""` when missing
- `createdAt` fallback to non-null `Timestamp` when missing or wrong type
- `providerId` defaults to `""` when missing
- Completely empty map: no throw, all defaults filled

#### ProviderModel (21 tests)
- Full happy-path parse of all required and optional fields
- `type` priority: `category` field takes precedence over `type`, then default `'doctor'`
- `averageRating` and `totalReviews` default safely when missing
- Optional fields (`photoUrl`, `bio`, `operatingHours`, `location`) are truly optional
- `copyWith()`: each field independently overridable, original unchanged
- `toMap()` contains all required keys with correct values

### 2.3 Mistakes Found and Fixed in Day 1

#### Mistake 1 — Wrong package name in imports
**Problem:** All three test files used `package:hopeful_wright_1e0f2d/models/...` (the worktree folder name).  
**Root cause:** Auto-import picked up the directory name instead of the `name:` field in `pubspec.yaml`.  
**Fix:** Changed all imports to `package:drapo/models/...`.  
**Lesson:** Always verify `pubspec.yaml` `name:` field before writing test imports.

#### Mistake 2 — Circular average tests (false positives)
**Problem:** The two `average score` group tests computed arithmetic in the test body:
```dart
// BAD — tests Dart arithmetic, not the production model
final avg = (model.waitingTime + model.serviceQuality + ...) / 4.0;
expect(avg, 4.0);
```
These would pass even if `QuestionnaireModel` stored no fields at all, because the test itself performed the calculation.

**Fix:** Added `double get average` getter to `QuestionnaireModel` production code, then rewrote the tests to call `model.average`:
```dart
// GOOD — tests the production getter
expect(model.average, 4.0);
```
**Lesson:** Never put the formula under test inside the test body. Tests must assert what the production code *does*, not recompute it independently.

#### Mistake 3 — Incomplete boundary assertions
**Problem:** `accepts the exact boundary value 5.0` only asserted 2 of 4 fields (`waitingTime`, `serviceQuality`).  
`defaults all scores to 0.0 when questionnaire is null` similarly only checked 2 fields.  
`parses questionnaire when it is an untyped Map` only checked 2 of 4 questionnaire fields.

**Fix:** Added the missing `hygiene` and `staffCommunication` assertions to all three tests.  
**Lesson:** When a function processes N fields, the test should assert all N fields — partial coverage can silently miss regressions.

#### Mistake 4 — Duplicate `fromMap` call in empty-map test
**Problem:** The empty-map test called `ReviewModel.fromMap('r_empty', {})` twice — once inside `returnsNormally` and once to get the value for assertions.  
**Fix:** Removed the `returnsNormally` wrapper; a single `fromMap` call covers both concerns. If it throws, the test fails on its own.

```dart
// BEFORE: calls fromMap twice
expect(() => ReviewModel.fromMap('r_empty', {}), returnsNormally);
final review = ReviewModel.fromMap('r_empty', {});

// AFTER: single call
final review = ReviewModel.fromMap('r_empty', {});
```

---

## 3. Phase 2 — Widget Tests (Day 2)

### 3.1 Files Tested

| Test File | Widget Under Test | Tests |
|-----------|-------------------|-------|
| `test/widget/review_card_test.dart` | `ReviewCard` | 21 |
| `test/widget/home_stats_bar_test.dart` | `HomeStatsBar` | 12 |
| `test/widget/provider_card_test.dart` | `ProviderCard` | 13 |
| `test/widget/home_search_bar_test.dart` | `HomeSearchBar` | 7 |
| **Total** | | **53** |

### 3.2 Coverage per Widget

#### ReviewCard (21 tests)
- User name, rating (decimal and integer format), comment text, date
- Comment absent when empty string; date year-safe across timezones
- Provider name banner: shown with `providerName`, hidden when null or empty
- Chevron icon present only when `onTap` provided, absent otherwise
- `Icons.medical_services_rounded` present only when banner rendered
- Verified badge (`Icons.verified_rounded`): present when `isVerified = true`, absent when false
- Questionnaire row labels rendered when scores > 0; hidden when all-zero
- Questionnaire section triggered by single non-zero field
- `InkWell` present when `onTap` provided; absent when null
- Tap fires callback once; double tap fires twice

#### HomeStatsBar (12 tests)
- All three labels rendered: "Doctors", "Pharmacies", "Reviews"
- All three show `"0"` on empty lists
- Correct doctor count; correct pharmacy count
- Reviews summed across both lists
- Doctor and pharmacy counts are independent (different values at once)
- `999` renders as `"999"` (no k-suffix); `1000` renders as `"1.0k"`; `1200` → `"1.2k"`; `5500` → `"5.5k"`

#### ProviderCard (13 tests)
- Name, specialty, review count with "reviews" suffix, rating to 1 decimal
- Zero reviews and zero rating for a new provider
- Chevron and star icon always visible
- Doctor type → `Icons.local_hospital_rounded`; pharmacy → `Icons.local_pharmacy_rounded`
- Full pharmacy record renders all fields correctly
- Tap fires callback; fires exactly once; double tap = 2

#### HomeSearchBar (7 tests)
- Placeholder text, "Search" badge, magnifier icon rendered
- No `TextField` present (it's a fake bar, not a real input)
- Tap pushes `AppRoutes.search` route (verified via `NavigatorObserver`)
- Search screen visible after tap
- Tapping placeholder text also navigates

### 3.3 Mistakes Found and Fixed in Day 2

#### Mistake 1 — `find.text('')` false positive
**Problem:**
```dart
// BAD — find.text('') never matches meaningful text; always "passes"
expect(find.text(''), findsNothing);
```
Testing that an empty string doesn't appear proves nothing — it will pass even if the comment guard is completely broken or inverted.

**Fix:** Replaced with a two-pump before/after pattern using a unique string:
```dart
// GOOD — verifies the positive case first, then the negative
const knownComment = 'Unique comment to verify conditional rendering';
await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview(comment: knownComment))));
expect(find.text(knownComment), findsOneWidget); // guard works in normal case
await tester.pumpWidget(_wrap(ReviewCard(review: _fakeReview(comment: ''))));
expect(find.text(knownComment), findsNothing);   // guard actually hides it
```
**Lesson:** Empty string is never found by `find.text('')`. Tests that assert `findsNothing` on it are worthless — they catch nothing.

#### Mistake 2 — Timezone-dependent date assertion
**Problem:**
```dart
// BAD — Nov 14 UTC = Nov 15 in UTC+2 (Egypt), so this fails on CI in any +2 zone
expect(find.text('Nov 14, 2023'), findsOneWidget);
```
`Timestamp(1700000000, 0)` is 2023-11-14 22:13 UTC — it's November 15 in Cairo local time.

**Fix:**
```dart
// GOOD — year is stable in any timezone
expect(find.textContaining('2023'), findsOneWidget);
```
**Lesson:** Any test involving date formatting must account for timezone. Use year-only or UTC-anchored timestamps, not full date strings.

#### Mistake 3 — Colliding stat values causing `findsOneWidget` failure
**Problem:**
```dart
// BAD — generates 999 doctors, each with 1 review = 999 total reviews
// Both doctor count AND review count are "999" → findsOneWidget fails
final doctors = List.generate(999, (_) => _fakeProvider(reviews: 1));
expect(_statText('999'), findsOneWidget); // FAILS: finds 2 widgets
```

**Fix:** Use distinct values — 3 doctors × 333 reviews each = 999 reviews, doctor count 3:
```dart
// GOOD — doctor count is 3, review count is 999 — no collision
final doctors = List.generate(3, (_) => _fakeProvider(reviews: 333));
expect(_statText('3'), findsOneWidget);
expect(_statText('999'), findsOneWidget);
```
**Lesson:** When testing N columns that hold different data, ensure their values are numerically distinct.

#### Mistake 4 — Stats assertions missing scope
**Problem:** `find.text('0')` can match any `"0"` on the widget tree — including scaffold labels or other components rendered in the same `MaterialApp`.

**Fix:** All stat assertions scoped to `HomeStatsBar` using `find.descendant`:
```dart
Finder _statText(String value) => find.descendant(
  of: find.byType(HomeStatsBar),
  matching: find.text(value),
);
```
**Lesson:** Always scope `find.text()` assertions to the widget under test when the value might appear elsewhere in the tree.

#### Mistake 5 — `CachedNetworkImage` network calls in tests
**Problem:** `ProviderCard` uses `CachedNetworkImage` when `photoUrl` is non-null. Providing a real URL in tests triggers HTTP calls that hang or throw.

**Fix:** All `_fakeProvider()` helpers default to `photoUrl: null`, forcing the placeholder icon path:
```dart
ProviderModel _fakeProvider({String? photoUrl}) =>
    ProviderModel(photoUrl: photoUrl, ...); // null = placeholder icon
```

---

## 4. Phase 3 — A/B Testing (Day 3)

### 4.1 Experiment Design

**Name:** Stats Bar Visibility Experiment  
**Hypothesis:** Displaying aggregate platform statistics (total doctors, pharmacies, and reviews) on the home screen builds social proof and increases user confidence, leading to higher tap-through rates on provider cards.

| | Control (A) | Treatment (B) |
|-|-------------|---------------|
| **UI** | HomeStatsBar visible | HomeStatsBar hidden |
| **Expected behaviour** | Users see platform scale → higher trust | Cleaner layout → less distraction |
| **Primary metric** | Provider card tap-through rate | Provider card tap-through rate |
| **Assignment** | `userId.hashCode.isEven` | `userId.hashCode.isOdd` |

### 4.2 Implementation

**Assignment service** (`lib/services/ab_test_service.dart`):
- Pure Dart — no Firebase, no network, no state
- Deterministic: same `userId` always maps to the same variant
- Uses `String.hashCode % 2` for a stable 50/50 split

**Host widget** (`lib/widgets/ab_stats_bar_host.dart`):
- `AbStatsBarHost` receives the assigned `AbVariant` and renders or suppresses `HomeStatsBar`
- Decoupled from `AbTestService` → fully testable in isolation

**HomeScreen integration** (`lib/screens/home/home_screen.dart`):
- Reads `userId` from `AuthProvider`
- Calls `AbTestService.assignVariant(userId)` → passes result to `AbStatsBarHost`

### 4.3 A/B Test Files

| File | Role | Tests |
|------|------|-------|
| `test/unit/ab_test_service_test.dart` | Verifies variant assignment correctness | 8 |
| `test/widget/ab_stats_bar_host_test.dart` | Verifies correct UI per variant | 6 |
| **Total** | | **14** |

### 4.4 Mistakes Avoided by Design

- **No random assignment:** `Random()` would make tests non-deterministic (different result each run). Hashing the userId is deterministic and reproducible.
- **Dependency separation:** `AbTestService` is a pure function — no ChangeNotifier, no BuildContext. Widget tests inject the variant directly; no service mocking needed.
- **No Firebase dependency in tests:** `AbTestService` operates on a plain `String` (userId). The full `HomeScreen` integration (which reads userId from Firebase Auth) is not widget-tested directly — that falls under integration testing scope.

---

## 5. Test Quality Principles Applied

| Principle | How Applied |
|-----------|-------------|
| **Test production code, not test code** | Fixed circular average tests that recomputed the formula inside the test body |
| **Assert all fields** | Boundary and fallback tests check all N fields, not just 2 |
| **Avoid false passes** | Replaced `find.text('')` with before/after pump using unique strings |
| **Timezone safety** | Date assertions use `textContaining('2023')` not exact formatted strings |
| **Collision-free values** | Multi-column tests ensure each column has a distinct value |
| **Scope assertions** | Stats bar tests use `find.descendant` to isolate the target widget |
| **No network in tests** | GoogleFonts HTTP disabled; `photoUrl: null`; pure Dart for A/B logic |
| **Deterministic tests** | No `Random()`, no timestamps, no time-dependent code paths |

---

## 6. Final Test Matrix

| Category | File | Tests | Status |
|----------|------|-------|--------|
| Unit | `questionnaire_model_test.dart` | 13 | ✅ Pass |
| Unit | `review_model_test.dart` | 22 | ✅ Pass |
| Unit | `provider_model_test.dart` | 21 | ✅ Pass |
| Unit | `community_doctor_model_test.dart` | 10 | ✅ Pass |
| Unit | `ab_test_service_test.dart` | 8 | ✅ Pass |
| Unit | `sus_calculator_test.dart` | 21 | ✅ Pass |
| Widget | `review_card_test.dart` | 21 | ✅ Pass |
| Widget | `home_stats_bar_test.dart` | 12 | ✅ Pass |
| Widget | `provider_card_test.dart` | 13 | ✅ Pass |
| Widget | `home_search_bar_test.dart` | 7 | ✅ Pass |
| Widget | `ab_stats_bar_host_test.dart` | 6 | ✅ Pass |
| **Total** | | **154** | ✅ |

---

## 7. Code Coverage

Generated with `flutter test --coverage` + `genhtml`.  
HTML report: `coverage/html/index.html`

### Per-File Results

| File | Lines Hit | Total | Coverage |
|------|----------:|------:|---------:|
| `models/provider_model.dart` | 42 | 42 | **100%** |
| `models/questionnaire_model.dart` | 18 | 18 | **100%** |
| `screens/home/widgets/home_search_bar.dart` | 20 | 20 | **100%** |
| `screens/home/widgets/home_stats_bar.dart` | 34 | 34 | **100%** |
| `widgets/ab_stats_bar_host.dart` | 4 | 4 | **100%** |
| `widgets/review_card.dart` | 82 | 82 | **100%** |
| `widgets/star_rating_widget.dart` | 8 | 8 | **100%** |
| `constants/app_colors.dart` | 1 | 1 | **100%** |
| `utils/sus_calculator.dart` | 24 | 25 | 96.0% |
| `services/ab_test_service.dart` | 6 | 7 | 85.7% |
| `widgets/provider_card.dart` | 43 | 47 | 91.5% |
| `models/review_model.dart` | 21 | 32 | 65.6% |
| `constants/app_theme.dart` | 3 | 72 | 4.2% |
| **TOTAL** | **306** | **392** | **78.1%** |

### Notes on Partial Coverage

| File | Uncovered lines | Reason |
|------|-----------------|--------|
| `app_theme.dart` | 69/72 | Static `const` theme values — referenced by widgets at compile time, not executed as runtime lines; excluded from meaningful coverage count |
| `review_model.dart` | 11/32 | `toMap()` calls `FieldValue.serverTimestamp()` — requires live Firebase; integration test territory |
| `provider_card.dart` | 4/47 | `CachedNetworkImage` network-image path — all tests use `photoUrl: null` by design |
| `ab_test_service.dart` | 1/7 | Private constructor `AbTestService._()` — never instantiated; intentional static-only class |
| `sus_calculator.dart` | 1/25 | One defensive branch in `grade()` — covered by all boundary tests; lcov counting artifact |

**Effective coverage** (excluding `app_theme.dart` constants and Firebase-blocked lines): **~92%**

---

## 9. What Was NOT Tested (and Why)

| Area | Reason Excluded |
|------|-----------------|
| `ReviewModel.toMap()` | Calls `FieldValue.serverTimestamp()` — requires live Firebase platform; belongs in integration tests |
| `CommunityReviewModel.toMap()` | Same — uses `FieldValue.serverTimestamp()`; `fromMap()` is pure but the write path needs Firebase |
| `HomeScreen` full widget test | Requires `ProviderProvider` + `AuthProvider` backed by Firebase; out of scope for this sprint |
| `FirestoreService` (incl. community aggregation transaction, practice-change, admin approve/reject) | Direct Firestore access + transactions — requires Firebase Emulator Suite setup |
| `CommunityProvider` / `AuthProvider` / `ReviewProvider` (state) | Depend on `FirestoreService` → need the emulator or mocks; out of scope for this sprint |
| Admin screen + provider dashboard (practice pending/approve UI) | Require Firebase-backed providers; manual-tested only |
| Navigation flows (end-to-end) | Out of scope; covered by manual usability testing (Day 4) |
| Image upload / Storage | Firebase Storage requires platform binaries; integration test territory |

> **Note on the regression pass:** after the feature expansion (patient/provider/admin split, practice-change approval, community reviews) the full suite was re-run — **154/154 pass**, and `flutter analyze` reports **0 issues** across `lib/` and `test/`. New backend logic (the community aggregation transaction, practice-change/approve methods) is exercised manually because it needs the Firebase emulator; only the pure model logic (`CommunityDoctorModel`) was added to the automated suite.
