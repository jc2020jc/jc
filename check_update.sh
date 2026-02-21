#!/bin/bash
# OpenClaw 更新前检查脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== OpenClaw 更新前检查 ==="

# 检查命令是否可用
echo -n "1. 检查 openclaw 命令是否可用: "
if command -v openclaw > /dev/null; then
    echo -e "${GREEN}✓${NC}"
    echo -e "   - 当前版本: $(openclaw --version)"
    echo -e "   - 安装位置: $(which openclaw)"
    echo -e "   - 符号链接: $(readlink -f $(which openclaw))"
else
    echo -e "${RED}✗${NC}"
    echo -e "   - 命令未找到，请重新安装"
    exit 1
fi

# 检查磁盘空间
echo -n "2. 检查磁盘空间: "
DISK_AVAIL=$(df -h /usr | awk 'NR==2 {print $4}' | sed 's/G//')
if (( $(echo "$DISK_AVAIL > 2" | bc -l) )); then
    echo -e "${GREEN}✓${NC}"
    echo -e "   - 可用空间: ${DISK_AVAIL}GB"
else
    echo -e "${RED}✗${NC}"
    echo -e "   - 磁盘空间不足"
    exit 1
fi

# 检查内存
echo -n "3. 检查内存: "
MEM_AVAIL=$(free -h | awk '/Mem:/ {print $7}' | sed 's/G//')
if (( $(echo "$MEM_AVAIL > 0.5" | bc -l) )); then
    echo -e "${GREEN}✓${NC}"
    echo -e "   - 可用内存: ${MEM_AVAIL}GB"
else
    echo -e "${YELLOW}⚠${NC}"
    echo -e "   - 内存较低，建议关闭其他应用程序"
fi

# 检查 npm 配置
echo -n "4. 检查 npm 配置: "
if npm config list > /dev/null; then
    echo -e "${GREEN}✓${NC}"
    echo -e "   - npm 版本: $(npm --version)"
    echo -e "   - 节点版本: $(node --version)"
else
    echo -e "${RED}✗${NC}"
    echo -e "   - npm 不可用"
    exit 1
fi

# 检查 node_modules 完整性
echo -n "5. 检查 OpenClaw 安装完整性: "
INSTALL_PATH=$(dirname $(readlink -f $(which openclaw)))
if [ -d "$INSTALL_PATH/node_modules" ] && [ -d "$INSTALL_PATH/dist" ]; then
    echo -e "${GREEN}✓${NC}"
    echo -e "   - 安装目录完整"
    echo -e "   - 包含 node_modules 和 dist 目录"
else
    echo -e "${YELLOW}⚠${NC}"
    echo -e "   - 安装目录可能不完整，建议重新安装"
fi

# 检查配置文件
echo -n "6. 检查配置文件: "
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC}"
    echo -e "   - 配置文件不存在，将在首次运行时创建"
fi

echo "=== 检查完成 ==="
echo -e "${YELLOW}注意:${NC} 建议在更新前备份配置文件"
echo "   cp -r ~/.openclaw ~/.openclaw.bak"
