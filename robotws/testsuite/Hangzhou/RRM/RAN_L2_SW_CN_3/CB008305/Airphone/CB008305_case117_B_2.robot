# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case117_B_2_multiple_UEs_mixed_scheduling_with_1_layer_to_4_layers_mixed
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_shuihe
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
# ${dlMuMimoRankAdaption}                         text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
# ${miNrCellUtilPerPLMN}                           text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case117_B_2_multiple_UEs_mixed_scheduling_with_1_layer_to_4_layers_mixed
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 2 NonGBR UEs
#     Step3:Push full buffer And Check Pair
#     Step4.1:Make UE1 report rank3
#     Step4.2:Make UE1 report rank2
#     Step4.3:Make UE1 report rank1
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    15    6    15    6    15    6    15    6    0
#     Set Pos By Modify L1ByPTestModeConfiguration    12    6    12    6    12    6    12    6    1
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${msg1FrequencyStart}
#     ...       ${schedulBSD}    ${dlMuMimoRankAdaption}    ${miNrCellUtilPerPLMN}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 2 NonGBR UEs
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
#     Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer And Check Pair
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
# #    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
# #    : FOR    ${UE_ID}    IN RANGE    1      3
# #    \    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1
#     : FOR    ${i}    IN RANGE    1     11
#     \    Airphone SA Start Data Traffic    1    DL    150M    trf_id=${i}     pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    2    DL    150M    trf_id=${i}     pdu_id=1    duration=${3600}
#     Wait Throughput Timer    8
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     : FOR    ${UE_ID}    IN RANGE    1      3
#     \    ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=${UE_ID}    direction=dl
# #    \    run keyword and continue on failure    Should Be True    ${Dl_throughput} > 1400000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# #    run keyword and continue on failure    check_log_with_au2anlysis
# #    ...    ini_path=${CURDIR}/log_check/tti_case117_rank4_4.ini    log_need_to_check=i    save_log_directory=${save_log}
#     run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer${/}
#     ${PM_counter_8layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34011
#     ...   cell_id=1
#     #run keyword and continue on failure    Should Be True    ${PM_counter_8layer_value} > 20000000
# 
# Step4.1:Make UE1 report rank3
#     Start Capture GNB and AP Syslog in 'Step4.1_Make_UE1_report_rank3' File
#     Start GNB BIP Log
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     Wait Throughput Timer    8
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4.1_Make_UE1_report_rank3${/}
#     : FOR    ${UE_ID}    IN RANGE    1      3
#     \    ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=${UE_ID}    direction=dl
# #    \    run keyword and continue on failure    Should Be True    ${Dl_throughput} > 1400000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4.1_Make_UE1_report_rank3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# #    run keyword and continue on failure    check_log_with_au2anlysis
# #    ...    ini_path=${CURDIR}/log_check/tti_case117_rank4_4.ini    log_need_to_check=i    save_log_directory=${save_log}
#     run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4.1_Make_UE1_report_rank3' File
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer${/}
#     ${PM_counter_4layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34007
#     ...   cell_id=1
#     #run keyword and continue on failure    Should Be True    ${PM_counter_4layer_value} > 20000000
# 
# Step4.2:Make UE1 report rank2
#     Start Capture GNB and AP Syslog in 'Step4.2_Make_UE1_report_rank2' File
#     Start GNB BIP Log
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     Wait Throughput Timer    8
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4.2_Make_UE1_report_rank2${/}
#     : FOR    ${UE_ID}    IN RANGE    1      3
#     \    ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=${UE_ID}    direction=dl
# #    \    run keyword and continue on failure    Should Be True    ${Dl_throughput} > 1400000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4.2_Make_UE1_report_rank2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# #    run keyword and continue on failure    check_log_with_au2anlysis
# #    ...    ini_path=${CURDIR}/log_check/tti_case117_rank4_4.ini    log_need_to_check=i    save_log_directory=${save_log}
#     run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4.2_Make_UE1_report_rank2' File
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer${/}
#     ${PM_counter_4layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34007
#     ...   cell_id=1
#     #run keyword and continue on failure    Should Be True    ${PM_counter_4layer_value} > 20000000
# 
# Step4.3:Make UE1 report rank1
#     Start Capture GNB and AP Syslog in 'Step4.3_Make_UE1_report_rank1' File
#     Start GNB BIP Log
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     Wait Throughput Timer    8
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4.3_Make_UE1_report_rank1${/}
#     : FOR    ${UE_ID}    IN RANGE    1      3
#     \    ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=${UE_ID}    direction=dl
# #    \    run keyword and continue on failure    Should Be True    ${Dl_throughput} > 1400000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4.3_Make_UE1_report_rank1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# #    run keyword and continue on failure    check_log_with_au2anlysis
# #    ...    ini_path=${CURDIR}/log_check/tti_case117_rank4_4.ini    log_need_to_check=i    save_log_directory=${save_log}
#     run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4.3_Make_UE1_report_rank1' File
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer${/}
#     ${PM_counter_4layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34007
#     ...   cell_id=1
#     #run keyword and continue on failure    Should Be True    ${PM_counter_4layer_value} > 20000000
#     ${PM_counter_2pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34013
#     ...   cell_id=1
#     #run keyword and continue on failure    Should Be True    ${PM_counter_2pairUE_value} > 20000000
#     ${PM_counter_usedPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C10001
#     ...   cell_id=1
#     #run keyword and continue on failure    Should Be True    ${PM_counter_usedPrb_value} > 20000000
#     ${PM_counter_availPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C10003
#     ...   cell_id=1
#     #run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 20000000
#     ${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C20001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_MaxAllocPrb_value} == 273
#     ${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55338C00001
#     ...   cell_id=1
#     #run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 20000000
# 
