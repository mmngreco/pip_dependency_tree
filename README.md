# Unexpected behaviour of PIP

You can can dowload in local all content with:

```bash
git clone --recurse-submodules https://github.com/mmngreco/pip_dependency_tree.git
```

There are two branches:

* `master`
* `crash`

Suppose we have an depdency tree like the one described below:

```
                +--------------------------+
                |   pkgA                   |
                |--------------------------|
                | pip-install-test>=0.4    |
            +---| pkgB                     |---+
            |   +--------------------------+   |
            |                                  |
     +------v------------------+      +--------v---------+
     |   pkgB                  |      | pip-install-test |
     |-------------------------|      |------------------|
     | pip-install-test==0.4   |      | None             |
     +-------------------------+      +------------------+
```

Here we have a `pkgA` that needs `pkgB` and `pip-install-test>=0.4.0` as
dependencies, but `pkgB` only works with `pip-install-test==0.4.0`. The expected
versions installed after the execution of
`pip install pkgA --process-dependency-links` are:

```
...
pkgB==0.0.0
pip-install-test==0.4
...
```

This should install `pip-install-test==0.4.0` but it doesn't:

```bash
# creates an enviroment
conda create -n tst python=3.6 pip=18 -y
conda activate tst

# clones code needed
git clone --recurse-submodules https://github.com/mmngreco/pip_dependency_tree.git
cd pip_dependency_tree

# takes a look at the versions in the setup.py
cat pkgA/setup.py
cat pkgB/setup.py

# installation
python -s -m pip install pkgA/. --process-dependency-links -I --no-cache-dir -q

# checks versions
python -s -m pip freeze
python -s -m pip check
```

The obtained result is:

```bash
$ python -s -m pip freeze
certifi==2019.6.16
pip-install-test==0.5
pkgA==0.0.0
pkgB==0.0.0

$ python -u -s -m pip check
pkgb 0.0.0 has requirement pip-install-test==0.4, but you have pip-install-test 0.5.
```

This problem also takes places with incompatible versions, as we can see in the next escenario:

```
                +--------------------------+
                |   pkgA                   |
                |--------------------------|
                | pip-install-test>=0.4    |
            +---| pkgB                     |---+
            |   +--------------------------+   |
            |                                  |
     +------v------------------+      +--------v---------+
     |   pkgB                  |      | pip-install-test |
     |-------------------------|      |------------------|
     | pip-install-test==0.3   |      | None             |
     +-------------------------+      +------------------+
```

In this case we have incompatible versions of `pip-install-test` between `pkgA` and `pkgB`, so
this should **crash** the installation process, but it doesn't.

The example:

```bash
# change to crash branch (in pip_dependency_tree folder)
git checkout crash --recurse-submodules

# checks numpy versions in the setup.py
cat pkgA/setup.py
cat pkgB/setup.py

python -s -m pip install pkgA/. --process-dependency-links -I --no-cache-dir -q
python -s -m pip freeze
python -s -m pip check
```

The obtained result:

```bash
$ python -s -m pip freeze
certifi==2019.6.16
pip-install-test==0.5
pkgA==0.0.0
pkgB==0.0.0

$ python -u -s -m pip check
pkgb 0.0.0 has requirement pip-install-test==0.4, but you have pip-install-test 0.5.
```
