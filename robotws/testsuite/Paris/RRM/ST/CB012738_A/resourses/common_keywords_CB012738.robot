*** Settings ***
Documentation    Test suite for RMOD cells bandwidth configuration with specific test plans
Library         Collections
Library         String
Library         OperatingSystem
Library         taf.rfrl.bts.devices.du.commissioning.GnbCommissioning          WITH NAME   gnb_scf
Library         ../../resources/vrf_nps_2/python/hytem_handler.py               WITH NAME  hytem_handler
Library         ../../resources/vrf_nps_2/python/syslog_analysis.py             WITH NAME  syslog_analysis

*** Keywords ***
Initialize Attenuator
    [Documentation]
    ...    Initialize the attenuator for test
    ...    - Set the attenuator to 38 dB on chanels 1 and 2
    ...    - Set the attenuator to 93.5 dB on others channel
    ${channels_group_1}=    Create List    0    1
    ${channels_group_1_attenuation}=    Create List    380    360
    ${channels_group_2}=    Create List    2    3    4    5    6   7
    ${channels_group_2_attenuation}=    Create List    935    935    935    935    935    935
    hytem_handler.set_channels_attenuation    ${channels_group_1}    ${channels_group_1_attenuation}    attenuator_id=0    verify=${true}
    hytem_handler.set_channels_attenuation    ${channels_group_2}    ${channels_group_2_attenuation}    attenuator_id=0    verify=${true}


CB012738 Test Suite Setup
    [Documentation]   Prepare TL for CB012738 test
    ...    - Turn all DUs, RUs, TestLine, PDU Power Position to on
    ...    - Backup TL configurations
    ...    - Validate Initial SCF
    ...    - Activate Energy Efficiency Monitoring
    ...    - Backup SBTS Configuration
    ...    - Validate current test SCF
    ...    - Collect Active Alarms and check for warnings
    ...    - Install Wireshark Plugin if necessary
    ...    - Install 5G TTI trace tools
    # Turn all DUs RUs TestLine PDU Power Position To   on
    Test Suite Preparation
    Activating Energy Effecency Monitoring
    Validate SCF Plan    ${PATH_Storage}/initial_conf_scf.xml
    # ===========================================
    Initialize Attenuator
    Initialize Configuration For test
    tti_tool_installer.Install_5g_ttitrace_tools    build_version=${ENB_BUILD}    capacity_unit_id=${CPTY_UNIT_ID}
    gnb_log.Setup gNB Btslog Collector

CB012738 Test Suite Teardown
    [Documentation]   Teardown for CB012738 test
    Test Suite Teardown
    Run Keyword and Ignore Error    gnblog.disconnect
    Run Keyword and Ignore Error    Useful_keywords.instance_disconnect  gnbbbu

Initialize Configuration For test
    [Documentation]    Initialize Configuration for test
    ...    - Backup SBTS Configuration
    ...    - Validate SCF Plan
    ...    - Collect Active Alarms and check for warnings
    Set BTSLog Rad Parameters on Classical gNB
    Enable Feature CB012738
    # Backup SBTS Configuration
    Backup SBTS Configuration    local_dir=${PATH_Storage}     filename_prefix=current_conf
    # Validate SCF Plan
    Validate SCF Plan    ${PATH_Storage}/current_conf_scf.xml
    # Collect Active Alarms and check for warnings
    ${Active_Alarms}=    Collect Active Alarms    alarms_path=${PATH_Storage}    alarms_prefix=current_
    Run Keyword If     ${Active_Alarms}
    ...     Fail  Warning BTS Alarm raise after feature activation, please check the logs.


TC Setup
    [Documentation]    Setup for test case
    ...    Enabling Feature CB012738
    ...    Start DCAP Lite and connect to DCAP
    ...    Creating BTS on DCAP
    Log    TC setup
    Test Case Dir Preparation
    # *********** Ue Preparation *******************
    Log To Console      Starting Test attached and Traffic Scenario
    taf_ue.require_ue      ue_alias=${UE1}     capabilities=${UE1_CAPABILITIE}

TC Teardown
    [Documentation]    teardown for test case
    # Release UE
    Run keyword and ignore error    taf_ue.detach_ue       ue_alias=${alias_1}
    # Run Keyword and Ignore Error    scout_utils.set_scout_config_id_tc    ${BTS_SCOUT_NAME}
    Run Keyword and Ignore Error    gnb_log.Teardown gNB Btslog Collector
    BuiltIn.Log   Collecting BTS Snapshot   console=True
    ${is_true}           Evaluate    "${GET_SNAPSHOT}" in ['yes', 'Yes', 'YES']
    Run Keyword If    ${is_true}
    ...  Run Keyword and Ignore Error  gnb_log.Collect Snapshot From gNB  log_dir=${res_path}
    ...  snapshot_coverage=Full  timeout=${SNAPSHOT_TIMEOUT}
    ${syslog_dir}=    utilities.get_folder_from_path  ${syslog_path}
    syslog_analysis.run_analysis
    ...    ${syslog_dir}
    ...    custom_patterns=${custom_patterns}
    ...    custom_msg_to_skip=${custom_msg_to_skip}
    ${syslog_msg}=    syslog_analysis.results_summary
    log    ${syslog_msg}    console=True



Check Feature activation
    [Documentation]    Check if the feature is activated
    [Arguments]    ${feature_activation_plan}
    ${feature_activation_plan}=    Set Variable    ${CURDIR}/../config/${SBTS_BRANCH}/${feature_activation_plan}

    # Should Contain String    ${feature_activation_plan}    "Feature Activation Plan"

Enable Feature CB012738
    [Documentation]    Configure initial cell parameters
    ...    Configure FR1 NSA FDD    bandwidth=20M  PRBs=106
    ...    Configure CORESET    duration=1    size=96
    ...    Set NRBTS Parameter    PDCCH-alSelection    dynamic
    # Set RD Parameter    rdStaticPdcchPowerOffset
    #     (0x58046f=0) ,0x0,false,"This parameter allow to decrease/increase PDCCH power offset
    #     Online modifiable.
    radParams.set_rad_flags    0x58046f=0   persistently=${False}
    ${test_plan}=    Set Variable    ${CURDIR}/../config/${SBTS_BRANCH}/${feature_activation_plan}
    gnb_scf.perform_bts_delta_json_commissioning
    ...     delta_file=${test_plan}
    ...     bts_id=0    du_id=0     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${720}
    Wait Until Keyword Succeeds  12 min  5 sec  gnbcell.Verify All Cells Are Onair
    # Check Feature activation    ${feature_activation_plan}

Connect UE
    [Documentation]    Connect UE
    [Arguments]    ${UE_ALIAS}
    taf_ue.attach_ue       ue_alias=${UE_ALIAS}
    BuiltIn.Sleep     3s

Release UE
    [Documentation]    Connect UE
    [Arguments]    ${UE_ALIAS}
    Run Keyword and Ignore Error    taf_ue.detach_ue       ue_alias=${UE_ALIAS}
    BuiltIn.Sleep     3s

Get UE Infos
    [Documentation]    get ue info and log it
    [Arguments]    ${UE_ALIAS}
    ${UE_INFO}=    taf_ue.Get UE Info    ${UE_ALIAS}    ALL
    Log To Console      Ue Info: ${UE_INFO}

Start DL Transmission
    [Documentation]    Start DL Transmission
    [Arguments]    ${UE_ALIAS}    ${DL_TPUT}
    ${dt_name}    Set Variable    dt_${UE_ALIAS}
    taf_ue.Start Data Transfer  dt_name=${dt_name}  ue_alias=${UE_ALIAS}  direction=${direction}  duration=${tput_duration}
        ...    throughput=${DL_TPUT}  protocol=${protocol}	 packet_size=${Packet_Size}
        ...    qci=${qci_dl}  buffer_client=${buffer_client}  buffer_server=${buffer_server}
    BuiltIn.Sleep     3s

Stop DL Transmission
    [Documentation]    Start DL Transmission
    [Arguments]    ${UE_ALIAS}
     ${dt_name}    Set Variable    dt_${UE_ALIAS}
     taf_ue.Stop Data Transfer  dt_name=${dt_name}
     BuiltIn.Sleep     3s

Start and Collect TTi Traces
    [Documentation]    Start ttiTrace for duration in s
    ...                Convert ttiTrace to csv
    ...                Collect csv to local VM
    [Arguments]    ${Step}    ${CPTY_UNIT_ID}    ${duration}=10s
    # Starting ttitrace collection
    tti_trace_collector.Start collecting TTI trace    common_unit_id=0    capacity_unit_id=${CPTY_UNIT_ID}
    BuiltIn.Sleep     ${duration}
    tti_trace_collector.Stop collecting TTI trace    common_unit_id=0    capacity_unit_id=${CPTY_UNIT_ID}
    BuiltIn.Sleep     5s
    run keyword And Continue On Failure  tti_trace_collector.download_tti_traces   common_unit_id=0    capacity_unit_id=${CPTY_UNIT_ID}
    ...  download_dir=${res_path}/ttitrace/${Step}    timeout=300
    Run Keyword And Continue On Failure  tti_trace_collector.Convert TTI traces to CSV    common_unit_id=0    capacity_unit_id=${CPTY_UNIT_ID}
    OperatingSystem.Run  mkdir ${res_path}/ttitrace/${Step}
    Run Keyword And Continue On Failure  tti_trace_collector.Download TTI trace CSV logs   common_unit_id=0    capacity_unit_id=${CPTY_UNIT_ID}
    ...  download_dir=${res_path}/ttitrace/${Step}    timeout=300


Verify PDCCH Power Boosting
    [Documentation]    Verifies the PDCCH power boosting status
    [Arguments]    ${Step}    ${CPTY_UNIT_ID}    ${duration}=10s    ${expected}=${True}
    Start and Collect TTi Traces    ${Step}    ${CPTY_UNIT_ID}    ${duration}
    Log    expted ${expected} checking PDCCH power boosting in progress
    # ${actual}=    Get PDCCH Power Boost Status    ${ue}
    # Should Be Equal    ${actual}    ${expected}

Modify NRBTS Parameter
    [Arguments]    ${dist_name}    ${param_name}    ${param_value}
    Log    set distName: ${param_value} parameter: ${param_name} to ${param_value}
    gnb_scf.perform_parameter_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${param_name}
    ...    operation=update
    ...    value=${param_value}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    bts_id=0
    ...    du_id=0
    ...    timeout=60
    BuiltIn.Sleep    2s


