*** Settings ***
Documentation
...         author: Hongye.fu
...         contact: Hongye.fu@nokia-sbell.com
...         squad group: NSB MN RAN RD VRF HAZ 4
...         CB014095 CRT (power_ue)

Library    OperatingSystem

Suite Setup    Run keywords    Set Global Variable    ${trunk_rolll_needed}    ${False}
...    AND    robot_common_operations.Common Suite Setup
...    AND    Wait For GNSS Update To Complete
...    AND    CI_interface.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

Resource    ./Resources/CB014095_Common_Keywords.robot


*** Variables ***
${connection}        COAM    # COAM connection alias
@{ul_traffic_list}    79   66   20   20   #20Mbps
@{port_list}         43567   43577   43587   43597
${traffic_duration}   600
${ue_alias}          spark_UE
${spark_ue_index}    1    # Use tl.ues[1] which is _sigspark_multiUE (835de864)
${spark_ue_num}      0    # Use UE0 in the 8UE Spark
@{ul_power_port_list}    43567   43577   43587   43597
@{dl_power_port_list}    57845   43617   43627   43637
${target_cell_id}    68719475329
@{UE_INDEX_LIST}=    ${spark_ue_index}

# Spark MultiUE configuration for UE1 (matching spark_ue_index=1)
&{MultiUECFG_SA}=
...    1=&{UE0_CONFIG}
...    ue_index_for_call=@{UE_INDEX_LIST}
&{UE0_CONFIG}=
...    detach_request=false
...    power_reset=true
...    ue_mode=5G_SA
...    apn=dxdata3
...    iperf_port=57845
...    dl=&{DL_CONFIG}
...    ul=&{UL_CONFIG}
...    target_percent=0.9
...    reset_sol=none
...    attach_mode=5G_SA
...    dt_name=DT_8
...    protocol=udp
...    connection_type=app
...    apn_address=dxdata3
&{DL_CONFIG}=    target_throughput=900MKbits/sec    duration=600
&{UL_CONFIG}=    target_throughput=70MKbits/sec    duration=600

*** Test Cases ***
[1]CB014095-SR-A-B1_5_CB014095-SR-A-B1_5_B2_Removal_of_sCellAdditionMethod_parameter_No_UE_blind
    [Tags]    HAZ3_T03
    [Setup]    Test Case setup
    Step1: Attach UE and start traffic
    Step2: Check throughput with SCell before removal
    Step3: Start RRC log collection
    Step4: Remove sCellAdditionMethod parameters online
    Step5: Wait for SCell release
    Step6: Verify SCell release in RRC message
    Step7: Verify cells onair and no alarms
    Step8: Check throughput after SCell release
    Step9: Stop traffic and detach UE
    [Teardown]    Test teardown



*** Keywords ***
Step1: Attach UE and start traffic
    log to console    "Step1: Attach UE and start traffic"
    # Attach Spark UE - use UE0 from 8UE Spark configuration (5G_SA mode)
    Prepare MultiUE And Attach    multiue_config_direction=${MultiUECFG_SA}    ue_alias=${ue_alias}
    sleep    5s
    # Start DL traffic
    log to console    Start DL traffic on Spark UE
    sparkMultiUE_yiyuan.start_data_transfer    ue_alias=${ue_alias}    direction=dl
    sleep    10s

Step2: Check throughput with SCell before removal
    log to console    "Step2: Check throughput with SCell (before parameter removal)"
    # Check DL throughput - may need to implement spark UE throughput check
    sleep    30s

Step3: Start RRC log collection
    log to console    "Step3: Start Spark log collection before parameter removal"
    sparkMultiUE_yiyuan.start_log    ue_alias=${ue_alias}
    sleep    2s

Step4: Remove sCellAdditionMethod parameters online
    log to console    "Step4: Remove sCellAdditionMethod and sCellOperationalMode parameters online"
    Connect to gnb coam via ssl    connection=${connection}
    log to console    Waiting for GNSS SW update fault 4420 to clear before recommissioning...
    Wait Until Keyword Succeeds    600 sec    10 sec    Verify Fault 4420 Is Absent    conn=${connection}
    ${delta_json}    Catenate    SEPARATOR=
    ...    [
    ...    {"distName": "MRBTS-4294967208/NRBTS-4294967208/NRCELL-1/NRREL-5", "operation": "update",
    ...      "parameters": [
    ...        {"parameterName": "sCellAdditionMethod", "operation": "delete"},
    ...        {"parameterName": "sCellOperationalMode", "operation": "delete"}
    ...      ]
    ...    },
    ...    {"distName": "MRBTS-4294967208/NRBTS-4294967208/NRCELL-1/NRREL-10", "operation": "update",
    ...      "parameters": [
    ...        {"parameterName": "sCellAdditionMethod", "operation": "delete"},
    ...        {"parameterName": "sCellOperationalMode", "operation": "delete"}
    ...      ]
    ...    }
    ...    ]
    ${delta_file}    Set Variable    /tmp/delta_remove_scell_params.json
    OperatingSystem.Create File    ${delta_file}    ${delta_json}
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    timeout=300    connection=${connection}
    [Teardown]    Run Keyword And Ignore error    COAM Logout

Step5: Wait for SCell release
    log to console    "Step5: Wait for SCell to be released (approximately 1 minute)"
    sleep    60s

Step6: Verify SCell release in RRC message
    log to console    "Step6: Stop Spark log and verify SCell release in RRC Reconfiguration message"
    Check SCell Release In RRC Reconfiguration    ue_alias=${ue_alias}

Step7: Verify cells onair and no alarms
    log to console    "Step7: Verify cells are still onair and no unexpected alarms"
    Connect to gnb coam via ssl    connection=${connection}
    ${onair_status}    Check Cells Onair And No Unexpected Alarm    Check_timer=2min    connection=${connection}
    Run Keyword If    '${onair_status}'!='pass'    Fail    Cell status check failed after parameter removal
    [Teardown]    Run Keyword And Ignore error    COAM Logout

Step8: Check throughput after SCell release
    log to console    "Step8: Check throughput after SCell release"
    # Check DL throughput - may need to implement spark UE throughput check
    sleep    30s

Step9: Stop traffic and detach UE
    log to console    "Step9: Stop traffic and detach UE"
    Run Keyword And Ignore Error    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=dl
    Run Keyword And Ignore Error    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}

Test teardown
    Run Keyword And Ignore Error    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=dl
    Run Keyword And Ignore Error    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Connect to gnb coam via ssl    connection=${connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    CI_interface.Common Case Teardown

Wait For GNSS Update To Complete
    [Documentation]    Wait for GNSS firmware upgrade fault 4420 to clear before commissioning in Suite Setup
    log to console    Checking if GNSS SW update fault 4420 is active...
    Connect to gnb coam via ssl    connection=${connection}
    ${status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    600 sec    10 sec    Verify Fault 4420 Is Absent    conn=${connection}
    Run Keyword And Ignore Error    COAM Logout
    Run Keyword If    '${status}' == 'False'    Fail    Fault 4420 (GNSS SW update) did not clear within 600 seconds

Verify Fault 4420 Is Absent
    [Documentation]    Verify that GNSS SW update fault 4420 is not active
    [Arguments]    ${conn}=${connection}
    @{alarms}    coam.get_active_alarms    connection=${conn}
    FOR    ${alarm}    IN    @{alarms}
        Run Keyword If    ${alarm['faultId']} == 4420    Fail    Fault 4420 (GNSS SW update ongoing) is still present
    END

