from app.services.recognition.decision import decide_match


def test_allows_score_above_threshold():
    decision = decide_match(0.82, 0.45)
    assert decision.matched is True
    assert decision.decision == "ALLOW"


def test_reviews_near_miss_score():
    decision = decide_match(0.41, 0.45)
    assert decision.matched is False
    assert decision.decision == "REVIEW"


def test_denies_missing_score():
    decision = decide_match(None, 0.45)
    assert decision.matched is False
    assert decision.failure_reason == "LOW_SCORE"

