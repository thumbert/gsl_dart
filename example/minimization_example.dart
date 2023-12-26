import 'dart:io';
import 'dart:math';

import 'package:gsl_dart/gsl_dart.dart';
import 'package:intl/intl.dart';

void main() {
  final minimizer = Minimizer(
      fn: (double x) => cos(x) + 1.0, xLower: 0, xUpper: 6, xInitial: 2);

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
      '${fmt.format(minimizer.minimum - mExpected)} '
      '${(minimizer.xUpper - minimizer.xLower).toStringAsFixed(7)}');

  do {
    iter++;
    status = minimizer.iterate();
    status = minimizer.stopTest(epsAbsolute: 0.001, epsRelative: 0.0);
    print('${iter.toString().padLeft(5)} '
        '[${minimizer.xLower.toStringAsFixed(7)}, '
        '${minimizer.xUpper.toStringAsFixed(7)}] '
        '${minimizer.minimum.toStringAsFixed(7)} '
        '${fmt.format(minimizer.minimum - mExpected)} '
        '${(minimizer.xUpper - minimizer.xLower).toStringAsFixed(7)}');
  } while (status == GSL_CONTINUE && iter < maxIteration);

  minimizer.free();

  /// I need to force an exit because otherwise the program hangs.
  /// Probably because I haven't released all C resources properly.
  exit(0);
}
