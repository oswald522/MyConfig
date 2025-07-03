# ArchLinux 常见系统增强

## Pacman 和 yay 添加多线程，加快速度下载

使用轻量级的 axle 代替了默认的 wget 来下载升级包，为包管理器 pacman 和 yaourt(yay) 添加多线程下载。具体可见附件

1. paman 添加多线程

   修改文件路径：/etc/[pacman.conf](../config/pacman/pacman.conf)

   编辑 pacman.conf 文件: `vim /etc/pacman.conf` 如果有类似 xfercommand 的话,注释掉,加上下面这句 : **line19:**`XferCommand = /usr/bin/axel -n 15 -q -o %o %u`

1. yay 添加多线程

   使用 yay 安装 aur 软件时，经常因为 github 下载文件超时导致下载失败。
   基本原理是替换 PKBUILD 内下载地址为*github.com*和*raw.githubcomusercontent.com*为*hub.fastgit.xyz*和*raw.fastgit.org*.
   修改文件路径：/etc/[makepkg.conf](../config/pacman/makepkg.conf):
   将 `'http::/usr/bin/wget -c -t 3 –waitretry=3 -O %o %u'` 类似语句改成 `http::/usr/bin/axel -o %o %u`或者`'https::/home/hhn/Software/codes/fake_aria2c -UWget -c -s10 %u -o %o %u'`

## 清理缓存文件，整理空间

1.  `yay -Sccc`
1.  `conda clean --all`
1.  `sudo pacman -R $(pacman -Qdtq)`

## 加快系统启动速度

谨慎进行处理，必须了解相应启动项的功能后进行操作。

1. 查看开机启动时间：`systemd-analyze`
1. 查看开机启动项及启动时间：`systemd-analyze blame`
1. 查看出错启动项：`systemctl --all | grep not-found`
1. 关闭出错启动项（ 以 plymouth-start.service 为例）：`systemctl mask plymouth-start.service`

## 加快 github 下载速度

1. 命令行替代`git config --global url."https://hub.fastgit.org".insteadOf https://github.com`或者直接编辑 ~/.gitconfig 文件替代。取消设置`git config --global --unset url."https://hub.fastgit.org.insteadof"`。

```shell
[url "https://hub.fastgit.org/"]
         insteadOf = https://github.com/
```

1. 使用镜像网站
   使用 github 的镜像网站进行搜索。国内最常用的镜像地址：https://github.com.cnpmjs.org、https://hub.fastgit.xyz、https://gitclone.com
1. 对于 github release 中下载的大文件使用https://toolwa.com/github/来下载，速度起飞,无需注册，亲测有效。
1. cdn 加速
   通过修改系统 hosts 文件的办法，绕过国内 dns 解析，直接访问 GitHub 的 CDN 节点，从而达到 github 访问加速的目的。不需要海外的服务器辅助，直接访问[ineo/github-host](https://gitlab.com/ineo6/hosts/-/raw/master/next-hosts)。
