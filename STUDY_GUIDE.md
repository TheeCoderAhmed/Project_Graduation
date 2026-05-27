# DRAPO — Team Study Guide

Flutter + Firebase healthcare reviews app.  
6 members, one area each. Teacher questions focus on UI changes and code explanation.

> **⚠️ Read this first — the review only covers YOUR files.**
> The teacher asks each member **only about the files they own**. So:
> - Read the **Quick Flutter concepts** table (everyone) + the **Universal answer playbook** (everyone).
> - Read **only your own member section** in full. You can ignore the other five.
> - **Back members (M5, M6)** also rehearse the data-flow diagrams for their files.
> - You will NOT be asked about code you didn't touch.

**Do these 3 things once before review day:**
1. Run the app (`flutter run`) and make one tiny change in your own file (e.g. a colour), hot-reload, watch it update — examiners often say "now do it live."
2. Open each of your own files once and skim it — recognising code on sight beats trying to recall it.
3. (M5/M6 only) Say your 2–3 end-to-end flows out loud once.

**Three account types:** `patient` (browse, review, save), `provider` (own listing + dashboard, reply to reviews), `admin` (approve provider practice changes). The bottom navigation is different per role — see Member 3.

**Two kinds of reviews:** in-app providers (listed in DRAPO) and **community reviews** of off-app doctors that patients add themselves (see Member 4).

---

## Quick Flutter concepts (read first — 10 min)

**Every member should be able to define these — teachers ask them no matter which file you own.**

| Term | What it means |
|------|---------------|
| `Widget` | Every visual element. Everything is a widget. |
| `StatelessWidget` | Widget with no changing state — just displays data passed in. |
| `StatefulWidget` | Widget that can change over time (loading, toggling, etc.). It has a `State` class. |
| `setState(() { ... })` | Call inside a StatefulWidget to change a value AND tell Flutter to redraw. Without it, the screen won't update. |
| `build(context)` | Called every time the widget needs to draw itself. Return the UI here. |
| `BuildContext` | A handle to where this widget sits in the tree. Used to find things like the theme, navigator, or providers. |
| `const` | Widget never changes — Flutter skips rebuilding it (a small speed win). |
| `initState()` | Runs once when a StatefulWidget is first created — used to kick off the first data load. |
| `Future` / `async` / `await` | A `Future` is a value that arrives later (e.g. a Firebase read). `async` marks a function that waits; `await` pauses until the Future finishes. |
| `Navigator.pushNamed(context, route)` | Opens another screen by its route name. `Navigator.pop(context)` closes it. |
| `ListView.builder` | Builds a scrolling list lazily — only the visible items are created (efficient for long lists). |
| `Column` / `Row` | Stack children vertically (Column) or horizontally (Row). |
| `Expanded` / `Flexible` | Inside a Row/Column, makes a child take the leftover space — prevents overflow. |
| `Padding` / `SizedBox` | `Padding` adds space around a child; `SizedBox` is a fixed-size gap or box. |
| `Provider` / `ChangeNotifierProvider` | Supplies a shared state object (like `AuthProvider`) to the widget tree. Set up in `main.dart` `MultiProvider`. |
| `context.watch<X>()` / `context.read<X>()` | `watch` = listen + rebuild when X changes; `read` = grab once, no rebuild (used inside button taps). |
| `?` / `!` / `??` (null-safety) | `String?` = can be null; `value!` = "I promise it's not null"; `a ?? b` = use `a`, or `b` if `a` is null. |
| `enum` | A fixed list of named options. e.g. `AbVariant.control` or `AbVariant.treatment`. |
| `AppColors.X` | Look in `lib/constants/app_colors.dart` to change any color. |
| `AppTheme.radiusX` | Look in `lib/constants/app_theme.dart` to change corner rounding. |
| `BorderRadius.circular(9999)` | Makes any box/container fully circular (pill or circle). |

---

## Universal answer playbook (works for ANY question)

If the teacher points at code you don't instantly recognise, stay calm and use this:

1. **"What does this do?"** → Read it top-down in plain words: *"It's a `StatelessWidget` that builds a `Row` with an icon and text."* Naming the widget types already earns marks.
2. **"Change X"** (colour / size / corner / text) → Almost always one of: `AppColors.*` (colour), `AppTheme.radius*` or `BorderRadius.circular()` (corners), a `fontSize:` / `size:` number, or the string literal in quotes. Point at the exact line and say what you'd change it to.
3. **"Where does the data come from?"** → Front members: *"My screen calls `someProvider.loadX()`; the actual Firebase work is in `firestore_service.dart`."* (That's M5/M6's code.) Back members: explain the load flow.
4. **"Why is it built this way?"** → Safe truths that almost always apply: *"Reused widget keeps it consistent,"* *"`const` avoids unnecessary rebuilds,"* *"`Expanded` stops overflow,"* *"the provider keeps UI and data separate."*
5. **Don't know? Narrow it.** → *"This part is [widget type]; the logic it calls lives in [file]."* Locating the right file is worth marks even if you can't recite the internals.

**Golden rule:** every screen follows the same shape — `Scaffold` → `body` → `Column`/`ListView` of widgets, data from a `provider` via `context.watch`. If you can say that sentence about your screen, you can answer most questions.

---

## Member assignments

**Split: 4 front-end members (M1–M4) + 2 back-end members (M5–M6).** Front members own screens/widgets and only need to *name* the back-end method they call. Back members own the data layer and explain *how* it works.

---

### Member 1 — Auth Screens + Design Tokens (FRONT)
**Your files:**
- [`lib/screens/auth/login_screen.dart`](lib/screens/auth/login_screen.dart)
- [`lib/screens/auth/signup_screen.dart`](lib/screens/auth/signup_screen.dart)
- [`lib/screens/onboarding/onboarding_screen.dart`](lib/screens/onboarding/onboarding_screen.dart)
- [`lib/screens/splash/splash_screen.dart`](lib/screens/splash/splash_screen.dart)
- [`lib/widgets/common/app_button.dart`](lib/widgets/common/app_button.dart)
- [`lib/widgets/common/app_text_field.dart`](lib/widgets/common/app_text_field.dart)
- [`lib/constants/app_colors.dart`](lib/constants/app_colors.dart) — every color in the app
- [`lib/constants/app_theme.dart`](lib/constants/app_theme.dart) — spacing, corner radii, button/input styles
- [`lib/constants/app_routes.dart`](lib/constants/app_routes.dart) — screen route name constants
- [`lib/constants/app_strings.dart`](lib/constants/app_strings.dart) — text strings

**Common teacher questions:**
- "Change the primary color" → `AppColors.primary` in `app_colors.dart`
- "Make all buttons circular" → `radiusFull` is already `9999`; buttons use it via `app_theme.dart`
- "What is `AppColors.tertiaryFixed`?" → Warm amber pill background for star rating badges
- "Change the app background color" → `AppColors.background`
- "Where are the new screens registered?" → `app_routes.dart` holds the route name constants (`community`, `communityDoctor`, `addCommunityReview`, `admin`); the actual screen for each is wired in `lib/main.dart` under `routes:`
- "What does `_formKey.currentState!.validate()` do?" → Runs all validator functions in the form; returns false if any field is invalid
- "Change the login button to a circle" → Find `ElevatedButton` → change `BorderRadius` to `BorderRadius.circular(9999)`
- "What does `context.read<AuthProvider>().signIn(...)` do?" → Calls the sign-in method on the AuthProvider state manager (that method lives in M6's files)
- "Change the text field border color" → Modify `AppTheme.inputDecorationTheme` in `app_theme.dart`
- "Why does the signup form change when I pick Provider?" → `signup_screen.dart` has getters `_isProvider`, `_isDoctor`, `_collectsIdentity`. When the role/type changes, `setState` rebuilds and `_buildProviderFields()` / `_buildIdentityFields()` add the extra fields
- "What extra fields does a Doctor enter?" → Listing type, gender, hospital, **department**, **room (optional)**, specialty, address, phone, and T.C. Kimlik. A Pharmacy skips gender/department/room/TC (it's a business, not a person)
- "What does a Patient enter beyond name/email/password?" → Gender + T.C. Kimlik No. Both are private — stored only on the user's own `users` doc, never shown to anyone else
- "What validates the T.C. Kimlik No?" → `TcKimlik.isValid()` (M5's file) — checks the official 11-digit checksum. The signup screen just *calls* it
- "Can someone sign up as admin?" → No. Signup only allows `patient` or `provider` (`isValidClientRole`). An admin is created by manually setting `role: admin` on the user doc in the Firebase console

---

### Member 2 — Home Screen + A/B Experiment (FRONT)
**Your files:**
- [`lib/screens/home/home_screen.dart`](lib/screens/home/home_screen.dart) — thin layout file, assembles the sections below; reads A/B variant and passes it down
- [`lib/screens/home/widgets/home_header.dart`](lib/screens/home/widgets/home_header.dart) — gradient banner with greeting and logo
- [`lib/screens/home/widgets/home_search_bar.dart`](lib/screens/home/widgets/home_search_bar.dart) — tappable fake search bar
- [`lib/screens/home/widgets/home_quick_categories.dart`](lib/screens/home/widgets/home_quick_categories.dart) — specialty chips row
- [`lib/screens/home/widgets/home_stats_bar.dart`](lib/screens/home/widgets/home_stats_bar.dart) — doctors/pharmacies/reviews count strip
- [`lib/screens/home/widgets/home_provider_section.dart`](lib/screens/home/widgets/home_provider_section.dart) — titled provider list sections
- [`lib/widgets/ab_stats_bar_host.dart`](lib/widgets/ab_stats_bar_host.dart) — shows or hides HomeStatsBar based on A/B variant
- [`lib/screens/notifications/notifications_screen.dart`](lib/screens/notifications/notifications_screen.dart) — notifications screen (the home header's bell icon opens it)
- [`lib/screens/settings/settings_screen.dart`](lib/screens/settings/settings_screen.dart) — settings (notification toggle, language)

**Common teacher questions:**
- "Make the logo box circular" → `home_header.dart` — find the logo `Container` → change `BorderRadius.circular(AppTheme.radiusMd)` to `BorderRadius.circular(9999)`
- "Change the greeting background gradient" → `home_header.dart` → `LinearGradient` → edit `AppColors.primary` / `primaryContainer`
- "Add a new specialty chip" → `home_quick_categories.dart` → add a new `_Category(...)` entry to the `categories` list
- "What does `horizontal: true` do on HomeProviderSection?" → Shows a horizontally scrollable row of compact cards instead of a vertical list
- "What triggers the data to load?" → `initState()` in `home_screen.dart` calls `loadHomeData()` after the first frame
- "What is the A/B test on the home screen?" → Some users see the stats bar (doctors/pharmacies/reviews counts), others don't. `AbStatsBarHost` in `ab_stats_bar_host.dart` checks the variant and renders or hides it
- "What is `AbVariant.control` vs `AbVariant.treatment`?" → Control = stats bar visible (current design). Treatment = stats bar hidden. Assigned by `AbTestService` based on the logged-in user's ID
- "What does `if (variant == AbVariant.treatment) return const SizedBox.shrink()` do?" → Returns an invisible empty widget — effectively hides the stats bar for treatment users
- "What is the Notifications screen?" → `notifications_screen.dart` — a static placeholder showing an empty-state ("You're all caught up!"). No backend yet; it's the destination of the home header's bell icon. If asked to change the message, edit the `Text` strings there.
- "How do settings persist?" → `settings_screen.dart` uses **`SharedPreferences`** (on-device key-value storage) to save the push-notification toggle + language. Loaded in `initState` via `_loadPrefs`; a failed write is non-fatal (UI already updated). No Firebase — it's local-only.
- "Change the available languages" → `settings_screen.dart` → the `_languages` list (`English`, `Turkish`, `Arabic`).

---

### Member 3 — Provider Browsing + Dashboard + Admin (FRONT)
**Your files:**
- [`lib/screens/search/search_screen.dart`](lib/screens/search/search_screen.dart)
- [`lib/screens/provider_profile/provider_profile_screen.dart`](lib/screens/provider_profile/provider_profile_screen.dart)
- [`lib/screens/provider_dashboard/provider_dashboard_screen.dart`](lib/screens/provider_dashboard/provider_dashboard_screen.dart)
- [`lib/screens/admin/admin_screen.dart`](lib/screens/admin/admin_screen.dart) — admin approvals panel
- [`lib/screens/main_wrapper.dart`](lib/screens/main_wrapper.dart) — bottom navigation (different per role)
- [`lib/widgets/provider_card.dart`](lib/widgets/provider_card.dart) — the card shown in search results and home
- [`lib/widgets/common/provider_avatar.dart`](lib/widgets/common/provider_avatar.dart) — gender/type-based avatar
- [`lib/main.dart`](lib/main.dart) — app entry point (you're the *explainer*; it's team-edited — see the table below)

**Common teacher questions:**
- "Change ProviderCard corners to be more rounded" → `provider_card.dart` → `BorderRadius.circular(AppTheme.radiusLg)` → increase value
- "What is `ProviderAvatar`?" → A widget that shows the provider's photo if it has one, otherwise draws a generated icon based on type + gender: pharmacy → teal pharmacy icon, female doctor → pink, male doctor → blue, unknown doctor → hospital icon. It replaced the old `_PlaceholderAvatar`. Lives in `lib/widgets/common/provider_avatar.dart`
- "How does the search filter work?" → `search_screen.dart` — `searchResults` are filtered by the `all/doctor/pharmacy` chip, then sorted by the chosen `SortOption` (top rated, most reviewed, name A–Z/Z–A)
- "Why are the filter chips in a scroll view?" → The chips row sits in `Expanded → SingleChildScrollView(horizontal)` so the chips scroll instead of overflowing the screen edge; the Sort button stays pinned on the right
- "What is the bottom nav difference per role?" → `main_wrapper.dart` builds different tab lists: **patient** = Home, Search, Community, Reviews, Profile; **provider** = Dashboard, Profile. A provider doesn't browse or review — they get reviewed
- "What is the Practice Information card on the dashboard?" → Shows the doctor's live hospital / department / room. "Request a change" opens a dialog that writes the new values to **pending** fields with status `pending` (live values are NOT changed). A gold badge shows the pending values until an admin approves
- "Why can't the doctor just edit their hospital directly?" → Security rules block providers from writing the live `hospital`/`department`/`room` fields. Their edits go to `pendingHospital` etc.; only an admin copies them across (anti-tamper, so listings stay trustworthy)
- "What does the Admin screen do?" → `admin_screen.dart` lists every provider with `practiceChangeStatus == 'pending'`, shows a `current → pending` diff, and **Approve** (copy pending to live, clear pending) or **Reject** (discard pending). The actual writes are `approvePracticeChange` / `rejectPracticeChange` in `firestore_service.dart`
- "Where is the Admin screen opened from?" → A button in the Profile → Account Details tab, shown only when `role == 'admin'`
- "What does `main.dart` do?" → App entry point: `main()` initialises Firebase then `runApp`. `DrapoApp` sets up the `MultiProvider` (the shared state objects), the `MaterialApp` theme, and the `routes:` map (route name → screen). `AuthGuard` wraps protected routes and redirects to login if signed out.
- "Why is `main.dart` so simple / who owns it?" → Intentionally **thin wiring only** (no logic) — like in real projects it's a shared file every member edits when adding a screen or provider, kept small to avoid merge conflicts. You're the explainer; everyone added their own lines (table below).

**Who touched `main.dart`:**

| Member | What they added |
|--------|-----------------|
| M1 (Auth) | `splash`, `onboarding`, `login`, `signup` routes |
| M2 (Home) | `notifications`, `settings` routes |
| M3 (you) | `home`→`MainWrapper`, `search`, `providerProfile`, `providerDashboard`, `admin` routes + skeleton |
| M4 (Reviews/Community) | `reviewsList`, `questionnaire`, `userProfile`, `communityDoctor`, `addCommunityReview` routes |
| M6 (Services/State) | the `MultiProvider` list — `AuthProvider`, `ProviderProvider`, `ReviewProvider`, `CommunityProvider` |

(M5 = models/rules, no `main.dart` wiring.) Each member can point to their own route/provider line if asked.

---

### Member 4 — Reviews + Community (FRONT)
**Your files:**
- [`lib/screens/questionnaire/questionnaire_screen.dart`](lib/screens/questionnaire/questionnaire_screen.dart) — write-a-review form
- [`lib/screens/reviews/reviews_list_screen.dart`](lib/screens/reviews/reviews_list_screen.dart) — list of reviews for a provider
- [`lib/widgets/review_card.dart`](lib/widgets/review_card.dart) — single review card widget
- [`lib/widgets/star_rating_widget.dart`](lib/widgets/star_rating_widget.dart) — star row display
- [`lib/screens/community/community_screen.dart`](lib/screens/community/community_screen.dart) — browsable list of off-app doctors
- [`lib/screens/community/community_doctor_detail_screen.dart`](lib/screens/community/community_doctor_detail_screen.dart) — one doctor + their reviews
- [`lib/screens/community/add_community_review_screen.dart`](lib/screens/community/add_community_review_screen.dart) — review-an-off-app-doctor form
- [`lib/screens/user_profile/user_profile_screen.dart`](lib/screens/user_profile/user_profile_screen.dart) — profile tab (saved providers, account details, admin button)

**Common teacher questions:**
- "Change the avatar shape from circle to square" → `review_card.dart` → `CircleAvatar` → replace with a `Container` with `BorderRadius.circular(AppTheme.radiusMd)`
- "What does `isVerified` control on the review card?" → Shows the blue checkmark badge (`Icons.verified_rounded`) next to the rating
- "What is the gold rating badge made of?" → `Container` with `AppColors.tertiaryFixed` background + `Icons.star_rounded` + text
- "What is `_buildQRow`?" → Builds one row of the questionnaire sub-ratings (Wait Time, Service, Hygiene, Staff) shown below the review text
- "What does `onTap: null` do to the ReviewCard?" → Card becomes non-tappable (no InkWell wrapper)
- "What is the 'Response from provider' block?" → `review_card.dart` renders a tinted box when `review.providerReply` is set. The provider writes it from their Dashboard ("Reply" / "Edit reply" → `replyToReview` in `review_provider.dart`)
- "What are Community reviews?" → Reviews of doctors **not listed on DRAPO**. A patient taps the floating "Review a doctor" button on the Community tab, fills name + hospital + department + specialty + rating + questionnaire + comment. The doctor appears on the Community list, searchable by name/hospital/department
- "How do multiple reviews of the same off-app doctor group together?" → They aggregate into one `community_doctors` record. The record ID is a slug built from name + hospital (`CommunityDoctorModel.buildId`), so two patients reviewing the same doctor land on the same listing and the average is shared
- "How does the Community search work?" → `community_screen.dart` calls `setQuery`; `CommunityProvider.filteredDoctors` matches the text against name, hospital, or department (case-insensitive)
- "Where does the community doctor detail get its breakdown?" → From the stored sums (`waitSum` etc.) divided by `totalReviews` — same bar UI as the provider dashboard
- "Do my community reviews show in the My Reviews tab?" → Yes. `reviews_list_screen.dart` merges in-app reviews + the user's community reviews into one date-sorted list. Off-app ones are labelled `Doctor · Hospital (off-app)` and aren't tappable (there's no provider profile for them)
- "How do you refresh the My Reviews list?" → Pull down — the list is wrapped in a `RefreshIndicator` whose `onRefresh` re-runs the load. (The tab stays alive in the `IndexedStack`, so it doesn't auto-refetch on switch.)
- "Why was the community FAB lifted up?" → It sat behind the translucent bottom nav (`MainWrapper` uses `extendBody`), so it's wrapped in `Padding(bottom: 72)` to clear the bar
- "What's on the Profile screen?" → `user_profile_screen.dart`: gradient header (name, email, role badge) + tabs. Patient sees **Saved Providers** + **Account Details**; provider/admin see only Account Details. Account Details shows name/email/role and, for the owner only, gender + T.C. Kimlik. Admins also get an **Admin Panel** button here.
- "Why does the profile show different tabs?" → `_isProvider` is read in `initState`; the `TabController` length is 1 (provider/admin) or 2 (patient). Providers have no bookmarks → no Saved tab.
- "Where do Saved Providers come from?" → The user's `bookmarks` list (on their `users` doc, managed by `AuthProvider`/`FirestoreService` — M6's code). The profile screen just displays them as `ProviderCard`s.

---

### Member 5 — Models, Utilities & Security Rules (BACK)
**Your files:**
- [`lib/models/provider_model.dart`](lib/models/provider_model.dart) — provider data structure
- [`lib/models/review_model.dart`](lib/models/review_model.dart) — review data structure
- [`lib/models/user_model.dart`](lib/models/user_model.dart) — user data structure
- [`lib/models/questionnaire_model.dart`](lib/models/questionnaire_model.dart) — questionnaire scores + `average` getter
- [`lib/models/community_doctor_model.dart`](lib/models/community_doctor_model.dart) — off-app doctor (aggregated)
- [`lib/models/community_review_model.dart`](lib/models/community_review_model.dart) — one community review
- [`lib/utils/tc_kimlik.dart`](lib/utils/tc_kimlik.dart) — T.C. Kimlik 11-digit checksum validator
- [`lib/utils/sus_calculator.dart`](lib/utils/sus_calculator.dart) — SUS usability score calculator
- [`firestore.rules`](firestore.rules) + [`storage.rules`](storage.rules) — the security rules (also see the *Security & data protection* section below)

> **Member 5 — 40-minute crash path** (your half is "what the data is + who can touch it"):
> 1. **`fromMap` / `toMap` / `copyWith`** — open ONE model (`provider_model.dart`). `fromMap` = Firestore Map → Dart object; `toMap` = object → Map to save; `copyWith` = changed copy. **Every model is this same shape** — learn one, you know all six.
> 2. **The model fields** — be able to list each model's fields and point out the new ones (provider practice fields, review reply fields, user private fields). It's just field-copying, no logic.
> 3. **Deterministic IDs + rules** — `userId_providerId` = one review per pair; the rules enforce role, field set (`hasOnly`), and rating 1–5. The *Security & data protection* section is your script.
> 4. **Locate-don't-derive** — TC Kimlik checksum + SUS formula: open the file, say "official formula," don't memorize the math.

**Common teacher questions:**
- "What is `fromMap`?" → Converts raw Firestore data (a Map) into a typed Dart object
- "What is `toMap`?" → Converts a Dart object back into a Map to save to Firestore
- "What is `copyWith`?" → Returns a copy of the object with some fields changed (the original is never mutated)
- "What is `QuestionnaireModel.average`?" → A getter returning the plain mean of all four criteria: `(waitingTime + serviceQuality + hygiene + staffCommunication) / 4.0`. Used to **display** one review's combined sub-score. (Provider *ranking* uses a different, AHP-weighted formula in the Cloud Function — see the ranking note in *Security & data protection*.)
- "What new fields are on `ProviderModel`?" → `gender`, `hospital`, `department`, `room` (live values) plus `pendingHospital`/`pendingDepartment`/`pendingRoom` and `practiceChangeStatus` for changes awaiting admin approval. `hasPendingPracticeChange` is a getter that returns true when status is `'pending'`
- "What new fields are on `ReviewModel`?" → `providerReply` + `providerReplyAt`. They're read in `fromMap` but **not** written in `toMap` — the reply is set by a separate update so it can't break the strict create rule
- "What's stored on `UserModel` that's private?" → `tcKimlik` and `gender`. They live only on the user's own `users` doc; the public `providers` collection never stores TC Kimlik (KVKK / data-protection)
- "What is the `CommunityDoctorModel` ID built from?" → `buildId(name, hospital)` makes a slug, so the same off-app doctor groups into one record shared by all their reviews
- "What validates the T.C. Kimlik No?" → `TcKimlik.isValid()` — official 11-digit checksum (point at the file; no need to recompute the math)
- "What does `SusCalculator.calculate(responses)` do?" → Takes a list of 10 ratings (1–5) from the SUS questionnaire and returns a 0–100 usability score using the official SUS formula
- *(All rules questions — fake reviews, locked scores, admin-only fields — are in the Security & data protection section. That's your territory.)*

---

### Member 6 — Services & State / Providers (BACK)
**Your files:**
- [`lib/services/auth_service.dart`](lib/services/auth_service.dart) — Firebase Auth operations
- [`lib/services/firestore_service.dart`](lib/services/firestore_service.dart) — Firestore read/write operations (the big one)
- [`lib/services/ab_test_service.dart`](lib/services/ab_test_service.dart) — A/B variant assignment (pure Dart, no Firebase)
- [`lib/providers/auth_provider.dart`](lib/providers/auth_provider.dart) — auth state + bookmarks
- [`lib/providers/provider_provider.dart`](lib/providers/provider_provider.dart) — provider list state
- [`lib/providers/review_provider.dart`](lib/providers/review_provider.dart) — review submission state
- [`lib/providers/community_provider.dart`](lib/providers/community_provider.dart) — community list/search/submit state
- [`functions/src/aggregation.js`](functions/src/aggregation.js) — Cloud Function: AHP-weighted provider ranking (`calculateProviderStats`)
- [`functions/src/index.js`](functions/src/index.js) — Cloud Function entry/triggers
- [`lib/widgets/common/loading_indicator.dart`](lib/widgets/common/loading_indicator.dart) — shared spinner widget

> **Member 6 — 40-minute crash path** (your half is "how the app reads/writes + holds state"):
> 1. **`notifyListeners()` + `watch` vs `read`** — a provider holds state; `notifyListeners()` rebuilds widgets that used `context.watch`; `read` reads once without rebuilding.
> 2. **`ChangeNotifier`** — base class that lets a provider broadcast changes to listening widgets.
> 3. **One load flow** — `review_provider.dart` `loadReviews`: set loading → call `firestoreService.getReviews` → store → `notifyListeners()`. **This shape repeats in every provider.**
> 4. **The community transaction** — `submitCommunityReview` in `firestore_service.dart`: ONE atomic transaction that creates-or-increments the doctor doc + writes the review, so two patients can't double-count.
> 5. **Pending vs live** — `requestPracticeChange` writes `pending*`; `approvePracticeChange` (admin) copies pending→live, `rejectPracticeChange` discards.
> 6. **A/B** — `assignVariant(userId)` hashes the ID (deterministic, not `Random()`).
>
> Rehearse out loud 3 end-to-end flows (review submit, community submit, practice change) using the diagrams in *How data flows*. That's the only "walk me through it" risk — and it's your job, since you own the services + providers.

**Common teacher questions:**
- "What does `notifyListeners()` do?" → Tells all widgets watching this provider to rebuild with updated data
- "What is the difference between `context.watch` and `context.read`?" → `watch` rebuilds the widget when data changes; `read` just reads once without subscribing
- "What does `ChangeNotifier` mean?" → Base class that lets a provider broadcast changes to listeners (the widgets)
- "Walk me through loading reviews" → Screen calls `reviewProvider.loadReviews(id)` → it sets loading + `notifyListeners()` → calls `firestoreService.getReviews(id)` → stores the list → `notifyListeners()` again so the screen rebuilds with data
- "What is `AbTestService.assignVariant(userId)`?" → Takes the logged-in user's ID, hashes it, and returns `AbVariant.control` or `AbVariant.treatment`. Same user always gets the same variant — no randomness each session
- "Why not use `Random()` for the A/B split?" → `Random()` gives a different result every call — the user would see different layouts each session. Hashing the userId is deterministic: same input, same output, every time
- "How is a community doctor's average kept correct?" → `submitCommunityReview` runs a Firestore **transaction**: creates the `community_doctors` doc on the first review or increments `totalReviews` + the rating/criteria sums with `FieldValue.increment`. Average = `ratingSum / totalReviews`. The review ID is `userId_communityDoctorId` so one patient = one review per doctor
- "Why a transaction and not a normal write?" → A transaction reads + writes atomically, so two patients reviewing at the same time can't both overwrite the count — the increments stack correctly
- "What does `requestPracticeChange` do?" → Writes the doctor's edits to the `pending*` fields + `practiceChangeStatus='pending'`. It never touches the live fields
- "What do `approvePracticeChange` / `rejectPracticeChange` do?" → Approve copies `pending*` onto the live fields and clears them; reject just clears the pending fields. Both are admin-only (enforced by M5's rules)
- "What happens if the Firestore write fails during signup?" → `auth_service.dart` deletes the just-created Auth account so there's no orphaned login with no user document
- "How does My Reviews load both kinds of review?" → `review_provider.dart` `loadUserReviews` calls `getUserReviews` (in-app) and `getUserCommunityReviews` (off-app) together with `Future.wait`, then exposes both lists for the screen to merge
- "How is the ranking score computed?" → In the Cloud Function `functions/src/aggregation.js` (`calculateProviderStats`), server-side. Each review's questionnaire is **AHP-weighted** (`staff 0.35 + hygiene 0.25 + service 0.25 + wait 0.15`); then `rankingScore = averageRating × 0.4 + avgQuestionnaireScore × 0.6`. The full formula + the weight rationale is the ranking note in *Security & data protection*. The app only displays the result — it can't write it (rules lock it)
- "Why is ranking in a Cloud Function and not the app?" → Trust. If the app computed/wrote the score, a tampered client could fake its own ranking. A server-side function the client can't touch keeps it honest
- "What is `LoadingIndicator`?" → A small shared widget (`loading_indicator.dart`) showing a spinner + optional message; reused by every screen while data loads

---

## Shared / generated / config files (no single member owns these)

If the teacher points at one of these, any member can give the one-line answer below — they're infrastructure, not a feature.

| File | What to say |
|------|-------------|
| `lib/firebase_options.dart` | Auto-generated by the FlutterFire CLI — Firebase project keys per platform. Nobody hand-edits or studies it. |
| `firebase.json` | Firebase config — which rules/indexes/functions files to deploy. |
| `firestore.indexes.json` | Composite query indexes (see the indexes Q in *Security*). |
| `google-services.json` | Android Firebase config (generated by Firebase console). |
| `pubspec.yaml` | Dependency + asset manifest — the packages the app uses. |
| `analysis_options.yaml` | Lint rules for `flutter analyze`. |
| `functions/test/aggregation.test.js` | JS unit test for the ranking Cloud Function (Node/Jest-style, separate from the Dart `flutter test` suite). |
| `ServiceAccountKey.json` | **Secret** — Firebase admin key. Must be gitignored, **never committed**. Used only by local seed/admin scripts. |

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

**Community review flow (off-app doctors):**
```
AddCommunityReviewScreen (name + hospital + ...)
      │
      ▼
CommunityProvider.submitReview(...)
      │
      ▼
FirestoreService.submitCommunityReview()   ← ONE transaction:
      │                                        • create or increment community_doctors
      ▼                                        • write community_reviews/{userId_doctorId}
community_doctors  +  community_reviews
```

**Practice-change approval flow (admin):**
```
Doctor Dashboard → "Request a change"
      │   writes pending* fields, status='pending'   (live fields untouched)
      ▼
providers/{uid}
      │
      ▼
Admin screen → Approve  → approvePracticeChange()  → pending copied to live, cleared
            → Reject   → rejectPracticeChange()   → pending discarded
```

---

## Security & data protection (any member may be asked)

The backend is locked down by **Firestore security rules** (`firestore.rules`) and **Storage rules** (`storage.rules`) — these run on Firebase's servers, so even a tampered app cannot bypass them.

**Common teacher questions:**
- "How do you stop a user editing someone else's account?" → `users/{userId}` rules only allow read/write when `request.auth.uid == userId`. Identity (`uid`, `email`, `role`) cannot be changed after sign-up — only `fullName`, `profilePhotoUrl`, `bookmarks`.
- "How do you stop a provider faking their own rating?" → On `providers`, the fields `averageRating`, `rankingScore`, `totalReviews` are **locked** — a provider editing their own profile is blocked from touching them. Only an admin can.
- "How do you stop a doctor lying about which hospital they're at?" → A provider is also blocked from writing the live `hospital`/`department`/`room` fields. Their edits go into the `pending*` fields, and only an **admin** can copy them across (the Admin screen). So a listing's hospital is always admin-verified.
- "How do you stop fake or duplicate reviews?" → Review document ID is forced to `userId_providerId`, so each patient can leave **one review per provider**. Only users with role `patient` can create a review, the `userId` must match the logged-in user, and ratings must be 1–5. Reviews can never be edited after submission — except the listing owner may set **only** `providerReply`/`providerReplyAt` (a reply, checked by `affectedKeys().hasOnly(...)`), nothing else.
- "What stops fake community (off-app) reviews?" → Same pattern: `community_reviews` ID is `userId_communityDoctorId` (one per patient per doctor), only `patient` role can create, `userId` must match, rating 1–5, valid questionnaire, and the field set is fixed with `hasOnly`. No edits allowed.
- "Who can become an admin?" → Nobody via signup — `isValidClientRole` allows only `patient`/`provider`. An admin's `role` is set manually in the Firebase console, and `isAdmin()` reads that role from the user's own doc.
- "Who can upload images?" → Only the owner, to their own `users/{uid}/profile/` path, images under 5 MB. Everything else in Storage is denied.
- "Where are the rules?" → `firestore.rules` and `storage.rules` in the project root. There is a final `match /{document=**} { allow read, write: if false; }` that denies anything not explicitly allowed.
- "What are the Firestore indexes for?" → `firestore.indexes.json` declares the composite indexes Firestore needs for the app's sorted/filtered queries: `providers` (type + rankingScore↓) for top-rated lists per type, `reviews` (providerId + createdAt↓) and (userId + createdAt↓) for a provider's reviews and "My Reviews", and `community_reviews` (communityDoctorId + createdAt↓) for one off-app doctor's reviews. Legacy indexes from the old template were removed.

**If asked "how is a provider's ranking calculated?"** → A trusted **Cloud Function** (`functions/src/aggregation.js`, `calculateProviderStats`) computes it server-side, then writes the read-only `rankingScore` / `averageRating` / `avgQuestionnaireScore` onto the provider doc. The client only displays them; security rules block the app from editing them.

The formula (matches Appendix B of the final report):
- **Questionnaire score per review** uses **AHP weights** (Analytic Hierarchy Process — weights from pairwise importance, sum to 1.0): `staffCommunication ×0.35 + hygiene ×0.25 + serviceQuality ×0.25 + waitingTime ×0.15`. (Staff communication weighted highest as the strongest driver of trust.)
- **`averageRating`** = mean of all `overallRating` stars.
- **`avgQuestionnaireScore`** = mean of the AHP questionnaire scores above.
- **`rankingScore`** = `averageRating × 0.4 + avgQuestionnaireScore × 0.6` — so the structured questionnaire counts more than the single star tap.

> Note: this AHP weighting is **only** for the server-side ranking. The in-app `QuestionnaireModel.average` getter is a plain unweighted mean used to *display* one review's sub-scores — don't confuse the two.

---

## Testing files (what they are, if teacher asks)

All tests live in `test/`. You never need to edit them — just know what each file tests.

| Test file | What it checks |
|-----------|---------------|
| `test/unit/questionnaire_model_test.dart` | `fromMap()` parsing, clamping 0–5, `average` getter |
| `test/unit/review_model_test.dart` | `fromMap()` safety: null fields, bad types, empty map |
| `test/unit/provider_model_test.dart` | `fromMap()`, `copyWith()`, `toMap()` round-trip |
| `test/unit/community_doctor_model_test.dart` | `buildId()` grouping (same name+hospital → same id), `averageRating` math, `fromMap()` safety |
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
| Bottom nav tabs (per role) | `lib/screens/main_wrapper.dart` → `screens` + `navItems` lists |
| Doctor avatar fallback icon/colour | `lib/widgets/common/provider_avatar.dart` |
| Community search fields | `lib/providers/community_provider.dart` → `filteredDoctors` |
| What admin can approve | `lib/screens/admin/admin_screen.dart` + `approvePracticeChange` in `firestore_service.dart` |
| Add a field to a model | edit the model's `fromMap`, `toMap`, `copyWith` (all three) + add the key to that collection's `hasOnly` list in `firestore.rules` |
