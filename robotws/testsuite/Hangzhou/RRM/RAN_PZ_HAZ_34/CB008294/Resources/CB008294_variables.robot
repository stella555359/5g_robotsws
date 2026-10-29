*** Settings ***
Documentation    This is about common variables used for CB008294 feature.



*** Variables ***
${testline_name}               null
${PERCENT_AVG}                 0.95      # Percent of peak TPUT
${PERCENT_MIN}                 0.85
${IS_UTE_ENV}                  ${False}
${ABSTRACT_LIB_CONFIG}         ${CURDIR}/../../../../../../../testline_configuration/${testline_name}/TestData/cpe_atue.yml
${TCPDUMP_LOG_NAME}            F1ap_log
${TIMER_FOR_MODIFY_VIA_API}    5min
${TIMER_FOR_CELL_ON_AIR}       8min


# UE and UE PC info
${UE_IP}                    ${tl.ues[0].data_transfer[0].bind_ue_ip}
${UE_PC_IP}                 ${tl.ues[0].ue_pc_address}
${UE_PC_USERNAME}           ${tl.ues[0].ue_pc_login}
${UE_PC_PASSWD}             ${tl.ues[0].ue_pc_password}
${UE_SN}                    ${tl.ues[0].serial_number}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_NAME}                 ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PWD}                  ${tl.test_pc.default_ssh_connection_details.password}
${GNB_IP}                   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}                ${tl.gnbs[0].cu.oam_http_connection_details.password}

${APPSERVER_ADDR}                   ${tl.ues[0].data_transfer[0].app_server.address}
${APPSERVER_USERNAME}               ${tl.ues[0].data_transfer[0].app_server.user}
${APPSERVER_PASSWORD}               ${tl.ues[0].data_transfer[0].app_server.password}
${APPSERVER_PORT}                   ${tl.ues[0].data_transfer[0].app_server.app_server_name}

${DL_TPUT_COMMON}   4300M
${UL_TPUT_COMMON}   600M
${DL_TPUT_4CC_COMMON}   2200M
${DL_TPUT_1CC_COMMON}   550M
${DL_TPUT_7CC_COMMON}   3800M

${DL_TPUT_LOW}   3800M

${EXP_DL_8CC}    4200
${EXP_UL_4CC}    578

${EXP_DL_1CC}    533
${EXP_UL_1CC}    144

${EXP_DL_4CC}    2132
${EXP_UL_4CC}    578

${EXP_DL_7CC}    3731
${EXP_UL_3CC}    432

${EXP_DL_8CC_B4}    3600
${EXP_UL_4CC_B4}    532

${GLOBAL_BTS_ID}         ${tl.gnbs[0].global_bts_id}

${ATTACH_RESULT}   ${False}

