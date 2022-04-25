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

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.



## Using the ```ffigen``` package to generate the bindings
### Installation notes Ubuntu 16.04

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

Note: I've copied all the header files from ```gsl-2.7.1/gsl/``` into this project's ```third_party/``` folder. 

Run ```dart run ffigen``` to generate the bindings.  They are available in ```./gsl_generated_bindings.dart```. 



