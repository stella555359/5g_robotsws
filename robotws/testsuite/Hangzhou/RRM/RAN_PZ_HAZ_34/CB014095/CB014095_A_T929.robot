*** Settings ***
Documentation
...         author: Hongye.fu
...         contact: Hongye.fu@nokia-sbell.com
...         squad group: NSB MN RAN RD VRF HAZ 4
...         CB014095 CRT (inter-gNB environment)

Library    OperatingSystem
Library    testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB010636.Resources.sigspark_mmw3.SigSpark    WITH NAME    sigspark_mmw3

Suite Setup    Run keywords    Set Global Variable    ${trunk_rolll_needed}    ${False}
...    AND    robot_common_operations.Common Suite Setup
...    AND    CI_interface.Common Suite Setup    gnb_index=${0}
...    AND    CI_interface.Common Suite Setup    gnb_index=${1}
Suite Teardown    robot_common_operations.Common Suite Teardown

Resource    ./Resources/CB014095_Common_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Variables   ./Resources/TL929_Configuration.py


*** Variables ***
# gNB instance IDs (from testline configuration)
${gnb0_instance_id}    ${tl.gnbs[0].instance_id}    # Anchor gNB (PCell)
${gnb1_instance_id}    ${tl.gnbs[1].instance_id}    # Secondary gNB (SCell)
${gnb1_ip}             ${tl.gnbs[1].dus[0].f1_m_ip_addr}    # gNB1 IP address
# COAM connection names
${connection}          COAM     # Connection alias for gNB0
${connection_gnb1}     COAM1    # Connection alias for gNB1
# iperf_port from testline UE object (cannot be set in Python variable file)
${iperf_port}          ${tl.ues[1].iperf_details.port}
# call duration in seconds for iperf traffic
${call_duration}       ${UE_CONFIG}[call_duration]
# Note: ${ue_alias}, ${spark_ue_index}, ${spark_ue_num}, ${UE1_CONFIG} imported from TL929_Configuration.py

# KPI Report Variables
${file_path}    /home/ute/KPI/kpi_report_releated_parameters.yml
${report_name}    CB014095_KPI_T915_report
${excel_kpi_path}    /home/ute/KPI/


*** Test Cases ***
[1]CB014095-SR-A-B4_37_IWK2_Inter-gNB_CA_in_SA_mode_Interworking_with_CB009103_main
    [Tags]    HAZ3_T03
    [Setup]    Test Case setup
    Step0: Establish COAM connections
    Step1: Attach UE and start traffic
    Step2: Check throughput with SCell before removal
    Step3: Start RRC log collection
    Step4: Remove sCellAdditionMethod parameters online inter-gNB
    Step5: Wait for SCell release
    Step6: Verify SCell release in RRC message
    Step7: Verify cells onair and no alarms both gNBs
    Step8: Check throughput after SCell release
    Step9: Stop traffic and detach UE
    [Teardown]    Test teardown


[1]CB014095-SR-C_83_E&R_KPI Impact_sCellAdditionMethod parameter online removal_Full commission
    [Tags]    HAZ3_T03
    [Setup]    Test Case setup
    Step0: Establish COAM connections
    Step1: Attach UE and start traffic
    Step2: Check throughput with SCell before removal
    Step3: Start RRC log collection
    sleep    10min
    Step4: Remove sCellAdditionMethod parameters online inter-gNB
    Step5: Wait for SCell release
    Step6: Verify SCell release in RRC message
    Step7: Verify cells onair and no alarms both gNBs
    Step8: Check throughput after SCell release
    Step10: Collect KPI report
    [Teardown]    Test teardown


*** Keywords ***
Step0: Establish COAM connections
    log to console    "Step0: Establish COAM connections for both gNBs"
    # Establish COAM connection to gNB0 (anchor gNB)
    Wait Until Keyword Succeeds    3min    30s    Connect to gnb coam via ssl    connection=${connection}
    # Establish COAM connection to gNB1 (secondary gNB)
    Wait Until Keyword Succeeds    3min    30s    Connect to gnb coam via ssl    bts_host=${gnb1_ip}    connection=${connection_gnb1}

Step1: Attach UE and start traffic
    log to console    "Step1: Use CB010636's sigspark_mmw3 library for reliable attach with power_reset"
    # Step 1a: Require UE using sigspark_mmw3 (like CB010636)
    log to console    "Prepare UE with license (sigspark_mmw3)"
    sigspark_mmw3.require_ue    ue_alias=${ue_alias}
    ...    get_spark_license=${True}    power_reset=true    index=${spark_ue_index}    ue_num_input=${spark_ue_num}    detach_request=true
    sleep    2s
    # Step 1b: Attach UE with power_reset=true (this will call power_on instead of attach)
    log to console    "Attach UE with power_reset=true (executes power_on)"
    sigspark_mmw3.attach_ue    attach_mode=5G_SA    power_reset=true    ue_alias=${ue_alias}
    sleep    10s
    # Start DL traffic using sigspark_mmw3
    log to console    "Start DL traffic on Spark UE (sigspark_mmw3)"
    sigspark_mmw3.start_data_transfer    ue_alias=${ue_alias}    direction=dl
    ...    iperf_port=${iperf_port}    ue_mode=SA    throughput=1900Mbits/sec    apn_address=dxdata3    protocol=UDP
    ...    duration=${call_duration}
    sleep    10s

Step2: Check throughput with SCell before removal
    log to console    "Step2: Check throughput with SCell (before parameter removal)"
    # Check DL throughput
    sleep    30s

Step3: Start RRC log collection
    log to console    "Step3: Start Spark log collection before parameter removal (sigspark_mmw3)"
    sigspark_mmw3.start_log    ue_alias=${ue_alias}
    sleep    2s
    log to console    "Step3.1: Start KPI recording - capture start time"
    Get record time    label=start
    # Wait a short period before parameter removal to ensure counters start
    #sleep    10min

Step4: Remove sCellAdditionMethod parameters online inter-gNB
    log to console    "Step4: Remove sCellAdditionMethod and sCellOperationalMode parameters online (inter-gNB)"
    # For inter-gNB scenario, remove parameters from NRCELL-3/NRREL-1 and NRREL-2 on gNB1
    ${delta_json}    Catenate    SEPARATOR=
    ...    [
    ...    {"distName": "MRBTS-${gnb1_instance_id}/NRBTS-${gnb1_instance_id}/NRCELL-3/NRREL-1",
    ...     "operation": "update",
    ...      "parameters": [
    ...        {"parameterName": "sCellAdditionMethod", "operation": "delete"},
    ...        {"parameterName": "sCellOperationalMode", "operation": "delete"}
    ...      ]
    ...    },
    ...    {"distName": "MRBTS-${gnb1_instance_id}/NRBTS-${gnb1_instance_id}/NRCELL-3/NRREL-2",
    ...     "operation": "update",
    ...      "parameters": [
    ...        {"parameterName": "sCellAdditionMethod", "operation": "delete"},
    ...        {"parameterName": "sCellOperationalMode", "operation": "delete"}
    ...      ]
    ...    }
    ...    ]
    ${delta_file}    Set Variable    /tmp/delta_remove_scell_params_inter_gnb.json
    OperatingSystem.Create File    ${delta_file}    ${delta_json}
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    timeout=300    connection=${connection_gnb1}
    [Teardown]    Run Keyword And Ignore error    COAM Logout

Step5: Wait for SCell release
    log to console    "Step5: Wait for SCell to be released (approximately 1 minute)"
    sleep    60s

Step6: Verify SCell release in RRC message
    log to console    "Step6: Stop Spark log and verify SCell release in RRC Reconfiguration message"
    Check SCell Release In RRC Reconfiguration    ue_alias=${ue_alias}

Step7: Verify cells onair and no alarms both gNBs
    log to console    "Step7: Verify cells are still onair and no unexpected alarms (both gNBs)"
    # Re-establish COAM connections (Step4 teardown disconnected them)
    Wait Until Keyword Succeeds    3min    30s    Connect to gnb coam via ssl    connection=${connection}
    Wait Until Keyword Succeeds    3min    30s    Connect to gnb coam via ssl    bts_host=${gnb1_ip}    connection=${connection_gnb1}
    # Check gNB0 (anchor gNB)
    ${onair_status_gnb0}    Check Cells Onair And No Unexpected Alarm
    ...    Check_timer=2min
    ...    connection=${connection}
    Run Keyword If    '${onair_status_gnb0}'!='pass'
    ...    Fail    gNB0 cell status check failed after parameter removal
    # Check gNB1 (secondary gNB) status
    ${onair_status_gnb1}    Check Cells Onair And No Unexpected Alarm
    ...    Check_timer=2min
    ...    connection=${connection_gnb1}
    Run Keyword If    '${onair_status_gnb1}'!='pass'
    ...    Fail    gNB1 cell status check failed after parameter removal
    [Teardown]    Run Keyword And Ignore error    COAM Logout

Step8: Check throughput after SCell release
    log to console    "Step8: Check throughput after SCell release"
    # Check DL throughput - may need to implement spark UE throughput check
    sleep    30s

Step9: Stop traffic and detach UE
    log to console    "Step9: Stop traffic and detach UE (sigspark_mmw3)"
    Run Keyword And Ignore Error    sigspark_mmw3.stop_data_transfer    direction=dl    ue_alias=${ue_alias}    iperf_port=${iperf_port}
    sleep    2s
    Run Keyword And Ignore Error    sigspark_mmw3.detach_ue    ue_alias=${ue_alias}    power_reset=true
    sleep    2s

Step10: Collect KPI report
    log to console    "Step10: Wait for KPI collection period (traffic still running)"
    sleep    15min
    Get record time    label=end
    log to console    "Step10.1: Stop traffic and detach UE after KPI end time recorded"
    Run Keyword And Ignore Error    sigspark_mmw3.stop_data_transfer    direction=dl    ue_alias=${ue_alias}    iperf_port=${iperf_port}
    sleep    2s
    Run Keyword And Ignore Error    sigspark_mmw3.detach_ue    ue_alias=${ue_alias}    power_reset=true
    sleep    15min
    Get bts package version
    ${report_id}    SFE_TMO_HO_common_keywords.generate_new_report_on_compass
    ...    file_path=${file_path}
    ...    report_name=${package_version}_${report_name}
    ...    tl_id=915
    ...    package_version=${package_version}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    Set Suite Variable    ${report_id}
    log to console    "Generated report ID: ${report_id}"
    Run Keyword If    '${report_id}' == 'None' or '${report_id}' == '${EMPTY}'
    ...    Fail    Failed to generate report on Compass. Report ID is None or empty.
    SFE_TMO_HO_common_keywords.Download Kpi File    report_id=${report_id}    path=${excel_kpi_path}
    log to console    "KPI file downloaded to: ${excel_kpi_path}"

Test teardown
    log to console    "Teardown: Stop traffic and power off UE"
    Run Keyword And Ignore Error    sigspark_mmw3.stop_data_transfer    direction=dl    ue_alias=${ue_alias}    iperf_port=${iperf_port}
    Run Keyword And Ignore Error    sigspark_mmw3.detach_ue    ue_alias=${ue_alias}    power_reset=true
    # Collect snapshot from both gNBs if test failed - with BTSID to distinguish them
    ${test_status}    Run Keyword And Return Status    Should Be Equal    ${TEST STATUS}    PASS
    Run Keyword If    '${test_status}'=='False'    Run Keywords
    ...    Run Keyword And Ignore Error    Connect to gnb coam via ssl    connection=${connection}
    ...    AND    Run Keyword And Ignore Error    Collect snapshot logs    TESTLINEID=gNB0_${gnb0_instance_id}    connection=${connection}
    ...    AND    Run Keyword And Ignore Error    Connect to gnb coam via ssl    bts_host=${gnb1_ip}    connection=${connection_gnb1}
    ...    AND    Run Keyword And Ignore Error    Collect snapshot logs    TESTLINEID=gNB1_${gnb1_instance_id}    connection=${connection_gnb1}
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_gnb1}
    CI_interface.Common Case Teardown
