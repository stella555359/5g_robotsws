*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006504


*** Variables ***
# Margin for assisted holdver duration (+/-)
${Margin}=                                  15 min

# maxAbsoluteTimeError for CA
${maxAbsoluteTimeError_for_CA}=             3100

# maxAbsoluteTimeError for NRTDD
${maxAbsoluteTimeError_for_NRTDD}=          500

# Time Error to disable eCPRI
${eCPRI_maxTimeError}=                      1350

# maxAbsoluteTimeError for ENDC
${maxAbsoluteTimeError_for_ENDC}=           3000

# maxAbsoluteTimeError for ENDC step 1
${maxAbsoluteTimeError_for_ENDC_try}=       4000

# Time Error to disable FDD
${FDD_maxTimeError}=                        5000

# maxAbsoluteTimeError for DSS
${maxAbsoluteTimeError_for_DSS}=            500

# OAM 5GNB IP and IDs (or PCELL ENB for CA LTE inter ENB confs)
${bts_addr}=                                ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${gnb_mrbts}=                               MRBTS-${tl.gnbs[1].dus[0].instance_id}
${gnb_nrbts}=                               NRBTS-${tl.gnbs[1].dus[0].global_bts_id}
${gnb_lnbts}=                               LNBTS-${tl.gnbs[1].dus[0].global_bts_id}

# OAM LTE IP and IDs
${enb_addr}=                                ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${enb_mrbts}=                               MRBTS-${tl.gnbs[0].instance_id}
${enb_nrbts}=                               NRBTS-${tl.gnbs[0].global_bts_id}
${enb_lnbts}=                               LNBTS-${tl.gnbs[0].global_bts_id}

# Result to save logs
${result_path}=                             /home/localuser/robot_temporary

# 5G VM
${5g_vm_addr}=                              ${tl.test_pcs[1].default_ssh_connection_details.addr}
${5g_vm_username}=                          ${tl.test_pcs[1].default_ssh_connection_details.username}
${5g_vm_password}=                          ${tl.test_pcs[1].default_ssh_connection_details.password}

# 4G VM
${4g_vm_addr}=                              ${tl.test_pcs[0].default_ssh_connection_details.addr}
${4g_vm_username}=                          ${tl.test_pcs[0].default_ssh_connection_details.username}
${4g_vm_password}=                          ${tl.test_pcs[0].default_ssh_connection_details.password}
