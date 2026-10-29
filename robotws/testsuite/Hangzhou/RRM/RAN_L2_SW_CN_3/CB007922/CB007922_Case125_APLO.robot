# *** Settings ***
# Documentation     Author: zhaona.jiang@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB007922_Case125_D_B_4d_RLQ_based_suspension_and_resume_scheduling_with_drx
# ...
# ...               This user scenario describes the successful DRX setup for UE together with TDD FR1 DL CA up to 2CCs in SA mode.
# ...               It is assumed that P(S)Cell and SCell have almost same coverage(intra-band).
# 
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS23R1
# ...    owner_jiangzhaona    AP
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           ta_a2a
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${pmi_cmd}        csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=500
#                   ...    cri_mode=fixed cri=1 li_mode=fixed li=1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# 
# ${actInterNumerologyCa}    text|false|//*[@name\="actInterNumerologyCa"]
# ${drxRetransTimerUl}    text|0slot|//*[@name\="drxRetransTimerUl"]
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
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${nrCellType}    text|4DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellAdditionMethod}    text|blind|//*[@name\="sCellAdditionMethod"]
# ${sCellActivationMethod}    text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|ms1280|//*[@name\="sCellDeactivationTimerGNB"]
# ${sCellActivationMinDataThreshold}    text|6000|//*[@name\="sCellActivationMinDataThreshold"]
# ${sCellActivationLevel}    text|1TTI|//*[@name\="sCellActivationLevel"]
# ${sCellDeactivationBadRlqCount}    text|0|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellBadChannelQualityThreshold}        text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${sCellGoodChannelQualityThreshold}        text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellChannelEstimationPeriod}    text|2000|//*[@name="sCellChannelEstimationPeriod"]
# ${chBw}           text|80MHz|//*[@name="chBw"]
# ${dlMimoMode}       text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${drxInactivityTimer}    text|10ms|//*[@name="drxInactivityTimer"]
# ${drxRetransTimerDl}     text|0slot|//*[@name="drxRetransTimerDl"]
# ${drxLongCycle}    text|40ms|//*[@name="drxLongCycle"]
# ${BEAM_SET}     beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# *** Test Cases ***
# CB007922_Case125_D_B_4d_RLQ_based_suspension_and_resume_scheduling_with_drx
#     Step1:Configure parameters as descript in precondition
#     Step2:Attach ue and send UL/DL data
#     Step3:increase path loss to trigger bad RLQ
#     Step4:decrease path loss to trigger good RLQ
#     Step5:increase path loss for Scell to trigger bad RLQ again and stop dl data
#     Step6:decrease path loss for scell and start the DL data transfer again
#     Step7:keep UE to Scell good coverage area and stop the DL data transfer
#     Step8:Detach UE
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
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}    ${guardPeriodLength}
#     ...    ${numberOfTransmittedSsBlocks}    ${basicBeamSet}    ${cellDepType}    ${frameStructureType}    ${drxLongCycle}
#     ...    ${prachConfigurationIndex}    ${lteToNrFrameShift}    ${ssBurstSetPeriod}    ${tdLteUlDlConfig}    ${actCDrx}    ${drxInactivityTimer}
#     ...    ${drxRetransTimerDl}    ${nrCellType}    ${drxRetransTimerUl}    ${actDl256Qam}    ${sCellAdditionMethod}    ${maxNumScellsDl}
#     ...    ${actFdmScheduling}    ${sCellDeactivationBadRlqCount}    ${sCellActivationMinDataThreshold}    ${sCellActivationMethod}
#     ...    ${sCellDeactivationTimerGNB}    ${sCellChannelEstimationPeriod}    ${sCellBadChannelQualityThreshold}    ${chBw}    ${dlMimoMode}
#     ...    ${sCellGoodChannelQualityThreshold}    ${sCellActivationLevel}    ${numberOfRxBeamforming}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:Attach ue and send UL/DL data
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Set SSB Beam
#     Airphone Location Change    id=${UE_ID}    cell_id=2
#     Airphone SA Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ue_id=1    pass_regexp=drx-Config
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    UL    50M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     #Wait Throughput Timer    3
#     Wait Throughput Timer    30
#     airphone_execute_egate_command    ${pmi_cmd}
#     Wait Until Keyword Succeeds    90s    3s    check thp
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step2_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step2_attach/tti
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}Step2_attach
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	${Total_thp}    evaluate    ${Pcell_dl_throughput}+${Scell_dl_throughput}
# 	should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     should be true    ${Total_thp} > 200000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:increase path loss to trigger bad RLQ
#     Start Collect GNB and AP Syslog in 'Step3_RLQ_bad' File
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=1 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
# 	Airphone Bler Testmode Nr    profile_id=1    dl_bler=200,600,700,800,200,300,400,500
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=1 testmode\=bler profile_id\=1 action\=activate
# 	Wait Throughput Timer    3
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    5
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step3_RLQ_bad
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} == 0
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step3_RLQ_bad/tti
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_RLQ_bad' File
# 
# Step4:decrease path loss to trigger good RLQ
#     Start Collect GNB and AP Syslog in 'Step4_RLQ_good' File
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=1 testmode\=bler profile_id\=1 action\=deactivate
# 	Wait Throughput Timer    3
#     Start GNB Ttitrace With Streaming Mode
# 	${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	should be true    ${Pcell_dl_throughput} > 100000
#     should be true    ${Scell_dl_throughput} > 100000
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step4_RLQ_good
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step4_RLQ_good/tti
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step4_RLQ_good' File
# 
# Step5:increase path loss for Scell to trigger bad RLQ again and stop dl data
#     Start Collect GNB and AP Syslog in 'Step5_RLQ_bad_stop_dl' File
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=1 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=1 testmode\=bler profile_id\=1 action\=activate
#     Wait Throughput Timer    3
#     Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer     3
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} == 0
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step5_RLQ_bad_stop_dl
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step5_RLQ_bad_stop_dl/tti    #decode need time some mins
# 	Wait Throughput Timer    120
# 	airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
# 	Wait Throughput Timer    10
# 	${Scell_dl_throughput_stop} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	should be true    ${Scell_dl_throughput_stop} == 0
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step5_RLQ_bad_stop_dl' File
# 
# Step6:decrease path loss for scell and start the DL data transfer again
#     Start Collect GNB and AP Syslog in 'Step6_RLQ_good_start_dl' File
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=1 testmode\=bler profile_id\=1 action\=deactivate
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Wait Throughput Timer    3
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	should be true    ${Pcell_dl_throughput} > 100000
#     should be true    ${Scell_dl_throughput} > 100000
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step6_RLQ_good_start_dl
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step6_RLQ_good_start_dl/tti
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step6_RLQ_good_start_dl' File
# 
# Step7:keep UE to Scell good coverage area and stop the DL data transfer
#     Start Collect GNB and AP Syslog in 'Step7_stop_data' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 qfi\=1 dir\=ul
#     #Airphone SA Stop Data Traffic    1    UL
#     Wait Throughput Timer    180
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step7_stop_data/
#     ${cell2_PM_slots_drx_active}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001     cell_id=2
#     ${cell2_PM_slots_drx_sleep}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002     cell_id=2
#     ${cell3_PM_slots_drx_active}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001     cell_id=3
#     ${cell3_PM_slots_drx_sleep}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002     cell_id=3
#     ${cell2_scale_sleep_active}    evaluate    round(float(${cell2_PM_slots_drx_sleep})/float(${cell2_PM_slots_drx_active}),2)
#     ${cell3_scale_sleep_active}    evaluate    round(float(${cell3_PM_slots_drx_sleep})/float(${cell3_PM_slots_drx_active}),2)
#     should be true    2.5<${cell2_scale_sleep_active}<=3.2
#     should be true    2.5<${cell3_scale_sleep_active}<=3.2
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_stop_data' File
# 
# Step8:Detach UE
#     airphone_sa_detach    ${UE_ID}
# 
# Set SSB Beam
#     airphone_execute_egate_command    ${BEAM_SET}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach
# 
# check thp
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     run keyword and continue on failure    should be true    ${Pcell_dl_throughput} > 0
#     run keyword and continue on failure    should be true    ${Scell_dl_throughput} > 0