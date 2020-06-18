#!/usr/bin/env bash
CONFIG=$1

pushd ../
source venv/bin/activate

python tools/train.py --cfg $CONFIG

deactivate
popd