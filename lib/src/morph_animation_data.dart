import 'dart:typed_data';

///
/// A generic interface for storing/retrieving morph target animation (aka "blendshape") frame data.
/// [morphTargets] contains the names of each morph target/blendshape.
/// Each value in [data] represents one frame.
/// Each frame consists of N weights (usually between 0.0 and 1.0), representing the weight
/// of the morph target/blendshape at the same index in [morphTargets].
///
class MorphAnimationData {
  final List<String> morphTargets;
  final Float32List data;
  final double frameLengthInMs;

  MorphAnimationData(this.data, this.morphTargets,
      {this.frameLengthInMs = 1000 / 60}) {
    assert(morphTargets.isNotEmpty);
    assert(numFrames > 0);
  }

  int get numMorphTargets => morphTargets.length;

  int get numFrames => data.length ~/ numMorphTargets;

  int get durationInMs => (numFrames * frameLengthInMs).toInt();

  List<int> _getMorphTargetIndices(List<String> names) {
    final indices = <int>[];
    for (final morphTarget in names) {
      var index = this.morphTargets.indexOf(morphTarget);
      if (index == -1) {
        throw Exception("Failed to find morph target $morphTarget");
      }
      indices.add(index);
    }
    return indices;
  }

  MorphAnimationData subset(List<String> newMorphTargets) {
    late List<int> indices = <int>[];
      for (final morphTarget in newMorphTargets) {
        var index = this.morphTargets.indexOf(morphTarget);
        if (index == -1) {
          throw Exception("Failed to find morph target $morphTarget");
        }
        indices.add(index);
      }
    

    var newData = Float32List(numFrames * indices.length);
    

    for (int frameNum = 0; frameNum < numFrames; frameNum++) {
      for (int newIdx = 0; newIdx < indices.length; newIdx++) {
        var oldIdx = indices[newIdx];
        newData[(frameNum * indices.length) + newIdx] =
            data[(frameNum * this.morphTargets.length) + oldIdx];
      }
    }
    return MorphAnimationData(newData, newMorphTargets,
        frameLengthInMs: frameLengthInMs);
  }

  String toCSV() {
    var sb = StringBuffer("Timestamp,BlendshapeCount,");
    sb.writeln(morphTargets.join(","));
    int frameNum = 0;
    for (int i = 0; i < data.length ~/ morphTargets.length; i++) {
      var frame =
          data.sublist(i * morphTargets.length, (i + 1) * morphTargets.length);
      sb.writeln("$frameNum,$numMorphTargets," + frame.join(','));
      frameNum++;
    }
    return sb.toString();
  }
}
