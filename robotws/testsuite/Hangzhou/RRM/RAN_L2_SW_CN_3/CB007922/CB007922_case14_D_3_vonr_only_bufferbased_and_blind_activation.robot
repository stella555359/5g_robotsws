# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_case14_D_3_vonr_only_bufferbased_and_blind_activation
# ...
# ...               Single UE connection setup and DL/UL data scheduling in SA option 2
# ...               BufferActivation scell Deactivation
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    CLOUD_5G_I_KL_AP_KL_SANSA_L1B_CPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS22R2    SBTS22R3    SBTS23R1
# Resource    ../resources/sg11/internal_resource/robot/modify_configuration.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}        gNB_scf_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQA_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.xml
# ${WTS_NAME}         wts_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.cfg
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
# ${a1ThresholdSCellAddSsbRsrpTDD}                text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${actMeasBasedSCellAddition}                    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${nrCellType}                                   text|2DL2UL|//*[@name\="nrCellType"]
# ${sCellDeactivationTimerGNB}                    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${actVoNR}                                      text|true|//*[@name\="actVoNR"]
# ${srbInactivityTimerSA}                         text|120|//*[@name\="srbInactivityTimerSA"]
# 
# *** Test Cases ***
# CB007922_case14_D_3_vonr_only_bufferbased_and_blind_activation
#     Step1:Set parameter and wait for onair
#     Step 2: Attach UE1 to one NR TDD FR1 cell
#     Step 3: Add 5QI-5 PDU Session
#     Step 4: Add 5QI-1 PDU Session Star VONR
#     Step 5: UE send A1 measurement report
#     Step 6: Send some DL data traffic
#     Step 7: Release VONR
#     Step 8: create VONR again with little vonr data
#     Step 9: Detach UE
# 
# *** Keywords ***
# Step1:Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=1
#     add_vonr_extend_parameter_on_bts      xml_path=${scfc_path}
#     ${modify_list}      create list        ${carrierAggregationSupportList}
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
#     ...     ${a1ThresholdSCellAddSsbRsrpTDD}
#     ...     ${actMeasBasedSCellAddition}
#     ...     ${nrCellType}
#     ...     ${sCellDeactivationTimerGNB}
#     ...     ${actVoNR}
#     ...     ${srbInactivityTimerSA}
#     modify_xml          ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair
#     ...    ${scfc_path}
#     ...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step 2: Attach UE1 to one NR TDD FR1 cell
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     ${ue_ability}    Obtain Ue Capability    vonr_n78
#     Airphone SA Attach    ue_id=${UE_ID}    ue_capability=${ue_ability}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     ${cmd}=    Set Variable    csi_override_testmode_nr profile_id=1 cqi=15 pmi=2 ri=1 cqi_mode=fixed pmi_mode=fixed ri_mode=fixed
#     airphone_execute_egate_command    ${cmd}
#     ${cmd}=    Set Variable    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1 scell=0,1
#     airphone_execute_egate_command    ${cmd}
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=1 kbps\=100 dir\=dl protocol\=udp seconds\=3600
#     Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step 3: Add 5QI-5 PDU Session
#     Start Collect GNB and AP Syslog in 'step3_add_5qi-5' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Pdu Session Modify    qosflows_to_add=2    by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5 qfi 2
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 trf_id\=1 kbps\=100 dir\=dl protocol\=tcp seconds\=3600
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_add_5qi-5
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_add_5qi-5
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_add_5qi-5${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_add_5qi-5${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_add_5qi-5' File
# 
# Step 4: Add 5QI-1 PDU Session Star VONR
#     Start Collect GNB and AP Syslog in 'step4_add_5qi-1' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Pdu Session Modify    qosflows_to_add=3    by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 1 qfi 3
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 kbps\=100 dir\=dl protocol\=udp seconds\=3600
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_add_5qi-1
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_add_5qi-1
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_add_5qi-1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_add_5qi-1${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_add_5qi-1' File
# 
# Step 5: UE send A1 measurement report
#     Start Collect GNB and AP Syslog in 'step5_trigger_A1' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Cqi Param    nr_cqi=15
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...    pass_regexp=SCellIndex 1 activated successfully
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_trigger_A1
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_trigger_A1
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_trigger_A1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_trigger_A1${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_trigger_A1' File
# 
# Step 6: Send some DL data traffic
#     Start Collect GNB and AP Syslog in 'step6_send_data' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=1 mbps\=175 dir\=dl seconds\=3600
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=2 mbps\=175 dir\=dl seconds\=3600
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=3 mbps\=175 dir\=dl seconds\=3600
#     Wait Throughput Timer    2
#     #${pcell_dl_tput}=    airphone_sa_get_throughput    ${UE_ID}    DL    ${PDU_ID}
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_data${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_send_data
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_send_data
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step6_send_data${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C23002    cell_id=1
#     ${PM_counter_value_Scell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C23002    cell_id=2
#     ${PM_counter_value5qi8_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01008    cell_id=1
#     ${PM_counter_value5qi5_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=1
#     ${PM_counter_value5qi1_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=1
#     ${PM_counter_value5qi8_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01008    cell_id=2
#     ${PM_counter_value5qi5_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=2
#     ${PM_counter_value5qi1_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=2
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_send_data/output
#     should be true    ${PM_counter_value_Pcell}>0
#     should be true    ${PM_counter_value_Scell}==0
#     should be true    ${PM_counter_value5qi8_p}>0
#     should be true    ${PM_counter_value5qi5_p}>0
#     should be true    ${PM_counter_value5qi1_p}>0
#     should be true    ${PM_counter_value5qi8_s}>0
#     should be true    ${PM_counter_value5qi5_s}==0
#     should be true    ${PM_counter_value5qi1_s}==0
#     #log    ${pcell_dl_tput}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_send_data' File
# 
# Step 7: Release VONR
#     Start Collect GNB and AP Syslog in 'step7_release_vonr' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Pdu Session Modify    qosflows_to_del=3    pass_regexp=Removed FiveQi:Qfi mapping fiveQi 1 qfi 3
#     Wait Throughput Timer    2
#     Airphone Pdu Session Modify    qosflows_to_del=2    pass_regexp=Removed FiveQi:Qfi mapping fiveQi 5 qfi 2
#     Wait Throughput Timer    2
#     #${pcell_dl_tput}=    airphone_sa_get_throughput    ${UE_ID}    DL    ${PDU_ID}
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_release_vonr${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_release_vonr${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step7_release_vonr
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    60
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step7_release_vonr${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C23002    cell_id=1
#     ${PM_counter_value_Scell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C23002    cell_id=2
#     ${PM_counter_value5qi8_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01008    cell_id=1
#     ${PM_counter_value5qi5_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=1
#     ${PM_counter_value5qi1_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=1
#     ${PM_counter_value5qi8_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01008    cell_id=2
#     ${PM_counter_value5qi5_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=2
#     ${PM_counter_value5qi1_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=2
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step7_release_vonr/output
#     should be true    ${PM_counter_value_Pcell}==0
#     should be true    ${PM_counter_value_Scell}==0
#     should be true    ${PM_counter_value5qi8_p}>0
#     should be true    ${PM_counter_value5qi5_p}==0
#     should be true    ${PM_counter_value5qi1_p}==0
#     should be true    ${PM_counter_value5qi8_s}>0
#     should be true    ${PM_counter_value5qi5_s}==0
#     should be true    ${PM_counter_value5qi1_s}==0
#     #log    ${pcell_dl_tput}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_release_vonr' File
# 
# Step 8: create VONR again with little vonr data
#     Start Collect GNB and AP Syslog in 'step8_creat_VONR_again' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Pdu Session Modify    qosflows_to_add=2    by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5 qfi 2
#     Wait Throughput Timer    2
#     Airphone Pdu Session Modify    qosflows_to_add=3    by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 1 qfi 3
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 trf_id\=1 kbps\=100 dir\=dl protocol\=tcp seconds\=3600
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 kbps\=100 dir\=dl protocol\=udp seconds\=3600
#     Wait Throughput Timer    2
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_creat_VONR_again${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_creat_VONR_again${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step8_creat_VONR_again
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step8_creat_VONR_again/output
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step7_release_vonr${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C23002    cell_id=1
#     ${PM_counter_value_Scell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C23002    cell_id=2
#     ${PM_counter_value5qi8_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01008    cell_id=1
#     ${PM_counter_value5qi5_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=1
#     ${PM_counter_value5qi1_p}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=1
#     ${PM_counter_value5qi8_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01008    cell_id=2
#     ${PM_counter_value5qi5_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01005    cell_id=2
#     ${PM_counter_value5qi1_s}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01001    cell_id=2
#     should be true    ${PM_counter_value_Pcell}>0
#     should be true    ${PM_counter_value_Scell}==0
#     should be true    ${PM_counter_value5qi8_p}>0
#     should be true    ${PM_counter_value5qi5_p}>0
#     should be true    ${PM_counter_value5qi1_p}>0
#     should be true    ${PM_counter_value5qi8_s}>0
#     should be true    ${PM_counter_value5qi5_s}==0
#     should be true    ${PM_counter_value5qi1_s}==0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step8_creat_VONR_again' File
# 
# Step 9: Detach UE
#     Start Collect GNB and AP Syslog in 'step9_detach' File
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step9_detach' File
