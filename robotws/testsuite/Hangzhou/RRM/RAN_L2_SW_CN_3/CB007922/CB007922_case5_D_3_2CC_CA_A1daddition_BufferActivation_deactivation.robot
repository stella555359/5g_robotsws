# *** Settings ***
# Documentation     Author: wenchao.zhang@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_case5_D_3_2CC_CA_A1daddition_BufferActivation_deactivation
# ...
# ...               Single UE connection setup and DL/UL data scheduling in SA option 2
# ...               BufferActivation scell Deactivation
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_KLL_AP_KLL_SANSA_L1B_CPRI_CMWV_TDD    5G_RAN_TDD    FR1    Owner_wenczhan    5G00    SBTS23R1
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      scfc_ASIK_ABIL_Cpri.xml
# ${AIRPHONE_NAME}    iphy_ASIK_ABIL_Cpri.xml
# ${WTS_NAME}       wts.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${carrierAggregationSupportList}                text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}                         text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}                               text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                               text|false|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}                  text|1 beam|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                                 text|beamSet_1|//*[@name\="basicBeamSet"]
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}                                      text|false|//*[@name\="actCDrx"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                             text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellAdditionMethod}                          text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                               text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}                        text|blind|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}                        text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${actMeasBasedSCellAddition}                    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${nrCellType}                                   text|2DL2UL|//*[@name\="nrCellType"]
# ${sCellDeactivationTimerGNB}                    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# 
# *** Test Cases ***
# CB007922_case5_D_3_2CC_CA_A1daddition_BufferActivation_deactivation
# 
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach UE1 to one NR TDD FR1 cell
#     Step 3: UE send A1 measurement report
#     Step 4: Send some DL data traffic
#     Step 5: Stop DL data traffic
#     Step 6: Detach UE
# 
# *** Keywords ***
# Step 1: Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
# 	change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
# 	${scfc_path}                Set Variable                             ${TEST_LOG_DIRECTORY()}${/}scfc.xml
# 	copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=1
# 	${modify_list}      create list        ${carrierAggregationSupportList}
#     ...     ${actInterNumerologyCa}
#     ...     ${flexibleCAMode}
#     ...     ${pucchModeSelect}
#     ...     ${actBeamforming}
#     ...     ${nrBtsBeamRefinementP2}
#     ...     ${numberOfTransmittedSsBlocks}
#     ...     ${basicBeamSet}
#     ...     ${cellDepType}
#     ...     ${actCDrx}
#     ...     ${frameStructureType}
#     ...     ${guardPeriodLength}
#     ...     ${lteToNrFrameShift}
#     ...     ${prachConfigurationIndex}
#     ...     ${ssBurstSetPeriod}
#     ...     ${sCellAdditionMethod}
#     ...     ${maxNumScellsDl}
#     ...     ${actFdmScheduling}
#     ...     ${sCellActivationMethod}
#     ...     ${a1MeasSCellAddEnabled}
#     ...     ${actMeasBasedSCellAddition}
#     ...     ${nrCellType}
#     ...     ${sCellDeactivationTimerGNB}
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Perform Full Commission And Reach Onair
# 	...    ${scfc_path}
# 	...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
# 	...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step 2: Attach UE1 to one NR TDD FR1 cell
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     Start GNB BIP Log
#     Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 	Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step 3: UE send A1 measurement report
#     Start Collect GNB and AP Syslog in 'step3_trigger_A1' File
#     Start GNB BIP Log
#     Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Cqi Param    nr_cqi=15
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...    pass_regexp=sCellToAddModList
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_trigger_A1
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_trigger_A1/output
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_trigger_A1${/}
#     Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_trigger_A1${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_trigger_A1' File
# 
# Step 4: Send some DL data traffic
#     Start Collect GNB and AP Syslog in 'step4_send_data' File
#     Start GNB BIP Log
#     Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
# 	#Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
# 	Wait Throughput Timer    15
#     #${pcell_dl_tput}=    airphone_sa_get_throughput    ${UE_ID}    DL    ${PDU_ID}
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step4_send_data${/}
# 	${PM_counter_pcell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55310C01006    cell_id=1
#     ${PM_counter_scell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01006    cell_id=2
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_send_data${/}
#     Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_send_data${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_send_data
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_send_data/output
# 	should be true    ${PM_counter_pcell_value}>0
# 	should be true    ${PM_counter_scell_value}>0
#     #log    ${pcell_dl_tput}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_send_data' File
# 
# Step 5: Stop DL data traffic
#     Start Collect GNB and AP Syslog in 'step5_stop_data' File
#     Start GNB BIP Log
#     Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
# 	airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
# 	Wait Throughput Timer     30
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_stop_data${/}
#     Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_stop_data${/}
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step5_stop_data${/}
# 	${PM_counter_pcell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55310C01006    cell_id=1
#     ${PM_counter_scell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01006    cell_id=2
#     #${dl_tput}=    airphone_sa_get_throughput    ${UE_ID}    DL    ${PDU_ID}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_stop_data
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_stop_data/output
# 	should be true    ${PM_counter_pcell_value}==0
# 	should be true    ${PM_counter_scell_value}==0
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'step5_stop_data' File
# 
# Step 6: Detach UE
#     Start Collect GNB and AP Syslog in 'step6_detach' File
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_detach' File
