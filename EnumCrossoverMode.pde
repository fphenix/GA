enum EnumCrossoverMode {
  RANDOM,    // resulting gene randomly taken from either parents
  CUTPOINT,  // resulting gene generated by taking the first parent gene upto the cut point, then from the other
  RANDOMCUT, // same as CUTPOINT but the cut point is chosen randomly
  DOUBLECUT, // double cutpoint
  DOUBLERANDOMCUT // same as DOUBLECUT but the cut points are chosen randomly
}