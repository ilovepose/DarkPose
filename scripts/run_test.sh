#!/usr/bin/env bash
CONFIG=$1
MODEL=$2

if [[ $CONFIG == *"mpii"* ]]
then
    GT=true
else
    GT=false
fi

pushd ../
source venv/bin/activate

python tools/test.py --cfg $CONFIG \
    TEST.MODEL_FILE $MODEL \
    TEST.USE_GT_BBOX $GT

deactivate
popd