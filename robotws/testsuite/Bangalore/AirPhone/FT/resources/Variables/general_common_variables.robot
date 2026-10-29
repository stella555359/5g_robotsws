*** Settings ****
Documentation    :copyright    : Nokia
                 ...              :author       :

*** Variables ***
${GNB_HOST}              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_USER}              ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GNB_PASS}              ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${AP_HOST}               ${tl.ues[0].l1.common_units[0].lmp_connection.addr}
${AP_USER}               ${tl.ues[0].l1.common_units[0].lmp_connection.username}
${AP_PASS}               ${tl.ues[0].l1.common_units[0].lmp_connection.password}

${DEF_EGATE_CONSOLE_LOG}          /opt/wts/latest/egate_console.log
${DEF_GNB_SYS_LOG}                /home/ute/logs/default_syslog_enbNone.log
${DEF_AP_SYS_LOG}                 /home/ute/logs/default_syslog_iphyNone.log
${ONLINE_GNB_SYS_LOG}             /home/ute/default_syslog_enbNone.log
${ONLINE_AP_SYS_LOG}              /home/ute/default_syslog_iphyNone.log
${CM_SET_LOG_FLUSH}                set_log flush

${VAL_SIB1}                        SystemInformationBlockType1-NR updated
${VAL_REG}                         Received REGISTRATION COMPLETE
${VAL_PDU_SESSION}                 Initial Context Setup Successful
${VAL_UE1_DEREG_REL}               AMF-1: UE CONTEXT RELEASE COMPLETE

${L_GNB_SYS}                       sysGnb
${L_AP_SYS}                        sysAp
${L_AP_GNB_SYS}                    sysApGnb
${L_GNB_BIP}                       gnbBIP
${L_AP_BIP}                        apBIP
${L_GNB_TTI}                       gnbTTI
${L_AP_TTI}                        apTTI
${L_EGATE_CONSOLE}                 egaet_console
${L_EGEN}                          EGEN
${L_EMIL}                          EMIL
${L_GNB_L3}                        gnbL3
${L_WTS_L3}                        wtsL3
${SOFTWARE_INFO}    ${EMPTY}
#Set Global Variable    ${SOFTWARE_INFO}    ${sw_info}
${SW_VERSION_TOTAL}      ${EMPTY}    # 0.800.829
${SW_BRANCH}             ${EMPTY}    # 5G20B
${FILES_BASE_LINK}             http://files.ute.nsn-rdnet.net/builds/enb/base
${TEST_LOG_DIRECTORY()}             /home/ute/logs/test_log_directory/
