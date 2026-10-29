# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB010659_A_b1_101_case11_TDD_UL_CP_OFDM_first_trans_64QAM_table_256QAM_retrans_MCS_30
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LL_AP_LO_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_shuihe
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${gnb_swcfg_src_file}    gNB_swconfig_LL_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.txt
# ${exp_dl_tput}    600000
# ${exp_ul_tput}    270000*3.6094/7.4063
# &{rad_para_dict}    0x340000=15    0x580367=0x4000
# #&{rad_para_dict}    0x340000=15    0x580367=0x10000
# ${SCFC_NAME}      gNB_scf_ASIL_ABIL_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# ${actAdaptiveReTxResMcs}                                  text|true|//*[@name\="actAdaptiveReTxResMcs"]
# ${actAdaptiveReTxResMcsEnh}                                  text|true|//*[@name\="actAdaptiveReTxResMcsEnh"]
# ${ullaDeltaSinrMin}    text|0|//*[@name\="ullaDeltaSinrMin"]
# ${ullaDeltaSinrMax}    text|0|//*[@name\="ullaDeltaSinrMax"]
# ${dllaDeltaCqiMax}    text|0|//*[@name\="dllaDeltaCqiMax"]
# ${dllaDeltaCqiMin}    text|0|//*[@name\="dllaDeltaCqiMin"]
# ${actUl256Qam}    text|true|//*[@name\="actUl256Qam"]
# ${ulDlDataSlotRatio}    text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${FILTER}     uldata_puschreceivereq
# @{title}    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
# ${ini_name}    bip_case07_cpofdm.ini
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB010659_A_b1_101_case11_TDD_UL_CP_OFDM_first_trans_64QAM_table_256QAM_retrans_MCS_30
#     [Documentation]    This test aims at checking adaptative retransmission in case of UL CP-OFDM modulation for MCS 29.
#     Step1:Commission configuration on WebUI Based Rad Flag    ${rad_para_dict}
#     Step2:Attach One NonGBR UEs On H0V0
#     Step3:Push full buffer And check    ${exp_dl_tput}    ${exp_ul_tput}
#     Step4:Add UL Bler and Check
# 
# *** Keywords ***
# Step1:Commission configuration on WebUI Based Rad Flag
#     [Arguments]    ${rad_para_dict}
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	modify_gnb_swconfig_by_10659    ${CONFIG_DIR_PATH}${/}${gnb_swcfg_src_file}    ${rad_para_dict}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
#     ${modify_list}    create list
#     ...    ${actAdaptiveReTxResMcs}    ${actAdaptiveReTxResMcsEnh}    ${ullaDeltaSinrMin}    ${ullaDeltaSinrMax}    ${dllaDeltaCqiMax}
#     ...    ${dllaDeltaCqiMin}    ${actUl256Qam}    ${ulDlDataSlotRatio}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     add_xml_element     ${scfc_path}    ${scfc_path}    <p name="minPctResourceReservedMcsDl">50</p>|//*[matches(@distName, '.*NRCELL-.$')]
#     add_xml_element     ${scfc_path}    ${scfc_path}    <p name="minPctResourceReservedMcsUl">50</p>|//*[matches(@distName, '.*NRCELL-.$')]
#     add_xml_element     ${scfc_path}    ${scfc_path}    <p name="targetPctResourceReservedMcsDl">75</p>|//*[matches(@distName, '.*NRCELL-.$')]
#     add_xml_element     ${scfc_path}    ${scfc_path}    <p name="targetPctResourceReservedMcsUl">75</p>|//*[matches(@distName, '.*NRCELL-.$')]
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach One NonGBR UEs On H0V0
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer And check
#     [Arguments]    ${exp_dl_tput}    ${exp_ul_tput}
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
#     : FOR    ${i}    IN RANGE    1     6
#     \    Airphone SA Start Data Traffic    1    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    1    UL    50M    trf_id=${i}    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    8
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > ${exp_dl_tput}
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue1} > ${exp_ul_tput}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Add UL Bler and Check
#     Start Capture GNB and AP Syslog in 'Step4_adding_UlBler' File
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command	  ul_cell_noise_testmode_nr profile_id\=1 noise_pusch\=-510
#     Wait Throughput Timer    1
#     airphone_execute_egate_command	  cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=activate
#     Wait Throughput Timer    1
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=300,200,100
#     Wait Throughput Timer    1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=bler action\=activate profile_id\=1
# 	Wait Throughput Timer    5
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_adding_UlBler
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure   check_reTx_status_and_reservedMCS   ${save_log}${/}tti_ul.csv   0.75   0.5
# 	run keyword and continue on failure   check_maxCodeRatePRB   ${save_log}${/}tti_ul.csv   0.97
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_adding_UlBler' File
# 
# 
