# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com...
# ...               QC case full name:
# ...               CB008360_D_B1a_case_139_Retransmission UEs paired with initTx Ues and SU
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_jiangzhaona
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
# ${WTS_NAME}           wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|80MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|8DL8UL|//*[@name\="nrCellType"]
# ${actUlMuMimo}                                  text|true|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${actUlMuMimoTapering}                          text|true|//*[@name\="actUlMuMimoTapering"]
# ${ulMuMimoTaperingH}                            text|20dB|//*[@name\="ulMuMimoTaperingH"]
# ${ulMuMimoTaperingV}                            text|25dB|//*[@name\="ulMuMimoTaperingV"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${prbThreshRangeOne}                            text|50|//*[@name\="prbThreshRangeOne"]
# ${prbThreshRangeTwo}                            text|50|//*[@name\="prbThreshRangeTwo"]
# ${prbThreshRangeThree}                          text|50|//*[@name\="prbThreshRangeThree"]
# ${bwpDN1}                                       text|MRBTS-1/NRBTS-2/BWP_PROFILE-7|//*[contains(@name,'cellBwpList')]//item[1]/*[@name\='bwpDN']
# ${bwpDN2}                                       text|MRBTS-1/NRBTS-2/BWP_PROFILE-77|//*[contains(@name,'cellBwpList')]//item[2]/*[@name\='bwpDN']
# ${ullaDeltaSinrMax}                             text|5|//*[@name\="ullaDeltaSinrMax"]
# ${ullaDeltaSinrMin}                             text|-5|//*[@name\="ullaDeltaSinrMin"]
# ${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
# ${actUlPtrs}                                    text|false|//*[@name\="actUlPtrs"]
# ${ulDMRSAdditionalPosition}                     text|One additional DMRS|//*[@name\="ulDMRSAdditionalPosition"]
# ${cSRS}                                         text|51|//*[@name\="cSRS"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|50|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB008360_D_B1a_case_139_Retransmission UEs paired with initTx Ues and SU
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 3 sa ue with rank2
# 	Step3:Send nack to UE1 to trigger retransmission
# 	Step4:move ue1 to ue2 position
# 	Step5:Detach ues
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     Set Pos By Modify L1ByPTestModeConfiguration    12    0    6    0    6    0    6    0
#     Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0    6    0    6    0    1
#     Set Pos By Modify L1ByPTestModeConfiguration    0    0    0    0    0    0    0    0    2
#     Set Pos By Modify L1ByPTestModeConfiguration    21    0    21    0    21    0    21    0    3
#     Set Pos By Modify L1ByPTestModeConfiguration    
#     ...    15    0    15    0    15    0    15    0    4    100000    0    0    0    0    0    0    0    2    2
#     Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
#     modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="ulMuMimoCorrThd2">50</p>|//*[contains(@distName, 'NRULMUMIMO-0')]
#     ${modify_list}    create list
#     ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}
#     ...    ${actUlMuMimoTapering}    ${ulMuMimoTaperingH}    ${ulMuMimoTaperingV}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${prbThreshRangeOne}    ${prbThreshRangeTwo}    ${prbThreshRangeThree}
#     ...    ${bwpDN1}    ${bwpDN2}    ${ullaDeltaSinrMax}    ${ullaDeltaSinrMin}    ${ulMuMimoCorrThd}    ${actUlPtrs}
#     ...    ${ulDMRSAdditionalPosition}    ${cSRS}    ${ulMuMimoPrbThresholdAbsolute}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach 3 sa ue with rank2
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Attach SA ue with capability to 5g cell    3    CA_P2_8x4_t2r4_n2
#     Airphone SA Start Data Traffic    1    UL    50M    trf_id=1    pdu_id=1    duration=${7200}
#     Airphone SA Start Data Traffic    2    UL    40M    trf_id=1    pdu_id=1    duration=${7200}
#     Airphone SA Start Data Traffic    3    UL    40M    trf_id=1    pdu_id=1    duration=${7200}
#     Wait Throughput Timer    3
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
#     ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch
#     ${ue3_ul_tput}=    Airphone Get Throughput On Specific Scell    3    0    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case139_tti_step2.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
# 	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
# 	should be true    ${UL_thp_counter} > 10000000
# 	should be true    ${PAIR_UE_PUSCH} > 10000
# 	should be true    ${ELIG_UE_PUSCH} > 30000
# #	should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH}) > 1
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Send nack to UE1 to trigger retransmission
#     Start Collect GNB and AP Syslog in 'Step3_trigger_retrx' File
#     #Start GNB BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Trigger ul bler    1    0
#     Wait Throughput Timer    3
#     ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
#     ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch
#     ${ue3_ul_tput}=    Airphone Get Throughput On Specific Scell    3    0    pusch
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_trigger_retrx
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case139_tti_step3.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
# 	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
# 	should be true    ${UL_thp_counter} > 5000000
# 	should be true    ${PAIR_UE_PUSCH} > 5000
# 	should be true    ${ELIG_UE_PUSCH} > 30000
# #	should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH})>1
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_trigger_retrx' File
# 
# Step4:move ue1 to ue2 position
#     Start Collect GNB and AP Syslog in 'Step4_move' File
#     #Start GNB BIP Log
# 
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_move
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case139_tti_step4.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	${counter_file}    download PM counter file    ${save_log}
# 	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
# 	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
# 	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
# 	should be true    ${UL_thp_counter} > 1000000
# 	should be true    ${PAIR_UE_PUSCH} > 5000
# 	should be true    ${ELIG_UE_PUSCH} > 30000
# #	should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH})>1
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step4_move' File
# 
# Step5:Detach ues
#     Airphone SA Stop Data Traffic     1    UL
#     Airphone SA Stop Data Traffic     2    UL
#     Airphone SA Stop Data Traffic     3    UL
#     Detach '3'UE
# 
# 
