library matrix;

import 'dart:ffi';

import 'package:gsl_dart/gsl_dart.dart';

class Matrix {
  Matrix(this.nRow, this.nCol) {
    _m = gsl.gsl_matrix_alloc(nRow, nCol);
  }

  final int nRow;
  final int nCol;
  late final Pointer<gsl_matrix> _m;

  /// Construct a matrix with all elements set to [value].
  Matrix.fill(double value, this.nRow, this.nCol) {
    _m = gsl.gsl_matrix_alloc(nRow, nCol);
    gsl.gsl_matrix_set_all(_m, value);
  }

  /// Create an identity matrix with all elements (i,j) = \delta(i,j).
  /// Works for both square and rectangular matrices.
  Matrix.identity(this.nRow, this.nCol) {
    _m = gsl.gsl_matrix_alloc(nRow, nCol);
    gsl.gsl_matrix_set_identity(_m);
  }

  /// Initialize a matrix from a list (by row).  That is column 0 is filled
  /// down the rows first, then column 1, etc.
  static Matrix from(List<double> x, int nRow, int nCol) {
    var m = Matrix(nRow, nCol);
    for (var i = 0; i < nRow; i++) {
      for (var j = 0; j < nCol; j++) {
        gsl.gsl_matrix_set(m._m, i, j, x[i + j * nCol]);
      }
    }

    return m;
  }

  double get(int i, int j) => gsl.gsl_matrix_get(_m, i, j);

  /// Add another matrix in place.
  /// a(i,j) <- a(i,j) + b(i,j)
  Matrix operator +(Matrix b) {
    gsl.gsl_matrix_add(_m, b._m);
    return this;
  }

  /// Return the maximum value in the matrix [m].
  double max() {
    return gsl.gsl_matrix_max(_m);
  }

  /// Return the minimum value in the matrix [m].
  double min() {
    return gsl.gsl_matrix_min(_m);
  }

  /// [isSymmetric] specifies if the matrix is symmetric or not.
  List<double> eigen() {
    var eigenValues = <double>[];
    if (nRow == nCol) {
      var eVal = gsl.gsl_vector_alloc(nRow);
      var eVec = gsl.gsl_matrix_alloc(nRow, nCol);
      var workspace = gsl.gsl_eigen_symmv_alloc(nRow);
      gsl.gsl_eigen_symmv(
        _m,
        eVal,
        eVec,
        workspace,
      );
      gsl.gsl_eigen_symmv_free(workspace);
      gsl.gsl_eigen_symmv_sort(
          eVal, eVec, gsl_eigen_sort_t.GSL_EIGEN_SORT_ABS_ASC);

      for (var i = 0; i < nRow; i++) {
        eigenValues.add(gsl.gsl_vector_get(eVal, i));
      }

      gsl.gsl_vector_free(eVal);
      gsl.gsl_matrix_free(eVec);
      //
      //
    } else {
      throw StateError('Not yet implemented');
    }
    return eigenValues;
  }

  /// Do this when you are done
  void free() => gsl.gsl_matrix_free(_m);
}
