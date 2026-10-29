# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...               QC case full name:
# ...               CB007922_Case160_D_A_11_interL2RT_intraBand_Single_UE_DL_UL_data_NSA_with_Beamrefinement_ssb8_degraded_upgrade
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CIT    SBTS00    SBTS23R1     owner_lilyu
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# Library           OperatingSystem
# Library           String
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${JSON_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          11
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${BEAR_ID}        2
# ${pmi_cmd}        csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=500
#                   ...    cri_mode=fixed cri=1 li_mode=fixed li=1
# ${SCFC_NAME}        gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}         wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg                  
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
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# 
# 
# 
# *** Test Cases ***
# CB007922_Case160_D_A_11_interL2RT_intraBand_Single_UE_DL_UL_data_NSA_with_Beamrefinement_ssb8_degraded_upgrade
#     Step1:Commission the above configuration on WebUI
#     Step2: open beaforming and ue attach
#     Step3:UE send A1 to add scell
#     Step4:push DL_UL_data to active scell
#     Step5: UE send A2 to release scell
#     Step6:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     #modify cfg file
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_periodiccsiacquisition_list_in_cells    ${scfc_path}
#     add_csirsBeamMgmt_list_in_cells    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}    ${cellDepType}
#     ...    ${actCDrx}    ${chBw}    ${nrBtsBeamRefinementP2}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${dlMimoMode}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${actPdschAtSsbSlots}
#     ...    ${maxCsirsNumber}    ${actMeasBasedSCellAddition}    ${maxNumScellsDl}     ${actFdmEnhancedScheduling}     ${sCellActivationLevel}
#     ...    ${sCellAdditionMethod}    ${sCellActivationMethod}    ${sCellActivationMinDataThreshold}    ${sCellDeactivationTimerGNB}
#     ...    ${numberOfRxBeamforming}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# 
# Step2: open beaforming and ue attach
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #open beaforming
# 	airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1 csirs_bestbeam\=0 csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# 	airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=2 ueBeamIndexInitial\=1,0 csirs_bestbeam\=5 csirs_rsrp_best\=-45 csirs_rsrp_avg\=-120
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${UE_ID} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=8
# 	airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${UE_ID} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=9
# 	${ue_ability}    Obtain Ue Capability    TDD_NSA_CA_NoRefinebeam
#     airphone_execute_egate_command    ue_attach id\=11 ue_nr_capabilities\=${ue_ability}
# 	Wait Throughput Timer    3
# 	airphone_execute_egate_command    ue_dc_enb_start ue\=11 target_gnb\=2 target_cells\=2 bearer\=2 type\=split_scg
# 	airphone_execute_egate_command    ${pmi_cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1
#     Wait Throughput Timer    10
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step2_ue_attach   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/CSI_RS_ATTACH_NSA.ini    log_need_to_check=u
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# 
# Step3:UE send A1 to add scell
#     Start Collect GNB and AP Syslog in 'step3_add_scell' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
# 	airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step3_add_scell   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/CSI_RS_A1_NSA.ini    log_need_to_check=u
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step3_add_scell
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_push_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_push_data${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_add_scell' File
# 
# Step4:push DL_UL_data to active scell
#     Start Collect GNB and AP Syslog in 'step4_active_scell' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    duration=${3600}
# 	Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    duration=${3600}
# 	Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=7    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=8    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    UL    25M    trf_id=1   duration=${3600}
#     Wait Until Keyword Succeeds    180s    3s    check thp
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_active_scell
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_active_scell/output
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step4_active_scell   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/RRC_scell_active_nsa.ini     log_need_to_check=u
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step4_active_scell
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_push_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_push_data${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_active_scell' File
# 
# Step5: UE send A2 to release scell
#     Start Collect GNB and AP Syslog in 'step5_release_scell' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr
#     airphone_execute_egate_command
#     ...    ue_measurement_send_nr event\=A2 id\=${UE_ID} meas_id\=2 rs_type\=ssb scell\=9 scell_rsrp\=30    pass_regexp=sCellToReleaseList
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step5_release_scell   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/CSI_RS_A2_NSA.ini    log_need_to_check=u
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step5_release_scell
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_change_beamid${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_change_beamid${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_release_scell' File
# 
# 
# Step6:Detach UE
#     Start Collect GNB and AP Syslog in 'step6_Detach_UE' File
#     Airphone NSA Stop Data Traffic   ${UE_ID}    DL
#     Airphone NSA Stop Data Traffic   ${UE_ID}    UL
#     Airphone NSA Detach    ${UE_ID}
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
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
