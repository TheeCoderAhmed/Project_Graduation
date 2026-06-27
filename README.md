# DRAPO — Patient-Centric Healthcare Review Platform

**DRAPO** (Doctor & Pharmacy Reviews and Opinions) is a mobile application that empowers patients in Turkey to evaluate healthcare providers — doctors and pharmacies — through structured post-visit questionnaires, and surfaces ranked results using an AHP-weighted scoring model.

Built as a final-year software engineering project.

---

## Problem Statement

Patients in Turkey have limited access to trustworthy, structured feedback about healthcare providers. Existing platforms either lack domain-specific criteria (e.g., hygiene, waiting time, staff communication) or don't support community-contributed provider listings. DRAPO addresses this gap with a role-aware review system and a transparent, mathematically grounded ranking algorithm.

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Structured Questionnaire Reviews** | Post-visit reviews scored across four clinical-quality criteria using a 5-point Likert scale |
| **AHP-Weighted Ranking** | Provider scores computed server-side with Analytic Hierarchy Process-inspired weights |
| **Dual Provider Types** | Supports both registered doctors (via national ID) and pharmacies |
| **Community Listings** | Patients can add off-app doctors not in the system — and review them too |
| **Role-Based Access** | Three roles: Patient, Provider, Admin — each with scoped permissions |
| **A/B Testing** | Integrated `AbTestService` to experiment with UI variants |
| **Identity Verification** | Turkish national ID (TC Kimlik) validation to prevent fake accounts |
| **Usability Tested** | SUS evaluation with 6 participants; mean score 78.75/100 (above industry average of 68) |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Mobile Frontend** | Flutter 3.19+ / Dart 3.3+ |
| **State Management** | `provider` package (ChangeNotifier pattern) |
| **Authentication** | Firebase Authentication (email/password) |
| **Database** | Cloud Firestore (NoSQL, real-time) |
| **Backend Logic** | Firebase Cloud Functions v2 (Node.js) |
| **Storage** | Firebase Cloud Storage |
| **Testing** | `flutter_test` (155 Dart tests) + `node:test` (2 server-side tests) |

---

## System Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Flutter Mobile App                  │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐ │
│  │  Screens │→ │Providers │→ │    Services         │ │
│  │ (UI/UX)  │  │ (State)  │  │ Firestore / Auth /  │ │
│  └──────────┘  └──────────┘  │ AbTest / Storage    │ │
│                               └────────────────────┘ │
└────────────────────────┬────────────────────────────┘
                         │ Firestore SDK
                         ▼
┌─────────────────────────────────────────────────────┐
│                  Firebase Backend                    │
│  ┌────────────┐  ┌───────────┐  ┌───────────────┐  │
│  │ Firestore  │  │   Auth    │  │ Cloud Fns v2  │  │
│  │ (5 colls)  │  │(TC+Email) │  │ (AHP scoring) │  │
│  └────────────┘  └───────────┘  └───────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

## Ranking Model

Provider scores are recomputed automatically by a Cloud Function (`recalculateProviderStats`) every time a review is written. The composite score formula:

```
rankingScore = 0.4 × averageOverallRating + 0.6 × weightedQuestionnaireScore
```

AHP-derived weights for the four service-quality dimensions:

| Criterion           | Weight | Rationale |
|---------------------|-------:|-----------|
| Staff Communication |  0.35  | Highest impact on patient trust |
| Hygiene             |  0.25  | Critical safety factor |
| Service Quality     |  0.25  | Core service delivery |
| Waiting Time        |  0.15  | Important but least critical |

Weights were derived through pairwise comparison matrices following the AHP methodology. See `functions/src/aggregation.js` for the implementation.

---

## Repository Layout

```
DRAPO/
├── lib/                        # Flutter app source (~8,500 lines of Dart)
│   ├── models/                 # Immutable value classes (ProviderModel, ReviewModel, ...)
│   ├── providers/              # ChangeNotifier state holders
│   ├── services/               # FirestoreService, AuthService, AbTestService
│   ├── screens/                # Feature-organized UI screens
│   │   ├── auth/               # Login, register, TC verification
│   │   ├── home/               # Feed and provider listings
│   │   ├── search/             # Provider search
│   │   ├── provider_profile/   # Provider detail + reviews
│   │   ├── questionnaire/      # Review submission flow
│   │   ├── community/          # Community-added provider listings
│   │   ├── user_profile/       # Patient profile management
│   │   ├── provider_dashboard/ # Provider's own analytics view
│   │   ├── notifications/      # In-app notifications
│   │   ├── settings/           # App settings
│   │   ├── admin/              # Admin control panel
│   │   └── onboarding/         # First-launch onboarding
│   ├── widgets/                # Reusable UI components
│   └── utils/                  # SusCalculator, TcKimlik validator
├── functions/                  # Firebase Cloud Functions (Node.js v2)
│   └── src/
│       ├── index.js            # onDocumentWritten trigger on reviews/{reviewId}
│       └── aggregation.js      # AHP-weighted ranking calculation
├── test/                       # Flutter tests (unit + widget + A/B)
├── functions/test/             # Node.js tests for aggregation logic
├── firestore.rules             # Server-side security & validation rules
├── firestore.indexes.json      # Composite indexes (providers, reviews, community_reviews)
└── storage.rules               # Cloud Storage rules
```

---

## Firestore Data Model

| Collection | Description | Read | Write |
|------------|-------------|------|-------|
| `users/{userId}` | Patient / provider / admin profiles | self + admin | self (limited fields) / admin |
| `providers/{providerId}` | Doctor & pharmacy listings with rolled-up stats | public | admin or provider (own record) |
| `reviews/{userId_providerId}` | Post-visit structured reviews | public | patient only, immutable |
| `community_doctors/{doctorId}` | Off-app, patient-built doctor listings | public | patient |
| `community_reviews/{userId_doctorId}` | Reviews of community-added doctors | public | patient only, immutable |

Review documents use a composite key `{userId}_{providerId}` — the Firestore security rules enforce "one review per patient per provider" without any application-layer logic.

---

## Testing Summary

| Type | Count | Coverage |
|------|-------|----------|
| Unit tests (Dart) | 120 | Models, services, utils |
| Widget tests (Dart) | 33 | Key UI components |
| A/B variant tests (Dart) | 2 | AbTestService logic |
| Server-side tests (Node.js) | 2 | Aggregation & AHP scoring |
| **Total** | **157** | ~92% effective coverage |

Full test report: [`TEST_REPORT.md`](TEST_REPORT.md)

---

## Usability Evaluation

**Method:** System Usability Scale (SUS) + Structured Task Observation  
**Participants:** 6 (ages 22–45, mixed tech literacy)  
**Mean SUS Score:** 78.75 / 100 *(industry average: 68)*

Full report: [`USABILITY_TEST.md`](USABILITY_TEST.md)

---

## Documentation Index

| File | Contents |
|------|----------|
| [`TEST_REPORT.md`](TEST_REPORT.md) | Full automated testing report |
| [`USABILITY_TEST.md`](USABILITY_TEST.md) | SUS usability evaluation with 6 participants |
| [`DESIGN.md`](DESIGN.md) | Design tokens — palette, typography |
| [`PRODUCT.md`](PRODUCT.md) | Product brief and feature rationale |
