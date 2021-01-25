# creates an enviroment
conda create -n pip20 python=3.6 pip -y
source activate pip20
pip install pip -U

# installation
echo \# python version $(which python)
python -s -m pip install pkgA/. -I --no-cache-dir -q && echo \# installed

# checks versions
echo \# ckeck depencencies
python -s -m pip freeze
python -s -m pip check

source deactivate
