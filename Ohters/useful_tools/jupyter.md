# Jupyter-lab 系统配置

## 1.初始配置

```shell
## install
pip install jupyterlab jupyterlab-language-pack-zh-CN -i https://pypi.tuna.tsinghua.edu.cn/simple

# 配置密码登录
jupyter-lab --generate-config --allow-root
jupyter-lab password
# 设置所有网络均可连接\禁用自动打开服务器\设置默认位置(`~Code`)
sed -i.bak 's/# c.NotebookApp.open_browser = True/c.NotebookApp.open_browser = False/g' ~/.jupyter/jupyter_lab_config.py
sed -i.bak 's/# c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '0.0.0.0'/g' ~/.jupyter/jupyter_lab_config.py
sed -i.bak "s|# c.ServerApp.notebook_dir = ''|c.ServerApp.notebook_dir = '~/Code'|g" ~/.jupyter/jupyter_lab_config.py


# 单次启动服务器，后台运行服务器
nohup jupyter-lab --log-level=DEBUG &> ~/.jupyter/jupyter.log &
## 另外启动一项
ssh -N -L localhost:8888:localhost:8888 jiaqian@192.168.1.112 -p22


nohup jupyter notebook --no-browser --ip=0.0.0.0 --port=9005 > jupyter.log 2>&1 &
```

## jupyter SSH 直接登录

```shell
jupyter notebook --port=8888 --no-browser --ip=0.0.0.0
ssh -N -L localhost:2000:localhost:8888 username@server_ip
```

## 配置R语言环境

conda install r-base -c conda-forge
R
install.packages("IRkernel", repos="<https://mirrors.tuna.tsinghua.edu.cn/CRAN/>")
IRkernel::installspec()
