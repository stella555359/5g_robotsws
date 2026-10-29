# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...               QC case full name:
# ...               CB007922_Case116_D_B_2_mutileUE_A1addition_BufferActivation_BF_Refine_FDM_withBler
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS00    SBTS22R4    ownerbylilyu    SBTS23R1
# Test Timeout      90 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${JSON_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          1
# ${UE_NUM}         5
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${BEAR_ID}        2
# ${pmi_cmd}        csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=500
#                   ...    cri_mode=fixed cri=1 li_mode=fixed li=1
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${mo}    com.nokia.srbts.nrbts:NRCELL
# ${actInterNumerologyCa}    text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|ms1280|//*[@name\="sCellDeactivationTimerGNB"]
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${sCellActivationMinDataThreshold}    text|6000|//*[@name\="sCellActivationMinDataThreshold"]
# ${sCellActivationLevel}    text|1TTI|//*[@name\="sCellActivationLevel"]
# ${chBw}           text|80MHz|//*[@name\="chBw"]
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrBtsBeamRefinementP2}    text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}    text|2|//*[@name\="maxCsirsNumber"]
# ${actMeasBasedSCellAddition}    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${a1MeasSCellAddEnabled}    text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmEnhancedScheduling}    text|true|//*[@name\="actFdmEnhancedScheduling"]
# 
# 
# 
# *** Test Cases ***
# CB007922_Case116_D_B_2_mutileUE_A1addition_BufferActivation_BF_Refine_FDM_withBler_bak
#     Step1:Commission the above configuration on WebUI
#     Step2: open beaforming and attach
#     Step3:push DL_UL_data and send A1
#     Step4: change SSBeamId
#     Step5:increase path loss
#     Step6:Detach UE
# 
# CB007922_Case116_D_B_2_mutileUE_A1addition_BufferActivation_BF_Refine_FDM_withBler
#     Step1:Commission the above configuration on WebUI
#     Step2: open beaforming and attach
#     Step3:push DL_UL_data and send A1
#     Step4: change SSBeamId
#     Step5:increase path loss
#     Step6:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_periodiccsiacquisition_list_in_cells    ${scfc_path}
# 	add_csirsBeamMgmt_list_in_cells    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}    ${cellDepType}
#     ...    ${actCDrx}    ${chBw}    ${nrBtsBeamRefinementP2}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${dlMimoMode}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${actPdschAtSsbSlots}
#     ...    ${maxCsirsNumber}    ${actMeasBasedSCellAddition}    ${maxNumScellsDl}     ${actFdmEnhancedScheduling}     ${sCellActivationLevel}
#     ...    ${sCellAdditionMethod}    ${sCellActivationMethod}    ${sCellActivationMinDataThreshold}    ${sCellDeactivationTimerGNB}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2: open beaforming and attach
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #open beaforming
# 	airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1 csirs_bestbeam\=0 csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# 	airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=2 ueBeamIndexInitial\=1,0 csirs_bestbeam\=5 csirs_rsrp_best\=-45 csirs_rsrp_avg\=-120
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ID} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=0,1
#     END
#     FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
#     Airphone Location Change    id=${UE_ID}    cell_id=2
#     Airphone Sa Attach    ue_id=${UE_ID}
#     END
#     FOR    ${ID}   IN RANGE    1    ${UE_NUM}+1
#     ${UE_ID}    SetVariable    ${ID}
#     ${GW_ID}    SetVariable    ${ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     airphone_execute_egate_command    ${pmi_cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1
#     END
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# 
# Step3:push DL_UL_data and send A1
#     Start Collect GNB and AP Syslog in 'step3_push_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    pdu_id=${PDU_ID}    duration=${3600}
# 	#Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=7    pdu_id=${PDU_ID}    duration=${3600}
# 	#Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=8    pdu_id=${PDU_ID}    duration=${3600}
# 	airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     END
# 	Wait Throughput Timer    30
# 	airphone_execute_egate_command    ${pmi_cmd}
#     Wait Until Keyword Succeeds    90s    3s    check thp
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_push_data
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_push_data/output
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl_refineBeam0.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}step3_push_data
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_push_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_push_data${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_push_data' File
# 
# 
# Step4: change SSBeamId
#     Start Collect GNB and AP Syslog in 'step4_change_beamid' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #change SSBeamId
#     FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ID} testmode\=beam_control action\=activate profile_id\=2 beamaction\=switch scell\=0,1
#     END
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_change_beamid
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_change_beamid/output
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl_refineBeam5.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}step4_change_beamid
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_change_beamid${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_change_beamid${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_change_beamid' File
# 
# Step5:increase path loss
#     Start Collect GNB and AP Syslog in 'Step5_pat_loss' File
# 	#airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=1 pmi\=0 ri\=1 pmi_mode\=fixed ri_mode\=fixed
# 	#airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
# 	FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
# 	Airphone Bler Testmode Nr    profile_id=1    dl_bler=200,600,700,800,200,300,400,500
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=1 testmode\=bler profile_id\=1 action\=activate
# 	END
# 	Wait Throughput Timer    3
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Step5_pat_loss
#     #${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     #${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
# 	#should be true    ${Pcell_dl_throughput} > 0
#     #should be true    ${Scell_dl_throughput} == 0
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Step5_pat_loss/output
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_nack.ini    log_need_to_check=i
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}Step5_pat_loss
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step5_pat_loss' File
# 
# Step6:Detach UE
#     Start Collect GNB and AP Syslog in 'step6_Detach_UE' File
#     FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     END
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_Detach_UE' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
#     #L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band CA Cell1&Cell2 Intra L2RT inter band CA Cell3&Cell4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# check thp
#     FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     END
