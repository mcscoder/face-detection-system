from dataclasses import dataclass


@dataclass(frozen=True)
class MatchDecision:
    matched: bool
    decision: str
    failure_reason: str | None


def decide_match(similarity_score: float | None, threshold: float) -> MatchDecision:
    if similarity_score is None:
        return MatchDecision(False, "DENY", "LOW_SCORE")
    if similarity_score >= threshold:
        return MatchDecision(True, "ALLOW", None)
    if similarity_score >= threshold * 0.9:
        return MatchDecision(False, "REVIEW", "LOW_SCORE")
    return MatchDecision(False, "DENY", "LOW_SCORE")

