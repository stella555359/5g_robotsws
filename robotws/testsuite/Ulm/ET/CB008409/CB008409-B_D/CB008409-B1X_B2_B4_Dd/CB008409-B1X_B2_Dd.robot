*** Settings ***

Documentation
...    CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...    Author: Ulm SQD 66 / Ulm VRF VT 6
...    Contact: I_MN_RAN_L2_SW_ULM_SQD_66@internal.nsn.com
...    Description: These testcases are validating the gNB behavior to improve link level performance, by reducing number of DL HARQ retransmissions
...                 and reducing overall DL residual BLER (rBLER) for VoNR and SRB 1/2 transmissions, using higher power per PRB for retransmissions.

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    taf.config.wts    WITH NAME    wts
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Resource   ../../../../resources/Common/gnb.robot
Resource   ../../../L2/resources/robot/test_setup.robot
Resource   ../../../L2/resources/common_keywords.robot
Resource   ../../../L2/resources/robot/tracing.robot
Resource   resources/CB008409-B1X_B2_B4_Dd_scenario_modifications.robot
Resource   ../../CB008409-B_D/resources/CB008409-B_D_scenario_validations.robot


Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces


*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB008409/CB008409-B_D/CB008409-B1X_B2_B4_Dd/CB008409-B1X_B2_Dd.json
${REINIT_GNB}                     true
${scf_to_load}                    CB008409-B1X_B2_Dd.xml
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}
${SKIP_SCF_CHANGES}                               ${False}


*** Test Cases ***

CB008409_B_ET_TC_B12_B13_B16_PowerBoostingForVoNRandSrbRetx_andIwkAdaptiveRetx_andPMC
    [Documentation]  This test case contains below three cases:
    ...    1. CB008409_B_ET_TC_B12_PowerBoostingForVoNR_Retx_SRB_Retx
    ...    2. CB008409_B_ET_TC_B13_PM_countersForReservedPRBs
    ...    3. CB008409_B_ET_TC_B16_IWK_Adaptive_reTX
    [Tags]    B12_B13_B16
    common_keywords.Run Test Scenario
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_xpm_B12_B13_B16
    CB008409-B_D_scenario_validations.Verify maxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
    CB008409-B_D_scenario_validations.Verify PM Counter
    tracing.Check For Errors In Syslog


CB008409_B_ET_TC_B14_OnlineModify
    [Tags]   B14
    common_keywords.Run Test Scenario
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_online_modify
    CB008409-B_D_scenario_validations.Verify Values Changed After Online Modification
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    tracing.Check For Errors In Syslog


CB008409_B_ET_TC_B2_IWK_Adaptive_reTX_RBG_randomization
    [Documentation]  Test Scenario Execution Steps:
    ...    ToDo
    [Tags]    B2
    common_keywords.Run Test Scenario
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_B2
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
    CB008409-B_D_scenario_validations.Verify RBG Randomization
    tracing.Check For Errors In Syslog


CB008409_Dd_ET_TC02_TC03_TDD_FDD_IWK_with_DL_RAT0_and_RAT1_DynSwitch_and_AdaptiveRetx
    [Documentation]  Test Scenario Execution Steps:
    ...    ToDo
    [Tags]    Dd_TC02_TC03
    common_keywords.Run Test Scenario
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_xpm_Dd_TC02_TC03
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
    CB008409-B_D_scenario_validations.Get Dynamic RAT0 RAT1 Pairing Slots
    CB008409-B_D_scenario_validations.Verify RAT0 RAT1 Dynamic Switch
    CB008409-B_D_scenario_validations.Verify PM Counter
    tracing.Check For Errors In Syslog


*** Keywords ***
OFFLINE
    [Tags]    OFFLINE
    # IMPORTANT: do not forget to comment out the *** Keyowrd ***
    # IMPORTANT: do not forget to comment out the Suite/Test Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration from JSON File
    ${result_base_dir}=    set variable    /home/ute/logs/2025-11-05T13-04-14-P/CB008409-B1X_B2_Dd/SBTS00_ENB_9999_251104_000008/20251105_130501
    set test variable  ${configuration_directory}    ${result_base_dir}/Configs
    set test variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_online_modify
    # Comment below 2 lines out for pcap to pickle conversion, if needed
    #Extract TTI Trace and Convert to Pickle    path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector_name}/
    #...    ttitrace_streaming.pcap
    CB008409-B_D_scenario_validations.Verify If Values Changed After Online Modification
    CB008409-B_D_scenario_validations.Verify Values Changed After Online Modification
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    syslog_validation.Verify Errors And Warnings In SYSLOG Trace



*** Keywords ***
#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Make necessary Changes to SCF
    [Documentation]
    IF   ${SKIP_SCF_CHANGES}   RETURN
    Update Requested RnD flags in SW config file
    Delta Json Commission With NIDD Default Value    CB008409-B1X_B2_Dd_NIDD_Configuration.json
    # for full commissioning, with full commissioning we can check, in change of NIDD value change, if there were some migration rules implemented
    #Load SCF Values
    #Execute full commissioning    scf_path=${configuration_directory}/SCF_updated.xml    gnb_id=0      # for full comissioning
    gnb.Get SCF From GNB    gnb_id=${0}   target_dir=${CONFIGURATION_DIRECTORY}    scf_name=scf_${SUITE_NAME}.xml


Update Basic Configuration File
    [Documentation]  WTS Basic config Prepration:
    ...    add wts core simulator config for HR-DRB on qos_flow 4, assigned to 5QI=7, as configured in gnbSCF
    wts.Load Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts.Insert    set_qosflow id=4 5qi=7                                                               after    set_qosflow id=3
    wts.Insert    set_qosrule id=3 proto=udp qos_flow=4                                                after    set_qosrule id=2
    wts.Modify    nwslice_set id=1    modification=qos_flows=1,2,3,4 qos_rules=1,2,3


Update Requested RnD flags in SW config file
    [Documentation]     AP tx power alignement is not calibratred by default, fix calibration in FDD cells
    @{AP_MOD_RD_FLAGS}=  create list  0x70700=6400    # Open Loop Power Control for FDD
    Update SW Config file on AP System Module    param_list=${AP_MOD_RD_FLAGS}
    Set suite variable    ${force_reboot}    ${true}


Load SCF Values
    ${scf_file}=      gnb.Get SCF from gNB
    ${distName_1}=    gnb.Get distNames from local SCF File
    ...   regex=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1   scf_path=${scf_file}
    ${distName_2}=    gnb.Get distNames from local SCF File
    ...   regex=MRBTS-1   scf_path=${scf_file}
    scf.load_scf    ${scf_file}
    ${vlan_id}=    scf.get_value_from_scf    dist_name=${distName_1[0]}    p_name=vlanId
    ${bts_name}=    scf.get_value_from_scf    dist_name=${distName_2[0]}    p_name=btsName
    scf.load_scf    ${CURDIR}/resources/${scf_to_load}
    Set Element    dist_name=${distName_1[0]}    p_name=vlanId    value=${vlan_id}
    Set Element    dist_name=${distName_2[0]}    p_name=btsName    value=${bts_name}
    scf.save_scf    ${configuration_directory}/SCF_updated.xml


Delta Json Commission With NIDD Default Value
    [Arguments]    ${delta_file_name}    ${gnb_id}=${0}    ${port}=3600    ${alias}=cOAM
    coam.connect_to
    ...    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    bts_port=${port}    name=${alias}
    coam.Perform_Delta_Recommissioning
    ...    delta_file=${CURDIR}/resources/${delta_file_name}
    ...    skip_parameter_relation_errors=false
    ...    should_activate=true
    ...    timeout=180
    ...    connection=${alias}
    coam.teardown    connection=${alias}

