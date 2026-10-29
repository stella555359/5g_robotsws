#!/bin/bash

# this script comes from Francois Tourlonnias reply in https://web.yammer.com/main/org/nokia.com/threads/eyJfdHlwZSI6IlRocmVhZCIsImlkIjoiMjQ2NDgxNDE1NTYwMzk2OCJ9
# and modified by zhangyin
content_sl=$(cat <<EOF
deb http://deb.debian.org/debian/ buster main contrib non-free@
deb-src http://deb.debian.org/debian/ buster main contrib non-free@
@

deb http://deb.debian.org/debian-security/ buster/updates main contrib non-free@
deb-src http://deb.debian.org/debian-security/ buster/updates main contrib non-free@
@

deb http://deb.debian.org/debian/ buster-updates main contrib non-free@
deb-src http://deb.debian.org/debian/ buster-updates main contrib non-free@

EOF
)

content_krb5_conf=$(cat <<EOF
[logging]
         default = FILE:/var/log/krb5libs.log
        kdc = FILE:/var/log/krb5kdc.log
        admin_server = FILE:/var/log/kadmind.log
[libdefaults]
        default_realm = NSN-INTRA.NET
        dns_lookup_realm = true
        dns_lookup_kdc = true
        ticket_lifetime = 365d
        renew_lifetime = 365d
        forwardable = yes
[realms]
        NSN-INTRA.NET = {
        kdc = cnhzdc004.nsn-intra.net
        kdc = fihedc002.nsn-intra.net
        kdc = defrdc001.emea.nsn-net.net
        kdc = plwrdc002.emea.nsn-net.net
        kdc = inbhdc009.apac.nsn-net.net
        kdc = uschdc006.americas.nsn-net.net
        admin_server = NSN-INTRA.NET
 }
[domain_realm]
        nsn-intra.net = NSN-INTRA.NET
        .nsn-intra.net = NSN-INTRA.NET
[appdefaults]
        pam = {
 debug = false
 krb4_convert = false
 }
EOF
)

install_krb5_user() {
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update
    sudo apt-get upgrade

    sudo cp -p /etc/apt/sources.list /etc/apt/sources.list_bck
    #echo $content_sl | sudo tee -a /etc/apt/sources.list
    tr -d '@' <<<"$content_sl" | sudo tee -a /etc/apt/sources.list > /dev/null
    #cat /etc/apt/sources.list
    sudo apt-get -y install krb5-user
    sudo mv /etc/apt/sources.list_bck /etc/apt/sources.list
}

mount_rotta() {
    echo "please input your NSN-INTRA username:"
    read login
    echo "$content_krb5_conf" | sudo tee "/etc/krb5.conf" > /dev/null
    mkdir -p /home/ute/rotta
    sudo kinit $login
    sudo mount -t cifs -o username=$login,domain=NSN-INTRA,sec=krb5,uid=1000,gid=1000 //eseefsn50.emea.nsn-net.net/rotta4internal /home/ute/rotta
    sub_dir=$(ls /home/ute/rotta)
    if [ -n  "$sub_dir" ]
    then
        echo "rotta is mounted to /home/ute/rotta successfully"
    else
        echo "fail to mount rotta"
    fi
}

install_krb5_user
mount_rotta
