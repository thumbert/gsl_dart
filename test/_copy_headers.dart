import 'dart:io';

import 'package:path/path.dart';

/// Given a directory with the GSL source files, copy the .h files into
/// an output directory (./third_party).
void copyGslHeaderFiles({required Directory gslSource, Directory? out}) {
  out ??= Directory('${Directory.current.path}/third_party');
  if (!out.existsSync()) {
    out.createSync();
  }

  /// note that the same .h file may appear in several places (duplicate)
  var i = 1;
  for (var e in gslSource.listSync(recursive: true)) {
    final name = basename(e.path);
    if (e is File && name.startsWith('gsl_') && name.endsWith('.h')) {
      print('$i: ${e.path}');
      i++;
      // copy the file
      e.copySync('${out.path}/$name');
    }
  }
  print('done');
}

void main(List<String> args) {
  copyGslHeaderFiles(
      gslSource: Directory('/home/adrian/Downloads/gsl-2.7.1/gsl'));
}
