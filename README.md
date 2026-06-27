# DRAPO — Patient-Centric Healthcare Review Platform

A Flutter + Firebase mobile application that lets patients evaluate healthcare
providers (doctors and pharmacies) through structured post-visit
questionnaires and produces AHP-inspired weighted rankings.

## Tech stack

- **Frontend:** Flutter 3.19+ / Dart 3.3+ with the `provider` package for state management
- **Backend:** Firebase Authentication, Firestore (NoSQL), Cloud Functions v2 (Node.js)
- **Tests:** `flutter_test` (155 Dart tests across unit + widget + A/B) and `node:test` (2 server-side aggregation tests)


## Repository layout

```
DRAPO/
├── lib/                     # Flutter app source (~8 500 lines of Dart)
│   ├── models/              # Plain Dart value classes (ProviderModel, ReviewModel, ...)
│   ├── providers/           # ChangeNotifier state holders
│   ├── services/            # FirestoreService, AuthService, AbTestService
│   ├── screens/             # One folder per feature area
│   ├── widgets/             # Reusable UI components
│   └── utils/               # SusCalculator, TcKimlik validator
├── functions/               # Firebase Cloud Functions (Node.js v2)
│   └── src/
│       ├── index.js         # onDocumentWritten trigger on reviews/{reviewId}
│       └── aggregation.js   # AHP-weighted ranking calculation
├── test/                    # Flutter tests (unit + widget + A/B)
├── functions/test/          # Node.js tests for the aggregation function
├── firestore.rules          # Server-side security & validation rules
├── firestore.indexes.json   # Composite indexes (providers, reviews, community_reviews)
└── storage.rules            # Cloud Storage rules
```

## Firestore collections

| Collection                             | Description                              | Read       | Write                            |
| -------------------------------------- | ---------------------------------------- | ---------- | -------------------------------- |
| `users/{userId}`                       | Patient / provider / admin profiles       | self+admin | self (limited fields) / admin    |
| `providers/{providerId}`               | Doctor & pharmacy listings, rolled-up stats | public  | admin or claim-by-uid for providers |
| `reviews/{userId_providerId}`          | Post-visit reviews (1 per user/provider)  | public     | patient only, immutable           |
| `community_doctors/{doctorId}`         | Off-app, patient-built doctor listings    | public     | patient                          |
| `community_reviews/{userId_doctorId}`  | Reviews of off-app doctors                | public     | patient only, immutable           |

Review documents are keyed deterministically by `request.auth.uid + '_' + providerId`
so the security rules can enforce "one review per patient per provider" automatically.

## Ranking model

Provider scores are recomputed server-side by the `recalculateProviderStats`
Cloud Function whenever a review document is written. The composite score is

```
rankingScore = 0.4 * averageOverallRating + 0.6 * weightedQuestionnaireScore
```

with AHP-inspired weights on the four service-quality criteria:

| Criterion           | Weight |
| ------------------- | -----: |
| Staff Communication |   0.35 |
| Hygiene             |   0.25 |
| Service Quality     |   0.25 |
| Waiting Time        |   0.15 |

See `functions/src/aggregation.js` and Appendix B of the final report.

## Documentation

- `TEST_REPORT.md`  — full testing report (154 automated Dart tests, ~92% effective coverage)
- `USABILITY_TEST.md` — SUS evaluation with 6 participants (mean score 78.75)
- `DESIGN.md`      — design tokens (palette, typography)
- `PRODUCT.md`     — product brief
- `STUDY_GUIDE.md` — architectural deep-dive for new contributors
