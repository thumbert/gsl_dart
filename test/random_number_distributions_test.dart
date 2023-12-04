library test.random_number_distributions_test;

import 'package:test/test.dart';

import 'dart:ffi';
import 'package:gsl_dart/src/gsl_generated_bindings.dart';

void tests(Gsl gsl) {
  group('Random number distributions: ', () {
    /// create a generator chosen by the environment variable
    gsl.gsl_rng_env_setup();
    var rand = gsl.gsl_rng_alloc(gsl.gsl_rng_default);
    tearDown(() {
      gsl.gsl_rng_free(rand);
    });
    test('Poisson distribution', () {
      // See https://www.gnu.org/software/gsl/doc/html/randist.html#examples
      var mu = 3.0;
      var sampleSize = 10;
      var out = <int>[];
      for (var i = 0; i < sampleSize; i++) {
        out.add(gsl.gsl_ran_poisson(rand, mu));
      }
      expect(out, [2, 5, 5, 2, 1, 0, 3, 4, 1, 1]);
    });
    test('t-distribution', () {
      var nu = 1.0;
      // density
      expect(gsl.gsl_ran_tdist_pdf(0, nu), 0.3183098861837906);
      // probability distribution function for x = 1.0
      expect(gsl.gsl_cdf_tdist_P(1.0, nu), 0.7499999999999998);
      // quantile function for p=0.75
      expect(gsl.gsl_cdf_tdist_Pinv(0.75, nu), 0.9999999999999999);
    });
  });
}

void main() {
  final dylib = DynamicLibrary.open('/usr/local/lib/libgsl.so');
  tests(Gsl(dylib));
}
