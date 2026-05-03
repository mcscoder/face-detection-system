class EnrollmentPrompt {
  const EnrollmentPrompt({
    required this.title,
    required this.instruction,
    required this.poseCode,
  });

  final String title;
  final String instruction;
  final String poseCode;
}

const guidedEnrollmentPrompts = [
  EnrollmentPrompt(
    title: 'Face forward',
    instruction: 'Center your face in the guide.',
    poseCode: 'face_forward',
  ),
  EnrollmentPrompt(
    title: 'Turn left',
    instruction: 'Turn your head slightly left.',
    poseCode: 'turn_left',
  ),
  EnrollmentPrompt(
    title: 'Turn right',
    instruction: 'Turn your head slightly right.',
    poseCode: 'turn_right',
  ),
  EnrollmentPrompt(
    title: 'Look up or down',
    instruction: 'Move your chin slightly up or down.',
    poseCode: 'look_up_down',
  ),
  EnrollmentPrompt(
    title: 'Natural look',
    instruction: 'Use your current everyday look.',
    poseCode: 'natural',
  ),
];

class GuidedEnrollmentProgress {
  const GuidedEnrollmentProgress({
    this.acceptedSamples = 0,
    this.promptIndex = 0,
  });

  final int acceptedSamples;
  final int promptIndex;

  int get totalSamples => guidedEnrollmentPrompts.length;
  int get remainingRequired {
    final remaining = totalSamples - acceptedSamples;
    if (remaining < 0) return 0;
    if (remaining > totalSamples) return totalSamples;
    return remaining;
  }

  bool get isComplete => acceptedSamples >= totalSamples;
  double get value => acceptedSamples / totalSamples;

  EnrollmentPrompt get currentPrompt {
    final index = promptIndex < 0
        ? 0
        : promptIndex >= totalSamples
            ? totalSamples - 1
            : promptIndex;
    return guidedEnrollmentPrompts[index];
  }

  GuidedEnrollmentProgress acceptSample() {
    final nextAccepted =
        acceptedSamples >= totalSamples ? totalSamples : acceptedSamples + 1;
    return GuidedEnrollmentProgress(
      acceptedSamples: nextAccepted,
      promptIndex:
          nextAccepted >= totalSamples ? totalSamples - 1 : nextAccepted,
    );
  }

  GuidedEnrollmentProgress reset() {
    return const GuidedEnrollmentProgress();
  }
}
