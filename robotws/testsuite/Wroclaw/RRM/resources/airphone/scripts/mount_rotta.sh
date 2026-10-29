#!/bin/bash

krb5_cfg=$(cat <<EOF
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


sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y krb5-user keyutils cifs-utils

echo "$krb5_cfg" | sudo tee /etc/krb5.conf > /dev/null

directory_path="/home/ute/rotta/5G_3"
mkdir -p $directory_path
chown ute:ute $directory_path

echo "user :"; read user
kinit $user;sudo mount -t cifs -o username=${user}@NSN-INTRA.NET,domain=NSN-INTRA,rw,norelatime,uid=1000,gid=1000,sec=krb5 //eseefsn50.emea.nsn-net.net/rotta4internal/5G_3 $directory_path
