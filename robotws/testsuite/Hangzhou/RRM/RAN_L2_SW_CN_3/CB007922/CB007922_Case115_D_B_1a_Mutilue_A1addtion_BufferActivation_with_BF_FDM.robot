*** Settings ***
Documentation     example case for RAN HZ L2 SW11. test step description in QC as below:
...
...               QC case full name:
...               CB007922_Case115_D_B_1a_Mutilue_A1addtion_BufferActivation_with_BF_FDM
...
...               Multiple UE connection setup and DL/UL data scheduling in SA option 2
...               (BF activated, FDM activated, A1 MR based SCell addition and buffer-based SCell activation)
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS00    ownerbylilyu    SBTS23R1
Test Timeout      90 minutes
Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
${UE_NUM}         5
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
#${carrierAggregationSupportList}    text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
${actInterNumerologyCa}    text|false|//*[@name\="actInterNumerologyCa"]
${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
${actBeamforming}    text|true|//*[@name\="actBeamforming"]
${nrBtsBeamRefinementP2}    text|false|//*[@name\="nrBtsBeamRefinementP2"]
${nrCellType}     text|4DL2UL|//*[@name\="nrCellType"]
${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
${sCellActivationMethod}    text|bufferBased|//*[@name\="sCellActivationMethod"]
${a1MeasSCellAddEnabled}    text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
${a1ThresholdSCellAddSsbRsrpTDD}    text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]

*** Test Cases ***
CB007922_Case115_D_B_1a_Mutilue_A1addtion_BufferActivation_with_BF_FDM_bak
    Step1:Commission the above configuration on WebUI
    step2:change MutilUE to cell2 ,open beaforming and attach to cell2
    Step3:Start enough_DLUL_data and send A1
    Step4:Detach UE

CB007922_Case115_D_B_1a_Mutilue_A1addtion_BufferActivation_with_BF_FDM
    Step1:Commission the above configuration on WebUI
    step2:change MutilUE to cell2 ,open beaforming and attach to cell2
    Step3:Start enough_DLUL_data and send A1
    Step4:Detach UE

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    add_ca_relation_CB7922    ${scfc_path}
    ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}
    ...    ${nrBtsBeamRefinementP2}    ${cellDepType}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}
    ...    ${prachConfigurationIndex}    ${ssBurstSetPeriod}    ${sCellAdditionMethod}    ${maxNumScellsDl}    ${actFdmScheduling}
    ...    ${sCellActivationMethod}    ${a1MeasSCellAddEnabled}    ${a1ThresholdSCellAddSsbRsrpTDD}    ${nrCellType}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
    Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File

Step2:change MutilUE to cell2 ,open beaforming and attach to cell2
    Start Collect GNB and AP Syslog in 'step2_ue_attach' File
    #Start GNB BIP Log
    #Start AP BIP Log
    #change cell to cell2
    FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
    Airphone Location Change    id=${UE_ID}    cell_id=2
    END
    #open beaforming
    airphone_execute_egate_command
    ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5,6,7 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-70
    airphone_execute_egate_command
    ...    beam_control_testmode_nr profile_id\=2 ueBeamIndexInitial\=1,0,2,3,4,5,6,7 ssbeam_bestbeam\=1 ssbeam_rsrp_best\=-45 ssbeam_rsrp_avg\=-80
    airphone_execute_egate_command
    ...    beam_control_testmode_nr profile_id\=3 ueBeamIndexInitial\=2,0,1,3,4,5,6,7 ssbeam_bestbeam\=2 ssbeam_rsrp_best\=-50 ssbeam_rsrp_avg\=-90
    airphone_execute_egate_command
    ...    beam_control_testmode_nr profile_id\=4 ueBeamIndexInitial\=3,0,1,2,4,5,6,7 ssbeam_bestbeam\=3 ssbeam_rsrp_best\=-55 ssbeam_rsrp_avg\=-89
    airphone_execute_egate_command
    ...    beam_control_testmode_nr profile_id\=5 ueBeamIndexInitial\=4,0,1,2,3,5,6,7 ssbeam_bestbeam\=4 ssbeam_rsrp_best\=-60 ssbeam_rsrp_avg\=-99
    airphone_execute_egate_command
    ...    beam_control_testmode_nr profile_id\=6 ueBeamIndexInitial\=5,0,1,2,3,4,6,7 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-65 ssbeam_rsrp_avg\=-98
    FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
    ${profile_id}    Evaluate    random.randint(1,6)    random
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ID} testmode\=beam_control action\=activate profile_id\=${profile_id} beamaction\=attach scell\=0,1
    END
    FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
    Airphone Sa Attach    ue_id=${UE_ID}
    END
    FOR    ${ID}   IN RANGE    1    ${UE_NUM}+1
    ${UE_ID}    SetVariable    ${ID}
    ${GW_ID}    SetVariable    ${ID}
    airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
    END
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
    #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File

Step3:send A1 report
    Start Collect GNB and AP Syslog in 'step3_send_A1_report' File
    #Start GNB BIP Log
    #Start AP BIP Log
    FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
    airphone_execute_egate_command    ue_meas_cfg_disp id\=${ID} meas_obj_type\=nr
    airphone_execute_egate_command    ue_measurement_send_nr id\=${ID} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
    END
    #Stop GNB BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1_report${/}
    #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1_report${/}
    [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_A1_report' File

Step3:Start enough_DLUL_data and send A1
    Start Collect GNB and AP Syslog in 'step3_Start_enough_DLUL_data' File
    #Start GNB BIP Log
    #Start AP BIP Log
    #Start GNB Ttitrace With Streaming Mode
    FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
    Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
	airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr
    airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
    END
    #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_Start_enough_DLUL_data${/}
    #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_Start_enough_DLUL_data${/}
    #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_Start_enough_DLUL_data
    Comment    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_Start_enough_DLUL_data/output
    #Wait Throughput Timer    20
    #FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
    #${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    #${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
	#END
	Wait Throughput Timer    300
    FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
    ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
    should be true    ${Pcell_dl_throughput} > 0
    should be true    ${Scell_dl_throughput} > 0
    END
    [Teardown]    Stop Collect GNB and AP Syslog in 'step3_Start_enough_DLUL_data' File

Step4:Detach UE
    Start Collect GNB and AP Syslog in 'Step4_Detach_UE' File
    FOR    ${UE_ID}    IN RANGE    1    ${UE_NUM}+1
    airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
    airphone_sa_detach    ${UE_ID}
    END
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_Detach_UE' File

add_ca_relation_CB7922
    [Arguments]    ${scfc_path}
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
    add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1

