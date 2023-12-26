import 'package:gsl_dart/gsl_dart.dart';

void main() {
  var a = Matrix.from([1.0, 2.0, 3.0, 4.0], 2, 2);
  var b = Matrix.from([2.0, 3.0, 4.0, 5.0], 2, 2);

  /// add the two matrices
  a += b;
  for (var j = 0; j < a.nCol; j++) {
    for (var i = 0; i < a.nRow; i++) {
      print('A[$i,$j]=${a.get(i, j)}');
    }
  } 


}
