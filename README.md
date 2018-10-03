# Leap Motion SDK Python 3 module builder

The Leap Motion Python module is [not officially compatible with Python 3](https://developer.leapmotion.com/documentation/python/devguide/Project_Setup.html#recompiling-leappython-for-python-3).

This project aims to provide a simple and automated way to build and install your Python 3 module for the Leap Motion.

## Dependencies

- `swig`
- `g++`
- `libpython3-dev` (on Debian/Ubuntu)

## Build the module

```shell
make
```

## Install the module

```shell
[sudo] make install
```

The `PREFIX` environment variable controls where `libLeap.so` (or `libLeap.dylib` for OSX) will be installed. `/usr` is used if none is specified.

```shell
[sudo] PREFIX=/your/local/prefix make install
```

## Test the module

```shell
make test
```

## Clean the source directory

```shell
make clean
```

## Uninstall the module

```shell
[sudo] make uninstall
```
