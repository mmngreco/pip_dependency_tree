OPT=$1
CNT_NAME=pip
EXEC="docker exec $CNT_NAME"

if [ "$OPT" = "" ];
then
    OPT=-d
fi

docker build -t pip:tst -f  ./Dockerfile .
docker run --rm \
    -v $(pwd):/root/git/pip_dependency_tree \
    -w /root/git \
    --name $CNT_NAME \
    -t $OPT pip:tst \
    /bin/bash

if [ "$OPT" = "-d" ];
then

# $EXEC git clone --recurse-submodules https://github.com/mmngreco/pip_dependency_tree.git
eval "$EXEC pip install pip_dependency_tree/pkgA/. --process-dependency-links"
eval "$EXEC pip check"
eval "$EXEC pip freeze"
docker stop $CNT_NAME

fi
