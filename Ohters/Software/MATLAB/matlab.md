# matlab 安装教程

1. 安装需要使用到的命令行

```shell
sudo mount Matlab913_R2022b_Lin64.iso /mnt
## GUI 安装
cd /mnt & ./install

## 命令行安装
echo -e "[Desktop Entry]\nName=Matlab\nType=Application\nExec=/usr/local/Polyspace/R2021a/bin/matlab -desktop\nIcon=/usr/local/Polyspace/R2021a/bin/glnxa64/cef_resources/matlab_icon.png\nTerminal=False\nComment=Scientific computing environment" > ~/Desktop/matlab.desktop && chmod +x ~/Desktop/matlab.desktop
```

1. 其他需要复制的内容
   05322-36228-06991-12654-51812-34369-14072-44298-22786-36732-05503-35033-50900-29808-05166-12170-05630-02560-02687-62114-45079-42917-06281-13007-19512-18270

2. 替换文件


[Desktop Entry]
Encoding=UTF-8
Name=Matlab 2018a
Comment=MATLAB
Exec=/usr/local/MATLAB/R2018a/bin/matlab
Icon=/usr/local/MATLAB/R2018a/toolbox/shared/dastudio/resources/MatlabIcon.png
Terminal=true
Type=Application
Categories=Application;



## 命令行安装

cd $MATLAB_INSTALLER_DIR
mkdir matlab
sudo mount Matlab913_R2022b_Lin64.iso ./matlab
sudo ./install -inputFile $INPUT_FILE -mode silent -agreeToLicense yes -fileInstallationKey $FILE_INSTALLATION_KEY -licensePath $LICENSE_FILE_PATH -destinationFolder $MATLAB_INSTALLATION_DIR -tmpdir $TMP_DIR -log $LOG_FILE_PATH