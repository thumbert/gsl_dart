library test.special_functions_test;

import 'package:test/test.dart';

import 'package:gsl_dart/gsl_dart.dart';

void tests() {
  group('Bessel functions: ', () {
    test('J0', () {
      expect(gsl.gsl_sf_bessel_J0(5.0), -0.17759677131433826);
    });
  });
}

void main() {
  tests();
}
