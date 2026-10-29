# *** Settings ***
# Documentation    Author: jing.pan@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB006293_D_case7_5G_eCPRI_mMIMO_SINR_Diagnoses
# ...
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS23R1
# #...    CLOUD_5G_I_MO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
# Resource    ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library     taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library     taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
# Library     ta_a2a
# 
# *** Variable ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_1='true'    L2_L1_BIP='false'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    CAPTURING_INTERFACE='any'
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# 
# ${actRemoteRfDiag}         text|true|//*[@name\="actRemoteRfDiag"]
# ${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrCellType}     text|4DL4UL|//*[@name\="nrCellType"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${chBw2}           text|80MHz|//*[contains(@distName, 'NRCELL-2')]/*[@name='chBw']
# ${chBw3}           text|60MHz|//*[contains(@distName, 'NRCELL-3')]/*[@name='chBw']
# ${dlMimoMode}       text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# ${cellId}         1
# ${cellType}       NR
# ${testOutcome}    Pass
# ${FILTER1}        itf_l2_ps_cell_testmeasurementreq || itf_l2_ps_cell_ultestmeasurementind
# @{title1}         itf_l2_ps_cell_TestMeasurementReq_t.transactionId
# ...               itf_l2_ps_cell_UlTestMeasurementInd_t.transactionId
# ...               itf_l2_ps_cell_UlTestMeasurementInd_t.nrCellIdentity
# ...               itf_l2_ps_cell_TestMeasurementReq_t.MeasurementTypeList_item
# ...               itf_l2_ps_cell_UlTestMeasurementIndSubcell_t.AvgRssiOfAnt_item
# ...               itf_l2_ps_cell_UlTestMeasurementIndSubcell_t.AvgSinrOfAnt_item
# ...               itf_l2_ps_cell_UlTestMeasurementIndSubcell_t.AvgRtwpOfAnt_item
# 
# *** Test Cases ***
# CB006293_D_case7_5G_eCPRI_mMIMO_SINR_Diagnoses
#     Step1:gNB is onair with the configuration
#     Step2:Attach UE1 to TDD FR1 cell
#     Step3:UE1 do UL DL data transfer
#     Step4:Run RF Diagnostic Test and check result
# 
# *** Keywords ***
# Step1:gNB is onair with the configuration
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}                Set Variable                      ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}
#     ...    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${cellDepType}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${ssBurstSetPeriod}
#     ...    ${actFdmScheduling}    ${chBw2}      ${chBw3}
#     ...    ${dlMimoMode}    ${tdLteUlDlConfig}    ${nrCellType}
#     ...    ${numberOfRxBeamforming}    ${actRemoteRfDiag}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair
#     ...    ${scfc_path}
#     ...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:Attach UE1 to TDD FR1 cell
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
# #    Start GNB BIP Log
# #    Start GNB Ttitrace With Streaming Mode
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     ${cmd}=    Set Variable    csi_override_testmode_nr profile_id=1 cqi=15 pmi=2 ri=0 cqi_mode=fixed pmi_mode=fixed ri_mode=fixed
#     airphone_execute_egate_command    ${cmd}
#     ${cmd}=    Set Variable    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1 scell=0,1
#     airphone_execute_egate_command    ${cmd}
#     Wait Throughput Timer    10
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
# #    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step3:UE1 do UL DL data transfer
#     Start Collect GNB and AP Syslog in 'step3_send_data' File
#     #Start GNB BIP Log
# #    Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    5M    trf_id=1    pdu_id=${PDU_ID}    duration=${36000}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
# #    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_data
#     Wait Throughput Timer    5
#     ${UE1_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
# #    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_send_data/output
#     should be true    ${UE1_dl_throughput_p}>1000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# 
# Step4:Run RF Diagnostic Test and check result
#     Start Collect GNB and AP Syslog in 'step4_RF_Diagnostic' File
#     Start GNB BIP Log
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=RF_Diagnostic
#     sleep    2    reason=Wait for response from admin
#     ${diagnostic_result_1}    TAF_ADMIN.start_rf_diagnostic_test    force_act_remote_rf_diag=True    cells=1    cell_type=NR
#     ...    rf_power_error_high_threshold=5  rf_power_error_low_threshold=-5    tx_antenna_vswr_high_threshold=5
#     ...    rx_antenna_rtwp_low_threshold=-120    rx_antenna_rtwp_high_threshold=-20
#     ...    rx_antenna_rssi_low_threshold=-110    rx_antenna_rssi_high_threshold=-30    alias=RF_Diagnostic
#     sleep    5    reason=Wait for response from admin
#     log    diagnostic_result_1=${diagnostic_result_1}     WARN
#     ${diagnostic_result_2}    TAF_ADMIN.save_rf_diagnostic_test_results    alias=RF_Diagnostic
#     log    diagnostic_result_2=${diagnostic_result_2}     WARN
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_RF_Diagnostic${/}
# 
#     run keyword and ignore error    OperatingSystem.Remove File    /home/ute/.local/lib/wireshark/plugins/3.6/epan/mcshark*
#     ${log_dir}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}step4_RF_Diagnostic
#     ${ret_transactionId}=    Get Field Value From BIP Files By Name    ${log_dir}${/}/tcpdump_L2L1_bip_filtering_off.pcap*
#     ...    itf_l2_ps_cell_TestMeasurementReq_t.MeasurementTypeList_item==3    itf_l2_ps_cell_TestMeasurementReq_t.transactionId
#     ${TransactionId}    Convert To Integer    ${ret_transactionId}[0]
#     ${ret2}=    Get Field Value From BIP Files By Xpath    ${log_dir}${/}/tcpdump_L2L1_bip_filtering_off.pcap*
#     ...    itf_l2_ps_cell_UlTestMeasurementInd_t.transactionId==${TransactionId}    itf_l2_ps_cell_UlTestMeasurementIndSubcell_t.AvgRssiOfAnt_item
# 
#     ${pdml} =  Get right pdml file    ${TEST_LOG_DIRECTORY()}
#     ${ret_SINR}     read xml     ${TEST_LOG_DIRECTORY()}/${pdml}
#     ...    attrib\=show|//*[matches(@showname, "AvgSinrOfAnt_item_0.*")]
#     ${ret_RSSI}     read xml     ${TEST_LOG_DIRECTORY()}/${pdml}
#     ...    attrib\=show|//*[matches(@showname, "AvgRssiOfAnt_item_0.*")]
#     ${bip_RSSI}    Get average value      ${TEST_LOG_DIRECTORY()}/${pdml}    AvgRssiOfAnt_item
#     ${bip_SINR}    Get average value      ${TEST_LOG_DIRECTORY()}/${pdml}    AvgSinrOfAnt_item
# 
# #    run keyword and ignore error
# #    ...    Convert BIP To CSV    ${log_dir}${/}/tcpdump_L2L1_bip_filtering_off.pcap2    ${log_dir}${/}/bip_1.csv    ${FILTER1}    ${title1}
# 
# #    Check RF Diagnostic Test Result
# #    log    diagnostic_result=${diagnostic_result_1}[requestMessage]     WARN
# #    log    requestMessage=${diagnostic_result_1}[requestMessage][0]     WARN
#     log    cellId=${diagnostic_result_1}[requestMessage][0][cellId]
#     log    cellType=${diagnostic_result_1}[requestMessage][0][cellType]
# #    log    results=${diagnostic_result_1}[requestMessage][0][results]     WARN
#     log    testOutcome=${diagnostic_result_1}[requestMessage][0][results][testOutcome]
#     log    rfAntResults=${diagnostic_result_1}[requestMessage][0][results][rfAntResults]    WARN
#     log    SINR=${diagnostic_result_1}[requestMessage][0][results][rfAntResults][0][sinr]
#     log    RSSI=${diagnostic_result_1}[requestMessage][0][results][rfAntResults][0][rssi]
#     log    RTWP=${diagnostic_result_1}[requestMessage][0][results][rfAntResults][0][rtwp]
# 
#     should be true    ${cellId} == ${diagnostic_result_1}[requestMessage][0][cellId]
#     should be true    "${cellType}" == "${diagnostic_result_1}[requestMessage][0][cellType]"
#     should be true    "${testOutcome}" == "${diagnostic_result_1}[requestMessage][0][results][testOutcome]"
#     should be true    ${bip_SINR}-2 <= ${diagnostic_result_1}[requestMessage][0][results][rfAntResults][0][sinr] <=${bip_SINR}+2
#     should be true    ${bip_RSSI}-4 <= ${diagnostic_result_1}[requestMessage][0][results][rfAntResults][0][rssi] <= ${bip_RSSI}+4
# 
# 
# Get average value
#     [Arguments]    ${pcap_path}      ${showname}
#     [Documentation]    This keyword is to get the average value of ${showname}
# #    ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/pcap2.pdml       showname="AvgRssiOfAnt_item.*:\\s(.*)\\"\\ssize
#     ${ret}     file match all       ${pcap_path}       showname="${showname}.*:\\s(.*)\\"\\ssize
#     ${value}     create list
# 	:FOR    ${r}    IN   @{ret}
# 	 \     ${f}     evaluate      float(${r})
# 	 \     append to list    ${value}      ${f}
# 	 ${avg}     evaluate      sum(${value})/len(${value})
# 	 Return From Keyword    ${avg}
# 
# Get right pdml file
#     [Arguments]    ${pdml_path}
#     [Documentation]    ignore the pdml file with size less than 5k
#      @{files} =	List Files In Directory    	${pdml_path}/    tcpdump*.pdml*
#      	:FOR    ${r}    IN   @{files}
# 	 \     ${f}     get_file_size      ${pdml_path}/${r}
# 	 \     Run Keyword If  ${f}<=2000    Remove File    ${pdml_path}/${r}
#      \     Run Keyword If  ${f}>2000    Return From Keyword    ${r}
