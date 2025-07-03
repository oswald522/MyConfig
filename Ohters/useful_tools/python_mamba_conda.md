# Python 合集

Python 的安装推荐使用 conda 进行，可以有效地进行环境隔离与区分。

## caffe 系统安装

1. 编译系统安装
   `git clone --depth 1  https://gitclone.com/github.com/BVLC/caffe.git`

2. conda install
   `conda install`

## mamba 安装及配置方法

```shell
# mamba install
conda install mamba -n base -c conda-forge
wget "https://hub.nuaa.cf/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
curl -L -O "https://hub.nuaa.cf/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
chmod +x Mambaforge-$(uname)-$(uname -m).sh
bash Mambaforge-$(uname)-$(uname -m).sh -b -u -p $HOME/Software/miniconda
# miniconda install chapter
wget  https://mirrors.bfsu.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b -f -u -p $HOME/Software/miniconda
# edit the condarc config
cat  > $HOME/.condarc << EOF
channels:
  - https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
  - https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
show_channel_urls: true
default_channels:
  - https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
  - https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
custom_channels:
  conda-forge: https://mirrors.ustc.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
auto_activate_base: true
EOF
```

## conda 安装及配置方法

Linux 系统:

```shell
wget  https://mirrors.bfsu.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b -f -u -p $HOME/Software/miniconda
conda config --set show_channel_urls yes
conda install mamba -n base -c conda-forge
conda create --name caffepy38 python==3.7
conda create --name torch-py39 python==3.9
conda create --name tf2-py39 python==3.9
```

pip3 install torch torchvision torchaudio --extra-index-url <https://download.pytorch.org/whl/cpu>

Windows 系统：

```shell
certutil -urlcache -split -f https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Windows-x86_64.exe
```

## pip 临时使用更改和永久更改

```shell


pip install -i https://pypi.tuna.tsinghua.edu.cn/simple some-package
pip config set global.index-url http://pypi.tuna.tsinghua.edu.cn/simple
pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn
pip install jupyterlab
```

pytorch=1.13.1=gpu_cuda113py38hde3f150_1

## Caffe 安装

```shell
mamba create -n caffepy36 python=3.6 caffe -c conda-forge
sudo apt install libopencv-im
```

## Pytorch 安装说明

pytorch 区分 GPU 版本和 CPU 版本，代码主要记录 GPU 版本安装过程。

GPU：`conda install pytorch pytorch-cuda=11.7 -c pytorch -c nvidia`

CPU:`conda install pytorch cpuonly -c pytorch`

测试代码
`python -c "import torch;print(torch.cuda.is_available());print(torch.__version__)"`

<https://www.jetbrains.com/pycharm/download/download-thanks.html?platform=linux&code=PCC>
`pip install torch torchvision -i https://pypi.tuna.tsinghua.edu.cn/simple`

```python
import torch
torch.cuda.is_available()
```

powershell -command "& { iwr <https://github.com/powerline/fonts/archive/master.zip> -OutFile ~\\fonts.zip }" Expand-Archive -Path ~\\fonts.zip -DestinationPath ~

## tf2 安装说明

tenorflow2 区分 GPU 版本和 CPU 版本，代码主要记录 GPU 版本安装过程。

**主要步骤如下：**

1. 任务管理器中检查设备类型
2. 启动 Anaconda Prompt 里面输入 nvidia-smi 来检查是否含有英伟达驱动，若没有则需要在 [英伟达官网](https://www.nvidia.cn/Download/index.aspx) 安装驱动：
   `axel -n 10
`
3. 在虚拟环境中安装 GPU 加速软件包 cuDNN、CUDA：首先根据官网 [GPU 安装匹配表](https://tensorflow.google.cn/install/source_windows?hl=en#gpu) 来确定 tensorflow、cuDNN、CUDA 的对应关系，然后根据网站 [GPU 驱动匹配表](https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html) 来确定自己的 GPU 所支持的 CUDA 版本。
4. 命令行进行安装。

GPU：

```shell

pip install tensorflow-gpu==2.2 -i https://pypi.tuna.tsinghua.edu.cn/simple

tensorflow-gpu==2.1、cuDNN=7.6、CUDA=10.1
conda create -n tf2py39 python==3.9
conda activate tf2py39
conda install cudatoolkit=10.1
conda install cudnn=7.6

python -m pip install "tensorflow<2.11"
python -m pip install "tensorflow<2.11"
```

CPU:`conda install pytorch cpuonly -c pytorch`

Linux:

```shell
conda install -c conda-forge cudatoolkit=11.2.2 cudnn=8.1.0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONDA_PREFIX/lib/
python3 -m pip install tensorflow
# Verify install:
python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
python3 -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
```

测试代码：

```python
// 测试 GPU 是否可用
import tensorflow as tf
import os
os.environ["CUDA_VISIBLE_DEVICES"] = "0"py
version=tf.__version__  #输出tensorflow版本
gpu_ok=tf.test.is_gpu_available()  #输出gpu可否使用（True/False）
print("tf version:",version,"\nuse GPU:",gpu_ok)
tf.test.is_built_with_cuda()  # 判断CUDA是否可用（True/False）
print("Num GPUs Available: ", len(tf.config.experimental.list_physical_devices('GPU')))
```

Linux:服务器配置命令行：

```shell
wget  https://mirrors.bfsu.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b -f -u -p $HOME/Software/miniconda
conda config --set show_channel_urls yes
conda install mamba -n base -c conda-forge
conda create --name caffepy37 python==3.7.7
# install caffe-gpu
conda install -c anaconda caffe-gpu
conda install -c anaconda caffe
# install pytorch
```

## django 环境配置

```shell
pip install django==4.1 -i https://mirrors.aliyun.com/pypi/simple/
django-admin startproject test_django

```
