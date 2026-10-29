*** Settings ***
Documentation
...     Test Suite Purpose:
...         Variable file for OAM


*** Variables ***


${GN_WEBUI_ASIx}                    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GN_WEBUI_USER}                    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${GN_WEBUI_PASSWORD}                ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_OAM_IP}                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_USER_NAME}                   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ASIK_USER_PWD}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

${MAX_LOOP}                         5
${PATH_Storage}                     ${OUTPUT DIR}
# ${PATH_eCLATPMParser}               ${custom['PATH_eCLATPMParser']}

${test_duration}                    5min
${throughput_dl}                    178Mbits/sec
${throughput_ul}                    80Mbits/sec
${average_throughput_deviation}     10%

# ${pc_ue_addr}                       ${tl.ues[0].ssh_connection_details.addr}
# ${pc_ue_user}                       ${tl.ues[0].ssh_connection_details.username}
# ${pc_ue_pwd}                        ${tl.ues[0].ssh_connection_details.password}
${timeout_for_switch_on}            15   s

${BOARD_NO}                         01