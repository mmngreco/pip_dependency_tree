# creates an enviroment
conda create -n pip18 python=3.6 pip=18.1 -y
source activate pip18

# installation
echo \# python version $(which python)
python -s -m pip install pkgA/. --process-dependency-links -I --no-cache-dir -q && echo \# installed

# checks versions
echo \# ckeck depencencies
python -s -m pip freeze
python -s -m pip check

source deactivate
