const admin = require("firebase-admin");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");

const { calculateProviderStats } = require("./aggregation");

admin.initializeApp();

exports.recalculateProviderStats = onDocumentWritten(
  "reviews/{reviewId}",
  async (event) => {
    const before = event.data && event.data.before.exists
      ? event.data.before.data()
      : null;
    const after = event.data && event.data.after.exists
      ? event.data.after.data()
      : null;
    const providerId = (after && after.providerId) || (before && before.providerId);

    if (!providerId) {
      logger.warn("Review write had no providerId", { reviewId: event.params.reviewId });
      return;
    }

    const snapshot = await admin.firestore()
      .collection("reviews")
      .where("providerId", "==", providerId)
      .get();
    const reviews = snapshot.docs.map((doc) => doc.data());
    const stats = calculateProviderStats(reviews);

    await admin.firestore().collection("providers").doc(providerId).set(
      stats,
      { merge: true },
    );
  },
);
