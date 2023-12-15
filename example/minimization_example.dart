import 'dart:ffi';
import 'dart:math';

import 'package:gsl_dart/gsl_dart.dart';
import 'package:intl/intl.dart';

void main() {
  final minimizer = Minimizer(xLower: 0, xUpper: 6, x0: 2);
  Minimizer.fn = (x, params) => cos(x) + 1.0;

  final mExpected = pi;
  final maxIteration = 100;
  final fmt = NumberFormat('+0.0000000;-0.0000000');

  int status = 0;
  var iter = 0;
  print('Using ${minimizer.algorithm} method');
  print(' iter [    lower,     upper]       min        err  err(est)');

  print('${iter.toString().padLeft(5)} '
      '[${minimizer.xLower.toStringAsFixed(7)}, '
      '${minimizer.xUpper.toStringAsFixed(7)}] '
      '${minimizer.minimum.toStringAsFixed(7)} '
      '${(minimizer.minimum - mExpected).toStringAsFixed(7)} '
      '${(minimizer.xUpper - minimizer.xLower).toStringAsFixed(7)}');

  do {
    iter++;
    status = minimizer.iterate();
    status = minimizer.stopTest(epsAbsolute: 0.001, epsRelative: 0.0);
    if (status == GSL_SUCCESS) {
      print('Converged:\n');
    }
    print('${iter.toString().padLeft(5)} '
        '[${minimizer.xLower.toStringAsFixed(7)}, '
        '${minimizer.xUpper.toStringAsFixed(7)}] '
        '${minimizer.minimum.toStringAsFixed(7)} '
        '${(minimizer.minimum - mExpected).toStringAsFixed(7)} '
        '${fmt.format(minimizer.xUpper - minimizer.xLower)}');
  } while (status == GSL_CONTINUE && iter < maxIteration);

  minimizer.free();
}
