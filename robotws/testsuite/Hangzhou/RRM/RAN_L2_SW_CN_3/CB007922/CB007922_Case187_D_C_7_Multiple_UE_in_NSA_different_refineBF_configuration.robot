# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...               QC case full name:
# ...               CB007922_Case187_D_C_7_Multiple_UE_in_NSA_different_refineBF_configuration
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS00    SBTS22R4     ownerbylilyu    SBTS23R1
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
# ${prachConfigurationIndex}    text|150|//*[@name\="prachConfigurationIndex"]
# ${sCellAdditionMethod}    text|blind|//*[@name\="sCellAdditionMethod"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|bufferBased|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|ms1280|//*[@name\="sCellDeactivationTimerGNB"]
# ${actPdschAtSsbSlots}    text|false|//*[@name\="actPdschAtSsbSlots"]
# ${sCellActivationMinDataThreshold}    text|6000|//*[@name\="sCellActivationMinDataThreshold"]
# ${sCellActivationLevel}    text|1TTI|//*[@name\="sCellActivationLevel"]
# ${chBw1}    text|100MHz|//*[contains(@distName, 'NRCELL-1')]/*[@name='chBw']
# ${chBw2}    text|80MHz|//*[contains(@distName, 'NRCELL-2')]/*[@name='chBw']
# ${chBw3}    text|80MHz|//*[contains(@distName, 'NRCELL-3')]/*[@name='chBw']
# ${chBw4}    text|80MHz|//*[contains(@distName, 'NRCELL-4')]/*[@name='chBw']
# ${numberOfTransmittedSsBlocks}    text|6 beams|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}    text|beamSet_6|//*[@name\="basicBeamSet"]
# ${pucchF3ModulationScheme}    text|qpsk_4psk|//*[@name\="pucchF3ModulationScheme"]
# ${actPerCsiReportBundlingTddFr1}    text|true|//*[@name\="actPerCsiReportBundlingTddFr1"]
# ${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${pucchF3MaxCodeRate}    text|zeroDot15|//*[@name\="pucchF3MaxCodeRate"]
# ${srPeriodicity}    text|slots160|//*[@name\="srPeriodicity"]
# ${csiReportPeriodicity}    text|slots320|//*[@name\="csiReportPeriodicity"]
# ${nrBtsBeamRefinementP2}    text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}    text|2|//*[@name\="maxCsirsNumber"]
# ${numberOfRxBeamforming}    text|4Rx|//*[@name\="numberOfRxBeamforming"]
# ${sCellDeactivationBadRlqCount}    text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# 
# 
# *** Test Cases ***
# CB007922_Case187_D_C_7_Multiple_UE_in_NSA_different_refineBF_configuration_bak
#     Step1:Commission the above configuration on WebUI
#     Step2: open beaforming and attach to cell2
#     Step3:push DL_UL_data
#     Step4: change SSBeamId
#     Step5:Detach UE
# 
# CB007922_Case187_D_C_7_Multiple_UE_in_NSA_different_refineBF_configuration
#     Step1:Commission the above configuration on WebUI
#     Step2: open beaforming and attach to cell2
#     Step3:push DL_UL_data
#     Step4: change SSBeamId
#     Step5:Detach UE
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
#     ...    ${actCDrx}    ${srPeriodicity}    ${csiReportPeriodicity}    ${chBw1}    ${chBw2}     ${actFdmScheduling}
#     ...    ${nrBtsBeamRefinementP2}    ${basicBeamSet}    ${numberOfTransmittedSsBlocks}    ${dlMimoMode}    ${chBw3}    ${chBw4}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${actPdschAtSsbSlots}
#     ...    ${maxCsirsNumber}    ${pucchF3ModulationScheme}    ${actPerCsiReportBundlingTddFr1}     ${pucchF3MaxCodeRate}     ${sCellActivationLevel}
#     ...    ${sCellAdditionMethod}    ${sCellActivationMethod}    ${sCellActivationMinDataThreshold}    ${sCellDeactivationTimerGNB}
# 	...    ${numberOfRxBeamforming}    ${sCellDeactivationBadRlqCount}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2: open beaforming and attach to cell2
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #open beaforming
# 	airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1 csirs_bestbeam\=0 csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# 	airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=2 ueBeamIndexInitial\=1,0 csirs_bestbeam\=5 csirs_rsrp_best\=-45 csirs_rsrp_avg\=-120
#     FOR    ${ID}    IN RANGE    11    ${UE_NUM}+11
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ID} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=8,9
# 	#airphone_execute_egate_command
#     #...    ue_testmode_set_nr id\=${ID} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=9
#     END
#     FOR    ${UE_ID}    IN RANGE    11    ${UE_NUM}+11
#     Airphone Nsa Attach    ue_id=${UE_ID}    cell_id=2
#     airphone_execute_egate_command    ${pmi_cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1
#     END
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# 
# Step3:push DL_UL_data
#     Start Collect GNB and AP Syslog in 'step3_push_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     FOR    ${UE_ID}    IN RANGE    11    ${UE_NUM}+11
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    duration=${3600}
# 	Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    duration=${3600}
#     Airphone NSA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    duration=${3600}
#     Airphone Nsa Start Data Traffic    ${UE_ID}    UL    25M    trf_id=1   duration=${3600}
#     END
# 	Wait Throughput Timer    30
#     airphone_execute_egate_command    ${pmi_cmd}
# 	Wait Until Keyword Succeeds    90s    3s    check thp
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_push_data
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_push_data/output
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl_refineBeam0.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}step3_push_data
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
#     FOR    ${ID}    IN RANGE    11    ${UE_NUM}+11
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ID} testmode\=beam_control action\=activate profile_id\=2 beamaction\=switch scell\=8
# 	airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ID} testmode\=beam_control action\=activate profile_id\=2 beamaction\=switch scell\=9
#     END
# 	Wait Throughput Timer    3
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_change_beamid
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_change_beamid/output
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/tti_dl_refineBeam5.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}step4_change_beamid
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_change_beamid${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_change_beamid${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_change_beamid' File
# 
# 
# Step5:Detach UE
#     Start Collect GNB and AP Syslog in 'step5_Detach_UE' File
#     FOR    ${UE_ID}    IN RANGE    11    ${UE_NUM}+11
#     Airphone NSA Stop Data Traffic   ${UE_ID}    DL
#     Airphone NSA Stop Data Traffic   ${UE_ID}    UL
#     Airphone NSA Detach    ${UE_ID}
#     END
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_Detach_UE' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
#     #L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band CA Cell1&Cell2 Intra L2RT inter band CA Cell3&Cell4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
# 
# 
# check thp
#     FOR    ${UE_ID}    IN RANGE    11    ${UE_NUM}+11
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=9    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 0
#     should be true    ${Scell_dl_throughput} > 0
#     END
