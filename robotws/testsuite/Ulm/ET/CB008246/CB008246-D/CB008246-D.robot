*** Settings ***
Documentation
...    CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...    Author: Ulm SQD 66
...    Contact: I_MN_RAN_L2_SW_ULM_SQD_66@internal.nsn.com
...    Description: CB008246-D is validates the the functionality of non-GBR DRB switch
...    between high reliability (HR) LA and basic reliability (BR) LA in DL due to change in radio conditions


#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.config.wts             WITH NAME    wts
Resource   ../../../resources/Common/gnb.robot
Resource   ../../L2/resources/common_keywords.robot
Resource   ../libraries/syslog_validation.robot
Resource   ../../L2/resources/robot/tracing.robot
Resource   resources/CB008246-D_scenario_modifications.robot
Resource   resources/CB008246-D_scenario_validations.robot



Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces



*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB008246/CB008246-D/CB008246-D.json
${REINIT_GNB}                     true
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***
CB008246_D_TC07_TC08_DL_DRB_Switch_ALL_New_Related_PM_Counters_TDD_FDD
    [Documentation]  This case aims to check all PM Counters
    ...     Test Scenario Execution Steps:
    ...     0.Set proper Outage/Recover NIDD params and static PDCCH in SCF
    ...     1.SA UE1 register in TDD/FDD Cell1, PDU session setup with default 5qi=6, 5qi6 is HR-DRB
    ...     2.DL traffic start and keep traffic with enough time
    ...     3.Configure and Activate csi_override_testmode_nr
    ...     4.During the traffic and after half of traffic_duration, set and active target_mcs via advanced bler_testmode
    ...     5.Deactive bler testmode after amount of time
    ...     6.Stop all the traffic and all testmodes, deregister all the UEs and colloct the logs
    [Tags]   TC07_TC08
    common_keywords.Run Test Scenario
    CB008246-D_scenario_validations.Prepare Variables For Validations    scenario=xpmc_scenario_static_TC07_TC08_pmcounter_TDD_FDD
    CB008246-D_scenario_validations.Get Statistical Analysis Of TTI Trace Events
    CB008246-D_scenario_validations.Verify Switch To BR Then HR
    CB008246-D_scenario_validations.Verify CB008246 DL PM Counters
    CB008246-D_scenario_validations.Generate Verdict For CB008246_R3_PMC
    CB008246-D_scenario_validations.Get RLC ReTx PMC Values
    tracing.Check For Errors In Syslog


*** Keywords ***
OFFLINE
    [Tags]    OFFLINE
    # IMPORTANT: do not forget to comment out the Suite/Test Setup/Teardown KWs on top of this file and Keywords!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/logs/CB008246-D/2025-07-21T11-00-21-F/CB008246-D/SBTS00_ENB_9999_250720_000001/20250721_110106/
    Set Test Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Test Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB008246-D_scenario_validations.Prepare Variables For Validations    scenario=xpmc_scenario_static_TC07_TC08_pmcounter_TDD_FDD
    CB008246-D_scenario_validations.Get Statistical Analysis Of TTI Trace Events
    CB008246-D_scenario_validations.Verify Switch To BR Then HR
    CB008246-D_scenario_validations.Verify CB008246 DL PM Counters
    CB008246-D_scenario_validations.Generate Verdict For CB008246_R3_PMC
    CB008246-D_scenario_validations.Get RLC ReTx PMC Values
    syslog_validation.Verify Errors And Warnings In SYSLOG Trace


*** Keywords ***
# Below testsuites are not anymore executed, but can be bring back, when shifting it do the Testcase section, added in Keyword section to decrease
# Pipeline time

CB008246_D_TC01_DL_DRB_Switch_between_HRLA_And_BRLA_with_Static_PDCCH_TDD
    [Documentation]  Test Scenario Execution Steps:
    ...     0.set proper Outage/Recover NIDD params and static PDCCH in SCF
    ...     1.SA UE1 register in Cell1, PDU session setup with default 5qi=6, 5qi6 is HR-DRB
    ...     2.DL traffic start and keep traffic with enough time
    ...     3.Configure and Activate csi_override_testmode_nr
    ...     4.During the traffic and after half of traffic_duration, set and active target_mcs via advanced bler_testmode
    ...     5.Deactive bler testmode after amount of time
    ...     6.Stop all the traffic and all testmodes, deregister all the UEs and colloct the logs
    [Tags]   TC01
    Run Test Scenario
    Prepare Variables for Validations    scenario=scenario_static_TC01_pdcch_TDD
    Get Statistical Analysis of TTI Trace Events
    Verify Switch to BR then HR
    Check Static PDCCH Aggregation Level for BR and HR

CB008246_D_TC02_DL_DRB_Switch_between_HRLA_And_BRLA_with_Static_PDCCH_FDD
    [Documentation]  Same as TC01 but for FDD
    [Tags]   TC02
    Run Test Scenario
    Prepare Variables for Validations    scenario=scenario_static_TC02_pdcch_FDD
    Get Statistical Analysis of TTI Trace Events
    Verify Switch to BR then HR
    Check Static PDCCH Aggregation Level for BR and HR

CB008246_D_TC04_DL_DRB_Switch_between_HRLA_And_BRLA_with_Dynamic_PDCCH_TDD
    [Documentation]  Same as TC01 but interworking with dynamic PDCCH
    [Tags]   TC04
    Run Test Scenario
    Prepare Variables for Validations    scenario=scenario_dynamic_TC04_pdcch_TDD
    Get Statistical Analysis of TTI Trace Events
    Verify Switch to BR then HR
    Check Dynamic PDCCH Aggregation Level for BR and HR

CB008246_D_TC05_DL_DRB_Switch_between_HRLA_And_BRLA_with_Dynamic_PDCCH_FDD
    [Documentation]  Same as TC04 but for FDD
    [Tags]   TC05
    Run Test Scenario
    Prepare Variables for Validations    scenario=scenario_dynamic_TC05_pdcch_FDD
    Get Statistical Analysis of TTI Trace Events
    Verify Switch to BR then HR
    Check Dynamic PDCCH Aggregation Level for BR and HR

CB008246_D_TC07_DL_DRB_Switch_ALL_New_Related_PM_Counters_TDD
    [Documentation]  This case aims to check all PM counters, sametest step as TC01 but with 2 UEs
    [Tags]   TC07    ALWAYS_REPORT
    Run Test Scenario
    Prepare Variables for Validations    scenario=scenario_static_TC07_pmcounter_TDD
    Get Statistical Analysis of TTI Trace Events
    Verify Switch to BR then HR
    Verify CB008246 DL PM Counters    numTx=4
    Generate verdict for CB008246_R3_PMC
    Get RLC ReTx PMC Values
    Verify Errors and Warnings in SYSLOG Trace

CB008246_D_TC08_DL_DRB_Switch_ALL_New_Related_PM_Counters_FDD
    [Documentation]  Same as TC07 but for FDD
    [Tags]   TC08
    Run Test Scenario
    Prepare Variables for Validations    scenario=xpmc_scenario_static_TC08_pmcounter_FDD
    Get Statistical Analysis of TTI Trace Events
    Verify Switch to BR then HR
    Verify CB008246 DL PM Counters    numTx=2
    Generate verdict for CB008246_R3_PMC
    Get RLC ReTx PMC Values
    Verify Errors and Warnings in SYSLOG Trace

CB008246_D_TC09_DL_DRB_Switch_between_HRLA_And_BRLA_with_Low_traffic_case
    [Documentation]  Same as TC04 but with low traffic (TDD)
    [Tags]   TC09
    Run Test Scenario
    Prepare Variables for Validations    scenario=scenario_dynamic_TC09_low_traffic_TDD
    Get Statistical Analysis of TTI Trace Events
    Verify Switch to BR then HR
    Check Dynamic PDCCH Aggregation Level for BR and HR


#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]
Make necessary Changes to SCF
    [Documentation]  Suite NIDD Prepration:
    ...    Peroform Delta Json Commission all -A necessary SCF parameters with NIDD default values, which including:
    ...    1. Feature flag: actLAForHiReliab=true under NRCELL1 and NRCELL2
    ...    2. Link Adaptation High Reliability DRB Profiles that associate with UEs configured 5qi vale: NRPDSCHHRLA under NRDRB-XX
    ...    3. PDSCH profile for Link Adaptation High Reliability parameters are configured for both NRCELL1 and NRCELL2
    ...    3. NRBTS/BWP_PROFILE/PDCCH: dciDedicatedAggregationLevelHR
    ...    4. 256QAM is disabled: NRBTS/NRCELL.actDl256Qam and NRBTS/NRCELL.actUl256Qam set as False
    ...    5. MU-MIMO disabled: NRBTS/NRCELL.actDlMuMimo set to False
    ...    6. Adaptive retransmission (CB008662) is disabled: NRBTS/NRCELL.actAdaptiveReTxResMcs set to False
    ...    7. CA is disabled: NRBTS/NRDU/carrierAggregationSupportList set to 'none'
    ...    8. PM counter related parameters
    ...    9. Requested SW RnD flags

    Update Requested RnD flags in SW config file
    Delta Json Commission With NIDD Default Value    CB008246-D_NIDD_Configuration.json
    gnb.Get SCF From GNB    gnb_id=${0}   target_dir=${CONFIGURATION_DIRECTORY}    scf_name=scf_${SUITE_NAME}.xml


Delta Json Commission With NIDD Default Value
    [Arguments]    ${delta_file_name}    ${gnb_id}=${0}    ${port}=3600    ${alias}=cOAM
    coam.Connect To
    ...    bts_host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    bts_port=${port}    name=${alias}
    coam.Perform Delta Recommissioning    delta_file=${CURDIR}/resources/${delta_file_name}
    ...    skip_parameter_relation_errors=false
    ...    connection=${alias}
    coam.Teardown    connection=${alias}


Update Requested RnD Flags In SW Config File
    [Documentation]    rdEnableAndDisableSubFeatures8246 0x5806F2
    ...    bitMask to Activate/Deactivate CB008246 subFeatures
    ...    LSB bit1: activates(1)/deactivate(0) CB008246-H
	...        bit2: consider(1)/ignore(0) PUSCH criteria in UL-PDCCH switch algo to recover from BR to HR
	...        bit3: consider(1)/ignore(0) PDSCH criteria in DL-PDCCH switch algo to recover from BR to HR
	...        bit4: activates(1)/deactivate(0) CB008246-G
	...        bit5: activates(1)/deactivate(0) CB008246-I (not yet implemented)
    ...    2023/07/25 Current recommended value to test A/B/C/D/E : 0
    ...    References:
    ...    https://nokia-my.sharepoint.com/personal/amol_thorat_nokia_com/_layouts/15/Doc.aspx?sourcedoc={856ca087-97a2-4c12-96fa-8a83c81c487b}
    ...    &action=edit&wd=target%28FIAT-PR%20MoM.one%7Ce56ef993-16c7-4144-b3c0-7a5672328f6a%2F%29&wdorigin=717
    @{A_rd_params}=  Create List
    ...    0x5806F2=0x18  # rdEnableAndDisableSubFeatures8246
    ...    0x5801CB=0     # rdFakeUeSchedulingEnable; disables fakeUe scheduling, to avoid syslog ERR print
    gnb.Update SW Config File On System Module  param_list=${A_rd_params}
    Set Suite Variable    ${force_reboot}    ${true}


Update Basic Configuration File
    [Documentation]  WTS Basic config Prepration:
    ...    UE is capable of High Reliability for PDSCH: UE-NR-Capability-> phy-Parameters-> phy-ParametersFRX-Diff-> dl-64QAM-MCS-TableAlt
    ...    Default UE_cap already support 4x4 MIMO(UE-NR-Capability->featureSets-->featureSetsDownlinkPerCC-->maxNumberMIMO-LayersPDSCH-->fourLayers)
    ...    if it's PM counter case, it requests config two HRLA PDSCH profiles that also ask different UE config different default 5qi value
    ...    In this case, UE1 default 5qi is 6, UE2 default 5qi is 9. UE1 and UE2 in cell1
    wts.Load Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts.Modify    command=set_qosflow id=1    modification=5qi=6 ue=1,3 default=on
    wts.Clone and Modify    command=set_qosflow id=1    modification=id=4 5qi=9 ue=2,4 default=on
    wts.Modify    command=nwslice_set id=1    modification=qos_flows=1,2,3,4
    wts.Save Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
