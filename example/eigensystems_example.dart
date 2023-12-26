import 'package:gsl_dart/gsl_dart.dart';

/// See https://www.gnu.org/software/gsl/doc/html/eigen.html#examples
void main() {
  var x = [1.0, 2.0, 3.0];
  var v = gsl.gsl_vector_alloc(3);
  for (var i = 0; i < x.length; i++) {
    gsl.gsl_vector_set(v, i, x[i]);
  }

  print(gsl.gsl_blas_dnrm2(v));
  gsl.gsl_vector_free(v);

  // final data = [
  //   1.0,
  //   1 / 2.0,
  //   1 / 3.0,
  //   1 / 4.0,
  //   1 / 2.0,
  //   1 / 3.0,
  //   1 / 4.0,
  //   1 / 5.0,
  //   1 / 3.0,
  //   1 / 4.0,
  //   1 / 5.0,
  //   1 / 6.0,
  //   1 / 4.0,
  //   1 / 5.0,
  //   1 / 6.0,
  //   1 / 7.0
  // ];

  // var m = Matrix.from(data, 4, 4);
  // var eVals = m.eigen();

  // print(eVals);
}
