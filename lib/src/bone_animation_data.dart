import 'package:vector_math/vector_math_64.dart';

///
/// Model class for bone animation frame data.
/// To create dynamic/runtime bone animations (as distinct from animations embedded in a glTF asset), create an instance containing the relevant
/// data and pass to the [setBoneAnimation] method on a [FilamentController].
/// [frameData] is laid out as [locX, locY, locZ, rotW, rotX, rotY, rotZ]
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
