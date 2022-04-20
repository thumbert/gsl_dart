import 'package:gsl_dart/gsl_dart.dart';
import 'package:test/test.dart';

import 'dart:ffi';

typedef J0Func = Double Function(Double x);
typedef J0 = double Function(double x);

void main() {
  final dylib = DynamicLibrary.open('/usr/local/lib/libgsl.so');

  final j0Pointer = dylib.lookup<NativeFunction<J0Func>>('gsl_sf_bessel_J0');
  final j0 = j0Pointer.asFunction<J0>();
  print('${j0(5.0)}'); //-0.17759677131433826

}
