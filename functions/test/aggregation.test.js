const assert = require("node:assert/strict");
const test = require("node:test");

const { calculateProviderStats } = require("../src/aggregation");

test("calculateProviderStats averages overall and questionnaire scores", () => {
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
    avgQuestionnaireScore: 3.75,
    rankingScore: 3.85,
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
