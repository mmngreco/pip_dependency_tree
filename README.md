# Unexpected behaviour of PIP

Suppose we have an depdency tree like the one described below:

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

Here we have a `pkgA` that needs `pkgB` and `numpy>=1.14.0` as dependencies,
but `pkgB` only works with `numpy==1.14.0`. The expected versions installed
after the execution of `pip install pkgA --process-dependency-links` are:

```
...
pkgB==0.0.0
numpy==1.14.0
...
```

This should install `numpy==1.14.0` but it doesn't:

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
python -s -m pip install pkgA/. --process-dependency-links -I --no-cache-dir -q

# checks versions
pip freeze | grep numpy  # numpy==1.17.1 ??
pip check
```

The obtained result is:

```bash
$ pip freeze
certifi==2019.6.16
numpy==1.17.1
pkgA==0.0.0
pkgB==0.0.0

$ python -u -s -m pip check
pkgb 0.0.0 has requirement numpy==1.14, but you have numpy 1.17.1.
```

This problem also takes places with incompatible versions, as we can see in the next escenario:

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

In this case we have incompatible versions of numpy between `pkgA` and `pkgB`, so
this should **crash** the installation process, but it doesn't.

The example:

```bash
# change to crashing branch
cd pkgA && git checkout crash
cd ../pkgB && git checkout crash && cd ..

# checks numpy versions in the setup.py
cat pkgA/setup.py
cat pkgB/setup.py

python -s -m pip install pkgA/. --process-dependency-links -I --no-cache-dir -q
python -s -m pip check
python -s -m pip freeze
```

The obtained result:

```bash
$ pip freeze
certifi==2019.6.16
numpy==1.17.1
pkgA==0.0.0
pkgB==0.0.0

$ python -u -s -m pip check
pkgb 0.0.0 has requirement numpy==1.14, but you have numpy 1.17.1.
```
