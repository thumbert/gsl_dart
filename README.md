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

Install it: `./configure && make && make install`

GSL libraries get installed in `/usr/local/lib`.  You need the location to load the dynamic library, see `/test`. 

According to the `ffigen` documentation, you need to have LLVM (9+) installed.  You can install it with `sudo apt-get install libclang-dev`.  It gets installed in the `usr/lib/llvm-14` folder. 

### Make `gsl` available in Dart
Go through the source folders of `gsl-2.7.1` to extract **all** the header files needed for the `ffigen` package to generate the Dart bindings.  For example, get the `gsl-2.7.1/blas/gsl_blas.h`, `gsl-2.7.1/blas/gsl_blas_types.h` files from the `blas` folder, etc.   Put all these header files in the `./third_party` folder.  Boring but needed. 

Check out the `pubspec.yaml` section for the `ffigen`.  Note how it refers to the `./third_party` folder. 

Run ```dart run ffigen``` to generate the bindings.  They are available in `./src/gsl_generated_bindings.dart` as specified in the 
`pubspec.yaml` file. 



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




