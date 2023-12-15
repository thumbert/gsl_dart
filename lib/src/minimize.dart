import 'dart:ffi';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:gsl_dart/gsl_dart.dart';
import 'package:gsl_dart/src/ffi/gsl_generated_bindings.dart';

enum MinimizeAlgorithm {
  brent,
  goldensection,
}

class Minimizer {
  /// See https://www.gnu.org/software/gsl/doc/html/min.html
  /// for the functions that are wrapped in this class.
  ///
  Minimizer({
    this.algorithm = MinimizeAlgorithm.brent,
    // required this.fn,
    required num xLower,
    required num xUpper,
    required this.x0,
  }) {
    // _fn(double x, Pointer<Void> params) => fn(x);

    final Pointer<gsl_function_struct> pFun = calloc<gsl_function_struct>();
    pFun.ref.function = Pointer.fromFunction(fn, 0.0);
    pFun.ref.params = Pointer.fromAddress(0);

    var type = switch (algorithm) {
      MinimizeAlgorithm.brent => gsl.gsl_min_fminimizer_brent,
      MinimizeAlgorithm.goldensection => gsl.gsl_min_fminimizer_goldensection,
    };
    _solver = gsl.gsl_min_fminimizer_alloc(type);

    // set the solver
    gsl.gsl_min_fminimizer_set(
        _solver, pFun, x0.toDouble(), xLower.toDouble(), xUpper.toDouble());
  }

  MinimizeAlgorithm algorithm;

  static late double Function(double, Pointer<Void>) fn;
  // static double fn(double x, Pointer<Void> params) => cos(x) + 1.0;

  late Pointer<gsl_min_fminimizer> _solver;

  /// Function to minimize
  // double Function(double) fn;

  /// Initial guess value for x
  num x0;

  /// Get the lower bound
  double get xLower => gsl.gsl_min_fminimizer_x_lower(_solver);

  /// Get the upper bound
  double get xUpper => gsl.gsl_min_fminimizer_x_upper(_solver);

  /// Get the current estimation of the minimum
  num get minimum => gsl.gsl_min_fminimizer_x_minimum(_solver);

  /// Perform one iteration step.  Return a status code, 0 is success.
  /// For reference, status codes are available in the gsl_generated_bindings
  /// lines 122704+.
  int iterate() => gsl.gsl_min_fminimizer_iterate(_solver);

  /// Should free resources when done
  void free() {
    // calloc.free(pFun);  // maybe this one too?
    gsl.gsl_min_fminimizer_free(_solver);
  }

  /// Iterate the solver over multiple steps, trying to find a minimum.
  /// Frees resources at termination.
  // int solve({
  //   required double epsAbsolute,
  //   required double epsRelative,
  //   int maxIterations = 100,
  // }) {
  //   var iter = 0;

  //   /// MAYBE not needed.

  //   // calloc.free(pFun);

  //   gsl.gsl_min_fminimizer_free(_solver);

  //   return 0;
  // }

  ///  This method tests for the convergence of the interval [xLower,
  ///  xUpper] with absolute error EPSABS and relative error EPSREL.
  ///  The test returns `GSL_SUCCESS' if the following condition is
  ///  achieved,
  ///
  ///       |a - b| < epsabs + epsrel min(|a|,|b|)
  ///
  ///  when the interval x = [a,b] does not include the origin.  If the
  ///  interval includes the origin then \min(|a|,|b|) is replaced by
  ///  zero (which is the minimum value of |x| over the interval).  This
  ///  ensures that the relative error is accurately estimated for minima
  ///  close to the origin.
  ///
  ///  This condition on the interval also implies that any estimate of
  ///  the minimum x_m in the interval satisfies the same condition with
  ///  respect to the true minimum x_m^*,
  ///
  ///       |x_m - x_m^*| < epsabs + epsrel x_m^*
  ///
  ///  assuming that the true minimum x_m^* is contained within the
  ///  interval.
  ///
  /// Return a status code.  0 means success.
  int stopTest({required double epsAbsolute, required double epsRelative}) {
    return gsl.gsl_min_test_interval(
        xLower.toDouble(), xUpper.toDouble(), epsAbsolute, epsRelative);
  }
}
