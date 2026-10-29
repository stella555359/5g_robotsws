# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case121_B_3_Peak throughput of two UEs with non-GBR paired to 8DL layers_64pipe
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_shuihe
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
# #@{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# ${chBw}                           text|60MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}                 text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                 text|0|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoSpectralEffThd}         text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${maxNumLayerPerMuRbg}            text|8|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoRankAdaption}           text|disabled|//*[@name\="dlMuMimoRankAdaption"]
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
# ${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile73}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${pattern}            CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008305_case121_B_3_Peak throughput of two UEs with non-GBR paired to 8DL layers_64pipe
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 2 NonGBR UEs
#     Step3:Push full buffer And Check Pair
#     Step4:Attach UE3
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
#     ...       ${bwp_profile7}    ${bwp_profile73}     ${actCustomBsr}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     add_xml_element     ${scfc_path}    ${scfc_path}
# 	...     <p name="customBeamSetName">BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001</p>|//*[@name\='beamSet']/item[1]
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 2 NonGBR UEs
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
# #    Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    2    ${pattern}
# 
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
# 		
#     csi_override_testmode_active    1    3    3
#     csi_override_testmode_active    2    3    3
# 
#     Wait Throughput Timer    2
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Push full buffer And Check Pair
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     SA send multiple trf data    1    DL    175M    4
#     SA send multiple trf data    2    DL    175M    4
# 	Wait Throughput Timer    5
#     #Start GNB BIP Log
#     #Wait Throughput Timer    1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
# 
#     Wait Throughput Timer    5
#     ${dl_tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
# 	
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue1} > 600000
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue2} > 600000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case121_step3_APLO.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Attach UE3
#     Start Capture GNB and AP Syslog in 'Step4_Attach_UE3' File
#     #Start GNB BIP Log
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell From UE 3    1    CA_P2_8x4_t2r4_n2
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 step\=10 trigger_puxch_update\=0
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
#     csi_override_testmode_active    3    3    3
# 
#     SA send multiple trf data    3    DL    175M    4
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4_Attach_UE3${/}
# 
#     Wait Throughput Timer    10
#     ${dl_tput_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue1} > 300000
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue2} > 300000
#     run keyword and continue on failure    Should Be True    ${dl_tput_ue3} > 300000
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    4
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_Attach_UE3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_case121_step4_APLO.ini    log_need_to_check=i    save_log_directory=${save_log}
#     
#     ${counter_file}    download PM counter file    ${save_log}
#     check_prb_counter    ${counter_file}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_Attach_UE3' File
# 
# Attach SA ue with capability to 5g cell From UE 3
#     [Arguments]    ${uenum}    ${pattern}    ${from}=3
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
#     ${PM_counter_2pairUE_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C34013   cell_id=1
#     ${PM_counter_usedPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C10001   cell_id=1
#     ${PM_counter_availPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C10003   cell_id=1
#     ${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C20001   cell_id=1
#     ${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55338C00001   cell_id=1
#     Should Be True    ${PM_counter_8layer_value} > 10000000
#     Should Be True    ${PM_counter_2pairUE_value} > 10000000
#     Should Be True    ${PM_counter_usedPrb_value} > 10000000
#     Should Be True    ${PM_counter_availPrb_value} > 10000000
#     Should Be True    ${PM_counter_MaxAllocPrb_value} == 162
#     Should Be True    ${PM_counter_usedPrbPlmn_value} > 10000000
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
