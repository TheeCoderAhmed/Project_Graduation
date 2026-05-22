# DRAPO — Team Study Guide

Flutter + Firebase healthcare reviews app.  
6 members, one area each. Teacher questions focus on UI changes and code explanation.

---

## Quick Flutter concepts (read first — 5 min)

| Term | What it means |
|------|---------------|
| `Widget` | Every visual element. Everything is a widget. |
| `StatelessWidget` | Widget with no changing state — just displays data passed in. |
| `StatefulWidget` | Widget that can change over time (loading, toggling, etc.). |
| `build(context)` | Called every time the widget needs to draw itself. Return the UI here. |
| `const` | Widget never changes — Flutter skips rebuilding it. |
| `AppColors.X` | Look in `lib/constants/app_colors.dart` to change any color. |
| `AppTheme.radiusX` | Look in `lib/constants/app_theme.dart` to change corner rounding. |
| `BorderRadius.circular(9999)` | Makes any box/container fully circular (pill or circle). |
| `enum` | A fixed list of named options. e.g. `AbVariant.control` or `AbVariant.treatment`. |

---

## Member assignments

### Member 1 — Design Tokens (Colors, Theme, Routes)
**Your files:**
- [`lib/constants/app_colors.dart`](lib/constants/app_colors.dart) — every color in the app
- [`lib/constants/app_theme.dart`](lib/constants/app_theme.dart) — spacing, corner radii, button/input styles
- [`lib/constants/app_routes.dart`](lib/constants/app_routes.dart) — screen route name constants
- [`lib/constants/app_strings.dart`](lib/constants/app_strings.dart) — text strings

**Common teacher questions:**
- "Change the primary color" → `AppColors.primary` in `app_colors.dart`
- "Make all buttons circular" → `radiusFull` is already `9999`; buttons use it via `app_theme.dart`
- "What is `AppColors.tertiaryFixed`?" → Warm amber pill background for star rating badges
- "Change the app background color" → `AppColors.background`

---

### Member 2 — Auth Screens (Login, Signup, Onboarding)
**Your files:**
- [`lib/screens/auth/login_screen.dart`](lib/screens/auth/login_screen.dart)
- [`lib/screens/auth/signup_screen.dart`](lib/screens/auth/signup_screen.dart)
- [`lib/screens/onboarding/onboarding_screen.dart`](lib/screens/onboarding/onboarding_screen.dart)
- [`lib/screens/splash/splash_screen.dart`](lib/screens/splash/splash_screen.dart)
- [`lib/widgets/common/app_button.dart`](lib/widgets/common/app_button.dart)
- [`lib/widgets/common/app_text_field.dart`](lib/widgets/common/app_text_field.dart)

**Common teacher questions:**
- "What does `_formKey.currentState!.validate()` do?" → Runs all validator functions in the form; returns false if any field is invalid
- "Change the login button to a circle" → Find `ElevatedButton` → change `BorderRadius` to `BorderRadius.circular(9999)`
- "What does `context.read<AuthProvider>().signIn(...)` do?" → Calls the sign-in method on the AuthProvider state manager
- "Change the text field border color" → Modify `AppTheme.inputDecorationTheme` in `app_theme.dart`

---

### Member 3 — Home Screen + A/B Experiment
**Your files:**
- [`lib/screens/home/home_screen.dart`](lib/screens/home/home_screen.dart) — thin layout file, assembles the sections below; reads A/B variant and passes it down
- [`lib/screens/home/widgets/home_header.dart`](lib/screens/home/widgets/home_header.dart) — gradient banner with greeting and logo
- [`lib/screens/home/widgets/home_search_bar.dart`](lib/screens/home/widgets/home_search_bar.dart) — tappable fake search bar
- [`lib/screens/home/widgets/home_quick_categories.dart`](lib/screens/home/widgets/home_quick_categories.dart) — specialty chips row
- [`lib/screens/home/widgets/home_stats_bar.dart`](lib/screens/home/widgets/home_stats_bar.dart) — doctors/pharmacies/reviews count strip
- [`lib/screens/home/widgets/home_provider_section.dart`](lib/screens/home/widgets/home_provider_section.dart) — titled provider list sections
- [`lib/widgets/ab_stats_bar_host.dart`](lib/widgets/ab_stats_bar_host.dart) — shows or hides HomeStatsBar based on A/B variant

**Common teacher questions:**
- "Make the logo box circular" → `home_header.dart` — find the logo `Container` → change `BorderRadius.circular(AppTheme.radiusMd)` to `BorderRadius.circular(9999)`
- "Change the greeting background gradient" → `home_header.dart` → `LinearGradient` → edit `AppColors.primary` / `primaryContainer`
- "Add a new specialty chip" → `home_quick_categories.dart` → add a new `_Category(...)` entry to the `categories` list
- "What does `horizontal: true` do on HomeProviderSection?" → Shows a horizontally scrollable row of compact cards instead of a vertical list
- "What triggers the data to load?" → `initState()` in `home_screen.dart` calls `loadHomeData()` after the first frame
- "What is the A/B test on the home screen?" → Some users see the stats bar (doctors/pharmacies/reviews counts), others don't. `AbStatsBarHost` in `ab_stats_bar_host.dart` checks the variant and renders or hides it
- "What is `AbVariant.control` vs `AbVariant.treatment`?" → Control = stats bar visible (current design). Treatment = stats bar hidden. Assigned by `AbTestService` based on the logged-in user's ID
- "What does `if (variant == AbVariant.treatment) return const SizedBox.shrink()` do?" → Returns an invisible empty widget — effectively hides the stats bar for treatment users

---

### Member 4 — Provider Browsing (Search + Profile)
**Your files:**
- [`lib/screens/search/search_screen.dart`](lib/screens/search/search_screen.dart)
- [`lib/screens/provider_profile/provider_profile_screen.dart`](lib/screens/provider_profile/provider_profile_screen.dart)
- [`lib/screens/provider_dashboard/provider_dashboard_screen.dart`](lib/screens/provider_dashboard/provider_dashboard_screen.dart)
- [`lib/widgets/provider_card.dart`](lib/widgets/provider_card.dart) — the card shown in search results and home

**Common teacher questions:**
- "Change ProviderCard corners to be more rounded" → `provider_card.dart` → `BorderRadius.circular(AppTheme.radiusLg)` → increase value
- "Make the provider avatar circular" → `provider_card.dart` → `ClipRRect` borderRadius → change to `BorderRadius.circular(9999)`
- "What is `_PlaceholderAvatar`?" → A fallback icon shown when the provider has no photo URL
- "How does the search filter work?" → `search_screen.dart` — look for the filtering logic that checks provider name and specialty

---

### Member 5 — Reviews (Questionnaire + Review Cards)
**Your files:**
- [`lib/screens/questionnaire/questionnaire_screen.dart`](lib/screens/questionnaire/questionnaire_screen.dart) — write-a-review form
- [`lib/screens/reviews/reviews_list_screen.dart`](lib/screens/reviews/reviews_list_screen.dart) — list of reviews for a provider
- [`lib/widgets/review_card.dart`](lib/widgets/review_card.dart) — single review card widget
- [`lib/widgets/star_rating_widget.dart`](lib/widgets/star_rating_widget.dart) — star row display

**Common teacher questions:**
- "Change the avatar shape from circle to square" → `review_card.dart` → `CircleAvatar` → replace with a `Container` with `BorderRadius.circular(AppTheme.radiusMd)`
- "What does `isVerified` control on the review card?" → Shows the blue checkmark badge (`Icons.verified_rounded`) next to the rating
- "What is the gold rating badge made of?" → `Container` with `AppColors.tertiaryFixed` background + `Icons.star_rounded` + text
- "What is `_buildQRow`?" → Builds one row of the questionnaire sub-ratings (Wait Time, Service, Hygiene, Staff) shown below the review text
- "What does `onTap: null` do to the ReviewCard?" → Card becomes non-tappable (no InkWell wrapper)

---

### Member 6 — Data Layer (Models, Services, Providers, Utilities)
**Your files:**
- [`lib/models/provider_model.dart`](lib/models/provider_model.dart) — provider data structure
- [`lib/models/review_model.dart`](lib/models/review_model.dart) — review data structure
- [`lib/models/user_model.dart`](lib/models/user_model.dart) — user data structure
- [`lib/models/questionnaire_model.dart`](lib/models/questionnaire_model.dart) — questionnaire scores + `average` getter
- [`lib/services/auth_service.dart`](lib/services/auth_service.dart) — Firebase Auth operations
- [`lib/services/firestore_service.dart`](lib/services/firestore_service.dart) — Firestore read/write operations
- [`lib/services/ab_test_service.dart`](lib/services/ab_test_service.dart) — A/B variant assignment (pure Dart, no Firebase)
- [`lib/utils/sus_calculator.dart`](lib/utils/sus_calculator.dart) — SUS usability score calculator
- [`lib/providers/auth_provider.dart`](lib/providers/auth_provider.dart) — auth state + bookmarks
- [`lib/providers/provider_provider.dart`](lib/providers/provider_provider.dart) — provider list state
- [`lib/providers/review_provider.dart`](lib/providers/review_provider.dart) — review submission state

**Common teacher questions:**
- "What is `fromMap`?" → Converts raw Firestore data (a Map) into a typed Dart object
- "What is `toMap`?" → Converts a Dart object back into a Map to save to Firestore
- "What does `notifyListeners()` do?" → Tells all widgets watching this provider to rebuild with updated data
- "What is the difference between `context.watch` and `context.read`?" → `watch` rebuilds the widget when data changes; `read` just reads once without subscribing
- "What does `ChangeNotifier` mean?" → Base class that lets a provider broadcast changes to listeners (the widgets)
- "What is `AbTestService.assignVariant(userId)`?" → Takes the logged-in user's ID, hashes it, and returns `AbVariant.control` or `AbVariant.treatment`. Same user always gets the same variant — no randomness each session
- "Why not use `Random()` for the A/B split?" → `Random()` gives a different result every call — the user would see different layouts each session. Hashing the userId is deterministic: same input, same output, every time
- "What is `QuestionnaireModel.average`?" → A getter that returns the mean of all four criteria scores: `(waitingTime + serviceQuality + hygiene + staffCommunication) / 4.0`
- "What does `SusCalculator.calculate(responses)` do?" → Takes a list of 10 ratings (1–5) from the SUS questionnaire and returns a 0–100 usability score using the official SUS formula

---

## How data flows (for any member)

```
Firebase Firestore
      │
      ▼
FirestoreService        ← raw read/write, no business logic
      │
      ▼
Provider (ChangeNotifier) ← holds state, calls notifyListeners()
      │
      ▼
Screen / Widget         ← context.watch() rebuilds when provider changes
```

**A/B test flow (added in testing phase):**
```
AuthProvider.userModel.userId
      │
      ▼
AbTestService.assignVariant(userId)   ← pure Dart, no Firebase
      │
      ▼
AbStatsBarHost(variant: ...)          ← renders or hides HomeStatsBar
```

---

## Security & data protection (any member may be asked)

The backend is locked down by **Firestore security rules** (`firestore.rules`) and **Storage rules** (`storage.rules`) — these run on Firebase's servers, so even a tampered app cannot bypass them.

**Common teacher questions:**
- "How do you stop a user editing someone else's account?" → `users/{userId}` rules only allow read/write when `request.auth.uid == userId`. Identity (`uid`, `email`, `role`) cannot be changed after sign-up — only `fullName`, `profilePhotoUrl`, `bookmarks`.
- "How do you stop a provider faking their own rating?" → On `providers`, the fields `averageRating`, `rankingScore`, `totalReviews` are **locked** — a provider editing their own profile is blocked from touching them. Only an admin can.
- "How do you stop fake or duplicate reviews?" → Review document ID is forced to `userId_providerId`, so each patient can leave **one review per provider**. Only users with role `patient` can create a review, the `userId` must match the logged-in user, and ratings must be 1–5. Reviews can never be edited after submission (`allow update: if false`).
- "Who can upload images?" → Only the owner, to their own `users/{uid}/profile/` path, images under 5 MB. Everything else in Storage is denied.
- "Where are the rules?" → `firestore.rules` and `storage.rules` in the project root. There is a final `match /{document=**} { allow read, write: if false; }` that denies anything not explicitly allowed.

**If asked "how is a provider's ranking calculated?"** → Each provider document stores a precomputed `rankingScore` and `averageRating`, shown read-only on the Provider Profile and Provider Dashboard. The score fields are locked by the security rules so the client cannot change them — in production they would be recalculated by a trusted Cloud Function, not the app.

---

## Testing files (what they are, if teacher asks)

All tests live in `test/`. You never need to edit them — just know what each file tests.

| Test file | What it checks |
|-----------|---------------|
| `test/unit/questionnaire_model_test.dart` | `fromMap()` parsing, clamping 0–5, `average` getter |
| `test/unit/review_model_test.dart` | `fromMap()` safety: null fields, bad types, empty map |
| `test/unit/provider_model_test.dart` | `fromMap()`, `copyWith()`, `toMap()` round-trip |
| `test/unit/ab_test_service_test.dart` | Same userId → same variant; 50/50 distribution; edge cases |
| `test/unit/sus_calculator_test.dart` | SUS formula correctness, boundary scores, grade bands |
| `test/widget/review_card_test.dart` | ReviewCard renders correctly, taps fire callback |
| `test/widget/home_stats_bar_test.dart` | Stats bar shows correct counts, number formatting (1.2k) |
| `test/widget/provider_card_test.dart` | ProviderCard content, type icons, tap behaviour |
| `test/widget/home_search_bar_test.dart` | Search bar navigates on tap, no real TextField |
| `test/widget/ab_stats_bar_host_test.dart` | Control shows stats bar; treatment hides it |

**If asked "what is a unit test?"** → Tests a single function or class in isolation with no UI, no Firebase, no network.

**If asked "what is a widget test?"** → Renders a widget inside a fake Flutter environment and checks that the right text, icons, and tap responses appear.

**If asked "what is A/B testing?"** → Running two versions of a feature (A = original, B = modified) on different users at the same time to measure which version performs better. Our experiment tests whether showing the stats bar increases provider tap-through rates.

**If asked about the SUS score (78.75)** → We tested with 6 real users. They filled a 10-question questionnaire after using the app. Score 0–100; average software scores 68; we got 78.75 (Grade B — Good). One user scored 52.5 because they didn't recognise the search bar was tappable — fixing that one issue should push the score above 80.

---

## Common "change X" cheat sheet

| What to change | Where to go |
|---------------|-------------|
| Any color | `lib/constants/app_colors.dart` |
| Button shape / corner radius | `lib/constants/app_theme.dart` → `elevatedButtonTheme` |
| Make any box circular | Add `shape: BoxShape.circle` or `BorderRadius.circular(9999)` |
| App font | `lib/constants/app_theme.dart` → `textTheme` (uses Manrope + Inter) |
| Screen background color | `Scaffold(backgroundColor: ...)` in that screen's file |
| Notification icon | `lib/screens/home/widgets/home_header.dart` → `Icons.notifications_outlined` |
| Star color | `AppColors.tertiary` in `app_colors.dart` (currently dark amber `#5A3B00`) |
| Card shadow | `AppTheme.subtleShadow` in `app_theme.dart` |
| Show/hide stats bar for all users | `lib/widgets/ab_stats_bar_host.dart` → always return `HomeStatsBar(...)` (remove the treatment check) |
| Add a new A/B variant arm | `lib/services/ab_test_service.dart` → extend `AbVariant` enum and update `assignVariant()` |
