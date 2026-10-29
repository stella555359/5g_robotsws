# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case113_B_2_multiple_UEs_mixed_scheduling_with_more_than_4Ues
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
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
# 
# ${chBw}                           text|60MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}                 text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                 text|0|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoSpectralEffThd}         text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${maxNumLayerPerMuRbg}            text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoRankAdaption}           text|always|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoTaperingH}              text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}              text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${actBeamforming}                 text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                   text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
# ${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}              text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}        text|97|//*[@name\="prachConfigurationIndex"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${srsUePeriodicity}               text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|42|//*[@name\="cSRS"]
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${nrBtsBeamRefinementP2}          text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}             text|2|//*[@name\="msg1FrequencyStart"]
# ${actUlMuMimoTapering}            text|false|//*[@name\="actUlMuMimoTapering"]
# ${schedulBSD}                     text|100ms|//*[@name\="schedulBSD"]
# ${miNrCellUtilPerPLMN}            text|15min|//*[@name\="miNrCellUtilPerPLMN"]
# ${actCsirsMultiplexing}           text|false|//*[@name\="actCsirsMultiplexing"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile73}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${UE1_ID}                         1
# ${UE2_ID}                         2
# ${UE3_ID}                         3
# ${UE4_ID}                         4
# ${UE5_ID}                         5
# ${pattern}                        CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case113_B_2_multiple_UEs_mixed_scheduling_with_more_than_4Ues
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4 NonGBR UEs At The Same Position
#     Step3:Push full buffer And Check Pair
#     Step4:Attach 2 other UEs And Check Two Virtual UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#  #   modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# #    add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
#     ${modify_list}    create list
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}
#     ...       ${dlMuMimoSpectralEffThd}    ${maxNumLayerPerMuRbg}    ${dlMuMimoRankAdaption}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${srsUePeriodicity}
#     ...       ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${nrBtsBeamRefinementP2}
#     ...       ${msg1FrequencyStart}    ${schedulBSD}    ${miNrCellUtilPerPLMN}    ${actDlSrsBm}    ${actCsirsMultiplexing}    ${actDl256Qam}
#     ...       ${bwp_profile7}    ${bwp_profile73}    ${actCustomBsr}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     add_xml_element     ${scfc_path}    ${scfc_path}
#     ...     <p name="customBeamSetName">BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001</p>|//*[@name\='beamSet']/item[1]
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 4 NonGBR UEs At The Same Position
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
# #    Start GNB BIP Log
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
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer And Check Pair
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
# #    Start GNB BIP Log    
#     SA send multiple trf data    1    DL    175M    2
#     SA send multiple trf data    2    DL    175M    2
#     SA send multiple trf data    3    DL    175M    2
#     SA send multiple trf data    4    DL    175M    2
#     run keyword and continue on failure    Wait Until Keyword Succeeds    120s    2s    check thp
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
# 
#     ${Pcell_dl_tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${Pcell_dl_tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${Pcell_dl_tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${Pcell_dl_tput_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
# 
# 
#     run keyword and continue on failure    Should Be True    ${Pcell_dl_tput_ue1} > 290000
#     run keyword and continue on failure    Should Be True    ${Pcell_dl_tput_ue2} > 290000
#     run keyword and continue on failure    Should Be True    ${Pcell_dl_tput_ue3} > 290000
#     run keyword and continue on failure    Should Be True    ${Pcell_dl_tput_ue4} > 290000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case113_step3_pair.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Attach 2 other UEs And Check Two Virtual UEs
#     Start Capture GNB and AP Syslog in 'Step4_Attach_2_other_UEs' File
# #    Start GNB BIP Log
#     Attach SA ue with capability to 5g cell From UE 5    2    CA_P2_8x4_t2r4_n2
#     ul_mimo_srs_beam_pos_active    ue=5    profile=5    init=0    sub=0    step=5    scell=0
#     ul_mimo_srs_beam_pos_active    ue=6    profile=6    init=3    sub=1    step=5    scell=0
#     csi_override_testmode_active    5    1    1
#     csi_override_testmode_active    6    1    1
#     SA send multiple trf data    5    DL    175M    2
#     SA send multiple trf data    6    DL    175M    2
# 
# #    Wait Throughput Timer    2
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Attach_2_other_UEs${/}
#     
#     Wait Throughput Timer    15
#     ${dl_tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput_ue5} =    Airphone Get Throughput On Specific Scell    ue_id=5   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput_ue6} =    Airphone Get Throughput On Specific Scell    ue_id=6   scell_id=0    type=pdsch    tput_type=ave
# 
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue1} > 167000
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue2} > 167000
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue3} > 167000
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue4} > 167000
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue5} > 167000
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue6} > 167000
# 
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step4_Attach_2_other_UEs${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step4_Attach_2_other_UEs${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable     ${rnti_1}     ${rnti_list[0]}
#     Set test Variable     ${rnti_2}     ${rnti_list[1]}
#     Set test Variable     ${rnti_3}     ${rnti_list[2]}
#     Set test Variable     ${rnti_4}     ${rnti_list[3]}
#     Set test Variable     ${rnti_5}     ${rnti_list[4]}
#     Set test Variable     ${rnti_6}     ${rnti_list[5]}
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_Attach_2_other_UEs
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case113_step4_2_virtual_ue_APLO.ini    log_need_to_check=i    save_log_directory=${save_log}
#     
#     ${counter_file}    download PM counter file    ${save_log}
#     check_prb_counter    ${counter_file}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_Attach_2_other_UEs' File
# 
# Attach SA ue with capability to 5g cell From UE 5
#     [Arguments]    ${uenum}    ${pattern}    ${from}=5
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
#     : FOR    ${num}    IN RANGE    ${from}    ${uenum}+${from}
#     \    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
#     \    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
#     \    airphone_set_traffic_type    ${num}    1    internal
#     \    ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${num}    1    1    ${num}
#     \    ${newNum}=    evaluate    ${num}+8
#     \    Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${num}    1    1    ${newNum}
#     \    Wait '2s' for stable running
# 
# check_prb_counter
#     [Arguments]    ${counter_file}
#     ${PM_counter_8layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34011   cell_id=1
#     ${PM_counter_4pairUE_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34015   cell_id=1
#     ${PM_counter_4layer_value}=     get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34007   cell_id=1
#     ${PM_counter_2pairUE_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34013   cell_id=1
#     ${PM_counter_usedPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C10001   cell_id=1
#     ${PM_counter_availPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C10003   cell_id=1
#     ${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C20001   cell_id=1
#     ${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55338C00001   cell_id=1
#     Should Be True    ${PM_counter_8layer_value}  > 10000000
#     Should Be True    ${PM_counter_4pairUE_value} > 10000000
#     Should Be True    ${PM_counter_4layer_value}  > 1000000
#     Should Be True    ${PM_counter_2pairUE_value} > 1000000
#     Should Be True    ${PM_counter_usedPrb_value} > 20000000
#     Should Be True    ${PM_counter_availPrb_value} > 20000000
#     Should Be True    ${PM_counter_MaxAllocPrb_value} == 162
#     Should Be True    ${PM_counter_usedPrbPlmn_value} > 20000000
#     
# ul_sinr_testmode_active
#     [Arguments]    ${ue_id}    ${profile_id}    ${sinr_srs}    ${sinr_pucch}    ${noise_srs}
#     airphone_execute_egate_command
#     ...    ul_sinr_testmode_nr profile_id\=${profile_id} sinr_target_srs\=${sinr_srs} sinr_target_pucch\=${sinr_pucch} noise_srs\=${noise_srs}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=${profile_id}
# 
# csi_override_testmode_active
#     [Arguments]    ${ueid}    ${profile_id}    ${ri}
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=${profile_id} cqi\=15 cqi_mode\=fixed ri\=${ri} ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ueid} testmode\=csi_override action\=activate profile_id\=${profile_id}
# 
# csi_override_testmode_deactive
#     [Arguments]    ${ueid}    ${profile_id}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${ueid} testmode\=csi_override action\=deactivate profile_id\=${profile_id}
#     
# cell_srs_beam_pos_active
#     [Arguments]    ${profile_id}    ${num_pos}    ${azimuth}    ${cell_id}
#     airphone_execute_egate_command
#     ...    cell_srs_beam_pos_nr profile_id\=${profile_id} num_of_ue_positions\=${num_pos} azimuth\=${azimuth}
#     airphone_execute_egate_command
#     ...    cell_testmode_set_nr cell_id\=${cell_id} gnb\=2 testmode\=cell_srs_beam_pos profile_id\=${profile_id} action\=activate    
# 
# Transfer data again
#     [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=3600s    trf_id=${num}
# 
# 
# check thp
#     FOR    ${UE_ID}    IN RANGE    1    5
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 290000
#     END