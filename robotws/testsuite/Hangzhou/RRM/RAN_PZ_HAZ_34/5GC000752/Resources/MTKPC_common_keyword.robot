*** Settings ***
Documentation
...   author: Haijun Zhang
...   contact: haijun.zhang@nokia-sbell.com
Library           Telnet    WITH NAME    telnet
Library           taf.transport.ssh    WITH NAME    ssh
Library           output2dict.py


*** Variables ***
${MTKPC_IP}                 ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${MTKPC_USERNAME}           ${tl.ues[0].iperf_details.ssh_connection_details.username}
${MTKPC_PASSWORD}           ${tl.ues[0].iperf_details.ssh_connection_details.password}
${MTKPC_IPERFPATH}          ${tl.ues[0].iperf_details.iperf_path}
${ALIAS_MTKPC}              alias_mtkpc


*** Keywords ***
