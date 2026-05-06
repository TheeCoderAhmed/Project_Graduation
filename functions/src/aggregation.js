function asNumber(value) {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function round2(value) {
  return Number(value.toFixed(2));
}

function questionnaireScore(review) {
  const questionnaire = review.questionnaire || {};
  return (
    asNumber(questionnaire.waitingTime) +
    asNumber(questionnaire.serviceQuality) +
    asNumber(questionnaire.hygiene) +
    asNumber(questionnaire.staffCommunication)
  ) / 4;
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
