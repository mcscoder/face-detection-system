from enum import Enum

from app.services.recognition.types import ExtractedFace

FORWARD_MAX_YAW = 10.0
FORWARD_MAX_PITCH = 12.0
DIRECTIONAL_MIN_YAW = 18.0
LOOK_MIN_PITCH = 12.0
LOOK_MAX_YAW = 20.0


class EnrollmentPromptPose(str, Enum):
    FACE_FORWARD = "face_forward"
    TURN_LEFT = "turn_left"
    TURN_RIGHT = "turn_right"
    LOOK_UP_DOWN = "look_up_down"
    NATURAL = "natural"


def validate_prompt_pose(face: ExtractedFace, expected_pose: str | None) -> None:
    if expected_pose is None or expected_pose == "":
        raise ValueError("INVALID_PROMPT")
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
        accepted = (
            abs(pose.yaw) <= FORWARD_MAX_YAW
            and abs(pose.pitch) <= FORWARD_MAX_PITCH
        )
    elif prompt == EnrollmentPromptPose.TURN_LEFT:
        accepted = pose.yaw <= -DIRECTIONAL_MIN_YAW
    elif prompt == EnrollmentPromptPose.TURN_RIGHT:
        accepted = pose.yaw >= DIRECTIONAL_MIN_YAW
    else:
        accepted = (
            abs(pose.pitch) >= LOOK_MIN_PITCH
            and abs(pose.yaw) <= LOOK_MAX_YAW
        )

    if not accepted:
        raise ValueError("WRONG_POSE")
