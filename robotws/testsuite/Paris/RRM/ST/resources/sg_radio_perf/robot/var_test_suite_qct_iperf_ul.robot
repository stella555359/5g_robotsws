*** Settings ***
Documentation
...     Test Suite Purpose:
...         Variable file for iperf UL manipulation along with QCT UE
...

*** Variables ***
# ${ULserver_ip}=          ${custom['iPerf_VM_UL_ipaddress']}
# ${ULserver_login}=       ${custom['iPerf_VM_UL_login']}
# ${ULserver_pwd}=         ${custom['iPerf_VM_UL_passwd']}
# ====================================
# only match with QCT/Anrdoid, not prisma
${ULserver_ip}=            ${tl.ues[0].ssh_connection_details.addr}
${ULserver_login}=         ${tl.ues[0].ssh_connection_details.username}
${ULserver_pwd}=           ${tl.ues[0].ssh_connection_details.password}
# ue ip should be retrieved dyn when Ue is QCT