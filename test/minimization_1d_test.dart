library test.minimization_1d_test;

import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'dart:ffi';
import 'package:gsl_dart/src/ffi/gsl_generated_bindings.dart';
import 'package:gsl_dart/gsl_dart.dart';
import 'package:intl/intl.dart';

class Minimizer {
  final maxIteration = 1000;

  static double fn1(double x, Pointer<Void> params) => cos(x) + 1.0;

  final fmt = NumberFormat('+0.0000000;-0.0000000');

  void calculate() {
    final Pointer<gsl_function_struct> pFun = calloc<gsl_function_struct>();
    pFun.ref.function = Pointer.fromFunction(fn1, 0.0);
    pFun.ref.params = Pointer.fromAddress(0);

    var iter = 0;

    var brent = gsl.gsl_min_fminimizer_brent;
    var solver = gsl.gsl_min_fminimizer_alloc(brent);

    var m = 2.0;
    var mExpected = pi;
    var a = 0.0;
    var b = 6.0;

    gsl.gsl_min_fminimizer_set(solver, pFun, m, a, b);

    var solverName =
        gsl.gsl_min_fminimizer_name(solver).cast<Utf8>().toDartString();
    var status = gsl.gsl_min_fminimizer_iterate(solver);
    print('Using $solverName method');
    print(' iter [    lower,     upper]       min        err  err(est)');
    print('${iter.toString().padLeft(5)} [${a.toStringAsFixed(7)}, '
        '${b.toStringAsFixed(7)}] ${m.toStringAsFixed(7)} '
        '${(m - mExpected).toStringAsFixed(7)} ${(b - a).toStringAsFixed(7)}');

    do {
      iter++;
      status = gsl.gsl_min_fminimizer_iterate(solver);

      m = gsl.gsl_min_fminimizer_x_minimum(solver);
      a = gsl.gsl_min_fminimizer_x_lower(solver);
      b = gsl.gsl_min_fminimizer_x_upper(solver);

      status = gsl.gsl_min_test_interval(a, b, 0.001, 0.0);
      if (status == GSL_SUCCESS) {
        print('Converged:\n');
      }
      print('${iter.toString().padLeft(5)} [${a.toStringAsFixed(7)}, '
          '${b.toStringAsFixed(7)}] ${m.toStringAsFixed(7)} '
          '${fmt.format(m - mExpected)} ${(b - a).toStringAsFixed(7)}');
    } while (status == GSL_CONTINUE && iter < maxIteration);

    calloc.free(pFun);
  }
}

void tests(Gsl gsl) {
  group('1D minimization: ', () {
    test('cos(x) + 1', () {
      var brent = gsl.gsl_min_fminimizer_brent;
      var solver = gsl.gsl_min_fminimizer_alloc(brent);

      var m = 2.0;
      var a = 0.0;
      var b = 6.0;

      // final fMin = calloc.allocate<gsl_function_struct>();

      /// I need a Pointer<gsl_function_struct>
      // var f = NativeCallable.isolateLocal(fn1);

      // gsl.gsl_min_fminimizer_set(solver, ??, m, a, b);

      expect(1, 1);
    });
  });
}

void main() {
  var minimizer = Minimizer();
  minimizer.calculate();
}
