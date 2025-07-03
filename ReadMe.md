
# 服务器综合管理脚本 (Extensible Server Management Script)

一个功能强大、可扩展的交互式 Shell 脚本，旨在简化新服务器的初始化、配置和日常管理任务。专为需要快速、可靠和可重复部署的运维人员和开发者设计。

## ✨ 主要特性

* **交互式菜单**：通过色彩丰富的菜单进行操作，清晰直观，无需记忆复杂命令。
* **一键开荒**：为全新的服务器提供一键式初始化流程，包括新建用户、更换镜像源、系统调优、安装常用软件等。
* **安全加固**：内置 SSH 安全加固模块，一键修改端口、禁用密码和 Root 登录。
* **模块化设计**：所有功能均为独立模块，易于维护和理解。
* **强大的扩展性**：无需修改主脚本，只需在 `functions.d` 目录中添加功能文件即可动态扩展菜单。
* **鲁棒性**：关键操作前进行备份（如 SSH 配置），并提供清晰的风险提示。
* **系统兼容**：主要支持 Debian/Ubuntu 和 RHEL/CentOS 系列的 Linux 发行版。

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone <您的仓库URL>
cd <仓库目录>
```

### 2. 授予执行权限

```bash
chmod +x manager.sh
```

#### 3. 运行脚本

脚本的大部分功能需要 `root` 权限，请使用 `sudo` 运行。

```bash
sudo bash manager.sh
```

之后，您将看到交互式菜单，根据提示选择要执行的功能即可。

## 📁 文件结构

脚本采用主次分离的结构，便于维护和扩展。

```shell
.
├── manager.sh          # 主管理脚本，负责菜单和核心逻辑
└── functions.d/        # 扩展功能目录
    └── install_htop.sh # 示例：一个独立的、可插拔的功能模块
```

## 🔧 如何扩展功能

本脚本最强大的特性之一就是其扩展性。您无需修改 `manager.sh`，只需在 `functions.d` 目录中添加自己的脚本即可。

**遵循以下三步规范，即可添加一个新功能：**

1. 在 `functions.d` 目录中创建一个新的 `.sh` 文件（例如 `my_feature.sh`）。
2. 在该文件中，定义两个变量和一个函数：
    * `OTHER_FUNC_DESC`: 功能的菜单描述文本。
    * `OTHER_FUNC_NAME`: 要执行的函数名。
    * 实现与 `OTHER_FUNC_NAME` 同名的函数。

**示例：** `functions.d/install_htop.sh`

```bash
#!/usr/bin/env bash

# 1. 定义菜单描述
OTHER_FUNC_DESC="安装 htop - 一个交互式进程查看器"

# 2. 定义要调用的函数名
OTHER_FUNC_NAME="func_install_htop"

# 3. 实现该函数
func_install_htop() {
    info "--- 开始：安装 htop ---"
    detect_os
    ${PKG_INSTALL_CMD} htop
    if [[ $? -eq 0 ]]; then
        info "htop 安装成功。"
    else
        error "htop 安装失败。"
    fi
    info "--- 完成：安装 htop ---"
}
```

完成以上步骤后，重新运行 `manager.sh`，在【99. 其他功能】菜单中就会自动出现您的新功能。

## 📄 许可证

本项目采用 [MIT](https://opensource.org/licenses/MIT) 许可证。
