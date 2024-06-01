import 'dart:math';

import 'package:animation_tools_dart/animation_tools_dart.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

expectTolerance(double v1, double v2, {double tolerance = 0.0001}) {
  expect((v1 - v2).abs() < tolerance, true);
}

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

    test('BVH test 1', () {
      var string = """HIERARCHY
ROOT Hips
{
	OFFSET 0.000000 0.000000 0.000000
	CHANNELS 6 Xposition Yposition Zposition Xrotation Yrotation Zrotation
	JOINT Spine
	{
		OFFSET 0.000000 0.000000 1.000000
		CHANNELS 3 Xrotation Yrotation Zrotation
	}
}
MOTION
Frames: 2
Frame Time: 0.06666666666666
""";
      var numFrames = 2;
      var trans = [
        [0, 0, 0],
        [1, 2, 3]
      ];
      var rots = [
        [
          [-1, -2, -3],
          [4, 5, 6]
        ],
        [
          [7, 8, 9],
          [10, 11, 12]
        ],
      ];
      for (int i = 0; i < numFrames; i++) {
        string += trans[i].map((x) => x.toString()).join(" ");
        string +=
            " ${rots[i].expand((y) => y.map((v) => v.toString())).join(" ")}\n";
      }
      print(string);
      var animation = BVHParser.parse(string, rotationMode: RotationMode.XYZ);
      expect(animation.frameData.length, 2); // 2 frames

      var frame1 = animation.frameData.first;
      expect(frame1.length, 2); // 2 bones
      var spine = frame1.first;

      expect(spine.translation.x, 0.0);
      expect(spine.translation.y, 0.0);
      expect(spine.translation.z, 0.0);

      var rotX = Quaternion.axisAngle(Vector3(1, 0, 0), radians(-1));
      var rotY = Quaternion.axisAngle(Vector3(0, 1, 0), radians(-2));
      var rotZ = Quaternion.axisAngle(Vector3(0, 0, 1), radians(-3));
      var expected = rotX * rotY * rotZ;

      expected = expected.normalized();

      expect(spine.rotation.w, expected.w);
      expect(spine.rotation.x, expected.x);
      expect(spine.rotation.y, expected.y);
      expect(spine.rotation.z, expected.z);
    });

    ///
    /// For most renderers, world coordinates use +Y as up and -Z as forward (into the screen)
    /// BVH uses +Z is up and +Y is forward
    /// To convert from the latter to the former, we can use the following change-of-basis matrix:
    /// 1 0 0
    /// 0 0 1
    /// 0 -1 0
    /// (i.e. rotate the BVH system by -90 degrees around its X axis).
    /// 
    /// Alternatively, we can use the transpose to convert from the former to the latter:
    /// 1 0 0
    /// 0 0 -1
    /// 0 1 0
    /// (i.e. rotate the 'conventional' system by 90 degrees around its X axis).
    /// 
    /// Let's double check with:
    ///   M * bv_new = bv_old 
    /// (bv_old/bv_new are basis vectors in the 'first' and 'second' coordinate systems respectively)
    /// M is a change-of-basis matrix that converts between the two.
    /// 
    /// Here, BVH is the "new" coordinate system, "conventional" is the old.
    /// BVH X is the same as "conventional X"
    /// [ 1  0  0     [ 1         [ 1 
    ///   0  0  -1   *  0      =    0
    ///   0  1  0 ]     0 ]         0 ]
    /// 
    /// "Conventional -Z" becomes BVH Y   
    /// [ 1  0  0     [ 0         [ 0 
    ///   0  0  1   *   1      =    0
    ///   0 -1  0 ]     0 ]         -1 ]
    /// 
    /// "Conventional Y" becomes BVH Z
    /// [ 1  0  0     [ 0         [ 0 
    ///   0  0  1   *   0      =    1
    ///   0 -1  0 ]     1 ]         0 ]
    /// 
    /// Now let's check the other way - "conventional" is the new system, BVH is the old - 
    /// using the transpose of this matrix.
    ///
    /// "BVH X" is the same as "Conventional X":
    /// [ 1  0  0      [ 1         [ 1 
    ///   0  0  -1   *   0      =    0
    ///   0  1  0 ]      0 ]         0 ]
    /// 
    /// "BVH Z" becomes "Conventional Y":
    /// [ 1  0  0     [ 0         [ 0 
    ///   0  0  -1  *   1      =    0
    ///   0  1  0 ]     0 ]         1 ]
    /// 
    /// "BVH -Y" axis becomes "Conventional Z" 
    /// [ 1  0  0     [ 0         [ 0 
    ///   0  0 -1   *   0      =   -1
    ///   0  1  0 ]     1 ]         0 ]
    /// 
    /// This test checks that the rotations are adequately transformed when passing this change-of-basis matrix.
    test('Change of basis', () {
      var string = """HIERARCHY
ROOT Bone
{
	OFFSET 0.000000 0.000000 0.000000
  CHANNELS 6 Xposition Yposition Zposition Xrotation Yrotation Zrotation
	End Site 
  {
      OFFSET 1.000000 0.000000 0.000000
	}
}
MOTION
Frames: 1
Frame Time: 0.06666666666666
0.000000 0.000000 0.000000 0.000000 90.000000 0.000000
""";
      var basis = Matrix3.rotationX(-pi / 2);
      // the BVH string contains a single frame, specifying a 90 degree rotation around BVH Y axis
      // we want to check that this becomes a 90 degree rotation around our "new" -Z axis
      var expectedRotation = Quaternion.axisAngle(Vector3(0, 0, -1), pi / 2);
      var animation =
          BVHParser.parse(string, rotationMode: RotationMode.XYZ, basis: basis);
      expectTolerance(
          animation.frameData.first.first.rotation.w, expectedRotation.w);
      expectTolerance(
          animation.frameData.first.first.rotation.x, expectedRotation.x);
      expectTolerance(
          animation.frameData.first.first.rotation.y, expectedRotation.y);
      expectTolerance(
          animation.frameData.first.first.rotation.z, expectedRotation.z);
    });
  });
}
