#!/bin/bash
shopt -s extglob
SHELL_FOLDER=$(dirname $(readlink -f "$0"))

# 添加 uci-defaults 脚本
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-custom-defaults << 'EOF'
#!/bin/sh
uci set network.lan.ipaddr='192.168.31.1'
uci set network.lan.netmask='255.255.255.0'
uci commit network
uci -q set luci.main.mediaurlbase='/luci-static/argon'
uci -q set argon.@global[0].mode='normal'
uci commit argon
uci -q set wizard.default.ipv6='0'
uci commit wizard
(echo 'root'; sleep 1; echo 'root') | /bin/busybox passwd root >/dev/null 2>&1
exit 0
EOF
chmod +x files/etc/uci-defaults/99-custom-defaults
