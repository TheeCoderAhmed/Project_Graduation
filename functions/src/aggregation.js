function asNumber(value) {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function round2(value) {
  return Number(value.toFixed(2));
}

// AHP-inspired weights derived from pairwise comparison of how strongly each
// criterion shapes the patient experience. Weights sum to 1.0 — see
// Appendix B of the final report and the worked example there.
//
//   Staff Communication : 0.35  — strongest driver of trust & satisfaction
//   Hygiene             : 0.25  — clinical-grade environment expectations
//   Service Quality     : 0.25  — professionalism & competence of care
//   Waiting Time        : 0.15  — important but secondary to the above
//
// Changing these weights changes provider rankings, so any adjustment must
// be coordinated with the report's Appendix B example.
const AHP_WEIGHTS = {
  staffCommunication: 0.35,
  hygiene:            0.25,
  serviceQuality:     0.25,
  waitingTime:        0.15,
};

function questionnaireScore(review) {
  const q = review.questionnaire || {};
  return (
    asNumber(q.staffCommunication) * AHP_WEIGHTS.staffCommunication +
    asNumber(q.hygiene)             * AHP_WEIGHTS.hygiene +
    asNumber(q.serviceQuality)      * AHP_WEIGHTS.serviceQuality +
    asNumber(q.waitingTime)         * AHP_WEIGHTS.waitingTime
  );
}

function calculateProviderStats(reviews) {
  if (reviews.length === 0) {
    return {
      totalReviews: 0,
      averageRating: 0,
      avgQuestionnaireScore: 0,
      rankingScore: 0,
    };
  }

  const totalReviews = reviews.length;
  const totalOverall = reviews.reduce(
    (sum, review) => sum + asNumber(review.overallRating),
    0,
  );
  const totalQuestionnaire = reviews.reduce(
    (sum, review) => sum + questionnaireScore(review),
    0,
  );

  const averageRating = totalOverall / totalReviews;
  const avgQuestionnaireScore = totalQuestionnaire / totalReviews;
  const rankingScore = (averageRating * 0.4) + (avgQuestionnaireScore * 0.6);

  return {
    totalReviews,
    averageRating: round2(averageRating),
    avgQuestionnaireScore: round2(avgQuestionnaireScore),
    rankingScore: round2(rankingScore),
  };
}

module.exports = { calculateProviderStats };
