#!/usr/bin/env bash

#===============================================================================================
#   System Manager Script
#   Description: A comprehensive and extensible script for server management.
#   Author: Your Name
#   Version: 2.0.0 (Extensible)
#===============================================================================================

# --- Global Variables and Style Definitions ---
readonly C_RED='\033[0;31m'
readonly C_GREEN='\033[0;32m'
readonly C_YELLOW='\033[0;33m'
readonly C_BLUE='\033[0;34m'
readonly C_PURPLE='\033[0;35m'
readonly C_CYAN='\033[0;36m'
readonly C_BOLD='\033[1m'
readonly C_NC='\033[0m'

OS_FAMILY=""
PKG_MANAGER=""
PKG_INSTALL_CMD=""
PKG_UPDATE_CMD=""

# --- Helper Functions ---
_log() {
    local level="$1" color="$2"; shift 2
    echo -e "${C_BOLD}${color}[${level}]$(date '+%Y-%m-%d %H:%M:%S')${C_NC} $*"
}
info() { _log "INFO" "${C_GREEN}" "$@"; }
warn() { _log "WARN" "${C_YELLOW}" "$@"; }
error() { _log "ERROR" "${C_RED}" "$@"; }
prompt() { _log "PROMPT" "${C_CYAN}" "$@"; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "此脚本需要以 root 权限运行！请使用 'sudo bash $0'。"
        exit 1
    fi
}

press_any_key_to_continue() {
    echo ""
    prompt "请按任意键继续..."
    # shellcheck disable=SC2162
    read -n 1 -s
}

detect_os() {
    if [[ -n "$OS_FAMILY" ]]; then return; fi
    info "正在检测操作系统..."
    if grep -qi "debian" /etc/os-release || grep -qi "ubuntu" /etc/os-release; then
        OS_FAMILY="debian"; PKG_MANAGER="apt-get"; PKG_INSTALL_CMD="apt-get install -y"; PKG_UPDATE_CMD="apt-get update"
    elif grep -qi "centos" /etc/os-release || grep -qi "rhel" /etc/os-release || grep -qi "fedora" /etc/os-release; then
        OS_FAMILY="rhel"; if command -v dnf &>/dev/null; then PKG_MANAGER="dnf"; else PKG_MANAGER="yum"; fi
        PKG_INSTALL_CMD="$PKG_MANAGER install -y"; PKG_UPDATE_CMD="$PKG_MANAGER makecache"
    else
        error "不支持的操作系统！目前仅支持 Debian/Ubuntu 和 CentOS/RHEL 系列。"
        exit 1
    fi
    info "检测到操作系统: ${C_BOLD}${OS_FAMILY}${C_NC}, 包管理器: ${C_BOLD}${PKG_MANAGER}${C_NC}"
}

# --- Global Variables for Extensible Functions ---
declare -a OTHER_FUNC_DESCS
declare -a OTHER_FUNC_NAMES

# --- Core Feature Functions (1-10) ---

func_new_system_setup() {
    info "==================== 开始：新系统一键开荒 ===================="
    detect_os
    func_create_user; press_any_key_to_continue
    func_change_mirror; press_any_key_to_continue
    func_install_common_tools; press_any_key_to_continue
    func_install_docker; press_any_key_to_continue
    func_tune_system; press_any_key_to_continue
    func_fetch_configs; press_any_key_to_continue
    func_harden_ssh
    info "==================== 完成：新系统一键开荒 ===================="
    info "所有基础设置已完成。请务必按照SSH部分的提示进行最终验证！"
}

func_reinstall_system() {
    warn "功能说明：此功能将显示重装系统（DD脚本）的命令。"
    warn "${C_BOLD}这是一个高危操作，会清除服务器所有数据！${C_NC}"
    warn "脚本不会自动执行，请您手动复制并执行命令。"
    echo -e "------------------------------------------------------------------"
    prompt "推荐的一键DD脚本命令 (使用管道符，无需保存文件)："
    echo -e "${C_YELLOW}curl -fsL https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh | bash"
    echo -e "------------------------------------------------------------------"
}

func_create_user() {
    info "--- 开始：新建用户 ---"
    read -rp "$(prompt '请输入新用户名 [默认为 test]: ')" username
    username=${username:-test}
    while true; do
        read -rsp "$(prompt "请输入 ${username} 的密码: ")" password; echo
        read -rsp "$(prompt '请再次输入密码以确认: ')" password_confirm; echo
        if [[ "$password" == "$password_confirm" && -n "$password" ]]; then break; else warn "密码不匹配或为空，请重试。"; fi
    done
    if id "$username" &>/dev/null; then warn "用户 ${username} 已存在。"; else
        info "正在创建用户: ${username}..."; useradd -m -s /bin/bash "$username"
        if [[ $? -eq 0 ]]; then info "用户 ${username} 创建成功。"; else error "创建用户失败！"; return 1; fi
    fi
    info "设置密码..."; echo "$username:$password" | chpasswd
    if [[ $? -ne 0 ]]; then error "密码设置失败！"; return 1; fi
    info "添加 sudo 权限..."; if [[ "$OS_FAMILY" == "debian" ]]; then usermod -aG sudo "$username"; else usermod -aG wheel "$username"; fi
    info "--- 完成：新建用户 ---"
}

func_change_mirror() {
    info "--- 开始：更换系统镜像源 ---"
    detect_os; warn "自动更换镜像源逻辑复杂，此处仅提供通用命令提示和备份功能。"
    local source_file; if [[ "$OS_FAMILY" == "debian" ]]; then source_file="/etc/apt/sources.list"; else source_file="/etc/yum.repos.d/CentOS-Base.repo"; fi
    if [[ -f "$source_file" ]]; then cp "$source_file" "${source_file}.bak_$(date +%F)"; info "已备份 ${source_file}"; fi
    prompt "请从以下镜像站获取配置并手动替换："; echo -e "${C_BLUE} - 阿里云: developer.aliyun.com/mirror/\n - 清华: mirrors.tuna.tsinghua.edu.cn/";
    info "更换后，请运行 '${C_BOLD}${PKG_UPDATE_CMD}${C_NC}' 来更新缓存。"
}

func_harden_ssh() {
    info "--- 开始：SSH 安全加固 ---"; local sshd_config="/etc/ssh/sshd_config"
    if [[ ! -f "$sshd_config" ]]; then error "未找到 SSH 配置文件!"; return 1; fi
    local backup_file="${sshd_config}.bak_$(date +%F-%T)"; info "备份 SSH 配置到: ${backup_file}"; cp "$sshd_config" "$backup_file"
    read -rp "$(prompt '请输入新的SSH端口号 (10000-65535) [默认为 22334]: ')" new_port; new_port=${new_port:-22334}
    info "正在修改 SSH 配置..."; sed -i -e "s/^#*Port .*/Port ${new_port}/" -e "s/^#*PermitRootLogin .*/PermitRootLogin no/" -e "s/^#*PubkeyAuthentication .*/PubkeyAuthentication yes/" -e "s/^#*PasswordAuthentication .*/PasswordAuthentication no/" "$sshd_config"
    info "SSH 配置修改完成。预览如下："; echo -e "${C_PURPLE}--------------------"; grep -E "^Port |^PermitRootLogin |^PubkeyAuthentication |^PasswordAuthentication " "$sshd_config"; echo -e "--------------------${C_NC}"
    warn "${C_BOLD}重要提示：SSH服务尚未重启！${C_NC}"; warn "1. 确保已配置公钥并放行新端口 ${new_port}。"; warn "2. ${C_BOLD}请新开终端测试连接成功后${C_NC}，再执行 'sudo systemctl restart sshd'。"
}

func_tune_system() {
    info "--- 开始：系统调优 ---"; info "将使用 Jerry048 的一键调优脚本。"; warn "此脚本会修改内核参数，请了解后再执行。"
    bash <(wget -qO- https://raw.githubusercontent.com/jerry048/Tune/main/tune.sh)
    info "--- 完成：系统调优 ---"
}

func_install_sing_box() {
    info "--- 开始：安装 sing-box ---"; info "将使用 233boy 的一键安装脚本。"
    bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)
    info "--- 完成：安装 sing-box ---"
}

func_install_common_tools() {
    info "--- 开始：安装常用软件 ---"; detect_os; local packages="zsh git curl axel tmux wget axel sudo unar"
    info "更新软件包列表..."; ${PKG_UPDATE_CMD} > /dev/null 2>&1
    info "安装: ${packages}..."; ${PKG_INSTALL_CMD} ${packages}
}

func_install_docker() {
    info "--- 开始：安装 Docker ---"; if command -v docker &>/dev/null; then info "Docker 已安装。"; return; fi
    info "使用官方脚本安装..."; curl -fsSL https://get.docker.com -o get-docker.sh
    if [[ $? -ne 0 ]]; then error "下载脚本失败！"; return 1; fi
    sh get-docker.sh --mirror Aliyun; rm -f get-docker.sh
    if command -v docker &>/dev/null; then info "Docker 安装成功，已设为开机自启。";
    touch /etc/docker/daemon.json;tee /etc/docker/daemon.json > /dev/null <<EOF
{
    "registry-mirrors": [
        "https://docker.baos.eu.org",
        "https://docker.1ms.run"
    ]
}
EOF
systemctl start docker; systemctl enable docker; else error "Docker 安装失败！"; fi
}

# 10. 拉取常用配置文件
func_fetch_configs() {
    info "--- 开始：拉取常用配置文件 ---"
    warn "此功能将从网络下载配置文件。请确保您信任配置文件的来源！"

    # 1. 定义配置文件源
    # 使用 Grml 的 zshrc，这是一个非常强大和流行的配置
    local zshrc_url="https://github.com/"
    local pip_conf_content="[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple"

    # 2. 询问目标用户
    read -rp "$(prompt '要为哪个用户配置? [默认为当前登录用户 '$SUDO_USER']: ')" target_user
    target_user=${target_user:-$SUDO_USER}

    if ! id "$target_user" &>/dev/null; then
        error "用户 ${target_user} 不存在！"
        return 1
    fi
    local target_home
    target_home=$(eval echo "~$target_user")
    info "将为用户 ${C_BOLD}${target_user}${C_NC} (主目录: ${target_home}) 进行配置..."

    # 3. 配置 ZSH (.zshrc)
    if command -v zsh &>/dev/null; then
        info "正在处理 .zshrc 配置..."
        local zshrc_path="${target_home}/.zshrc"

        # 检查 .zshrc 是否已存在
        if [[ -f "$zshrc_path" ]]; then
            warn "检测到用户 ${target_user} 已存在 .zshrc 文件。"
            read -rp "$(prompt '您想如何操作? [O]verwrite(覆盖), [B]ackup and overwrite(备份后覆盖), [S]kip(跳过): ')" -n 1 zsh_choice
            echo "" # 换行
            case "$zsh_choice" in
                o|O)
                    info "将直接覆盖现有文件。"
                    ;;
                b|B)
                    local backup_path="${zshrc_path}.bak_$(date +%F-%T)"
                    info "正在备份当前 .zshrc 到 ${backup_path}"
                    mv "$zshrc_path" "$backup_path"
                    ;;
                s|S)
                    info "已跳过 .zshrc 的配置。"
                    # 跳过 zsh 部分，继续后续的 pip 配置
                    # 使用 continue 2 跳出 case 和 if
                    goto_pip=true
                    ;;
                *)
                    warn "无效选择，已自动跳过 .zshrc 配置。"
                    goto_pip=true
                    ;;
            esac
        fi
        
        # 如果没有选择跳过，则执行下载
        if [[ "$goto_pip" != true ]]; then
            info "正在从 Grml 下载 .zshrc 文件..."
            # 使用 -o 指定输出文件，-s 静默模式，-L 跟随重定向，-f 失败时静默
            curl -fLso "$zshrc_path" "$zshrc_url"
            if [[ $? -eq 0 ]]; then
                info ".zshrc 文件下载成功。"
                chown "${target_user}:${target_user}" "$zshrc_path"
                info "文件所有者已设置为 ${target_user}。"
                warn "要使新配置生效，请为用户 ${target_user} 重新登录或执行 'source ~/.zshrc'。"
            else
                error "下载 .zshrc 文件失败！请检查网络或URL。"
            fi
        fi
    else
        warn "未检测到 zsh 命令，跳过 .zshrc 配置。"
    fi

    # 4. 配置 Pip
    info "正在处理 pip.conf 配置..."
    local pip_dir="${target_home}/.pip"
    local pip_conf_path="${pip_dir}/pip.conf"
    if [[ -f "$pip_conf_path" ]]; then
        warn "pip.conf 已存在，跳过配置以防覆盖。"
    else
        mkdir -p "$pip_dir"
        echo -e "$pip_conf_content" > "$pip_conf_path"
        chown -R "${target_user}:${target_user}" "$pip_dir"
        info "pip.conf 已成功创建并配置为清华源。"
    fi
    
    info "--- 完成：拉取常用配置文件 ---"
}

# --- Extensible Function Handling ---

load_other_functions() {
    local func_dir="functions.d"
    info "正在加载扩展功能..."
    if [[ ! -d "$func_dir" ]]; then warn "未找到扩展目录 'functions.d'。"; return; fi
    for f in "$func_dir"/*.sh; do
        if [[ -f "$f" ]]; then
            unset OTHER_FUNC_NAME OTHER_FUNC_DESC
            # shellcheck source=/dev/null
            source "$f"
            if [[ -n "$OTHER_FUNC_NAME" && -n "$OTHER_FUNC_DESC" ]]; then
                OTHER_FUNC_DESCS+=("$OTHER_FUNC_DESC"); OTHER_FUNC_NAMES+=("$OTHER_FUNC_NAME")
                info "  -> 已加载: ${C_CYAN}${OTHER_FUNC_DESC}${C_NC}"
            else
                warn "文件 '$f' 格式不规范，已忽略。"
            fi
        fi
    done
}

show_other_functions_menu() {
    if [[ ${#OTHER_FUNC_DESCS[@]} -eq 0 ]]; then warn "没有找到任何扩展功能。"; press_any_key_to_continue; return; fi
    while true; do
        clear; echo -e "${C_BOLD}${C_PURPLE}================== 其他功能 ==================${C_NC}"
        for i in "${!OTHER_FUNC_DESCS[@]}"; do echo -e "  ${C_GREEN}$((i+1)).${C_NC}  ${OTHER_FUNC_DESCS[$i]}"; done
        echo -e "\n  ${C_GREEN}0.${C_NC}  返回主菜单\n${C_BOLD}${C_PURPLE}============================================${C_NC}"
        read -rp "$(prompt '请选择: ')" choice
        if [[ "$choice" == "0" ]]; then break; fi
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice > 0 && choice <= ${#OTHER_FUNC_NAMES[@]} )); then
            local func_to_run="${OTHER_FUNC_NAMES[$((choice-1))]}"
            info "执行: ${OTHER_FUNC_DESCS[$((choice-1))]}"
            if command -v "$func_to_run" &>/dev/null; then $func_to_run; else error "函数 '$func_to_run' 未定义!"; fi
            press_any_key_to_continue
        else
            warn "无效输入。"; press_any_key_to_continue
        fi
    done
}

# --- Menu Display and Main Logic ---

# --- Menu Display and Main Logic ---

show_main_menu() {
    clear
    echo -e "${C_BOLD}${C_PURPLE}=======================================================${C_NC}"
    echo -e "${C_BOLD}${C_CYAN}          服务器综合管理脚本 V2.1 (可扩展)           ${C_NC}"
    echo -e "${C_BOLD}${C_PURPLE}=======================================================${C_NC}\n"
    
    echo -e "${C_YELLOW}  --- 核心功能 ---${C_NC}"
    echo -e "  ${C_GREEN}1.${C_NC}  新系统开荒 (组合: 3,4,5,6,8,9,10)"
    echo -e "  ${C_GREEN}2.${C_NC}  ${C_RED}重装系统 (DD脚本) [高危! 清空数据]${C_NC}\n"
    
    echo -e "${C_YELLOW}  --- 分步功能 (系统与安全) ---${C_NC}"
    echo -e "  ${C_GREEN}3.${C_NC}  新建用户并设置密码"
    echo -e "  ${C_GREEN}4.${C_NC}  更换系统镜像源 (手动)"
    echo -e "  ${C_GREEN}5.${C_NC}  SSH 安全加固 (改端口/禁密码/禁Root)"
    echo -e "  ${C_GREEN}6.${C_NC}  系统调优 (BBR/内核参数)"
    echo -e "  ${C_GREEN}7.${C_NC}  节点配置 (安装 sing-box)\n"
    
    echo -e "${C_YELLOW}  --- 分步功能 (软件与配置) ---${C_NC}"
    echo -e "  ${C_GREEN}8.${C_NC}  安装常用工具 (zsh, git, curl, etc.)"
    echo -e "  ${C_GREEN}9.${C_NC}  安装 Docker"
    echo -e "  ${C_GREEN}10.${C_NC} 拉取常用配置文件 (zsh, git, pip)\n"
    
    echo -e "${C_YELLOW}  --- 扩展功能 ---${C_NC}"
    echo -e "  ${C_GREEN}99.${C_NC} 其他功能 (从 'functions.d' 目录加载)\n"
    
    echo -e "  ${C_GREEN}0.${C_NC}  退出脚本\n"
    echo -e "${C_BOLD}${C_PURPLE}=======================================================${C_NC}"
}

main() {
    check_root
    load_other_functions
    while true; do
        show_main_menu
        prompt "请输入您要执行的功能编号 (可多选, 用空格分隔):"
        read -rp "" user_choices
        if [[ -z "$user_choices" ]]; then warn "输入为空。"; press_any_key_to_continue; continue; fi
        for choice in $user_choices; do
            if ! [[ "$choice" =~ ^[0-9]+$ ]]; then warn "无效输入: '$choice'。"; continue; fi
            case $choice in
                1) func_new_system_setup ;;
                2) func_reinstall_system ;;
                3) func_create_user ;;
                4) func_change_mirror ;;
                5) func_harden_ssh ;;
                6) func_tune_system ;;
                7) func_install_sing_box ;;
                8) func_install_common_tools ;;
                9) func_install_docker ;;
                10) func_fetch_configs ;;
                99) show_other_functions_menu ;;
                0) info "感谢使用，脚本退出。"; exit 0 ;;
                *) warn "无效选项: ${choice}" ;;
            esac
            if [[ "$choice" != "99" && "$choice" != "0" && "$choice" != "1" ]]; then press_any_key_to_continue; fi
        done
        [[ " $user_choices " =~ " 0 " ]] && break
    done
}

# --- Script Entry Point ---
main