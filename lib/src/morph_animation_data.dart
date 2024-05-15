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
  final List<List<double>> data;
  final double frameLengthInMs;

  MorphAnimationData(this.data, this.morphTargets,
      {this.frameLengthInMs = 1000 / 60}) {
    assert(morphTargets.isNotEmpty);
    assert(numFrames > 0);
  }

  int get numMorphTargets => morphTargets.length;

  int get numFrames => data.length;

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

  MorphAnimationData subset(List<String> morphTargets) {
    var indices = _getMorphTargetIndices(morphTargets);

    return MorphAnimationData(
        data.map((frame) => indices.map((i) => frame[i]).toList()).toList(),
        morphTargets,
        frameLengthInMs: frameLengthInMs);
  }

  Float32List extract({List<String>? morphTargets}) {
    late List<int> indices;
    if (morphTargets == null) {
      morphTargets = this.morphTargets;
      indices = List<int>.generate(morphTargets.length, (i) => i);
    } else {
      indices = <int>[];
      for (final morphTarget in morphTargets) {
        var index = this.morphTargets.indexOf(morphTarget);
        if (index == -1) {
          throw Exception("Failed to find morph target $morphTarget");
        }
        indices.add(index);
      }
    }

    var newData = Float32List(data.length * indices.length);
    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < indices.length; j++) {
        var oldIdx = indices[j];
        newData[(i * indices.length) + j] = data[i][oldIdx];
      }
    }
    return newData;
  }

  String toCSV() {
    var sb = StringBuffer("Timestamp,BlendshapeCount,");
    sb.writeln(morphTargets.join(","));
    int frameNum = 0;
    for (final frame in data) {
      sb.writeln("$frameNum,$numMorphTargets," + frame.join(','));
      frameNum++;
    }
    return sb.toString();
  }
}
