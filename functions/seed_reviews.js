/**
 * One-off seeder: creates (or updates) a doctor listing for a given account
 * and writes 10 varied reviews so the rating breakdown has data to show.
 *
 * Run (from the functions/ folder), with a service-account key:
 *
 *   GOOGLE_APPLICATION_CREDENTIALS=../serviceAccountKey.json \
 *   node seed_reviews.js
 *
 * Get the key: Firebase Console → Project settings → Service accounts →
 * Generate new private key. Save it as serviceAccountKey.json in the repo
 * root (already gitignored — never commit it).
 *
 * Admin SDK bypasses security rules, so this works regardless of the
 * patient-only review rules.
 */
const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: "drapo7",
});

const db = admin.firestore();
const auth = admin.auth();

const TARGET_EMAIL = "ahm3dbusinesss@gmail.com";

// 10 reviews with deliberately varied sub-scores so each breakdown bar differs.
const REVIEWS = [
  { name: "Elif Yılmaz",    overall: 5, wait: 5, service: 5, hygiene: 5, staff: 5, comment: "Excellent care, explained everything clearly." },
  { name: "Mehmet Demir",   overall: 4, wait: 3, service: 4, hygiene: 5, staff: 4, comment: "Good doctor, but the wait was a bit long." },
  { name: "Ayşe Kaya",      overall: 5, wait: 4, service: 5, hygiene: 5, staff: 5, comment: "Very professional and kind. Highly recommend." },
  { name: "Can Öztürk",     overall: 3, wait: 2, service: 3, hygiene: 4, staff: 3, comment: "Average experience, waiting room was crowded." },
  { name: "Zeynep Şahin",   overall: 5, wait: 5, service: 5, hygiene: 4, staff: 5, comment: "Quick appointment and great communication." },
  { name: "Burak Aydın",    overall: 4, wait: 4, service: 4, hygiene: 4, staff: 3, comment: "Solid visit. Staff could be friendlier." },
  { name: "Fatma Çelik",    overall: 5, wait: 4, service: 5, hygiene: 5, staff: 5, comment: "Felt very well cared for. Thank you doctor." },
  { name: "Emre Arslan",    overall: 2, wait: 1, service: 2, hygiene: 3, staff: 2, comment: "Long wait and felt rushed during the visit." },
  { name: "Selin Doğan",    overall: 4, wait: 3, service: 4, hygiene: 5, staff: 4, comment: "Clean clinic and helpful explanations." },
  { name: "Ahmet Koç",      overall: 5, wait: 5, service: 4, hygiene: 5, staff: 5, comment: "Best experience I've had. On time and thorough." },
];

async function main() {
  // 1. Resolve the provider account UID from its email.
  const user = await auth.getUserByEmail(TARGET_EMAIL);
  const uid = user.uid;
  const providerId = uid; // claim-at-signup keys listings by UID
  console.log(`Target account: ${TARGET_EMAIL} → uid ${uid}`);

  // 2. Upsert the doctor listing (so it exists even if not created at signup).
  await db.collection("providers").doc(providerId).set(
    {
      category: "doctor",
      type: "doctor",
      name: "Dr. Ahmed Haidar",
      specialty: "General Practitioner",
      address: "Çankaya, Ankara",
      phone: "+90 312 000 0000",
      hospital: "DRAPO Medical Center",
      gender: "male",
      ownerId: uid,
    },
    { merge: true },
  );
  console.log("Provider listing upserted.");

  // 3. Write 10 reviews with deterministic IDs.
  const batch = db.batch();
  let sumOverall = 0;
  let sumQ = 0;
  REVIEWS.forEach((r, i) => {
    const reviewUserId = `seed_patient_${i + 1}`;
    const reviewId = `${reviewUserId}_${providerId}`;
    const q = {
      waitingTime: r.wait,
      serviceQuality: r.service,
      hygiene: r.hygiene,
      staffCommunication: r.staff,
    };
    sumOverall += r.overall;
    sumQ += (r.wait + r.service + r.hygiene + r.staff) / 4;
    batch.set(db.collection("reviews").doc(reviewId), {
      providerId,
      userId: reviewUserId,
      userName: r.name,
      overallRating: r.overall,
      comment: r.comment,
      questionnaire: q,
      isVerified: i % 3 !== 0, // mix of verified / unverified
      // Spread dates over the last ~10 weeks.
      createdAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() - i * 7 * 24 * 60 * 60 * 1000),
      ),
    });
  });

  // 4. Pre-compute provider stats too, so the app shows them even if the
  //    aggregation Cloud Function is not deployed.
  const n = REVIEWS.length;
  const avgOverall = +(sumOverall / n).toFixed(2);
  const avgQ = +(sumQ / n).toFixed(2);
  const rankingScore = +(avgOverall * 0.4 + avgQ * 0.6).toFixed(2);
  batch.set(
    db.collection("providers").doc(providerId),
    {
      averageRating: avgOverall,
      avgQuestionnaireScore: avgQ,
      rankingScore,
      totalReviews: n,
    },
    { merge: true },
  );

  await batch.commit();
  console.log(`Seeded ${n} reviews. avgRating=${avgOverall} ranking=${rankingScore}`);
  console.log("Done.");
}

main().catch((e) => {
  console.error("Seed failed:", e);
  process.exit(1);
});
