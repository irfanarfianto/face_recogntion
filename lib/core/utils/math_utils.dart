import 'dart:math';

class MathUtils {
  static double euclideanDistance(List<double> e1, List<double> e2) {
    if (e1.length != e2.length) return 10.0; // Error / Max distance
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow(e1[i] - e2[i], 2);
    }
    return sqrt(sum);
  }
}
