*** Settings ***
Documentation
...  author:  Sara Nowak
...  contact: sara.nowak@nokia.com

Library     OperatingSystem                                                   WITH NAME    os
Library     DateTime                                                          WITH NAME    dt
Library     SSHLibrary                                                        WITH NAME    ssh_lib
Library     ute_fsmaccess
Library     ute_wtssim
Library     ta5g_pm_counters
Library     taf.ue                                                            WITH NAME    ue
Library     taf.rfrl.ue.ute_ue_config.UteUeConfig                             WITH NAME    uteueconfig
Library     taf.rfrl.utilities.test_config.DefaultFileLocation                WITH NAME    default_file_location
Library     taf.rfrl.bts.commissioning
Library     ./suite_specific_keywords.py
Library     ./tcp_runner.py
Library     ../../../../resources/pcap_verification/flow_verifier.py          WITH NAME    flow_verifier

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../../../resources/collect_logs.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./variables.py


*** Variables ***
${abstract_lib_config}       ${NONE}
${skip_commissioning}        ${NONE}
${COLLECT_MANDATORY_LOGS}    ${False}
@{CB008294_CUSTOM_ALLOWED_ALARMS}  7107

*** Keywords ***

A 100 Test Setup
    Log Action To Console    Start Test Setup
    Common Preconditions
    os.Create Directory    ${LOG_PATH}
    Setup UE Before Test
    Set actCarrierAggregationFr2SA on gNB 1    value=false
    Sleep    90s
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

A 100 Test Teardown
    Log Action To Console    End Test Procedure
    Log Action To Console    Start Test Teardown
    Run Keyword And Ignore Error    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT
    Run Keyword And Ignore Error    tcp_runner.Stop Data Transfer    dt_name=UL_UE_DT
    Run Keyword And Ignore Error    ue.Detach UE   UE
    Run Keyword And Ignore Error    Set actCarrierAggregationFr2SA on gNB 1    value=true
    Sleep    90s
    Common Postconditions
    Log Action To Console    End Test Teardown

C 101 Test Setup
    Log Action To Console    Start Test Setup
    Set State Of Cell 4 on gNB1 to Unlocked
    Common Preconditions
    os.Create Directory    ${LOG_PATH}
    Setup UE Before Test
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

C 101 Test Teardown
    Log Action To Console    End Test Procedure
    Log Action To Console    Start Test Teardown
    Run Keyword And Ignore Error    Set administrativeState for cell 4 on gNB 1    value=Unlocked
    Run Keyword And Ignore Error    ue.Detach UE   UE
    Common Postconditions
    Log Action To Console    End Test Teardown

A 400 Test Setup
    Log Action To Console    Start Test Setup
    Common Preconditions
    os.Create Directory    ${LOG_PATH}
    Perform Delta Commissioning On gNB     delta=${delta_a_400_timer_period_setup}     gnb_id=0
    Log Action To Console    Lock required cells
    Lock gNB Cell    cell_id=252
    Lock gNB Cell    cell_id=255
    Lock gNB Cell    cell_id=256
    Lock gNB Cell    cell_id=257
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    gnb_id=0    cell_id=257    du_id=0
    ...    operational_state=Disabled    procedural_status=initialization required
    ...    availability_status=Offline    administrative_state=Locked
    Setup UE Before Test
    Wait For Next Full Pm Interval
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

A 400 Test Teardown
    Log Action To Console    End Test Procedure
    Log Action To Console    Start Test Teardown
    Run Keyword And Ignore Error    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT
    Run Keyword And Ignore Error    tcp_runner.Stop Data Transfer    dt_name=UL_UE_DT
    Run Keyword And Ignore Error    ue.Detach UE   UE
    Log Action To Console    Unlock required cells
    Run Keyword And Ignore Error    Unlock gNB Cell    cell_id=252
    Run Keyword And Ignore Error    Unlock gNB Cell    cell_id=255
    Run Keyword And Ignore Error    Unlock gNB Cell    cell_id=256
    Run Keyword And Ignore Error    Unlock gNB Cell    cell_id=257
    Run Keyword And Ignore Error     Wait Until Keyword Succeeds    5min    10s
    ...                                                             Verify Cell Statuses    gnb_id=0    cell_id=257    du_id=0
    Common Postconditions
    Perform Delta Commissioning On gNB     delta=${delta_a_400_timer_period_teardown}     gnb_id=0
    Log Action To Console    End Test Teardown

A 004 PMO 1 Test Setup
    Log Action To Console    Start Test Setup
    Common Preconditions
    os.Create Directory    ${LOG_PATH}
    Log Action To Console    Lock required cells
    Perform Delta Commissioning On gNB     delta=${delta_a_400_timer_period_setup}     gnb_id=0
    Lock gNB Cell    cell_id=254
    Lock gNB Cell    cell_id=255
    Lock gNB Cell    cell_id=256
    Lock gNB Cell    cell_id=257
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    gnb_id=0    cell_id=257    du_id=0
    ...    operational_state=Disabled    procedural_status=initialization required
    ...    availability_status=Offline    administrative_state=Locked
    Wait For Next Full Pm Interval
    Setup UE Before Test
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

A 004 PMO 1 Test Teardown
    Log Action To Console    End Test Procedure
    Log Action To Console    Start Test Teardown
    Run Keyword And Ignore Error    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT
    Run Keyword And Ignore Error    tcp_runner.Stop Data Transfer    dt_name=UL_UE_DT
    Run Keyword And Ignore Error    ue.Detach UE   UE
    Log Action To Console    Unlock required cells
    Run Keyword And Ignore Error    Unlock gNB Cell    cell_id=254
    Run Keyword And Ignore Error    Unlock gNB Cell    cell_id=255
    Run Keyword And Ignore Error    Unlock gNB Cell    cell_id=256
    Run Keyword And Ignore Error    Unlock gNB Cell    cell_id=257
    Run Keyword And Ignore Error     Wait Until Keyword Succeeds    5min    10s
    ...                                                             Verify Cell Statuses    gnb_id=0    cell_id=257    du_id=0
    Common Postconditions
    Log Action To Console    End Test Teardown

A 000 PMO 2 Test Setup
    Log Action To Console    Start Test Setup
    Common Preconditions
    os.Create Directory    ${LOG_PATH}
    Perform Delta Commissioning On gNB     delta=${delta_a_000_pmo_2_activation}     gnb_id=0
    Wait Until Keyword Succeeds    300 sec    15 sec    Verify gNB is onAir
    Setup UE Before Test
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

A 000 PMO 2 Test Teardown
    Log Action To Console    End Test Procedure
    Log Action To Console    Start Test Teardown
    Run Keyword And Ignore Error    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT
    Run Keyword And Ignore Error    ue.Detach UE   UE
    Perform Delta Commissioning On gNB     delta=${delta_a_000_pmo_2_deactivation}     gnb_id=0
    Wait Until Keyword Succeeds    300 sec    15 sec    Verify gNB is onAir
    Common Postconditions
    Log Action To Console    End Test Teardown

W 101 Test Setup
    Log Action To Console    Start Test Setup
    Common Preconditions
    os.Create Directory    ${LOG_PATH}
    Setup UE Before Test
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

W 22 CB010496 Test Setup
    Log Action To Console    Start Test Setup
    os.Create Directory    ${LOG_PATH}
    Setup UE Before Test
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

W 101 Test Teardown
    Log Action To Console    End Test Procedure
    Log Action To Console    Start Test Teardown
    Run Keyword And Ignore Error    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT
    Run Keyword And Ignore Error    ue.Detach UE   UE
    Common Postconditions
    Log Action To Console    End Test Teardown

W 201 Test Setup
    Log Action To Console    Start Test Setup
    Common Preconditions
    os.Create Directory    ${LOG_PATH}
    Setup UE Before Test
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

W 23 CB010496 Test Setup
    Log Action To Console    Start Test Setup
    os.Create Directory    ${LOG_PATH}
    Setup UE Before Test
    Log Action To Console    End Test Setup
    Log Action To Console    Start Test Procedure

W 201 Test Teardown
    Log Action To Console    End Test Procedure
    Log Action To Console    Start Test Teardown
    Run Keyword And Ignore Error    tcp_runner.Stop Data Transfer    dt_name=UL_UE_DT
    Run Keyword And Ignore Error    ue.Detach UE   UE
    Common Postconditions
    Log Action To Console    End Test Teardown

Suite Setup
    [Documentation]    Common part for all test cases
    Evaluate    "warnings.filterwarnings(action='ignore', module='dateutil')"
    Run Keyword If    '${skip_commissioning}' != 'true'    Run Keywords
    ...                                                    Upload Swconfig On Classical Gnb    bts_id=0    prefix_tag=CB008294   AND
    ...                                                    Log Action To Console    Perform Commissioning On Gnb    AND
    ...                                                    Perform Full Commissioning On Classical Gnb    prefix_tag=CB008294   AND
    ...                                                    Wait Until Keyword Succeeds    15min    10s    Verify Setup Of All Cells
    ...                                                                                                   gnb_id=0    du_id=0
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}

Suite Setup 8SK050
    [Documentation]    Common part for all test cases
    Evaluate    "warnings.filterwarnings(action='ignore', module='dateutil')"
    Run Keyword If    '${skip_commissioning}' != 'true'    Run Keywords
    ...    Prepare BTS for Tests    AND
    ...    Perform Commissioning with Swconfig upload    prefix_tag=CB008294

    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}

Prepare BTS for Tests
    Common Suite Setup With OnAir Test Line Preparation
    ...    list_of_additional_allowed_alarms=${CB008294_CUSTOM_ALLOWED_ALARMS}
    ...    should_LTE_neighbour_be_changed=${False}
    ...    should_5G_neighbour_be_changed=${False}

Perform Commissioning with Swconfig upload
    [Arguments]    ${prefix_tag}   ${bts_id}=0
    Upload Swconfig On Classical Gnb    bts_id=${bts_id}    prefix_tag=${prefix_tag}
    Perform Full Commissioning On Classical Gnb    bts_id=${bts_id}    prefix_tag=${prefix_tag}
    Wait Until Keyword Succeeds    15min    10s    Verify Setup Of All Cells    gnb_id=${bts_id}    du_id=0

Setup UE Before Test
    ${status}=    Run Keyword And Return Status    ue.Require Ue    UE    CPE
    Run Keyword If    '${status}' == '${False}'    Run Keywords     Restart UE PROXY Service     AND    ue.Require Ue    UE    CPE
    Run Keyword And Ignore Error    ue.Detach UE   UE

Restart UE PROXY Service
    Log Action To Console        Restart UE PROXY Service

    ${host}=    Set Variable  ${abstract_lib_config.UE_PC.ue_pc_ip}
    ${username}=    Set Variable  ${abstract_lib_config.UE_PC.ue_pc_login}
    ${password}=    Set Variable  ${abstract_lib_config.UE_PC.ue_pc_password}

    ssh_lib.Open Connection      host=${host}    timeout=60s
    ssh_lib.Login                username=${username}    password=${password}
    ssh_lib.Execute Command      net stop UE_PROXY_AT && net start UE_PROXY_AT
    Sleep                        10s

    [Teardown]   ssh_lib.Close Connection

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Log given message to console with extra magic :)
    ...                :param msg:     message logged
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Attach UE
    ${date}=    Get Current Date   result_format=%Y_%m_%d_%H_%M_%S
    ${pcap_file}=    Set variable    ue_attach_${date}.pcap
    collect_logs.Start tcpdump on CU     filename=${pcap_file}    interface=any -U
    Set Test Variable    ${pcap_attach_log_path}    ${pcap_file}
    ue.Attach UE   UE
    ue.Create PDU Session    UE
    Sleep  20s
    collect_logs.Stop tcpdump on CU and Download Logs    filename=${pcap_file}

Set actCarrierAggregationFr2SA on gNB 1
    [Arguments]    ${value}=true
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    param_name=actCarrierAggregationFr2SA
    ...    param_value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${360}

Set administrativeState for cell 4 on gNB 1
    [Arguments]    ${value}=Unlocked
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_ids[3]}
    ...    param_name=administrativeState
    ...    param_value=${value}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${360}

Enable FR2 CA on gNB 1
    Log Action To Console    Enable FR2 CA on gNB 1
    Set actCarrierAggregationFr2SA on gNB 1    value=true

Disable FR2 CA on gNB 1
    Log Action To Console    Disable FR2 CA on gNB 1
    Set actCarrierAggregationFr2SA on gNB 1    value=false

Check If UE Is Attached To Cell 1 Of gNB 1
    Log Action To Console    Check If UE Is Attached To Cell 1 Of gNB 1

Detach UE
    Log Action To Console    Detach UE
    ue.Detach UE   UE

Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Log Action To Console    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Attach UE

Attach UE With PDU Session Setup to Cell 2 of gNB 1
    Log Action To Console    Attach UE With PDU Session Setup to Cell 2 of gNB 1
    Attach UE

Check If UE Is Attached To Cell 1 Of gNB 1 and No Scells Are Configured
    Log Action To Console    Check If UE Is Attached To Cell 1 Of gNB 1 and No Scells Are Configured

    ${is_found}=    Check If Message Is In Flow    awaited_message=${query_rrc_reconfiguration_with_scell_message}
    ...                                            pcap_file=${LOG_PATH}/${pcap_attach_log_path}
    Run Keyword If    ${is_found}    Fail    msg=7 scells were found

    @{message_query}=    Create List    ${query_pdu_session_resource_setup_message}
    flow_verifier.Expect Messages In Flow    awaited_messages=${message_query}    pcap_file=${LOG_PATH}/${pcap_attach_log_path}

Check If UE Is Attached To Cell 1 Of gNB 1 and 3 Consecutive Scells Are Configured
    Log Action To Console    Check If UE Is Attached To Cell 1 Of gNB 1 and 3 Consecutive Scells Are Configured

    @{message_query}=    Create List    ${query_pdu_session_resource_setup_message}
    ...                                 ${query_rrc_reconfiguration_with_3_consecutive_scell_message}
    flow_verifier.Expect Messages In Flow    awaited_messages=${message_query}    pcap_file=${LOG_PATH}/${pcap_attach_log_path}

Check If UE Is Attached To Cell 1 Of gNB 1 and 3 Scells Are Configured
    Log Action To Console    Check If UE Is Attached To Cell 1 Of gNB 1 and 3 Scells Are Configured

    @{message_query}=    Create List    ${query_pdu_session_resource_setup_message}
    ...                                 ${query_rrc_reconfiguration_with_3_scell_message}
    flow_verifier.Expect Messages In Flow    awaited_messages=${message_query}    pcap_file=${LOG_PATH}/${pcap_attach_log_path}

Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured
    Log Action To Console    Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured

    @{message_query}=    Create List    ${query_pdu_session_resource_setup_message}    ${query_rrc_reconfiguration_with_scell_message}
    flow_verifier.Expect Messages In Flow    awaited_messages=${message_query}    pcap_file=${LOG_PATH}/${pcap_attach_log_path}

Check If UE Is Attached To Cell 2 Of gNB 1 and 6 Scells Are Configured
    Log Action To Console    Check If UE Is Attached To Cell 2 Of gNB 1 and 6 Scells Are Configured

    @{message_query}=    Create List    ${query_pdu_session_resource_setup_message}    ${query_rrc_reconfiguration_with_6_scell_message}
    flow_verifier.Expect Messages In Flow    awaited_messages=${message_query}    pcap_file=${LOG_PATH}/${pcap_attach_log_path}

Run Downlink TCP Data Transmission for 60 seconds
    Log Action To Console    Run Downlink TCP Data Transmission for 60 seconds

    ${duration}=    Set Variable    ${60}

    tcp_runner.Start Data Transfer    dt_name=DL_UE_DT    ue_alias=UE
    ...    app_server_cmd=iperf3 -s -B <APP_SERVER_BIND_IP> -p <APP_SERVER_IPERF_PORT> -i 1
    ...    ue_cmd=/usr/bin/iperf3 -c <APP_SERVER_BIND_IP> -p <UE_IPERF_PORT> -t ${duration} -B <UE_IP> -i 1 -P 6 -R
    Sleep    ${duration}
    Sleep    10s  # 4s
    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT

Run Uplink TCP Data Transmission for 60 seconds
    Log Action To Console    Run Uplink TCP Data Transmission for 60 seconds

    ${duration}=    Set Variable    ${60}

    tcp_runner.Start Data Transfer    dt_name=UL_UE_DT    ue_alias=UE
    ...    app_server_cmd=iperf3 -s -B <APP_SERVER_BIND_IP> -p <APP_SERVER_IPERF_PORT> -i 1
    ...    ue_cmd=/usr/bin/iperf3 -c <APP_SERVER_BIND_IP> -p <UE_IPERF_PORT> -t ${duration} -B <UE_IP> -i 1 -P 6 -M 1360
    Sleep    ${duration}
    Sleep    30s
    tcp_runner.Stop Data Transfer    dt_name=UL_UE_DT

Verify 8CC Downlink TCP Data Transmission
    Log Action To Console    Verify 8CC Downlink TCP Data Transmission

    ${iperf_log_path}=    tcp_runner.Get App Server Iperf Log Path    dt_name=DL_UE_DT
    Verify TCP Downlink Data Transfer    minimum_level=4.02 Gbits/sec    maximum_level=4.4 Gbits/sec   iperf_log_path=${iperf_log_path}

Verify 4CC Uplink TCP Data Transmission
    Log Action To Console    Verify 4CC Uplink TCP Data Transmission

    ${iperf_log_path}=    tcp_runner.Get App Server Iperf Log Path    dt_name=UL_UE_DT

    Verify TCP Uplink Data Transfer    minimum_level=505 Mbits/sec    maximum_level=590 Mbits/sec   iperf_log_path=${iperf_log_path}

Verify 4CC Downlink TCP Data Transmission
    Log Action To Console    Verify 4CC Downlink TCP Data Transmission

    ${iperf_log_path}=    tcp_runner.Get App Server Iperf Log Path    dt_name=DL_UE_DT
    Verify TCP Downlink Data Transfer    minimum_level=2.01 Gbits/sec    maximum_level=2.2 Gbits/sec   iperf_log_path=${iperf_log_path}

Verify 2CC Uplink TCP Data Transmission
    Log Action To Console    Verify 2CC Uplink TCP Data Transmission

    ${iperf_log_path}=    tcp_runner.Get App Server Iperf Log Path    dt_name=UL_UE_DT

    Verify TCP Uplink Data Transfer    minimum_level=245 Mbits/sec    maximum_level=295 Mbits/sec   iperf_log_path=${iperf_log_path}

Verify 1CC Downlink TCP Data Transmission
    Log Action To Console    Verify 1CC Downlink TCP Data Transmission

    ${iperf_log_path}=    tcp_runner.Get App Server Iperf Log Path    dt_name=DL_UE_DT

    Verify TCP Downlink Data Transfer    minimum_level=0.505 Gbits/sec    maximum_level=0.550 Gbits/sec   iperf_log_path=${iperf_log_path}

Verify 1CC Uplink TCP Data Transmission
    Log Action To Console    Verify 1CC Uplink TCP Data Transmission

    ${iperf_log_path}=    tcp_runner.Get App Server Iperf Log Path    dt_name=UL_UE_DT

    Verify TCP Uplink Data Transfer    minimum_level=110 Mbits/sec    maximum_level=170 Mbits/sec   iperf_log_path=${iperf_log_path}

Set State Of Cell 4 on gNB1 to Shutting Down
    Log Action To Console    Set State Of Cell 8 on gNB1 to Shutting Down

    ${date}=    Get Current Date   result_format=%Y_%m_%d_%H_%M_%S
    ${pcap_file}=    Set variable    ue_release_${date}.pcap
    collect_logs.Start tcpdump on CU     filename=${pcap_file}    interface=any -U
    Set Test Variable    ${pcap_release_log_path}    ${pcap_file}

    Set administrativeState for cell 4 on gNB 1    value=Shutting Down
    Sleep    100s

    collect_logs.Stop tcpdump on CU and Download Logs    filename=${pcap_file}

Set State Of Cell 4 on gNB1 to Unlocked
    Log Action To Console    Set State Of Cell 8 on gNB1 to Unlocked

    Set administrativeState for cell 4 on gNB 1    value=Unlocked
    Wait Until Keyword Succeeds    5min    10s
    ...    Verify Cell Statuses   gnb_id=0    cell_id=${cell_ids[3]}    du_id=0
    ...        operational_state=Enabled    procedural_status=configured    availability_status=Online    administrative_state=Unlocked

Check If UE Was Released
    Log Action To Console    Check If UE Was Released

    ${is_found}=    Get NG Reset Message    pcap_file=${LOG_PATH}/${pcap_release_log_path}
    Run Keyword If    ${is_found}    Log Action To Console   UE was released    ELSE    Fail    msg=NG Reset was not found

Check If Cell Is Locked
    Log Action To Console    Check If Cell Is Locked
    Verify Cell Statuses    cell_id=${cell_ids[3]}    operational_state=Disabled    procedural_status=initialization required
    ...                                               availability_status=Offline    administrative_state=Locked

Collect Counters Values
    [Arguments]    ${counters}    ${pm_counters_file}

    &{counters_values}=    Create Dictionary

    FOR    ${counter}    IN    @{counters}
        @{values}    get_pm_counter_value    counter=${counter.id}    localmoid=${counter.localmoid}   filepath=${pm_counters_file}

        ${values_length}=  Get Length    ${values}
        ${value}=  	Set Variable If	   ${values_length} != 0	${values[0]}	${-1}

        Set To Dictionary    ${counters_values}    ${counter.label}=${value}

        Log    Value of ${counter}: ${value}
    END

    [Return]    ${counters_values}

Collect A 400 PM Counters Before Test
    Log Action To Console     Collect A 400 PM Counters Before Test\n

    Wait For Next Full Pm Interval
    ${pm_counters_file}=    Get Latest Unpacked Full PM Counters File

    &{counters_before_tests}=    Collect Counters Values    ${a_400_counters}    ${pm_counters_file}

    Log    Value of counters before test: ${counters_before_tests}

    Set Global Variable    ${counters_before_tests}

Collect A 400 PM Counters After Test
    Log Action To Console     Collect A 400 PM Counters After Test\n

    Wait For Next Full Pm Interval
    ${pm_counters_file}=    Get Latest Unpacked Full PM Counters File

    &{counters_after_tests}=    Collect Counters Values    ${a_400_counters}    ${pm_counters_file}

    Log    Value of counters before test: ${counters_after_tests}

    Set Global Variable    ${counters_after_tests}

Collect A 004 PMO 1 PM Counters Before Test
    Log Action To Console     Collect A 004 PMO 1 PM Counters Before Test\n

    Wait For Next Full Pm Interval
    ${pm_counters_file}=    Get Latest Unpacked Full PM Counters File

    &{counters_before_tests}=    Collect Counters Values    ${a_400_pmo_1_counters}    ${pm_counters_file}

    Log    Value of counters before test: ${counters_before_tests}

    Set Global Variable    ${counters_before_tests}

Collect A 004 PMO 1 PM Counters After Test
    Log Action To Console     Collect A 004 PMO 1 PM Counters After Test\n

    Wait For Next Full Pm Interval
    ${pm_counters_file}=    Get Latest Unpacked Full PM Counters File

    &{counters_after_tests}=    Collect Counters Values    ${a_400_pmo_1_counters}    ${pm_counters_file}

    Log    Value of counters before test: ${counters_after_tests}

    Set Global Variable    ${counters_after_tests}

Collect A 000 PMO 2 PM Counters Before Test
    Log Action To Console     Collect A 000 PMO 2 PM Counters Before Test\n

    Wait For Next Full Pm Interval
    ${pm_counters_file}=    Get Latest Unpacked Full PM Counters File

    &{counters_before_tests}=    Collect Counters Values    ${a_000_pmo_2_counters}    ${pm_counters_file}

    Log    Value of counters before test: ${counters_before_tests}

    Set Global Variable    ${counters_before_tests}

Collect A 000 PMO 2 PM Counters After Test
    Log Action To Console     Collect A 000 PMO 2 PM Counters After Test\n

    Wait For Next Full Pm Interval
    ${pm_counters_file}=    Get Latest Unpacked Full PM Counters File

    &{counters_after_tests}=    Collect Counters Values    ${a_000_pmo_2_counters}    ${pm_counters_file}

    Log    Value of counters before test: ${counters_after_tests}

    Set Global Variable    ${counters_after_tests}

Prepare First Counters Collection To Verification
    Log Action To Console    Prepare First Counters Collection To Verification

    @{counters}=    Get Slice From List    ${a_400_pmo_1_counters}    0   -3

    @{counters_labels}=    Create List
    FOR    ${item}    IN    @{counters}
        Append To List    ${counters_labels}    ${item.label}
    END

    Set Global Variable    ${all_counters_before_tests}    ${counters_before_tests}
    Set Global Variable    ${all_counters_before_tests}    ${counters_after_tests}

    ${counters_before_tests}=    Cut Counters    ${counters_before_tests}    ${counters_labels}
    ${counters_after_tests}=    Cut Counters    ${counters_after_tests}    ${counters_labels}

    Set Global Variable    ${counters_before_tests}
    Set Global Variable    ${counters_after_tests}

Cut Counters
    [Arguments]    ${all}    ${required}

    &{counter_collection}=    Create Dictionary

    FOR    ${label}    IN    @{required}
        ${value}=    Get From Dictionary    ${all}    ${label}
        Set To Dictionary    ${counter_collection}    ${label}=${value}
    END

    [Return]    ${counter_collection}

Prepare Second Counters Collection To Verification
    Log Action To Console    Prepare Second Counters Collection To Verification

    @{counters}=    Get Slice From List    ${a_400_pmo_1_counters}    -3    -1

    @{counters_labels}=    Create List
    FOR    ${item}    IN    @{counters}
        Append To List    ${counters_labels}    ${item.label}
    END

    ${counters_before_tests}=    Cut Counters    ${all_counters_before_tests}    ${counters_labels}
    ${counters_after_tests}=    Cut Counters    ${all_counters_before_tests}    ${counters_labels}

    Set Global Variable    ${counters_before_tests}
    Set Global Variable    ${counters_after_tests}

Prepare Third Counters Collection To Verification
    Log Action To Console    Prepare Second Counters Collection To Verification

    @{counters}=    Get Slice From List    ${a_400_pmo_1_counters}    -1

    @{counters_labels}=    Create List
    FOR    ${item}    IN    @{counters}
        Append To List    ${counters_labels}    ${item.label}
    END

    ${counters_before_tests}=    Cut Counters    ${all_counters_before_tests}    ${counters_labels}
    ${counters_after_tests}=    Cut Counters    ${all_counters_before_tests}    ${counters_labels}

    Set Global Variable    ${counters_before_tests}
    Set Global Variable    ${counters_after_tests}

Verify If Counters Level Is 780
    Log Action To Console    Verify If Counters Level Is 780
    Require Counter Values    ${counters_before_tests}    900
    Require Counter Values    ${counters_after_tests}    780

Verify If Counters Level Is 900
    Log Action To Console    Verify If Counters Level Is 900
    Require Counter Values    ${counters_before_tests}    900
    Require Counter Values    ${counters_after_tests}    900

Verify Counter Updates
    Log Action To Console    Verify Counter Updates
    Compare Counter Values    ${counters_before_tests}    ${counters_after_tests}
