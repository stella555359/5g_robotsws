# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB007922_Case136_D_A_3a_interL2RT_Single_UE_DL_UL_NSA_SSBBF_and_blind_addition_5GC001116_SF0_SSF26_4X2
# ...
# ...               This user scenario describes the successful operations, deletion or addition of CA association between PSCell and SCell.
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS23R1    owner_jiangzhaona    AP
# #...    CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${UE1_ID}        11
# ${UE2_ID}        12
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# #${carrierAggregationSupportList}    text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}    text|true|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[contains(@distName, 'NRCELLGRP')]/*[@name='numberOfTransmittedSsBlocks']
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellAdditionMethod}    text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${chBw4}           text|60MHz|//*[contains(@distName, 'NRCELL-4')]/*[@name='chBw']
# ${chBw3}           text|80MHz|//*[contains(@distName, 'NRCELL-3')]/*[@name='chBw']
# ${chBw1}           text|80MHz|//*[contains(@distName, 'NRCELL-1')]/*[@name='chBw']
# ${dlMimoMode}    text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name="dlMimoMode"]
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# *** Test Cases ***
# CB007922_Case136_D_A_3a_interL2RT_Single_UE_DL_UL_NSA_SSBBF_and_blind_addition_5GC001116_SF0_SSF26_4X2
#     Step1:Configure parameters as descript in precondition
#     Step2:Attach UE-1 to the LTE cell and initiate EN-DC toward the TDD FR1
#     Step3:Push UL/DL data
#     Step4:Detach ue
# 
# *** Keywords ***
# Step1:Configure parameters as descript in precondition
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
#     ...    ${chBw1}    ${chBw3}    ${chBw4}    ${sCellDeactivationTimerGNB}    ${numberOfRxBeamforming}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:Attach UE-1 to the LTE cell and initiate EN-DC toward the TDD FR1
#     Start Collect GNB and AP Syslog in 'step2_attach' File
#     Airphone Nsa Attach    ue_id=${UE1_ID}    cell_id=4
#     Set UE_${UE1_ID} SSB Beam
#     wait 5s to check log
#     ${save_log2}=    Set Variable    ${TEST_LOG_DIRECTORY()}step2_attach
#     airphone_collect_egate_log_files      ${save_log2}   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/RRC_scelladd_50.ini    log_need_to_check=p    save_log_directory=${save_log2}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_attach' File
# 
# Step3:Push UL/DL data
#     Start Collect GNB and AP Syslog in 'step3_send_data' File
#     Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=2    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=3    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE1_ID}    DL    175M    trf_id=4    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE1_ID}    UL    25M    trf_id=5    duration=${3600}
#     Capture tti for 8s in step3_send_data
#     ${save_log3}=    Set Variable    ${TEST_LOG_DIRECTORY()}step3_send_data
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_ul_136.ini    log_need_to_check=i    save_log_directory=${save_log3}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl_136.ini    log_need_to_check=i    save_log_directory=${save_log3}
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE1_ID}    scell_id=9    type=pdsch    tput_type=ave
# 	${Total_thp}    evaluate    ${Pcell_dl_throughput}+${Scell_dl_throughput}
# 	should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     should be true    ${Total_thp} > 245000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# 
# Step4:Detach ue
#     Airphone NSA Detach    ${UE1_ID}
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
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    ${ttiduring}
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${ttipath}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}${ttipath}/tti
# 
# 
