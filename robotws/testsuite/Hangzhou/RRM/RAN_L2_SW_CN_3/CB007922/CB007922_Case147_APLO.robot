# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB007922_Case147_D_A_6c_interL2RT_interBand_Multiple_UE_DL_UL_data_scheduling_NSA_SSBBF_and_A1_Scell_addition
# ...
# ...               This user scenario describes the successful EN-DC setup with TDD FR1-TDD FR1 Carrier aggregation
# ...               in NSA 3x feature activated for the multiple 5G-UEs
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    owner_jiangzhaona    AP
# #...    CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# #Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# 
# ${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|ms1280|//*[@name\="sCellDeactivationTimerGNB"]
# ${chBw}           text|80MHz|//*[@name='chBw']
# ${dlMimoMode}    text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name="dlMimoMode"]
# ${BEAM_SET}    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# *** Test Cases ***
# CB007922_Case147_D_A_6c_interL2RT_interBand_Multiple_UE_DL_UL_data_scheduling_NSA_SSBBF_and_A1_Scell_addition
#     Step1:Configure parameters as describe in precondition
#     Step2:Attach 5CA capable 5G-UEs and 5NCA capable 5G-UEs to LTE cell and trigger SgNB addition procedure to NR TDD FR1 cell
#     Step3:Set SSB beam
#     Step4:Start some DL and UL data traffic to each UE
#     Step5:Stop data and detach all UEs
# 
# *** Keywords ***
# Step1:Configure parameters as describe in precondition
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}
#     ...    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${cellDepType}    ${actCDrx}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${ssBurstSetPeriod}    ${dlMimoMode}    ${actPdschAtSsbSlots}
#     ...    ${tdLteUlDlConfig}    ${sCellActivationMethod}    ${sCellAdditionMethod}    ${maxNumScellsDl}    ${actFdmScheduling}
#     ...    ${chBw}    ${sCellDeactivationTimerGNB}    ${numberOfRxBeamforming}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:Attach 5CA capable 5G-UEs and 5NCA capable 5G-UEs to LTE cell and trigger SgNB addition procedure to NR TDD FR1 cell
#     Start Collect GNB and AP Syslog in 'step2_attach' File
#     Attach CA 5UEs to cell4
#     Attach NCA 5UEs to cell4
#     wait 5s to stable
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step2_attach   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/RRC_scelladd_50.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step2_attach
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_attach' File
# 
# Step3:Set SSB beam
#     Set 10UEs SSB Beam
# 
# Step4:Start some DL and UL data traffic to each UE
#     Start Collect GNB and AP Syslog in 'step4_send_data' File
#     send 10UEs DL and UL data
#     Capture tti for 2s in step4_send_data
#     Check step4_send_data ttitrace
#     Wait until keyword succeeds    60s    5s    Verify CA 5UEs throughput
#     Wait until keyword succeeds    60s    5s    Verify NCA 5UEs throughput
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_send_data' File
# 
# Step5:Stop data and detach all UEs
#     Airphone NSA Stop Data Traffic And Detach 10UEs
# 
# 
# Set ${UE_num}UEs SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET}
#     : FOR    ${num}    IN RANGE    11    11+${UE_num}
#     \    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=secondary
# 
# Attach CA ${numOfUE}UEs to cell${cellId}
#     : FOR    ${num}    IN RANGE    11    11+${numOfUE}
#     \    ${ue_id}    Evaluate    str(${num})
#     \    Airphone Nsa Attach    ue_id=${ue_id}    cell_id=${cellId}
#     \    Wait 3s to stable
#     \    airphone_execute_egate_command    ue_measurement_send_nr id\=${ue_id} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=80
#     ...    pass_regexp=sCellToAddModList
# 
# Attach NCA ${numOfUE}UEs to cell${cellId}
#     : FOR    ${num}    IN RANGE    16    16+${numOfUE}
#     \    ${ue_id}    Evaluate    str(${num})
#     \    Wait 3s to stable
#     \    Airphone Nsa Attach    ue_id=${ue_id}    cell_id=${cellId}
# 
# 
# wait ${time} to stable
#     sleep    ${time}
# 
# send ${ues}UEs DL and UL data
#     : FOR    ${num}    IN RANGE    11    11+${ues}
#     \    Airphone NSA Start Data Traffic    ${num}    DL    175M    trf_id=${num}    duration=${3600}
#     \    Airphone Nsa Start Data Traffic    ${num}    UL    25M    trf_id=${num}    duration=${3600}
# 
# Capture tti for ${ttiduring} in ${ttipath}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    ${ttiduring}
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${ttipath}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${ttipath}/tti
# 
# Check ${ttipath} ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl_136.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${ttipath}
# 
# Verify CA ${numOfUE}UEs throughput
#     : FOR    ${num}    IN RANGE    11    11+${numOfUE}
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=9    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>9000
#     \    should_be_true    ${dl_throughput_scell1}>9000
# 
# Verify NCA ${numOfUE}UES throughput
#     : FOR    ${num}    IN RANGE    16    16+${numOfUE}
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>9000
# 
# Airphone NSA Stop Data Traffic And Detach ${allUEs}UEs
#     : FOR    ${num}    IN RANGE    11    11+${allUEs}
#     \    ${ue_id}    Evaluate    str(${num})
#     \    Airphone NSA Stop Data Traffic   ${ue_id}    DL
#     \    Airphone NSA Stop Data Traffic   ${ue_id}    UL
#     \    Airphone NSA Detach    ${ue_id}
