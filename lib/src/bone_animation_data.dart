import 'package:vector_math/vector_math_64.dart';

typedef BoneAnimationFrame = ({Quaternion rotation, Vector3 translation});

///
/// Bone space is the coordinate system anchored at the root of a bone
/// in its rest position, with Y pointing "up" (i.e. towards the "tail" of
/// the bone. This is used as the default for constructing an instance of 
/// BoneAnimationData (i.e. "rotation around X" means "rotate this bone
/// around its local X axis in its rest position").
/// ParentWorldRotation is an oddity; this is a rotation
/// around the origin of the bone's parent, but around world-space defined axes. 
/// (i.e. translate the point in parent space to the origin, rotate, then translate back).
/// This accounts for BVH which describes each bone's rotation in world-space axes, but 
/// around its parents origin.
///
enum Space { World, Model, Bone, ParentWorldRotation }

///
/// Represents a skeletal animation, namely:
/// - a list of bone ("joints") names that will be animated
/// - frame data, where each frame contains a quaternion rotation and a vector translation
///
class BoneAnimationData {
  final List<String> bones;
  final List<List<BoneAnimationFrame>> frameData;
  double frameLengthInMs;
  final Space space;
  BoneAnimationData(this.bones, this.frameData,
      {this.frameLengthInMs = 1000.0 / 60.0, this.space = Space.Bone});

  int get numFrames => frameData.length;

  BoneAnimationData frame(int frame) {
    return BoneAnimationData(bones, [frameData[frame]],
        frameLengthInMs: frameLengthInMs, space: space);
  }
}
