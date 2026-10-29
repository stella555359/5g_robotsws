# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB007922_Case122_D_B_4a_2CC_CA_Single_CAUE_A1add_blindactivition_Data_transfermation_with_DRX_SA
# ...
# ...               This user scenario describes the successful DRX setup for UE 
#    ...    together with TDD FR1 DL CA up to 2CCs in SA mode
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD   
#    ...     RAN_5G    CRT    SBTS00    SBTS23R1
# ...    owner_jiangzhaona    AP
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           ta_a2a
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# 
# ${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|true|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# ${actDl256Qam}    text|true|//*[@name\="actDl256Qam"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}    text|0|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}    text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}    text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${actMeasBasedSCellAddition}    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${chBw}           text|80MHz|//*[@name="chBw"]
# ${dlMimoMode}       text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${drxInactivityTimer}    text|20ms|//*[@name="drxInactivityTimer"]
# ${drxRetransTimerDl}     text|0slot|//*[@name="drxRetransTimerDl"]
# ${drxLongCycle}    text|40ms|//*[@name="drxLongCycle"]
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# *** Test Cases ***
# CB007922_Case122_D_B_4a_2CC_CA_Single_CAUE_A1add_blindactivition_Data_transfermation_with_DRX_SA
#     Step1:Update parameters between 2 TDD cells
#     Step2:Attach UE1 to one NR TDD FR1 cell
#     Step3:UE send A1 measurement report
#     Step4:Start DL data traffic
#     Step5:Stop data and Detach UE
# 
# *** Keywords ***
# Step1:Update parameters between 2 TDD cells
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}
#     ...    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${cellDepType}    ${actCDrx}    
#    ...    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${ssBurstSetPeriod}   
#    ...     ${drxInactivityTimer}    ${drxRetransTimerDl}
#     ...    ${actDl256Qam}    ${sCellAdditionMethod}    ${maxNumScellsDl}    ${actFdmScheduling}    
#    ...    ${sCellDeactivationBadRlqCount}    ${drxLongCycle}
#     ...    ${tdLteUlDlConfig}    ${sCellActivationMethod}    ${a1MeasSCellAddEnabled}    
#    ...    ${actMeasBasedSCellAddition}    ${chBw}    ${dlMimoMode}
#     ...    ${a1ThresholdSCellAddSsbRsrpTDD}    ${numberOfRxBeamforming}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:Attach UE1 to one NR TDD FR1 cell
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     Set SSB Beam
#     Airphone Location Change    id=${UE_ID}    cell_id=2
#     Airphone SA Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ue_id=${UE_ID}    pass_regexp=drx-Config
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:UE send A1 measurement report
#     Start Collect GNB and AP Syslog in 'Step3_trigger_A1' File
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_trigger_A1' File
# 
# Step4:Start DL data traffic
#     Start Collect GNB and AP Syslog in 'Step4_start_dl' File
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Wait Throughput Timer    3
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    8
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step4_start_dl
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step4_start_dl/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}Step4_start_dl
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    
#    ...    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1   
#    ...     type=pdsch    tput_type=ave
# 	should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_start_dl' File
# 
# Step5:Stop data and Detach UE
#     Start Collect GNB and AP Syslog in 'Step5_stop_data' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     Wait Throughput Timer    180
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step5_stop_data/
#     ${cell2_PM_slots_drx_active}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
#    ...    counter_id=M55308C11001     cell_id=2
#     ${cell2_PM_slots_drx_sleep}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
#    ...    counter_id=M55308C11002     cell_id=2
#     ${cell3_PM_slots_drx_active}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
#    ...    counter_id=M55308C11001     cell_id=3
#     ${cell3_PM_slots_drx_sleep}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    
#    ...    counter_id=M55308C11002     cell_id=3
#     ${cell2_scale_sleep_active}    evaluate    round(float(${cell2_PM_slots_drx_sleep})/float(${cell2_PM_slots_drx_active}),2)
#     ${cell3_scale_sleep_active}    evaluate    round(float(${cell3_PM_slots_drx_sleep})/float(${cell3_PM_slots_drx_active}),2)
#     should be true    2.5<${cell2_scale_sleep_active}<=3.2
#     should be true    2.5<${cell3_scale_sleep_active}<=3.2
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_stop_data' File
# 
# Set SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach
