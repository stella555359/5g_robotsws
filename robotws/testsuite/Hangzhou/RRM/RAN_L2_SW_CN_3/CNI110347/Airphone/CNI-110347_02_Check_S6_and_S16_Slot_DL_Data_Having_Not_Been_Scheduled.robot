# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...               FGCR2504
# ...               QC case full name:
# ...               CNI-110347_02_Check_S6_and_S16_Slot_DL_Data_Having_Not_Been_Scheduled
#             
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    CRT    SBTS00
# ...    OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# Library          ${CURDIR}/log_check/Check_CNI110347_function.py
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_CR2504_CNI110347.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_CR2504_CNI110347.xml
# ${WTS_NAME}         wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_CR2504_CNI110347.cfg
# ${COMAVALUE}    ${CURDIR}/log_check/ap_coma.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog\
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|2x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|2DL2UL|//*[@name\="nrCellType"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|3ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                             text|20|//*[@name\="ssBurstSetPeriod"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# ${numberOfRxBeamforming}                        text|2Rx|//*[@name\="numberOfRxBeamforming"]
# ${csiReportPeriodicity}                         text|slots320|//*[@name\="csiReportPeriodicity"]
# 
# #CNI-110347_Bell_Canada
# ${MCC}                                          text|302|//*[@name\="mcc"]
# ${MNC}                                          text|610|//*[@name\="mnc"]
# ${actCaWimaxInterferenceAvoidance}              text|true|//*[@name\="actCaWimaxInterferenceAvoidance"]
# 
# ${pattern}    t2r2_n2
# 
# *** Test Cases ***
# CNI-110347_02_Check_S6_and_S16_Slot_DL_Data_Having_Not_Been_Scheduled
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE1 in cell1
#     Step3:Start UL DL data traffic
# 	Step4:Check CNI110347 function in TTItrace
# 
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}
#     ...       ${chBw}
#     ...       ${dlMimoMode}
#     ...       ${nrCellType}
#     ...       ${pucchModeSelect}
#     ...       ${actFdmScheduling}
#     ...       ${frameStructureType}
#     ...       ${guardPeriodLength}
#     ...       ${lteToNrFrameShift}
#     ...       ${prachConfigurationIndex}
#     ...       ${ssBurstSetPeriod}
#     ...       ${actDl256Qam}
#     ...       ${numberOfRxBeamforming}
#     ...       ${csiReportPeriodicity}
# 	...       ${MCC}
# 	...       ${MNC}
# 	...       ${actCaWimaxInterferenceAvoidance}
# 	
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach UE1 in cell1
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Airphone Set Traffic Type    1    1    internal
# 	${ue_cap}    Obtain Ue Capability    ${pattern}
#     Airphone Sa Attach    ue_id=1    ue_capability=${ue_cap}
#     Airphone Pdu Session Setup    ue_id=1    pdu_id=1    nwslice_id=1    gw_id=1
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Start UL DL data traffic
#     Start Collect GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    175M    trf_id=1    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    10
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_inject_buffer' File
# 
# Step4:Check CNI110347 function in TTItrace
# 	#DL slot6,7,16,17 no data used in PDSCH 
# 	#DL slot5,15 have data used in PDSCH
# 	#UL slot8,9 and 18 have data used in PUSCH
#     ${dl_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti_dl.csv
# 	${ul_ttitrace_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3_inject_buffer${/}tti_ul.csv  
# 	${CNI110347_DL_check_point}    Check_Slot6_7_And_Slot16_17_PDSCH_no_used_data    ${dl_ttitrace_path}
# 	${CNI110347_UL_check_point}    Check_Slot8_9_And_Slot18_PUSCH_Used_data    ${ul_ttitrace_path}	
# 	log    ${CNI110347_DL_check_point}
# 	log    ${CNI110347_UL_check_point}
# 	run keyword and continue on failure    should_be_true    ${CNI110347_DL_check_point}
# 	run keyword and continue on failure    should_be_true    ${CNI110347_UL_check_point}