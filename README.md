# Unexpected behaviour of PIP

Suppose we have an depdency tree like described below:

```
                +---------------+
                |   pkgA        |
                |---------------|
                | numpy>=1.14.0 |
            +---| pkgB          |---+
            |   +---------------+   |
            |                       |
     +------v--------+     +--------v------+
     |   pkgB        |     |   numpy       |
     |---------------|     |---------------|
     | numpy==1.14.0 |     | whatever      |
     +---------------+     +---------------+
```

Here we have an `pkgA` that needs `pkgB` and `numpy>=1.14.0` as dependencies,
where `pkgB` only works with `numpy==1.14.0`. The expected versions installed
after execute `pip install pkgA --process-dependency-links` is:

```
...
pkgB==0.0.0
numpy==1.14.0
...
```

Concretly: This should install `numpy==1.14.0` but it doesn't. Here an example:

```bash
# creates an enviroment
conda create -n tst python=3.6 pip=18 -y
conda activate tst

# clones code needed
git clone --recurse-submodules https://github.com/mmngreco/pip_dependency_tree.git

# takes a look at the versions in the setup.py
cat pkgA/setup.py | grep numpy
cat pkgB/setup.py | grep numpy

# installation
pip install pkgA/. --process-dependency-links -I --no-cache-dir

# checks versions
pip freeze | grep numpy  # numpy==1.17.1 ??
pip check
```

The obtained result is:

```
pip freeze
...
pkgB==0.0.0
numpy==1.17.1
...
```

In order to check incompatible versions also, we try the next escenario:

```
                +---------------+
                |   pkgA        |
                |---------------|
                | numpy>=1.14.0 |
            +---| pkgB          |---+
            |   +---------------+   |
            |                       |
     +------v--------+     +--------v------+
     |   pkgB        |     |   numpy       |
     |---------------|     |---------------|
     | numpy==1.13.0 |     | whatever      |
     +---------------+     +---------------+
```

In this case we have incompatible versions of numpy between `pkgA` and `pkgB` then
this should **crash** installation process, but it doesn't.

The example:

```bash
# change to crashing branch
cd pkgA
git checkout crash  # pkgA

cd ../pkgB
git checkout crash  # pkgB
cd ..

# checks numpy versions in the setup.py
cat pkgA/setup.py
cat pkgB/setup.py

pip install pkgA/. --process-dependency-links -I --no-cache-dir
pip check
pip freeze | grep numpy  # numpy==1.17.1
```


The obtained result:

```
pip freeze
...
pkgB==0.0.0
numpy==1.17.1
...
```

