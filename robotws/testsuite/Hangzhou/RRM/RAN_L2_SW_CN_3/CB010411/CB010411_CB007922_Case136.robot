# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB007922_Case136_D_A_3a_interL2RT_Single_UE_DL_UL_NSA_SSBBF_and_blind_addition_5GC001116_SF0_SSF26_4X2
# ...
# ...               This user scenario describes the successful operations, deletion or addition of CA association between PSCell and SCell.
# 
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# #Test Teardown     AiC Common Test Teardown
# Force Tags        CLOUD_5GC_dRNIC_1vDU_O_AP_LO    AP    SBTS00    RAN_5G_TDD    RAN_5G
# Test Timeout      60 minutes
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/vRan/
# ${DU_SCF}             scfc_VDU_7922.xml
# ${CU_SCF}             scfc_VCU_7922.xml
# ${AIRPHONE_NAME}      iphy_7922.xml
# ${WTS_NAME}           basic_setup_7922.cfg
# ${UE_ID}         11
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# #${carrierAggregationSupportList}    text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${basicBeamSet}          text|beamSet_6|//*[@name\="basicBeamSet"]
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${cellDepType}           text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}               text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}     text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}     text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${tdLteUlDlConfig}       text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ssBurstSetPeriod}      text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellAdditionMethod}        text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}        text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}      text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}     text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${chBw}                  text|60MHz|//*[@name='chBw']
# ${dlMimoMode}            text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name="dlMimoMode"]
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# *** Test Cases ***
# CB007922_Case136_D_A_3a_interL2RT_Single_UE_DL_UL_NSA_SSBBF_and_blind_addition_5GC001116_SF0_SSF26_4X2_vran
#     Step1:Configure parameters as descript in precondition
#     Step2:Attach UE-1 to the LTE cell and initiate EN-DC toward the TDD FR1
#     Step3:Push UL/DL data
#     Step4:Detach ue
# 
# *** Keywords ***
# Step1:Configure parameters as descript in precondition
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     ${vDU_scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc_VDU_7922.xml
#     copy_file    ${CONFIG_DIR_PATH}/${DU_SCF}   ${vDU_scfc_path}
# 
#     ${vCU_scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc_VCU_7922.xml
#     copy_file    ${CONFIG_DIR_PATH}/${CU_SCF}   ${vCU_scfc_path}
# 
# 
#     ${modify_list_DU}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}    ${actCDrx}
#     ...    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${cellDepType}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${ssBurstSetPeriod}
#     ...    ${tdLteUlDlConfig}    ${sCellActivationMethod}    ${actFdmScheduling}
#     ...    ${sCellDeactivationTimerGNB}
#     ...    ${chBw}    ${numberOfRxBeamforming}
#     #...    ${dlMimoMode}    ${actPdschAtSsbSlots}
#     modify_xml   ${vDU_scfc_path}   ${vDU_scfc_path}    ${modify_list_DU}
# 
#     ${modify_list_CU}    create list    ${sCellAdditionMethod}    ${maxNumScellsDl}
#     modify_xml   ${vCU_scfc_path}   ${vCU_scfc_path}    ${modify_list_CU}
# 
#     Modify TL VM And AP SCTP Configuration
#     AIC Perform Full Commission And Reach Onair   ${vDU_scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}     ${vCU_scfc_path}
#     #AIC Perform Full Commission And Reach Onair   ${vDU_scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}     ${CONFIG_DIR_PATH}/${CU_SCF}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:Attach UE-1 to the LTE cell and initiate EN-DC toward the TDD FR1
#     Start Collect GNB and AP Syslog in 'step2_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step2_attach
#     Airphone Nsa Attach    ue_id=${UE_ID}    cell_id=1
#     Set UE_${UE_ID} SSB Beam
#     Wait '2s' for stable
#     airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/RRC_scelladd_51.ini    log_need_to_check=p    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_attach' File
# 
# Step3:Push UL/DL data
#     Start Collect GNB and AP Syslog in 'step3_send_data' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step3_send_data
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    UL    25M     trf_id=5    duration=${3600}
#     ${id}    VDU Start TTiTrace Log
#     Wait '5s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}step3_send_data/ttiTrace
# 
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_ul_136.ini    log_need_to_check=i    save_log_directory=${save_log}
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/tti_dl_136.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${Pcell_dl_tput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     ${Scell_dl_tput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=2    type=pdsch    tput_type=ave
#     ${Total_thp}    evaluate    ${Pcell_dl_tput}+${Scell_dl_tput}
#     should be true    ${Pcell_dl_tput} > 0
#     should be true    ${Scell_dl_tput} > 0
#     should be true    ${Total_thp} > 245000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# 
# Step4:Detach ue
#     Airphone NSA Detach    ${UE_ID}
# 
# Set UE_${UE_ID} SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${UE_ID} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=secondary
# 
# wait ${time} to check log
#     sleep    ${time}
# 
# Capture tti for ${ttiduring} in ${ttipath}
#     ${id}    VDU Start TTiTrace Log
#     #Wait ${ttiduring} for stable
#     Wait '8s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}${ttipath}/ttiTrace
# 
# Check ${ttipath} ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${ttipath}
