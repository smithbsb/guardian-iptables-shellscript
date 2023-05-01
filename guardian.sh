#!/bin/bash
#
#Desabilitando o tráfego entre as placas
#################################
echo 0 > /proc/sys/net/ipv4/ip_forward
#
##Apagando e restaurando as chains e tabelas
######################################
iptables -Z  # Zera as regras de todas as chains
iptables -F  # Remove as regras de todas as chains
iptables -X  # Apaga todas as chains
#iptables -t nat -Z
#iptables -t nat -F
#iptables -t nat -X
#iptables -t mangle -Z
#iptables -t mangle -F
#iptables -t mangle -X
#
##Proteção contra ping, SYN Cookies, IP Spoofing e proteções do kernel
##########################################################
echo 1 > /proc/sys/net/ipv4/tcp_syncookies          # Syn Flood (DoS)
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts  # Port scanners
echo 0 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses      # Sem resposta remota
for i in  /proc/sys/net/ipv4/conf/*; do
echo 0 > $i/accept_redirects                # Sem redirecionar rotas
echo 0 > $i/accept_source_route            # Sem traceroute
echo 1 > $i/log_martians                # Loga pacotes suspeitos no kernel
echo 1 > $i/rp_filter                  # Ip Spoofing
echo 1 > $i/secure_redirects; done                      # Redirecionamento seguro de pacotes
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all        # Sem ping e tracert
#
# Carregando os módulos - Não é necessário todos os módulos,
# somente aqueles que você irá utilizar.
# O iptables, por padrão, carrega os módulos principais automaticamente.
# Para identificar qual módulo adicional carregar, você deve elaborar todo o script
# e depois de acordo com o nome do alvo utilizado, você carrega o mesmo módulo.
# Por exemplo, se você utilizar a seguinte regra:
# iptables -A FORWARD -p udp -m multiport --dport 80,1024:65535 -j DROP
# o módulo "ipt_multiport" deve ser carregado.
# Abaixo estão quase todos os módulos.
################################
modprobe ip_tables
modprobe iptable_nat
modprobe iptable_filter
modprobe iptable_mangle
#
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp
modprobe ip_queue
modprobe ip_gre
#
modprobe ipt_LOG
modprobe ipt_MARK
modprobe ipt_REDIRECT
modprobe ipt_REJECT
modprobe ipt_MASQUERADE
modprobe ipt_TCPMSS
modprobe ipt_TOS
modprobe ipt_NETMAP
#
modprobe ipt_limit
modprobe ipt_mac
modprobe ipt_multiport
modprobe ipt_owner
modprobe ipt_state
modprobe ipt_tos
modprobe ipt_mark
modprobe ipt_tcpmss
modprobe ipt_string
modprobe ipt_statistic
#
modprobe nf_nat_pptp
modprobe nf_nat_proto_gre
#
# Definindo políticas padrões
######################
iptables  -P  INPUT DROP  # iptables a política padrão da chain INPUT é proibir tudo
iptables  -P  FORWARD DROP
iptables  -P  OUTPUT ACCEPT
#
# Liberando a Loopback
####################
iptables -A  INPUT -i lo -j ACCEPT
#
## Regras de segurança na internet e acessos
#####################################
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state NEW !  -i  ethx -j DROP    # Interface de entrada da internet
iptables -A FORWARD -m state --state NEW ! -i ethx -j DROP    # Interface de entrada da internet
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP
#
# Redirecionamento para o Squid e mascaramento/compartilhamento
###########################################
iptables -t nat -A PREROUTING -i ethx -p tcp --dport 80 -j REDIRECT --to-port 3128  # Interface da rede interna
iptables -t nat -A POSTROUTING -o ethx -j MASQUERADE  # Interface de entrada da internet
#
# A partir daqui você pode inserir as regras de liberação e bloqueio, não esqueça habilitar no final o tráfego entre as placas.
#
# Habilitando o tráfego entre as placas
##########################
echo 1 > /proc/sys/net/ipv4/ip_forward
#

