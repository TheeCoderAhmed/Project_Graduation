const assert = require("node:assert/strict");
const test = require("node:test");

const { calculateProviderStats } = require("../src/aggregation");

test("calculateProviderStats applies AHP weights to the questionnaire", () => {
  // Review 1: q-score = 4*0.35 + 5*0.25 + 4*0.25 + 5*0.15 = 4.40
  // Review 2: q-score = 2*0.35 + 4*0.25 + 3*0.25 + 3*0.15 = 2.90
  // avgQuestionnaire = (4.40 + 2.90) / 2                   = 3.65
  // averageRating    = (5 + 3) / 2                          = 4.00
  // rankingScore     = 4.00 * 0.4 + 3.65 * 0.6              = 3.79
  const stats = calculateProviderStats([
    {
      overallRating: 5,
      questionnaire: {
        waitingTime: 5,
        serviceQuality: 4,
        hygiene: 5,
        staffCommunication: 4,
      },
    },
    {
      overallRating: 3,
      questionnaire: {
        waitingTime: 3,
        serviceQuality: 3,
        hygiene: 4,
        staffCommunication: 2,
      },
    },
  ]);

  assert.deepEqual(stats, {
    totalReviews: 2,
    averageRating: 4,
    avgQuestionnaireScore: 3.65,
    rankingScore: 3.79,
  });
});

test("calculateProviderStats resets trusted scores when no reviews remain", () => {
  assert.deepEqual(calculateProviderStats([]), {
    totalReviews: 0,
    averageRating: 0,
    avgQuestionnaireScore: 0,
    rankingScore: 0,
  });
});
