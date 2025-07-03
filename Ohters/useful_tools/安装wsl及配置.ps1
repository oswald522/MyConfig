# 手动安装的范围
# 下载地址合集
# https://learn.microsoft.com/en-us/windows/wsl/install-manual
# ubuntu: https://aka.ms/wslubuntu
# ubuntu22.04: https://aka.ms/wslubuntu2204
# ubuntu20.04: https://aka.ms/wslubuntu2004
# ubuntu18.04: https://aka.ms/wsl-ubuntu-1804
# ubuntu16.04: https://aka.ms/wsl-ubuntu-1604
# kali: https://aka.ms/wsl-kali-linux-new
# debian: https://aka.ms/wsl-debian-gnulinux
# 内核升级包https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
# Ubuntu：https://aka.ms/wslubuntu
# Ubuntu22.04：https://aka.ms/wslubuntu2204


# install wsl  after on Windows 10 version 2004 or higher
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
# Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
wsl.exe -l -o
# Ubuntu          Ubuntu
# Debian          Debian GNU/Linux
# kali-linux      Kali Linux Rolling
# openSUSE-42     openSUSE Leap 42
# SLES-12         SUSE Linux Enterprise Server v12
# Ubuntu-16.04    Ubuntu 16.04 LTS
# Ubuntu-18.04    Ubuntu 18.04 LTS
# Ubuntu-20.04    Ubuntu 20.04 LTS
wsl.exe --install -d <Distribution Name>.

wsl.exe --install -d Ubuntu-22.04




$distroName = "Ubuntu22.04"     # Ubuntu发行版名称
$distroUrl = "ubuntu2204"
$distroUser = "test"     # 自定义用户名
$distroPassword = "test123456"  # 自定义密码
# 自动安装wsl2内核
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl.exe --install 








安装WSL2内核升级包
$wslUpdatePath = "wsl_update.msi"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $wslUpdatePath, "/quiet" -Wait
$wslKernelStatus = (wsl -l -v)
if ($wslKernelStatus -match "WSL2") {
    Write-Host "WSL2内核升级包安装成功!"
} else {
    Write-Host "WSL2内核升级包安装失败,请重新尝试！"
}

wsl --set-default-version 2

# $ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri "https://aka.ms/wsl${distroUrl}" -OutFile "$distroName.appx" -UseBasicParsing
Add-AppxPackage "$distroName.appx"

# 创建并进入Ubuntu发行版，并创建新用户
wsl -d $distroName -u root -- bash -c "adduser --disabled-password --gecos '' $distroUser"

# 设置用户密码
wsl -d $distroName -u root -- bash -c "echo '${distroUser}:$distroPassword' | chpasswd"

# 完成提示
Write-Host "WSL2 Ubuntu已安装,用户名为'$distroUser'，密码为'$distroPassword'" -ForegroundColor Green

