# *** Settings ***
# Documentation    Author: jing.pan@nokia-sbell.com
# ...
# ...        example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...        QC case full name:
# ...        CB007922_case10_D_3_Single_UE_Peak_BW80_80_closedmode44_256qam_64qam
# ...
# ...        Single UE connection setup and DL/UL data scheduling in SA option 2
# ...        A1 MR based SCell addition and buffer-based SCell activation
# ...        The parameter "PDSCH to HARQ feedback Timing" in the DL DCI indicates the transmission
# ...        timing of UCI report within PUCCH to the UE. If the DL DCI is sent at NR-Slot n, the corresponding
# ...        UCI transmission shall happen at NR-slot n + k1. k1 being equal to dlDataToUlAck[PDSCH to HARQ feedback Timing].
# ...        The dlDataToUlAck is determined by 5G_RAN_UP_12062 and reported to C-Plane in cell configuration response message.
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    CLOUD_5G_I_KL_AP_KL_SANSA_L1B_CPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS22R2    SBTS22R3    SBTS23R1
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}    1
# ${PDU_ID}    1
# ${GW_ID}    1
# ${SLICE_ID}     1
# ${SCFC_NAME}        gNB_scf_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQA_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.xml
# ${WTS_NAME}         wts_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${MSG1}     itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}     itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}    itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}    itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${carrierAggregationSupportList}    text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}       text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}        text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}        text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}        text|false|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}       text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}     text|1 beam|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}          text|beamSet_1|//*[@name\="basicBeamSet"]
# ${nrCellType}        text|4DL2UL|//*[@name\="nrCellType"]
# ${cellDepType}          text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}          text|false|//*[@name\="actCDrx"]
# ${frameStructureType}      text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}       text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}       text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}     text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}       text|20|//*[@name\="ssBurstSetPeriod"]
# ${actDl256Qam}          text|false|//*[@name\="actDl256Qam"]
# ${sCellAdditionMethod}        text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}        text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}       text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}    text|0|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}       text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}       text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${actMeasBasedSCellAddition}    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${a1ThresholdSCellAddSsbRsrpTDD}                text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# #${chBw}            text|60MHz|//*[@name\="chBw"]
# 
# *** Test Cases ***
# CB007922_case10_D_3_Single_UE_Peak_BW80_80_closedmode44_256qam_64qam
#     Step1:Set parameter and wait for onair
#     Step2:Attach CA UE to cell1 and Send measurement report for A1 event to gNB
#     Step3:Initiate enough DL and UL data transfer for UE
#     Step4:Detach UE
#     Step5:Change actDl256Qam is true
#     Step6:Attach CA UE to cell1
#     Step7:Send measurement report for A1 event to gNB
#     Step8:Initiate enough DL and UL data transfer for UE
#     Step9:Detach UE
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
#     ${modify_list}    create list    ${carrierAggregationSupportList}
#     ...    ${actInterNumerologyCa}
#     ...    ${flexibleCAMode}
#     ...    ${pucchModeSelect}
#     ...    ${actBeamforming}
#     ...    ${nrBtsBeamRefinementP2}
#     ...    ${numberOfTransmittedSsBlocks}
#     ...    ${basicBeamSet}
#     ...    ${cellDepType}
#     ...    ${actCDrx}
#     ...    ${frameStructureType}
#     ...    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}
#     ...    ${prachConfigurationIndex}
#     ...    ${ssBurstSetPeriod}
#     ...    ${actDl256Qam}
#     ...    ${sCellAdditionMethod}
#     ...    ${maxNumScellsDl}
#     ...    ${actFdmScheduling}
#     ...    ${sCellDeactivationBadRlqCount}
#     ...    ${sCellActivationMethod}
#     ...    ${a1MeasSCellAddEnabled}
#     ...    ${actMeasBasedSCellAddition}
#     ...    ${a1ThresholdSCellAddSsbRsrpTDD}
# #    ...    ${chBw}
#     modify_xml          ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair
#     ...    ${scfc_path}
#     ...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:Attach CA UE to cell1 and Send measurement report for A1 event to gNB
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Airphone Cqi Param    nr_cqi=15
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...    pass_regexp=sCellToAddModList
#     Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
# #    ${ret1}=    Get Field Value From BIP Files By Name    ${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}*.pcap*    ${MSG1}    ${FILTER1}
# #    ${ret2}=    Get Field Value From BIP Files By Name    ${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}*.pcap*    ${MSG2}    ${FILTER2}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step3:Initiate enough DL and UL data transfer for UE
#     Start Collect GNB and AP Syslog in 'step3_send_dl_data' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
# #    Airphone SA Start Data Traffic    ${UE_ID}    UL    20M     trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_dl_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_dl_data${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_dl_data
#     Wait Throughput Timer    10
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_send_dl_data/output
#     check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/A2A_log_Check/deactDl256Qam.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}step3_send_dl_data
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_dl_data' File
# 
# Step4:Detach UE
#     Start Collect GNB and AP Syslog in 'step4_detach' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     #airphone_sa_stop_data_traffic    ${UE_ID}    UL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_detach' File
# 
# Step5:Change actDl256Qam is true
#     Start Collect GNB and AP Syslog in 'step5_Change_parameter' File
#     Start GNB BIP Log
# #    Start AP BIP Log
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-1
#     ...    parameter=actDl256Qam    operation=update    value=true
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-2
#     ...    parameter=actDl256Qam    operation=update    value=true
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait Throughput Timer    20
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_Change_parameter${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_Change_parameter${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_Change_parameter' File
# 
# Step6:Attach CA UE to cell1
#     Start Collect GNB and AP Syslog in 'step6_ue_attach_again' File
#     Start GNB BIP Log
# #    Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_ue_attach_again
#    # Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_ue_attach_again/output
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_ue_attach_again${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_ue_attach_again${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_ue_attach_again' File
# 
# Step7:Send measurement report for A1 event to gNB
#     Start Collect GNB and AP Syslog in 'step7_triger_a1' File
#     Start GNB BIP Log
# #    Start AP BIP Log
#     Airphone Cqi Param    nr_cqi=15
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...    pass_regexp=sCellToAddModList
#     Wait Throughput Timer    10
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_triger_a1${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_triger_a1${/}
# #    ${ret1}=    Get Field Value From BIP Files By Name    ${TEST_LOG_DIRECTORY()}${/}step7_triger_a1${/}*.pcap*    ${MSG1}    ${FILTER1}
# #    ${ret2}=    Get Field Value From BIP Files By Name    ${TEST_LOG_DIRECTORY()}${/}step7_triger_a1${/}*.pcap*    ${MSG2}    ${FILTER2}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_triger_a1' File
# 
# Step8:Initiate enough DL and UL data transfer for UE
#     Start Collect GNB and AP Syslog in 'step8_send_dl_data_again' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_send_dl_data_again${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_send_dl_data_again${/}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step8_send_dl_data_again
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step8_send_dl_data_again/output
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/actDl256Qam.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step8_send_dl_data_again
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step8_send_dl_data_again' File
# 
# Step9:Detach UE
#     Start Collect GNB and AP Syslog in 'step9_detach_again' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
# #    airphone_sa_stop_data_traffic    ${UE_ID}    UL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step9_detach_again' File
