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
  // Model: a * exp(-lambda*t) + b
  for (var i = 0; i < n; i++) {
    var ti = i * tMax / (n - 1.0);
    var yi = 5 * exp(-1.5 * ti) + 1.0;
    var si = 0.1 * yi;
    var dy = gsl.gsl_ran_gaussian(r, si);

    t[i] = ti;
    y[i] = yi + dy;
    weights[i] = 1.0 / (si * si);
    print('$ti, ${y[i]}, $si');
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
    double labmda = gsl.gsl_vector_get(x, 1);
    double b = gsl.gsl_vector_get(x, 2);

    for (var i = 0; i < n; i++) {
      var yi = a * exp(-labmda * t[i]) + b;
      print('$i, $yi, ${y[i]}');
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
    return GSL_SUCCESS;
  }, exceptionalReturn: 1)
      .nativeFunction;

  pFdf.ref.fvv = nullptr;
  pFdf.ref.n = n;
  pFdf.ref.p = p;
  pFdf.ref.params = Pointer.fromAddress(data.address);

  // setup the callback
  // var pCallback = calloc<
  //     NativeFunction<
  //         Void Function(
  //             Size, Pointer<Void>, Pointer<gsl_multifit_nlinear_workspace>)>>();

  void callable(Size iter, Pointer<Void> params,
      Pointer<gsl_multifit_nlinear_workspace> w) {
    print('Boo');
  }

  var pCallable = NativeCallable<
          Void Function(Size, Pointer<Void>,
              Pointer<gsl_multifit_nlinear_workspace>)>.listener(callable)
      .nativeFunction;
  // Pointer<NativeFunction<Void Function(Size, Pointer<Void>, Pointer<gsl_multifit_nlinear_workspace>)>>

  // initialize solver with starting points and weights
  var pX = calloc<gsl_vector>();
  pX.ref = x.vector;
  var pWts = calloc<gsl_vector>();
  pWts.ref = wts.vector;
  gsl.gsl_multifit_nlinear_winit(pX, pWts, pFdf, w);

  var pChisq0 = calloc<Double>();
  var pChisq = calloc<Double>();
  print('residuals:');
  var f = gsl.gsl_multifit_nlinear_residual(w); // length 100
  gsl.gsl_blas_ddot(f, f, pChisq0);
  print('Initial chisq: ${pChisq0.value}');

  // solve the system with a maximum of 100 iterations
  const maxIter = 100;
  const xtol = 1e-8;
  const gtol = 1e-8;
  const ftol = 0.0;
  var pInfo = calloc<Int>();
  var status = gsl.gsl_multifit_nlinear_driver(
      maxIter, xtol, gtol, ftol, pCallable, nullptr, pInfo, w);

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
