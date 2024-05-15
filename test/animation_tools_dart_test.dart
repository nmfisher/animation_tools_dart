import 'package:animation_tools_dart/animation_tools_dart.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('MorphAnimationData test', () {
      var morphTargets = ["target1", "target2", "target3"];
      var numFrames = 60;
      var frameData = List.generate(
          numFrames,
          (frameNum) => [
                (1 + frameNum) / numFrames,
                ((1 + frameNum) / numFrames) * 2,
                ((1 + frameNum) / numFrames) * 3
              ]);

      var animationData = MorphAnimationData(frameData, morphTargets);
      assert(animationData.numFrames == 60);
      var copy = animationData.subset(["target2"]);
      assert(copy.numFrames == 60);
      assert(copy.data[0].length == 1);
      print(copy.data[59][0]);
      assert((copy.data[59][0] - 2.0).abs() < 0.0001);
      var extracted =
          animationData.extract(morphTargets: ["target2", "target3"]);
      assert(extracted.length == numFrames * 2);
      assert((extracted.last - 3.0).abs() < 0.00001);
    });
  });
}
