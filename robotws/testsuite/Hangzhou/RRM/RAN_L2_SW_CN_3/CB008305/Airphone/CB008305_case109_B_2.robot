# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case109_B_2_Peak_throughput_of_4_UEs_8DL_layers_with_25dB_tapering_on_horizontal_5GC001208
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
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# #${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
# ${dlMuMimoRankAdaption}                         text|always|//*[@name\="dlMuMimoRankAdaption"]
# ${miNrCellUtilPerPLMN}                           text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${bwp_profile57}    attrib\=distName|replace('BWP_PROFILE-54', 'BWP_PROFILE-57')|//managedObject
# ${bwp_profile57_p}    text|replace('BWP_PROFILE-54', 'BWP_PROFILE-57')|//p
# ${nPdcchCandidatesInAL4_1}
# ...    text|n2|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8_1}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL16_1}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[1]/*[@name\="numOfPdcchCandidatesInAL16"]
# ${nPdcchCandidatesInAL2_2}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL2"]
# ${nPdcchCandidatesInAL4_2}
# ...    text|n4|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8_2}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[2]/*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL4_3}
# ...    text|n2|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="numOfPdcchCandidatesInAL4"]
# ${nPdcchCandidatesInAL8_3}
# ...    text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="numOfPdcchCandidatesInAL8"]
# ${nPdcchCandidatesInAL16_3}
# ...     text|n0|//*[contains(@distName, 'BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1')]//item[3]/*[@name\="numOfPdcchCandidatesInAL16"]
# ${msg1FrequencyStart}    text|0|//*[@name\="msg1FrequencyStart"]
# ${discardTimer}    text|1500ms|//*[contains(@distName, 'MRBTS-1/NRBTS-2/NRDRB-15')]//*[@name\="discardTimer"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case109_B_2_Peak_throughput_of_4_UEs_8DL_layers_with_25dB_tapering_on_horizontal_5GC001208
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4 NonGBR UEs
#     Step3:Push full buffer And check
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    15    6    15    6    15    6    15    6    0
#     Set Pos By Modify L1ByPTestModeConfiguration    12    6    12    6    12    6    12    6    1
#     Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0      6    0    6    0    2
#     Set Pos By Modify L1ByPTestModeConfiguration    21    0    21    0      21    0    21    0    3
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${msg1FrequencyStart}
#     ...       ${schedulBSD}    ${dlMuMimoRankAdaption}    ${miNrCellUtilPerPLMN}
#     ...       ${bwp_profile57}    ${bwp_profile57_p}    ${nPdcchCandidatesInAL4_1}    ${nPdcchCandidatesInAL8_1}    ${nPdcchCandidatesInAL16_1}
#     ...       ${nPdcchCandidatesInAL2_2}    ${nPdcchCandidatesInAL4_2}    ${nPdcchCandidatesInAL8_2}    ${nPdcchCandidatesInAL4_3}
#     ...       ${nPdcchCandidatesInAL8_3}    ${nPdcchCandidatesInAL16_3}
#     ...       ${msg1FrequencyStart}    ${discardTimer}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 4 NonGBR UEs
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     Start GNB BIP Log
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    4    CA_P2_8x4_t2r4_n2
#     Wait Throughput Timer    5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer And check
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     Start GNB BIP Log
#     : FOR    ${i}    IN RANGE    1     5
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=3    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=4    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=5    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    8
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Dl_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=dl
#     ${Dl_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=dl
#     ${Dl_throughput_ue4} =    Airphone Sa Get Throughput    ue_id=4    direction=dl
# #    run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 700000
# #    run keyword and continue on failure    Should Be True    ${Dl_throughput_ue2} > 700000
# #    run keyword and continue on failure    Should Be True    ${Dl_throughput_ue3} > 700000
# #    run keyword and continue on failure    Should Be True    ${Dl_throughput_ue4} > 700000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case109.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_inject_buffer${/}
#     ${PM_counter_8layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34011
#     ...   cell_id=1
#     #run keyword and continue on failure    Should Be True    ${PM_counter_8layer_value} > 20000000
#     ${PM_counter_4pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34015
#     ...   cell_id=1
#     #run keyword and continue on failure    Should Be True    ${PM_counter_4pairUE_value} > 20000000
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
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File
