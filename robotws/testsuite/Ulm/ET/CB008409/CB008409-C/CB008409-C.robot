*** Settings ***
Documentation
...    CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...    Author: I_MN_RAN_RD_VRF_ULM_5 / I_MN_RAN_RD_VRF_ULM_SQD_66_GMS
...    Contact: <I_MN_RAN_RD_VRF_ULM_SQD_66@internal.nsn.com>
...    Contact: <I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com>
...    Description: Test Suite for subfeature CB008409-C Normalization of UE reported high CQI value
...    of CB008409 VoNR DL coverage enhancement




#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Library    taf.config.wts                                                   WITH NAME  wts
Resource   ../../../resources/Common/commissioning.robot
Resource   ../../L2/resources/common_keywords.robot
Resource   ../../L2/resources/robot/test_setup.robot
Resource   ../../L2/resources/robot/tracing.robot
Resource   resources/CB008409-C_scenario_modifications.robot
Resource   resources/CB008409-C_scenario_validations.robot
Resource   resources/syslog_validation.robot


Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces


*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB008409/CB008409-C/CB008409-C.json
${REINIT_GNB}                     true
${scf_to_load}                    scf_CB008409_A_C_and_HR.xml
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}
${SKIP_SCF_CHANGES}                               ${False}

*** Test Cases ***

CB008409_C_ET_TC_03_B12_OnlineModification
    [Tags]   TC03    CRT
    common_keywords.Run Test Scenario
    CB008409-C_scenario_validations.Prepare Variables For Validations   scenario=scenario_TC03
    CB008409-C_scenario_validations.Show Cqi Value Increment Report
    CB008409-C_scenario_validations.Verify CB008409-C Restriction Phases And Incremental CQI Step Size Values
    ...    testcase=TC03    allowedCqiIncrementSpecial=${3}
    CB008409-C_scenario_validations.Verify PM Counter
    tracing.Check For Errors In Syslog


*** Keywords ***
# Below TC's are not any more executed and moved to Keyword section to reduce git pipeline time, bring them back by moving them to Test Cases section
CB008409_C_ET_TC_02_B11_RestrictionUEreportedCQI
    [Tags]   TC02    CIT    ALWAYS_REPORT
    Run Test Scenario
    Prepare Variables For Validations    scenario=scenario_TC02
    Show Cqi value increment report
    Verify CB008409-C restriction phases and incremental CQI step size values
    ...    testcase=TC02
    Verify Errors and Warnings in SYSLOG Trace


CB008409_C_ET_TC_04_B13_IWK_with_HR_LA
    [Tags]   TC04    CRT
    Run Test Scenario
    Prepare Variables for validations    scenario=scenario_TC04
    Show Cqi value increment report
    Verify CB008409-C restriction phases and incremental CQI step size values
    ...    testcase=TC04    allowedCqiIncrementSpecial=${16}
    Verify Errors and Warnings in SYSLOG Trace


OFFLINE
    [Tags]    OFFLINE
    # IMPORTANT: do not forget to comment out the Suite/Test Setup/Teardown KWs on top of this file and uncomment the Keyword name above
    Test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/logs/CB008409-C/2025-06-27T08-38-39-P/CB008409-C/SBTS00_ENB_9999_250626_000010/20250627_083934
    Set Test Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Test Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB008409-C_scenario_validations.Prepare Variables For Validations    scenario=scenario_TC03
    # Uncomment below 2 lines for pcap to pickle conversion, if needed
    #CB008409-C_scenario_validations.Extract TTI Trace And Convert to Pickle
    #...    path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector_name}/ttitrace_streaming.pcap
    CB008409-C_scenario_validations.Show Cqi Value Increment Report
    CB008409-C_scenario_validations.Verify CB008409-C Restriction Phases And Incremental CQI Step Size Values
    ...    testcase=TC03    allowedCqiIncrementSpecial=${3}
    CB008409-C_scenario_validations.Verify PM Counter
    Syslog_validation.Verify Errors And Warnings In SYSLOG Trace

*** Keywords ***
#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Make necessary Changes to SCF
    [Documentation]
    IF   ${SKIP_SCF_CHANGES}   RETURN
    Update Requested RnD flags in SW config file
    Load SCF Values
    commissioning.Execute Full Commissioning    scf_path=${configuration_directory}/SCF_updated.xml    gnb_id=0    skip_relation_errors=${False}
    ...    use_oam_http_connection=${False}    timeout=300


Update Basic Configuration File
    [Documentation]  WTS Basic config Prepration:
    ...    add wts core simulator config for HR-DRB on qos_flow 4, assigned to 5QI=7, as configured in gnbSCF
    wts.Load Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts.Insert    set_qosflow id=4 5qi=7                                                               after    set_qosflow id=3
    wts.Insert    set_qosrule id=3 proto=udp qos_flow=4                                                after    set_qosrule id=2
    wts.Modify    nwslice_set id=1    modification=qos_flows=1,2,3,4 qos_rules=1,2,3
    wts.Save Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}


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
