from enum import Enum

from app.services.recognition.types import ExtractedFace


class EnrollmentPromptPose(str, Enum):
    FACE_FORWARD = "face_forward"
    TURN_LEFT = "turn_left"
    TURN_RIGHT = "turn_right"
    LOOK_UP_DOWN = "look_up_down"
    NATURAL = "natural"


def validate_prompt_pose(face: ExtractedFace, expected_pose: str | None) -> None:
    if expected_pose is None or expected_pose == "":
        return
    try:
        prompt = EnrollmentPromptPose(expected_pose)
    except ValueError:
        raise ValueError("INVALID_PROMPT") from None

    if prompt == EnrollmentPromptPose.NATURAL:
        return
    pose = face.pose
    if pose is None:
        raise ValueError("WRONG_POSE")

    if prompt == EnrollmentPromptPose.FACE_FORWARD:
        accepted = abs(pose.yaw) <= 18 and abs(pose.pitch) <= 18
    elif prompt == EnrollmentPromptPose.TURN_LEFT:
        accepted = pose.yaw <= -12
    elif prompt == EnrollmentPromptPose.TURN_RIGHT:
        accepted = pose.yaw >= 12
    else:
        accepted = abs(pose.pitch) >= 10 and abs(pose.yaw) <= 28

    if not accepted:
        raise ValueError("WRONG_POSE")
