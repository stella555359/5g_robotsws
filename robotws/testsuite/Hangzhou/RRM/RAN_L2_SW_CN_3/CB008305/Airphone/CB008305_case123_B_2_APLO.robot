# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008305_case123_B_4_PM counters for DL MU-MIMO
# ...               maxNumLayerPerMuRbg=4 was updated in CB009235,
# ...               this scenario will be converd by "CB009235_B_B201_CASE24_dlMuAware_8DL4UL_SE_check_maxDlMuMimoLayer_4"
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          sg10_bwp_3_1116.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
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
# ${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile73}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-73|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${actVoNR}                        text|true|//*[@name\="actVoNR"]
# ${actEnhancedVoNR}                text|true|//*[@name\="actEnhancedVoNR"]
# ${discardTimer}                   text|1500ms|//*[contains(@distName, 'NRDRB-15')]/*[@name='discardTimer']
# ${UE1_ID}                         1
# ${UE2_ID}                         2
# ${UE3_ID}                         3
# ${UE4_ID}                         4
# ${UE5_ID}                         5
# ${pattern}                        CA_P2_8x4_t2r4_n2
# ${pattern002}                     vonr_n78
# 
# *** Test Cases ***
# CB008305_case123_B_4_PM counters for DL MU-MIMO
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4 NonGBR UEs Aad 1 GBR UE
#     Step3:Push full buffer in DL And Make GBR Call
#     Step4:Online modify maxNumLayerPerMuRbg=6 to check counter
# #    Step5:Online modify maxNumLayerPerMuRbg=4 to check counter
#     Step6:Detach UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008305    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
#     ${modify_list}    create list
#     ...       ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actFdmScheduling}    ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}
#     ...       ${dlMuMimoSpectralEffThd}    ${maxNumLayerPerMuRbg}    ${dlMuMimoRankAdaption}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}
#     ...       ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${srsUePeriodicity}
#     ...       ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${nrBtsBeamRefinementP2}
#     ...       ${msg1FrequencyStart}    ${schedulBSD}    ${miNrCellUtilPerPLMN}    ${actDlSrsBm}    ${actCsirsMultiplexing}    ${actDl256Qam}
#     ...       ${bwp_profile7}    ${bwp_profile73}    ${actVoNR}    ${actEnhancedVoNR}    ${discardTimer}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="actDlTxResumeOnPdcpStatRep">false</p>|//*[contains(@distName, 'NRDRB-15')]
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="dlAllowMinDelayLinkX2Calib">false</p>|//*[contains(@distName, 'NRDRB-15')]
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="durationThresDiscardDl">40</p>|//*[contains(@distName, 'NRDRB-15')]
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="durationThresDiscardUl">20</p>|//*[contains(@distName, 'NRDRB-15')]
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="endMarkerTimer">2000</p>|//*[contains(@distName, 'NRDRB-15')]
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="volThresDiscardDl">8000</p>|//*[contains(@distName, 'NRDRB-15')]
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="volThresDiscardUl">800</p>|//*[contains(@distName, 'NRDRB-15')]
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="schedulBSD">50ms</p>|//*[contains(@distName, 'NRDRB_MAC-3')]
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1' File
# 
# Step2:Attach 4 NonGBR UEs Aad 1 GBR UE
#     Start Collect GNB and AP Syslog in 'Step2' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
#     Start GNB BIP Log
#     #ul_sinr_testmode_active    ${UE1_ID}    6    100    -300    -1053
#     #ul_sinr_testmode_active    ${UE2_ID}    6    100    -300    -1053
#     #ul_sinr_testmode_active    ${UE3_ID}    6    100    -300    -1053
#     #ul_sinr_testmode_active    ${UE4_ID}    6    100    -300    -1053
#     #ul_sinr_testmode_active    ${UE5_ID}    6    100    -300    -1053
#     Attach SA ue with capability to 5g cell    4    ${pattern}
#     Attach SA ue with capability to 5g cell    1    ${pattern002}    5
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=5 pdu\=1 qosflows_to_add\=2 by\=amf
#     ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5 qfi 2
#     Wait Throughput Timer    5
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=5 pdu\=1 qosflows_to_add\=3 by\=amf
#     ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 1 qfi 3
#     Wait Throughput Timer    3
#     csi_override_testmode_active    ${UE1_ID}    1    3
#     csi_override_testmode_active    ${UE2_ID}    1    3
#     csi_override_testmode_active    ${UE3_ID}    1    3
#     csi_override_testmode_active    ${UE4_ID}    1    3
#     csi_override_testmode_active    ${UE5_ID}    1    3
#     ue_srs_beam_pos_active    ${UE1_ID}    1    0
#     ue_srs_beam_pos_active    ${UE2_ID}    2    1
#     ue_srs_beam_pos_active    ${UE3_ID}    3    2
#     ue_srs_beam_pos_active    ${UE4_ID}    4    3
#     Stop Gnb BIP Log    log_dir=${save_log}
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2' File
# 
# Step3:Push full buffer in DL And Make GBR Call
#     Start Collect GNB and AP Syslog in 'Step3' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     SA send multiple trf data    ${UE1_ID}    DL    175M    2
#     SA send multiple trf data    ${UE2_ID}    DL    175M    2
#     SA send multiple trf data    ${UE3_ID}    DL    175M    2
#     SA send multiple trf data    ${UE4_ID}    DL    175M    2
#     airphone_execute_egate_command    trf_data_start ue\=${UE5_ID} pdu\=1 qfi\=3 trf_id\=1 mbps\=70 dir\=dl protocol\=tcp seconds\=3600
#     Start GNB BIP Log
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case123_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Check 5UEs Thp On Specific Scell
#     ${counter_file}    download PM counter file    ${save_log}
#     Check MUlayer, PairUE, 5QI1, Legacy PM counter    ${counter_file}    8    4
#     ${dL_thp_counter}=                  get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     Should Be True    ${dL_thp_counter} > 130000000
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3' File
# 
# Step4:Online modify maxNumLayerPerMuRbg=6 to check counter
#     Start Collect GNB and AP Syslog in 'Step4' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
#     Perform Online Change Parameter Value    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    dlMuMaxNumLayerPerMuRbg    6    update
#     Wait Throughput Timer    30
#     Start GNB BIP Log
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case123_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Check 5UEs Thp On Specific Scell
#     ${counter_file}    download PM counter file    ${save_log}
#     Check MUlayer, PairUE, 5QI1, Legacy PM counter    ${counter_file}    6    3
#     ${dL_thp_counter}=                  get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     Should Be True    ${dL_thp_counter} > 100000000
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4' File
# 
# 
# Step5:Online modify maxNumLayerPerMuRbg=4 to check counter
#     Start Collect GNB and AP Syslog in 'Step5' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
#     Perform Online Change Parameter Value    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    dlMuMaxNumLayerPerMuRbg    4    update
#     Wait Throughput Timer    30
#     Start GNB BIP Log
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_case123_step5.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Check 5UEs Thp On Specific Scell
#     ${counter_file}    download PM counter file    ${save_log}
#     Check MUlayer, PairUE, 5QI1, Legacy PM counter    ${counter_file}    4    2
#     ${dL_thp_counter}=                  get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12001   cell_id=1
#     Should Be True    ${dL_thp_counter} > 75000000
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5' File
# 
# Step6:Detach UEs
#     Stop '5'UE DL Traffic
#     Detach '5'UE
# 
# Check MUlayer, PairUE, 5QI1, Legacy PM counter
#     [Arguments]    ${counter_file}    ${MUlayer}    ${PairUE}
#     ${PM_counter_8layer_value}=         get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34011    cell_id=1
#     ${PM_counter_6layer_value}=         get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34009    cell_id=1
#     ${PM_counter_4layer_value}=         get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34007    cell_id=1
#     ${PM_counter_4pairUE_value}=        get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34015    cell_id=1
#     ${PM_counter_3pairUE_value}=        get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34014    cell_id=1
#     ${PM_counter_2pairUE_value}=        get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C34013    cell_id=1
#     ${PM_counter_usedPrb_value}=        get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C10001    cell_id=1
#     ${PM_counter_availPrb_value}=       get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C10003    cell_id=1
#     ${PM_counter_MaxAllocPrb_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C20001    cell_id=1
#     ${PM_counter_usedPrbPlmn_value}=    get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55338C00001    cell_id=1
#     ${PM_counter_5qi1_value}=           get_counter_value_from_counter_file    counter_file=${counter_file}    counter_id=M55308C23002    cell_id=1
#     Run Keyword IF    ${MUlayer}==8    Should Be True    ${PM_counter_8layer_value} > 10000000
#     ...    ELSE IF    ${MUlayer}==6    Should Be True    ${PM_counter_6layer_value} > 10000000
#     ...    ELSE IF    ${MUlayer}==4    Should Be True    ${PM_counter_4layer_value} > 10000000
#     Run Keyword IF    ${PairUE}==4     Should Be True    ${PM_counter_4pairUE_value} > 10000000
#     ...    ELSE IF    ${PairUE}==3     Should Be True    ${PM_counter_3pairUE_value} > 10000000
#     ...    ELSE IF    ${PairUE}==2     Should Be True    ${PM_counter_2pairUE_value} > 10000000
#     Should Be True    ${PM_counter_usedPrb_value} > 12000000
#     Should Be True    ${PM_counter_availPrb_value} > 12000000
#     Should Be True    ${PM_counter_MaxAllocPrb_value} > 140
#     Should Be True    ${PM_counter_usedPrbPlmn_value} > 12000000
#     Should Be True    ${PM_counter_5qi1_value} > 500000
# 
# Check 5UEs Thp On Specific Scell
#     ${Dl_throughput_ue1} =    Airphone Get Throughput On Specific Scell    1    0    pdsch
#     ${Dl_throughput_ue2} =    Airphone Get Throughput On Specific Scell    2    0    pdsch
#     ${Dl_throughput_ue3} =    Airphone Get Throughput On Specific Scell    3    0    pdsch
#     ${Dl_throughput_ue4} =    Airphone Get Throughput On Specific Scell    4    0    pdsch
#     ${Dl_throughput_ue5} =    Airphone Get Throughput On Specific Scell    5    0    pdsch
#     Should Be True    ${Dl_throughput_ue1} > 0
#     Should Be True    ${Dl_throughput_ue2} > 0
#     Should Be True    ${Dl_throughput_ue3} > 0
#     Should Be True    ${Dl_throughput_ue4} > 0
#     Should Be True    ${Dl_throughput_ue5} > 0
# 
