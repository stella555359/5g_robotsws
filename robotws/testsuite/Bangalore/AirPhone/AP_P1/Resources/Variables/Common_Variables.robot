*** Settings ***
Documentation     This file contains common variables used across AP P1 testcases

*** Variables ***

${NOKIA_PASS}            oZPS0POrRieRtu
${GNB_IP}                192.168.255.129
${AP_IP}                 192.168.200.1
${WTS_INSTALL_PATH}      /opt/wts/latest
${UE_ID}                 1
${PROFILE_ID}            1
${BEARER_ID}             2
${GNB_ID}                2
${CELL_ID}               2
${DU_HOST}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${DU_USER}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_PWD}                ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${LOG_PATH}              ${OUTPUT DIR}
${AP_Username}           toor4nsn
${BTS_ID}                2003
${NRBTS_DISTNAME}        MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
${NRCELL_DISTNAME}       ${NRBTS_DISTNAME}/NRCELL-1
${GNB_USERNAME}          toor4nsn
${EGATE_PORT}            20000
${EDAEMON_PORT}          22222
${GNB_PCAP_NEEDED}       False
${WTS_PCAP_NEEDED}       False
${WTS_PCAP_INTERFACE}    eth3
${RUN_TYPE}              FS_TDD_NSA
# {RUN_TYPE} can be set to FS_TDD_NSA, FS_FDD_NSA, L1B_TDD_SA
&{AP_XML_DICT}           FS_TDD_NSA=AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml
...                      FS_FDD_NSA=AirPhoneConfig_fullstack_fdd_nsa_cmwv.xml
...                      L1B_TDD_SA=AirPhoneConfig_l1bypass_tdd_sa_cmwv.xml
&{SETUP_CFG_DICT}        FS_TDD_NSA=basic_fullstack_nsa_call_tdd_cmwv.cfg
...                      FS_FDD_NSA=basic_fullstack_nsa_call_fdd_cmwv.cfg
...                      L1B_TDD_SA=basic_l1bypass_sa_call_tdd_cmwv.cfg
${AP_XML_NAME}           ${AP_XML_DICT['${RUN_TYPE}']}
${SETUP_CFG_NAME}        ${SETUP_CFG_DICT['${RUN_TYPE}']}
${SETUP_CFG_PATH}        ${WTS_INSTALL_PATH}/${SETUP_CFG_NAME}
${AP_XML_PATH}           ${WTS_INSTALL_PATH}/${AP_XML_NAME}
${WTS_CFG_PATH}          NONE
${SOSREPORT_NEEDED}      True
${GNB_HOST}              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_USER}              ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GNB_PASS}              ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${AP_HOST}               ${tl.ues[0].l1.common_units[0].lmp_connection.addr}
${AP_USER}               ${tl.ues[0].l1.common_units[0].lmp_connection.username}
${AP_PASS}               ${tl.ues[0].l1.common_units[0].lmp_connection.password}
${DEFAULT_DATARATE}      1                 # 1Mbps for both uplink and downlink
${DEFAULT_DATATIMEOUT}   1min
${NUMBER_OF_CELLS}       1
${BIP_CAPTURE_NEEDED}    False
${TOPOLOGY}              CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
${SAVE_WTS_PCAP_FLAG}    True
${WTS_ACTIVE}            False
${DCAP_LOGS_NEEDED}      False
${GNB_TTI_TRACE_NEEDED}      False
${BTS_LOG_NEEDED}        True
${BIP_LOG_NEEDED}        True
${AP_TTI_TRACE_NEEDED}   True
${COPY_PASS_LOGS}        False
${log_iperf_files}       False
${tti_trace_capture}     L2Ps
${RFM_Plugin}            ${EMPTY}