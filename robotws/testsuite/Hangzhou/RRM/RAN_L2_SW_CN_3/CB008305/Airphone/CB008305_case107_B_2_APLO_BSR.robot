# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case107_B_2_Peak_throughput_of_4_UEs_8DL_layers_with_25dB_tapering_on_horizontal_5GC001070
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      450 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          sg10_bwp_3_1116.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|60MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}                               text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                              text|33|//*[@name\="dlMuMimoCorrThd"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# #${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${ulDlDataSlotRatio}                            text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|23|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
# ${dlMuMimoRankAdaption}                         text|always|//*[@name\="dlMuMimoRankAdaption"]
# ${miNrCellUtilPerPLMN}                           text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${actCustomBsr}                                 text|true|//*[@name\="actCustomBsr"]
# #bwp1070
# ${bwp_profile6}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-6|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile63}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-63|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${msg1FrequencyStart}    text|0|//*[@name\="msg1FrequencyStart"]
# #${discardTimer}    text|1500ms|//*[contains(@distName, 'MRBTS-1/NRBTS-2/NRDRB-15')]//*[@name\="discardTimer"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case107_B_2_Peak_throughput_of_4_UEs_8DL_layers_with_25dB_tapering_on_horizontal_5GC001070
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4 NonGBR UEs
#     Step3:Push full buffer And check
#     Step4:Robustness test
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     #add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${actFdmScheduling}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${nrBtsBeamRefinementP2}    ${msg1FrequencyStart}
#     ...       ${schedulBSD}    ${dlMuMimoRankAdaption}    ${miNrCellUtilPerPLMN}    ${actCustomBsr}      
#     ...       ${bwp_profile6}    ${bwp_profile63}    ${msg1FrequencyStart}
#     #...       ${discardTimer}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     add_xml_element     ${scfc_path}    ${scfc_path}
#     ...     <p name="customBeamSetName">BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001</p>|//*[@name\='beamSet']/item[1]
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 4 NonGBR UEs
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
#     Attach SA ue with capability to 5g cell    4    ${pattern}
#     ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=0    sub=0    step=5    scell=0
#     ul_mimo_srs_beam_pos_active    ue=2    profile=2    init=1    sub=2    step=5    scell=0
#     ul_mimo_srs_beam_pos_active    ue=3    profile=3    init=2    sub=3    step=5    scell=0
#     ul_mimo_srs_beam_pos_active    ue=4    profile=4    init=3    sub=1    step=5    scell=0
# 
#     Wait Throughput Timer    3
#     csi_override_testmode_active    1    1    1
#     csi_override_testmode_active    2    2    1
#     csi_override_testmode_active    3    3    1
#     csi_override_testmode_active    4    4    1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer And check
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     SA send multiple trf data    1    DL    150M    4
#     SA send multiple trf data    2    DL    150M    4
#     SA send multiple trf data    3    DL    150M    4
#     SA send multiple trf data    4    DL    150M    4
#     
# #    : FOR    ${i}    IN RANGE    1     5
# #    \    Airphone SA Start Data Traffic    1    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
# #    \    Airphone SA Start Data Traffic    2    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
# #    \    Airphone SA Start Data Traffic    3    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
# #    \    Airphone SA Start Data Traffic    4    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
# #    Wait Throughput Timer    8
#     run keyword and continue on failure    Wait Until Keyword Succeeds    120s    2s    check thp
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
# 
#     ${Pcell_dl_tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${Pcell_dl_tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${Pcell_dl_tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${Pcell_dl_tput_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
# 
# 
#     run keyword and continue on failure    Should Be True    ${Pcell_dl_tput_ue1} > 285000
#     run keyword and continue on failure    Should Be True    ${Pcell_dl_tput_ue2} > 285000
#     run keyword and continue on failure    Should Be True    ${Pcell_dl_tput_ue3} > 285000
#     run keyword and continue on failure    Should Be True    ${Pcell_dl_tput_ue4} > 285000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case107.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
#     ${Counter_8layer_value}=      get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34011    cell_id=1
#     ${Counter_4pairUE_value}=     get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34015    cell_id=1
#     ${Counter_usedPrb_value}=     get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10001    cell_id=1
#     ${Counter_availPrb_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10003    cell_id=1
#     ${Counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55338C00001    cell_id=1
#     ${Counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C20001    cell_id=1
#     run keyword and continue on failure    Should Be True    ${Counter_8layer_value}  > 12000000
#     run keyword and continue on failure    Should Be True    ${Counter_4pairUE_value} > 12000000
#     run keyword and continue on failure    Should Be True    ${Counter_usedPrb_value} > 12000000
#     run keyword and continue on failure    Should Be True    ${Counter_availPrb_value} > 12000000
#     run keyword and continue on failure    Should Be True    ${Counter_availPrb_value} > 12000000
#     run keyword and continue on failure    Should Be True    ${Counter_MaxAllocPrb_value} == 162
# 
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Robustness test
#     Start Capture GNB and AP Syslog in 'Step4_Robustness_test' File
#     Stop '4'UE DL Traffic
#     Detach '3'UE
#     Wait Throughput Timer    8
# 
#     FOR    ${id}    IN RANGE    1    101    1
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     Wait Throughput Timer    3
#     ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=1    sub=1    step=5    scell=0
#     csi_override_testmode_active    1    1    1
#     
#     SA send multiple trf data    1    DL    150M    4
#     SA send multiple trf data    4    DL    150M    4
#     Wait Throughput Timer    5
#     ${Pcell_dl_throughput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${Pcell_dl_throughput_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 srsMode\=fixed init_pos\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_${id}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case107.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Stop '1'UE DL Traffic
#     Detach '1'UE
#     END
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_Robustness_test' File
# 
# check thp
#     FOR    ${UE_ID}    IN RANGE    1    5
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 285000
#     END
