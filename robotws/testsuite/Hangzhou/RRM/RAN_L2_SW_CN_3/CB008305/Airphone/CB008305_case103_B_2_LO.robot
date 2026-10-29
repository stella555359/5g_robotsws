# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case103_B_2_three_UEs_mixed_scheduling_with_dlMuMimoRankAdaption_equal_to_adaptive
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    
# Test Timeout      90 minutes
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
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}                 text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                 text|0|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoSpectralEffThd}         text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${maxNumLayerPerMuRbg}            text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoRankAdaption}           text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoTaperingH}              text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}              text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${actDlSrsBm}                                   text|true|//*[@name\="actDlSrsBm"]
# ${srsUePeriodicity}                             text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|42|//*[@name\="cSRS"]
# ${bSRS}                                         text|2|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                                   text|100ms|//*[@name\="schedulBSD"]
# ${miNrCellUtilPerPLMN}                          text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${actCsirsMultiplexing}                         text|false|//*[@name\="actCsirsMultiplexing"]
# ${actCustomBsr}                                 text|true|//*[@name\="actCustomBsr"]
# #bwp1208
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile57}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-57|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case103_B_2_three_UEs_mixed_scheduling_with_dlMuMimoRankAdaption_equal_to_adaptive
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 3 NonGBR UEs
#     Step3:Push full buffer And check
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}
#     ...       ${dlMuMimoSpectralEffThd}    ${maxNumLayerPerMuRbg}    ${dlMuMimoRankAdaption}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${srsUePeriodicity}    
#     ...       ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${nrBtsBeamRefinementP2}    
#     ...       ${msg1FrequencyStart}    ${schedulBSD}    ${miNrCellUtilPerPLMN}    ${actDlSrsBm}    ${actCsirsMultiplexing}    ${actDl256Qam}    
#     ...       ${actCustomBsr}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     add_xml_element     ${scfc_path}    ${scfc_path}
#     ...     <p name="customBeamSetName">BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001</p>|//*[@name\='beamSet']/item[1]
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 3 NonGBR UEs
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
#     Attach SA ue with capability to 5g cell    3    ${pattern}
#     ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=0    sub=2    step=5    scell=0
#     ul_mimo_srs_beam_pos_active    ue=2    profile=2    init=1    sub=3    step=5    scell=0
#     ul_mimo_srs_beam_pos_active    ue=3    profile=3    init=3    sub=1    step=5    scell=0
#     Wait Throughput Timer    3
#     csi_override_testmode_active    1    1    3
#     csi_override_testmode_active    2    2    3
#     csi_override_testmode_active    3    3    3
# 
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable     ${rnti_1}     ${rnti_list[0]}
#     Set test Variable     ${rnti_2}     ${rnti_list[1]}
#     Set test Variable     ${rnti_3}     ${rnti_list[2]}
#    [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 	
# 
# Step3:Push full buffer And check
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     SA send multiple trf data    1    DL    150M    5
#     SA send multiple trf data    2    DL    150M    5
#     SA send multiple trf data    3    DL    150M    5
#     
# #    : FOR    ${i}    IN RANGE    1     4
# #    \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
# #    \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
# #    \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=3    pdu_id=1    duration=${3600}
# #    \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=4    pdu_id=1    duration=${3600}
# #    \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=5    pdu_id=1    duration=${3600}
# 	
#     run keyword and continue on failure    Wait Until Keyword Succeeds    120s    2s    check thp
#     ${Dl_tput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Dl_tput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=dl
#     ${Dl_tput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=dl
# 
# 
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Wait Throughput Timer    8
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case103_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
# 
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
#     
#     ${PM_counter_noPair_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34012    cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_noPair_value} < 2000000
#     ${PM_counter_8layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34011
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_8layer_value} < 2000000
#     ${PM_counter_2pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34013
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_2pairUE_value} < 2000000
#     ${PM_counter_6layer_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34009
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_6layer_value} > 20000000
#     ${PM_counter_3pairUE_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C34014
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_3pairUE_value} > 20000000
#     ${PM_counter_usedPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C10001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_usedPrb_value} > 20000000
#     ${PM_counter_availPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C10003
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 20000000
#     ${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55308C20001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_MaxAllocPrb_value} == 273
#     ${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55338C00001
#     ...   cell_id=1
#     run keyword and continue on failure    Should Be True    ${PM_counter_availPrb_value} > 20000000
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# check thp
#     FOR    ${UE_ID}    IN RANGE    1    4
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 550000
#     END
