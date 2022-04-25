import 'dart:ffi';

import 'package:gsl_dart/gsl_dart.dart';

void main() {
  final dylib = DynamicLibrary.open('/usr/local/lib/libgsl.so');
  final gsl = Gsl(dylib);
  print(gsl.gsl_log1p(1.0));
}
