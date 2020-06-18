#!/usr/bin/env bash

#PROXYCHAINS=proxychains4

TORCH_VER=1.0.1
TORCHVISION_VER=0.3.0

DATASET_ROOT=$HOME/datasets
COCO_ROOT=${DATASET_ROOT}/MSCOCO
MPII_ROOT=${DATASET_ROOT}/MPII
MODELS_ROOT=${DATASET_ROOT}/models


# Create directory
create_directories(){
    if [[ ! -d data ]]; then
        mkdir data
    fi
}


# Install packages
install_python_packages(){
    # python.h is needed
    sudo apt install -y python3-dev
    # necessary package
    sudo apt install -y python3-tk
}


# Install virtualenv for python3
install_virtualenv(){
    sudo -H pip3 install virtualenv
}


# Create virtual environment and install packages
create_virtualenv(){
    virtualenv venv -p python3
    source venv/bin/activate
    pip install pip -U
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    pip install -r requirements.txt
    deactivate
}


# Get the python version
get_python_version(){
    source venv/bin/activate
    PYTHON_VERSION=`python -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)";`
    deactivate
}


# Get the cuda version
get_cuda_version(){
    CUDA_VERSION=`nvcc --version | grep "release" | awk '{print $6}' | cut -c2-`
    CUDA_VERSION=${CUDA_VERSION%.*}
}


# Install Pytorch
install_pytorch(){
    get_python_version
    get_cuda_version

    PY_VER=${PYTHON_VERSION/./''}
    CUDA_VER=${CUDA_VERSION/./''}

    TORCH_URL="https://download.pytorch.org/whl/cu${CUDA_VER}/torch-${TORCH_VER}-cp${PY_VER}-cp${PY_VER}m-linux_x86_64.whl"
    TORCH_VISION_URL="https://download.pytorch.org/whl/cu${CUDA_VER}/torchvision-${TORCHVISION_VER}-cp${PY_VER}-cp${PY_VER}m-manylinux1_x86_64.whl"
    source venv/bin/activate
    ${PROXYCHAINS} pip install ${TORCH_URL}
    ${PROXYCHAINS} pip install ${TORCH_VISION_URL}
    deactivate
}



# Compile lib
compile_nms_lib(){
    source venv/bin/activate
    pushd lib
    make
    popd
    deactivate
}


# Install coco api
install_coco(){
    source venv/bin/activate
    ${PROXYCHAINS} git clone https://github.com/cocodataset/cocoapi.git
    pushd cocoapi/PythonAPI
    python setup.py install
    deactivate
    popd
}


# Link and config dataset directory
link_datasets(){
    # Check directory and create folders
    if [[ ! -f data/coco ]]; then
        pushd data
        ln -s ${COCO_ROOT} coco
        popd
    fi

    if [[ ! -f data/mpii ]]; then
        pushd data
        ln -s ${MPII_ROOT} mpii
        popd
    fi
}

link_models(){
    ln -s ${MODELS_ROOT} models
}

# msgs
prompt_msgs(){
    echo '1. please specify the root path to the dataset folder'
    echo '2. please specify the models path to the models pretrained'
    echo '3. config scripts params and run scripts shell to train or test'
}


create_directories
install_python_packages
install_virtualenv
create_virtualenv
install_pytorch
compile_nms_lib
install_coco
link_datasets
link_models
prompt_msgs
