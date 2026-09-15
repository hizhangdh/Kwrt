#!/bin/bash
shopt -s extglob
SHELL_FOLDER=$(dirname $(readlink -f "$0"))

# 设置默认 LAN IP 为 192.168.31.1/24
sed -i "s/192.168.1.1/192.168.31.1/g" package/base-files/files/bin/config_generate

# 设置默认主题为 argon
sed -i "s/luci-theme-bootstrap/luci-theme-argon/g" feeds/luci/collections/luci/Makefile

# 添加 uci-defaults 脚本
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-custom-defaults << 'EOF'
#!/bin/sh

# 设置 argon 主题为 normal 模式
uci -q set luci.main.mediaurlbase='/luci-static/argon'
uci -q set argon.@global[0].mode='normal'
uci commit argon

# 关闭 IPv6 向导
uci -q set wizard.default.ipv6='0'
uci commit wizard
/etc/init.d/wizard restart

# 提交 luci 配置
uci commit luci

# 设置 root 密码为 root
(echo 'root'; sleep 1; echo 'root') | /bin/busybox passwd root >/dev/null 2>&1

exit 0
EOF
chmod +x files/etc/uci-defaults/99-custom-defaults
