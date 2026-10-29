# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB007922_Case158_D_A_10_LTE_enforced_MGAP_configuration_for_TDD_FR1_CA_UE_by_SgNB_addition
# ...
# ...               This user scenario describes the successful EN-DC setup with TDD FR1-TDD FR1 Carrier aggregation
# ...               in NSA 3x feature activated for the multiple 5G-UEs
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS22R3    SBTS23R1
# ...    owner_jiangzhaona    AP
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# #Resource          ../resources/sg10/internal_resource/internal_resource.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${UE_ID}          11
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
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|true|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${tdLteUlDlConfig}      text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellAdditionMethod}    text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|ms1280|//*[@name\="sCellDeactivationTimerGNB"]
# ${gapOffset}    text|20|//*[@name\="gapOffset"]
# ${mgta}    text|ms0dot5|//*[@name\="mgta"]
# ${lteToNrTimeOffset}    text|0|//*[@name\="lteToNrTimeOffset"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${chBw}           text|20MHz|//*[@name='chBw']
# ${dlMimoMode}    text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name="dlMimoMode"]
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# ${BEAM_CMD}    ue_testmode_set_nr id\=11 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=secondary
# ${GAP_CMD}    ue_enb_param id\=11 drx_config\=off measurement_gap\=gp0:20 gap_trigger\=enb_and_gnb_triggered mgta\=ms0dot50 gap_purpose\=perUE
# ${ENDC_CMD}       ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=4 bearer\=2 type\=split_scg
# *** Test Cases ***
# CB007922_Case158_D_A_10_LTE_enforced_MGAP_configuration_for_TDD_FR1_CA_UE_by_SgNB_addition
#     Step1:Configure parameters as describe in precondition
#     Step2:Attach UE to LTE cell
#     Step3:Try to trigger Enb enter gap measurement
#     Step4:Check RRCConnectionReconfiguration Message
#     Step5:Send dl data
#     Step6:Detach ue
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
#     ...    ${chBw}    ${sCellDeactivationTimerGNB}    ${gapOffset}    ${mgta}    ${lteToNrTimeOffset}    ${lteToNrFrameShift}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:Attach UE to LTE cell
#     Start Collect GNB and AP Syslog in 'step2_attach' File
#     airphone_execute_egate_command    ue_attach id\=${UE_ID}
#     Set UE_${UE_ID} SSB Beam
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_attach' File
# 
# Step3:Try to trigger Enb enter gap measurement
#     Start Collect GNB and AP Syslog in 'step3_gap' File
#     airphone_execute_egate_command    ${GAP_CMD}
#     airphone_execute_egate_command    ${ENDC_CMD}    pass_regexp=Successfully reconfigured dual connectivity
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_gap' File
# 
# Step4:Check RRCConnectionReconfiguration Message
#     Start Collect GNB and AP Syslog in 'step4_RRC' File
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step4_RRC   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/Gap_drx.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step4_RRC
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_RRC' File
# 
# Step5:Send dl data
#     Start Collect GNB and AP Syslog in 'step5_send_dl' File
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    duration=${3600}
# 	Airphone Nsa Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    duration=${3600}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    8
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_send_dl
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_send_dl/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step5_send_dl
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
# 	${Total_thp}    evaluate    ${Pcell_dl_throughput}+${Scell_dl_throughput}
# 	should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     should be true    ${Total_thp} > 15500
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_send_dl' File
# 
# Step6:Detach ue
#     Airphone NSA Stop Data Traffic   ${UE_ID}    DL
#     Airphone NSA Detach    ${UE_ID}
# 
# 
# Set UE_${UE_ID} SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET}
#     airphone_execute_egate_command    ${BEAM_CMD}
# 
# wait ${time} to stable
#     sleep    ${time}
# 
# 
# 
