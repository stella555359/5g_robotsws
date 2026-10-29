# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_Case131_D_C3_vonr_only_A1add_and_bufferbased_activation
# ...
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS22R3    Owner_xueminm    SBTS23R1
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC_vonr.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${carrierAggregationSupportList}                text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}                         text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}                               text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}                  text|1 beam|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                                 text|beamSet_1|//*[@name\="basicBeamSet"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                             text|20|//*[@name\="ssBurstSetPeriod"]
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${maxNumScellsDl}                               text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actCDrx}                                      text|true|//*[@name\="actCDrx"]
# ${actCDrxVoNR}                                  text|true|//*[@name\="actCDrxVoNR"]
# ${actVoNR}                                      text|true|//*[@name\="actVoNR"]
# ${actEnhancedVoNR}                              text|true|//*[@name\="actEnhancedVoNR"]
# ${csiReportPeriodicity}                         text|slots320|//*[@name\="csiReportPeriodicity"]
# ${sCellAdditionMethod}                          text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${sCellActivationMethod}                        text|blind|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}                        text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${actMeasBasedSCellAddition}                    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${sCellDeactivationTimerGNB}                    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# 
# *** Test Cases ***
# CB007922_Case131_D_C3_vonr_only_A1add_and_bufferbased_activation
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach UE1 to one NR TDD FR1 cell
#     Step 3: UE send A1 measurement report
#     Step 4: Add 5Q1 PDU Session Start VONR
#     Step 5: Add 5Q8 PDU Session
#     Step 6: Send some DL data traffic
#     Step 7: Release VONR
# 
# *** Keywords ***
# Step 1: Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
# 	${scfc_path}                Set Variable                 ${TEST_LOG_DIRECTORY()}${/}scfc.xml
# 	copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
# 	add_ca_relation_CB7922    ${scfc_path}
# 	add_vonr_extend_parameter_on_bts      xml_path=${scfc_path}
# 	add_drxprofile_list_in_cells    xml_path=${scfc_path}    profile_id=2
# 	...     drxInactivityTimer=4ms    drxLongCycle=40ms    drxOnDurationTimer=6ms    drxRetransTimerDl=0slot    drxRetransTimerUl=0slot
# 	${modify_list}      create list
#     ...     ${carrierAggregationSupportList}
#     ...     ${actInterNumerologyCa}
#     ...     ${flexibleCAMode}
#     ...     ${pucchModeSelect}
#     ...     ${actBeamforming}
#     ...     ${nrBtsBeamRefinementP2}
#     ...     ${numberOfTransmittedSsBlocks}
#     ...     ${basicBeamSet}
#     ...     ${frameStructureType}
#     ...     ${guardPeriodLength}
#     ...     ${lteToNrFrameShift}
#     ...     ${prachConfigurationIndex}
#     ...     ${ssBurstSetPeriod}
#     ...     ${cellDepType}
#     ...     ${maxNumScellsDl}
#     ...     ${actFdmScheduling}
#     ...     ${actCDrx}
#     ...     ${actCDrxVoNR}
#     ...     ${actVoNR}
#     ...     ${actEnhancedVoNR}
#     ...     ${csiReportPeriodicity}
#     ...     ${sCellAdditionMethod}
#     ...     ${sCellActivationMethod}
#     ...     ${a1MeasSCellAddEnabled}
#     ...     ${actMeasBasedSCellAddition}
#     ...     ${sCellDeactivationTimerGNB}
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Perform Full Commission And Reach Onair
# 	...    ${scfc_path}
# 	...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
# 	...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
# 	comment  cell1 and cell2 is intra cell, cell2 and cell3 is inter cell, cell3 and cell4 is diff band cell
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# Step 2: Attach UE1 to one NR TDD FR1 cell
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Location Change    id=${UE_ID}    cell_id=2
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
# 	${ue_ability}    Obtain Ue Capability    vonr_n78
#     Airphone SA Attach    ue_id=${UE_ID}    ue_capability=${ue_ability}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 	Wait Throughput Timer    10
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=1 mbps\=5 dir\=dl protocol\=tcp seconds\=3600
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step 3: UE send A1 measurement report
#     Start Collect GNB and AP Syslog in 'step3_trigger_A1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...    pass_regexp=SCellIndex 1 activated successfully
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_trigger_A1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_trigger_A1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_trigger_A1${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_trigger_A1' File
# 
# Step 4: Add 5Q1 PDU Session Start VONR
#     Start Collect GNB and AP Syslog in 'step4_add_5q1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
# 	Start GNB Ttitrace With Streaming Mode
# 	Airphone Pdu Session Modify    qosflows_to_add=2    by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 1 qfi 2
# 	Wait Throughput Timer    5
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 trf_id\=2 mbps\=5 dir\=dl seconds\=3600
# 	Wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_add_5q1
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_add_5q1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_add_5q1${/}
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'step4_add_5q1' File
# 
# Step 5: Add 5Q8 PDU Session
#     Start Collect GNB and AP Syslog in 'step5_add_5q8' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
# 	Start GNB Ttitrace With Streaming Mode
# 	Airphone Pdu Session Modify    qosflows_to_add=3    by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 8 qfi 3
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_add_5q8
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_add_5q8${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_add_5q8${/}
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'step5_add_5q8' File
# 
# Step 6: Send some DL data traffic
#     Start Collect GNB and AP Syslog in 'step6_send_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 mbps\=175 dir\=dl seconds\=3600
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=2 mbps\=175 dir\=dl seconds\=3600
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=3 mbps\=175 dir\=dl seconds\=3600
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=4 mbps\=175 dir\=dl seconds\=3600
# 	Wait Throughput Timer    90
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_data${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_send_data
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step6_send_data${/}
#     ${PM_counter_value5qi1_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=2
#     ${PM_counter_value5qi1_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=3
#     ${PM_counter_value5qi5_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=2
#     ${PM_counter_value5qi5_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=3
# 	${PM_counter_value5qi8_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55310C01008    cell_id=2
#     ${PM_counter_value5qi8_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01008    cell_id=3
#     should be true    ${PM_counter_value5qi1_p}>0
#     should be true    ${PM_counter_value5qi1_s}==0
#     should be true    ${PM_counter_value5qi5_p}>0
#     should be true    ${PM_counter_value5qi5_s}==0
#     should be true    ${PM_counter_value5qi5_p}>0
#     should be true    ${PM_counter_value5qi8_s}>0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_send_data' File
# 
# Step 7: Release VONR
#     Start Collect GNB and AP Syslog in 'step7_release_vonr' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Pdu Session Modify    qosflows_to_del=2    pass_regexp=Removed FiveQi:Qfi mapping fiveQi 1 qfi 2
# 	Wait Throughput Timer    60
# 	#Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_release_vonr${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_release_vonr${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step7_release_vonr
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step7_release_vonr${/}
#     ${PM_counter_value5qi1_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=2
#     ${PM_counter_value5qi1_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=3
#     ${PM_counter_value5qi5_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=2
#     ${PM_counter_value5qi5_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=3
# 	${PM_counter_value5qi8_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55310C01008    cell_id=2
#     ${PM_counter_value5qi8_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01008    cell_id=3
#     should be true    ${PM_counter_value5qi1_p}==0
#     should be true    ${PM_counter_value5qi1_s}==0
#     should be true    ${PM_counter_value5qi5_p}>0
#     should be true    ${PM_counter_value5qi5_s}==0
#     should be true    ${PM_counter_value5qi5_p}>0
#     should be true    ${PM_counter_value5qi8_s}>0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_release_vonr' File
