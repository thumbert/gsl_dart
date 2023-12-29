Interface [Dart](https://dart.dev/) with the GNU Scientific Library 
[gsl](https://www.gnu.org/software/gsl/) .

## Features
GSL covers a large number of mathematical topics.  See the extremely well 
written [manual](https://www.gnu.org/software/gsl/doc/html/index.html) for 
details.  These bindings are done for GLS version```2.7.1```.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information


### How to install `gsl` on Ubuntu 22.04

Download the `gsl-2.7.1.tar.gz` file. 

Gunzip it: `gunzip gsl-2.7.1.tar.gz`

Untar it: `tar -xvf gsl-2.7.1.tar`

Reading the `INSTALL` file says that doing `./configure && make && make install` should configure, build and install the package.  It does, but it won't be enough to allow for 
a full Dart interop.  Why?  If you proceed as mentioned above, the dynamic library `libgsl.so` gets created in `/usr/local/lib` but it doesn't link to the BLAS library `libgslcblas.so`.  You can check  
```bash
ldd /usr/local/lib/libgsl.so
        linux-vdso.so.1 (0x00007ffe1f174000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fcf9577d000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fcf95000000)
```

To enable all the linear algebra functionality that comes with BLAS, you need to install it and then link it correctly.  To install BLAS do 
```bash
sudo apt-get install libblas-dev liblapack-dev
```
It will install the dynamic library in `/usr/local/lib/libgslcblas.so`.


You need to customize the existing `configure` file, because otherwise the resulting `libgsl.so` does not link to `libgslcblas.so`.  To do this, edit the **`configure.ac`** file  as specified in https://www.gnu.org/software/gsl/doc/html/autoconf.html. 

at line 131 or so, add
```
AC_CHECK_LIB([m],[cos])

# ------------------------------------------------------------------
# Check for BLAS
# ------------------------------------------------------------------
AC_CHECK_LIB([cblas],[cblas_dgemm],[],[
  echo "Library libcblas not found. Looking for GSL cblas." 
  echo -n " The present value of LDFLAGS is: " 
  echo $LDFLAGS
  AC_CHECK_LIB([gslcblas],[cblas_dgemm],[],[
    echo "Library libgslcblas not found. gsl_dart requires a cblas library." 
    echo "You may be required to add a cblas library to the LIBS "
    echo "environment variable. "
    echo ""
    echo -n " The present value of LDFLAGS is: " 
    echo $LDFLAGS
    echo ""
  ],[])
],[])

# ------------------------------------------------------------------
# Check for GSL library (must check for BLAS first)
# ------------------------------------------------------------------
AC_CHECK_LIB([gsl], [gsl_vector_get], [], 
	[echo ""
        echo "GSL not found."
        echo "gsl_dart requires the GSL library."
	echo ""
	echo -n " The present value of LDFLAGS is: " 
	echo $LDFLAGS
        exit -1
	],[])
```

Run `autoreconf --verbose --install --force` to create the Makefile. 

Now install it: `./configure && make && make install`.  

To check that you `libgslcblas.so` is linked properly, check that it exists in the list of dependencies: 
```bash
ldd /usr/local/lib/libgsl.so
        linux-vdso.so.1 (0x00007ffe1f174000)
        libgslcblas.so.0 => /usr/local/lib/libgslcblas.so.0 (0x00007fcf95879000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fcf9577d000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fcf95000000)
```


### Make `gsl` available in Dart

As a user, you don't need this step.  It's only needed as a package author.

According to the `ffigen` documentation, you need to have LLVM (9+) installed.  You can install it with `sudo apt-get install libclang-dev`.  It gets installed in the `usr/lib/llvm-14` folder. 

Go through the source folders of `gsl-2.7.1` to extract **all** the header files needed for the `ffigen` package to generate the Dart bindings.  For example, get the `gsl-2.7.1/blas/gsl_blas.h`, `gsl-2.7.1/blas/gsl_blas_types.h` files from the `blas` folder, etc.   Put all these header files in the `./third_party` folder.  Boring but needed. 

Check out the `pubspec.yaml` section for the `ffigen`.  Note how it refers to the `./third_party` folder. 

Run ```dart run ffigen``` to generate the bindings.  They get generated in `./src/gsl_generated_bindings.dart` as specified in the `pubspec.yaml` file. 

There are a bunch of **[SEVERE]** warnings due to the `gsl_spmatrix_pool` not being found.  That means the sparse matrix functionality is not working properly.  TODO: fix it.   There are also multiple other errors with functions not found, etc. 


#### Run a C example

See for example the `example/eigen.c` file.  Run `gcc -Wall -o eigen eigen.c -lgsl -lgslcblas -lm`.  Then `./eigen` and you will see output.

To see the dynamic dependencies do `ldd eigen` to get
```bash
$ ldd eigen
    linux-vdso.so.1 (0x00007ffe83ffa000)
    libgsl.so.27 => /usr/local/lib/libgsl.so.27 (0x00007f9b5b400000)
    libgslcblas.so.0 => /usr/local/lib/libgslcblas.so.0 (0x00007f9b5b6eb000)
    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f9b5b000000)
    libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f9b5b319000)
    /lib64/ld-linux-x86-64.so.2 (0x00007f9b5b749000)
``` 
You can find the names of the symbols with `nm /usr/local/lib/libgslcblas.so`.




### Installation notes for Ubuntu 16.04

Ubuntu 16.04 doesn't have a modern llvm package (it's stuck at 3.8).  I've installed llvm-12 using
```
printf "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-12 main" |sudo tee /etc/apt/sources.list.d/llvm-toolchain-xenial-12.list
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key |sudo apt-key add -
sudo apt update
sudo apt install llvm-12
```
it gets installed in ```/usr/lib/llvm-12``` directory.
There is no ```libclang.so``` in the ```/usr/lib/llvm-12``` as package ```ffigen``` wants.
But notice you have a ```libclang.so.1``` file.  Making a symbolic link named ```libclang.so``` 
solved the problem for me
```
ln -s libclang.so.1 libclang.so
```




