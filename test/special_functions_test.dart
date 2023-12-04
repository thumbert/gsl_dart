library test.special_functions_test;

import 'package:test/test.dart';

import 'dart:ffi';
import 'package:gsl_dart/src/gsl_generated_bindings.dart';

void tests(Gsl gsl) {
  group('Bessel functions: ', () {
    test('J0', () {
      expect(gsl.gsl_sf_bessel_J0(5.0), -0.17759677131433826);
    });
  });
}

void main() {
  final dylib = DynamicLibrary.open('/usr/local/lib/libgsl.so');
  tests(Gsl(dylib));
}
