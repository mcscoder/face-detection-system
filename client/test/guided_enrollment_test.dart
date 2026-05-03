import 'package:face_detection_client/models/guided_enrollment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guided enrollment prompts keep the expected order', () {
    expect(
      guidedEnrollmentPrompts.map((prompt) => prompt.title),
      [
        'Face forward',
        'Turn left',
        'Turn right',
        'Look up or down',
        'Natural look',
      ],
    );
  });

  test('guided enrollment progress advances and completes', () {
    var progress = const GuidedEnrollmentProgress();

    expect(progress.currentPrompt.title, 'Face forward');
    progress = progress.acceptSample();
    expect(progress.currentPrompt.title, 'Turn left');
    progress = progress.acceptSample();
    progress = progress.acceptSample();
    progress = progress.acceptSample();
    progress = progress.acceptSample();

    expect(progress.acceptedSamples, 5);
    expect(progress.remainingRequired, 0);
    expect(progress.isComplete, isTrue);
  });
}
