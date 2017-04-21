#!/bin/bash
#
#防火墙配置
#
#@author yufei 2014-02-17
#

#清除预设配置
/sbin/iptables -P INPUT ACCEPT
/sbin/iptables -F
/sbin/iptables -X
/etc/init.d/iptables save

#允许架构间服务器访问
/sbin/iptables -A INPUT -s 172.17.159.61 -j ACCEPT
/sbin/iptables -A INPUT -s 172.17.159.62 -j ACCEPT
#/sbin/iptables -A INPUT -s 192.168.1.8 -j ACCEPT

#允许dns
/sbin/iptables -A FORWARD -p udp --dport 53 -j ACCEPT
/sbin/iptables -A INPUT -p udp --dport 53 -j ACCEPT
/sbin/iptables -A OUTPUT -p udp --sport 53 -j ACCEPT

#允许回环口
/sbin/iptables -A INPUT -i lo -p all -j ACCEPT
/sbin/iptables -A OUTPUT -o lo -p all -j ACCEPT

#允许ping
/sbin/iptables -A INPUT -p icmp -m limit --limit 1/s -j ACCEPT
/sbin/iptables -A INPUT -p icmp -j LOG --log-level 4 --log-prefix "iptables_ping"
/sbin/iptables -A INPUT -p icmp -j DROP
/sbin/iptables -A OUTPUT -p icmp -j ACCEPT

#允许连接状态 拒绝非法连接
/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A INPUT -m state --state INVALID -j DROP
/sbin/iptables -A OUTPUT -m state --state INVALID -j DROP
/sbin/iptables -A FORWARD -m state --state INVALID -j DROP

#阻止危险出口
/sbin/iptables -A OUTPUT -p tcp --sport 31337 -j DROP
/sbin/iptables -A OUTPUT -p tcp --dport 31337 -j DROP

#允许ntp时间同步
/sbin/iptables -A INPUT -p udp --dport 123 -j ACCEPT

#ssh
/sbin/iptables -A INPUT -s 192.168.1.8 -p tcp --dport 8022 -j ACCEPT
/sbin/iptables -A INPUT -p tcp -m multiport --dports 22,8022 -j LOG --log-level 4 --log-prefix "iptables_ssh"
/sbin/iptables -A INPUT -s 192.168.1.8 -p tcp --dport 8022 -j ACCEPT
/sbin/iptables -A INPUT -s 172.17.159.61 -p tcp --dport 8022 -j ACCEPT
/sbin/iptables -A INPUT -s 172.17.159.62 -p tcp --dport 8022 -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 8022 -j DROP

/sbin/iptables -A OUTPUT -s 172.17.159.61 -p tcp --dport 22 -j ACCEPT
/sbin/iptables -A OUTPUT -s 172.17.159.62 -p tcp --dport 22 -j ACCEPT
/sbin/iptables -A OUTPUT -s 192.168.1.8 -p tcp --dport 22 -j ACCEPT
/sbin/iptables -A OUTPUT -p tcp --dport 22 -j DROP

#mysql
/sbin/iptables -A INPUT -s 172.17.159.61 -p tcp --dport 3306 -j ACCEPT
/sbin/iptables -A INPUT -s 172.17.159.62 -p tcp --dport 3306 -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 3306 -j DROP
/sbin/iptables -A OUTPUT -s 172.17.159.61 -p tcp --dport 3306 -j ACCEPT
/sbin/iptables -A OUTPUT -s 172.17.159.62 -p tcp --dport 3306 -j ACCEPT
/sbin/iptables -A OUTPUT -p tcp --dport 3306 -j DROP

#web
/sbin/iptables -A INPUT -p tcp --dport 80 -j ACCEPT
/sbin/iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 80 -j ACCEPT
/sbin/iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

#ftp
/sbin/iptables -A INPUT -p tcp -m multiport --dports 21,20,40000:40050 -j LOG --log-level 4 --log-prefix "iptables_ftp"
/sbin/iptables -A INPUT -s 192.168.1.8 -p tcp --dport 21 -j ACCEPT
/sbin/iptables -A INPUT -s 192.168.1.8 -p tcp --dport 20 -j ACCEPT
/sbin/iptables -A INPUT -s 192.168.1.8 -p tcp --dport 40000:40050 -j ACCEPT
/sbin/iptables -A INPUT -p tcp --dport 21 -j DROP

#默认阻止所有端口
/sbin/iptables -P INPUT DROP
/sbin/iptables -P OUTPUT ACCEPT
/sbin/iptables -P FORWARD ACCEPT
/etc/init.d/iptables save
/etc/init.d/iptables restart