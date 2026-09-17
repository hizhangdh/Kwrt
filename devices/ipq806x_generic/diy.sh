#!/bin/bash
shopt -s extglob
SHELL_FOLDER=$(dirname $(readlink -f "$0"))

# ===== 添加 uci-defaults 脚本 =====
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-custom-defaults << 'EOF'
#!/bin/sh

# ===== 把 LAN 接口改成 DHCP 客户端 =====
uci set network.lan.proto='dhcp'
uci -q delete network.lan.ipaddr
uci -q delete network.lan.netmask
uci -q delete network.lan.gateway
uci -q delete network.lan.dns
uci commit network

# ===== 关闭 LAN 接口的 DHCP 服务 =====
uci set dhcp.lan.ignore='1'
uci commit dhcp

# 设置 argon 主题
uci -q set luci.main.mediaurlbase='/luci-static/argon'
uci -q set argon.@global[0].mode='normal'
uci commit argon

# 关闭 IPv6 向导
uci -q set wizard.default.ipv6='0'
uci commit wizard

# ===== 允许 WAN 口访问管理页面 =====
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-WAN-Web'
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].dest_port='80 443'
uci set firewall.@rule[-1].target='ACCEPT'
uci commit firewall

# 设置 root 密码
(echo 'root'; sleep 1; echo 'root') | /bin/busybox passwd root >/dev/null 2>&1

exit 0
EOF
chmod +x files/etc/uci-defaults/99-custom-defaults
