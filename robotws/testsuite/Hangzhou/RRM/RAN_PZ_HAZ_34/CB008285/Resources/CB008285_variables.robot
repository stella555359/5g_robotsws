*** Settings ***
Documentation    This is about common variables used for 2329 feature.



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

${DL_TPUT_COMMON}   550M
${UL_TPUT_COMMON}   160M

${EXP_DL_COMMON}    533
${EXP_UL_COMMON}    144

${EXP_DL_B4}    426
${EXP_UL_B4}    133


${FILTER_RRC_RECONFIG}    (nr-rrc.rrcReconfiguration_element)  && (nr-rrc.dmrs_AdditionalPosition == 0)
${CODEBOOK_XPATH}  .//nr-rrc.codebookSubset
${DMRS_XPATH}                                    .//nr-rrc.dmrs_UplinkForPUSCH_MappingTypeB//nr-rrc.dmrs_AdditionalPosition
${PUCCH_RESOURCE}
${FILTER_RRC_SETUP}       ((nr-rrc.setup_element)&&!(nr-rrc.rrcReconfiguration_element)) && (f1ap.procedureCode == 12)
${CQI_XPATH}   .//nr-rrc.cri_RI_PMI_CQI_element//..//..//nr-rrc.reportConfigType//nr-rrc.pucch_Resource
${BEAM_REPORT_XPATH}   .//nr-rrc.ssb_Index_RSRP_element//..//..//nr-rrc.reportConfigType//nr-rrc.pucch_Resource

${TCEIPADDRESS}          10.57.167.186
${TCEPORTNUMBER}         49151

${EMIL_HOST}             ${tl.ues[0].ue_pc_address}
${EMIL_USER}             ${tl.ues[0].ue_pc_login}
${EMIL_PASSWORKD}        ${tl.ues[0].ue_pc_password}
${TRACE_HOST}            10.57.167.186
${TRACE_USER}            dcapuser
${TRACE_PASSWORD}        tester@Hzmm1
${TRACE_FOLDER}          /sharedvolume/ntracer/_data
${GLOBAL_BTS_ID}         ${tl.gnbs[0].global_bts_id}

${nTracer_name}          nTracer

${EMIL_PROTOCOL}         5G Cell Trace
${PROFILE_PATH}
${EMIL_PATH}             /cygdrive/c/Program Files/Emil
${CHECK_MESSAGE_FILE}    attach_message.txt
${EMIL_LOG_DIR}          /cygdrive/c/temp/emil_logs

${gNb_CuType}   SA
${X2_link_shutdown_time}    0

${dscp}           15
${timeout}        180
@{selenium_gnb_login}


${1CC_PERCENT}   0.95
${8CC_tput_UL}   600M
${8CC_tput_DL}   4300M
${8CC_tput_UL_EXP}   578
${8CC_tput_DL_EXP}    4200
${8CC_PERCENT}    0.85
