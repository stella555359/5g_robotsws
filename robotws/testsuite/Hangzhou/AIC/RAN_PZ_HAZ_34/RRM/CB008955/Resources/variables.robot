*** Settings ***
Documentation    author: Luo Tina
...              contact: tina.luo@nokia-sbell.com
...              This file is used to put the common variables

*** Variables ***
# ----------  TTI Decoder server part -----------------
${ttitrace_server_ip}    10.71.217.178
${TTI_username}    nokia5G
${TTI_password}   noki@123
# ----------  Dcap server part -----------------
${DCAP_IP}   10.101.60.50
${DCAP_IPv6}   fe80::cf37:d489:36b:9455
${DCAP_PORT}     443
${DCAP_USER}    dcapuser
${DCAP_PASSWORD}     dcapadmin!
${DCAP_LOG_DIR}     /sharedvolume/uptracer/_data/
${DCAP_CP_LOG_DIR}     /sharedvolume/flowtracer5g/tmp/5G
${DCAP_UP_LOG_DIR}     /sharedvolume/udptracer/_data/
