import 'dart:ffi';
import 'dart:io';
import 'gsl_generated_bindings.dart';

Gsl? _gsl;

DynamicLibrary? _dynLib;

Gsl get gsl {
  return _gsl ??= Gsl(open());
}

DynamicLibrary open() {
  if (_gsl == null) {
    if (Platform.isLinux) {
      _dynLib = DynamicLibrary.open('/usr/local/lib/libgsl.so');
    } else {
      throw StateError('Your platform is not supported yet');
    }
  }
  return _dynLib!;
}
