import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:ffi/ffi.dart';
import 'package:gsl_dart/gsl_dart.dart';

typedef T = Void Function(
    Size, Pointer<Void>, Pointer<gsl_multifit_nlinear_workspace>);

final class Data extends Struct {
  @UintPtr()
  external int n;

  external Pointer<Double> t;

  external Pointer<Double> y;
}

void exponentialFitting() {
  // Fit function y(t) = a * exp(-lambda*t) + b
  // to a list of observations (ti,yi)

  // number of observations
  final n = 100;
  // max time
  final tMax = 3.0;
  // number of parameters
  const p = 3;

  final type = gsl.gsl_multifit_nlinear_trust;

  var covar = gsl.gsl_matrix_alloc(p, p);
  Pointer<Double> xInitial = calloc(3);
  xInitial[0] = 1.0;
  xInitial[1] = 1.0;
  xInitial[2] = 0.0;
  var x = gsl.gsl_vector_view_array(xInitial, p);

  Pointer<Double> t = calloc(n);
  Pointer<Double> y = calloc(n);
  Pointer<Double> weights = calloc(n);
  var wts = gsl.gsl_vector_view_array(weights, n);

  gsl.gsl_rng_env_setup();
  var r = gsl.gsl_rng_alloc(gsl.gsl_rng_default);

  // generate the data to be fitted
  // Model: A * exp(-lambda*t) + b
  for (var i = 0; i < n; i++) {
    var ti = i * tMax / (n - 1.0);
    var yi = 5 * exp(-1.5 * ti) + 1.0;
    var si = 0.1 * yi;
    var dy = gsl.gsl_ran_gaussian(r, si);

    t[i] = ti;
    y[i] = yi + dy;
    weights[i] = 1.0 / (si * si);
  }
  var data = calloc<Data>();
  data.ref.n = n;
  data.ref.t = t;
  data.ref.y = y;

  // allocate workspace with default parameters
  var fdfParams = calloc<gsl_multifit_nlinear_parameters>();
  fdfParams.ref = gsl.gsl_multifit_nlinear_default_parameters();
  var w = gsl.gsl_multifit_nlinear_alloc(type, fdfParams, n, p);

  // setup the non-linear function to minimize
  var pFdf = calloc<gsl_multifit_nlinear_fdf>();
  pFdf.ref.f = NativeCallable<
              Int Function(Pointer<gsl_vector>, Pointer<Void>,
                  Pointer<gsl_vector>)>.isolateLocal(
          (Pointer<gsl_vector> x, Pointer<Void> data, Pointer<gsl_vector> f) {
    Pointer<Data> pData = data.cast();
    var n = pData.ref.n;
    var t = pData.ref.t;
    var y = pData.ref.y;

    double a = gsl.gsl_vector_get(x, 0);
    double lambda = gsl.gsl_vector_get(x, 1);
    double b = gsl.gsl_vector_get(x, 2);

    for (var i = 0; i < n; i++) {
      var yi = a * exp(-lambda * t[i]) + b;
      gsl.gsl_vector_set(f, i, yi - y[i]);
    }

    return GSL_SUCCESS;
  }, exceptionalReturn: 1)
      .nativeFunction;

  // setup the gradient of the function
  pFdf.ref.df = NativeCallable<
              Int Function(Pointer<gsl_vector>, Pointer<Void>,
                  Pointer<gsl_matrix>)>.isolateLocal(
          (Pointer<gsl_vector> x, Pointer<Void> data, Pointer<gsl_matrix> J) {
    var n = data.cast<Data>().ref.n;
    var t = data.cast<Data>().ref.t;

    double A = gsl.gsl_vector_get(x, 0);
    double lambda = gsl.gsl_vector_get(x, 1);

    for (var i = 0; i < n; i++) {
      // Jacobian matrix J(i,j) = dfi / dxj;
      // where fi = (Yi - yi)/sigma[i]
      //       Yi = a * exp(-lambda * t_i) + b
      // and the xj are the parameters [A, lambda, b]
      // double e = exp(-lambda * t.elementAt(i).value);
      double e = exp(-lambda * t[i]);
      gsl.gsl_matrix_set(J, i, 0, e);
      gsl.gsl_matrix_set(J, i, 1, -t[i] * A * e);
      gsl.gsl_matrix_set(J, i, 2, 1.0);
    }
    return GSL_SUCCESS;
  }, exceptionalReturn: 1)
      .nativeFunction;

  pFdf.ref.fvv = nullptr;
  pFdf.ref.n = n;
  pFdf.ref.p = p;
  pFdf.ref.params = Pointer.fromAddress(data.address);

  // setup the callback
  void callback(int iter, Pointer<Void> params,
      Pointer<gsl_multifit_nlinear_workspace> w) {
    var f = gsl.gsl_multifit_nlinear_residual(w);
    var x = gsl.gsl_multifit_nlinear_position(w);
    var pRcond = calloc<Double>();

    gsl.gsl_multifit_nlinear_rcond(pRcond, w);

    print('iter:${iter.toString().padLeft(3)}, '
        'A = ${gsl.gsl_vector_get(x, 0).toStringAsFixed(4)}, '
        'lambda = ${gsl.gsl_vector_get(x, 1).toStringAsFixed(4)}, '
        'b = ${gsl.gsl_vector_get(x, 2).toStringAsFixed(4)}, '
        'cond(J) = ${(1 / pRcond.value).toStringAsFixed(4).padRight(7)}, '
        '|f(x)| = ${gsl.gsl_blas_dnrm2(f).toStringAsFixed(4)}');
  }

  var pCallable = NativeCallable<
          Void Function(Size, Pointer<Void>,
              Pointer<gsl_multifit_nlinear_workspace>)>.isolateLocal(callback)
      .nativeFunction;

  // initialize solver with starting points and weights
  var pX = calloc<gsl_vector>();
  pX.ref = x.vector;
  var pWts = calloc<gsl_vector>();
  pWts.ref = wts.vector;
  gsl.gsl_multifit_nlinear_winit(pX, pWts, pFdf, w);

  var pChisq0 = calloc<Double>();
  var pChisq = calloc<Double>();
  var f = gsl.gsl_multifit_nlinear_residual(w); // length 100
  gsl.gsl_blas_ddot(f, f, pChisq0);

  // solve the system with a maximum of 100 iterations
  const maxIter = 100;
  const xtol = 1e-8;
  const gtol = 1e-8;
  const ftol = 0.0;
  const epsRel = 0.0;
  var pInfo = calloc<Int>();
  var status = gsl.gsl_multifit_nlinear_driver(
      maxIter, xtol, gtol, ftol, pCallable, nullptr, pInfo, w);

  // compute covariance of best fit parameters
  var jacobian = gsl.gsl_multifit_nlinear_jac(w);
  gsl.gsl_multifit_nlinear_covar(jacobian, epsRel, covar);

  // compute final cost
  gsl.gsl_blas_ddot(f, f, pChisq);

  // output
  print(
      'Summary from method ${gsl.gsl_multifit_nlinear_name(w).cast<Utf8>().toDartString()}');
  print('Number of iterations: ${gsl.gsl_multifit_nlinear_niter(w)}');
  print('Function evaluations: ${pFdf.ref.nevalf}');
  print('Jacobian evaluations: ${pFdf.ref.nevaldf}');
  var reason = pInfo.value == 1 ? 'small step size' : 'small gradient';
  print('Reason for stopping: $reason');
  print('initial |f(x)| = ${sqrt(pChisq0.value)}');
  print('final   |f(x)| = ${sqrt(pChisq.value)}');

  var dof = n - p;
  var c = max(1, sqrt(pChisq.value / dof));
  print('chisq/dof = ${pChisq.value / dof}');
  print('Results:');
  print('----------------------------');
  var err0 = c * sqrt(gsl.gsl_matrix_get(covar, 0, 0));
  var err1 = c * sqrt(gsl.gsl_matrix_get(covar, 1, 1));
  var err2 = c * sqrt(gsl.gsl_matrix_get(covar, 2, 2));
  print('A      = ${gsl.gsl_vector_get(w.ref.x, 0).toStringAsFixed(5)} +/- ${err0.toStringAsFixed(5)}');
  print('lambda = ${gsl.gsl_vector_get(w.ref.x, 1).toStringAsFixed(5)} +/- ${err1.toStringAsFixed(5)}');
  print('b      = ${gsl.gsl_vector_get(w.ref.x, 2).toStringAsFixed(5)} +/- ${err2.toStringAsFixed(5)}');

  print('\nStatus: ${gsl.gsl_strerror(status).cast<Utf8>().toDartString()}');

  //
}

void example2() {}

/// https://www.gnu.org/software/gsl/doc/html/nls.html#exponential-fitting-example
void main() {
  exponentialFitting();

  /// I need to force an exit because otherwise the program hangs.
  /// Probably because I haven't released all C resources properly.
  exit(0);
}
