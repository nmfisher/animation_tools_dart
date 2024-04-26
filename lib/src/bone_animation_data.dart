import 'package:vector_math/vector_math_64.dart';

///
/// Model class for bone animation frame data.
///
class BoneAnimationData {
  final List<String> bones;
  final List<String> meshNames;
  final List<List<Quaternion>> rotationFrameData;
  final List<List<Vector3>> translationFrameData;
  double frameLengthInMs;
  final bool isModelSpace;
  BoneAnimationData(this.bones, this.meshNames, this.rotationFrameData,
      this.translationFrameData, this.frameLengthInMs,
      {this.isModelSpace = false});

  int get numFrames => rotationFrameData.length;

  BoneAnimationData frame(int frame) {
    return BoneAnimationData(bones, meshNames, [rotationFrameData[frame]],
        [translationFrameData[frame]], frameLengthInMs,
        isModelSpace: isModelSpace);
  }
}
