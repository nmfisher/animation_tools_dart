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
    assert(data.length == morphTargets.length * numFrames);
  }

  int get numMorphTargets => morphTargets.length;

  int get numFrames => data.length;

  Iterable<double> getData(String morphName) sync* {
    int index = morphTargets.indexOf(morphName);
    if (index == -1) {
      throw Exception("No data for morph $morphName");
    }
    for (int i = 0; i < numFrames; i++) {
      yield data[i][index];
    }
  }
}
