import 'package:flutter_test/flutter_test.dart';

// TEMPORARY PROBE — verifies the aura-checks CI job fails on test failure.
// Must never be merged. Will be removed immediately after the probe run.
void main() {
  test('failure probe: this test is expected to fail', () {
    expect(1, 2, reason: 'deliberate probe failure');
  });
}
