#!/usr/bin/env bash

# 规范第一步：定义此功能的菜单描述
# 这个变量会被主脚本读取，用于在二级菜单中显示
OTHER_FUNC_DESC="安装 htop - 一个交互式进程查看器"

# 规范第二步：定义此功能要调用的函数名
# 这个变量告诉主脚本，当用户选择此项时，应该执行哪个函数
OTHER_FUNC_NAME="func_install_htop"

# 规范第三步：实现这个函数
# 函数名必须与 OTHER_FUNC_NAME 的值完全一致
func_install_htop() {
    # 在这里编写功能的具体实现代码
    info "--- 开始：安装 htop ---"
    
    # 可以直接使用主脚本中定义的全局函数和变量，因为此文件是被 source 的
    detect_os
    
    info "正在使用 ${PKG_MANAGER} 安装 htop..."
    ${PKG_INSTALL_CMD} htop
    
    if [[ $? -eq 0 ]]; then
        info "htop 安装成功。"
        info "您可以直接在终端输入 'htop' 来运行它。"
    else
        error "htop 安装失败。"
    fi
    
    info "--- 完成：安装 htop ---"
}