*** Settings ***
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG11/Resources/SG11_Common_setup_teardown.robot
Suite Setup       SG11 Common Suite Setup
Suite Teardown    SG11 Common Suite Teardown
Test Setup        SG11 Common Case Setup
Test Teardown     SG11 Common Case Teardown

*** Variables ***
${cell_type}             NR
${ue_index}              ${0}
${UL_TPUT}               150
${DL_TPUT}               600
${UL_EXPECT}             30
${DL_EXPECT}             400
${TARGET_AVG_PERCENT}    0.98
${SCF_FILE}              ${CURDIR}/config/scf.xml
@{BLOCK_CELL_LIST}       2    3    5
@{cell_list}             ${611844096}    ${611844100}
@{L2STREAM_COMPONENT_CONFIG}    &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
SA_Case_Template
    Full Commission With SCF File    ${SCF_FILE}
    Wait Until Keyword Succeeds    10min    30s    Verify All Cells Should Be Onair
    SBTS Block Cells And Check Status    ${block_cell_list}
    ${ue_type}    ue.Translate Power Ue Type From Testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    #UE Attach
    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify Attach    ue_type=${ue_type}    ue_index=${ue_index}
    ${rc}    ${output}=    Run And Return Rc And Output    sshpass -p "nokia123@" ssh mn5gran@10.64.57.18 "adb shell ifconfig"
    # Start Traffic
    Log To Console    ue pdu IP: ${output},start straffic...
    power_ue.Start Traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_tput}
    ...    duration=1200    ue_type=${ue_type}    iperf_type=via_command    protocol=udp
    Sleep    1s
    power_ue.Start Traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_tput}    duration=1200
    ...    ue_type=${ue_type}    protocol=udp    buffer_size=1400B    process_num=${2}    seg_size=1350    window=16M
    Sleep    5s
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=10s    check_source=aasyslog
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${DL_EXPECT}
    ...    target_avg_percent=${TARGET_AVG_PERCENT}    ue_index=${ue_index}    check_source=aasyslog
    ...    cells=${cell_list}    actCarrierAggregation=${true}
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=${UL_EXPECT}
    ...    target_avg_percent=${TARGET_AVG_PERCENT}    ue_index=${ue_index}    check_source=aasyslog
    ...    cells=${cell_list}    actCarrierAggregation=${true}
    Capture Convert Format Ttitrace With Streaming Mode    1s
    power_ue.Stop Traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop Traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}


*** Keywords ***
UE Attach And Check Tput
    [Arguments]    ${ue_index}=${0}    ${dl_tput}=600    ${ul_tput}=150    ${duration}=30    ${TARGET_AVG_PERCENT}=0.98
    ...    ${dl_expect}=400    ${ul_expect}=50
    ${ue_type}    ue.Translate Power Ue Type From Testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    #UE Attach
    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify Attach    ue_type=${ue_type}    ue_index=${ue_index}
    ${rc}    ${output}=    Run And Return Rc And Output    sshpass -p "nokia123@" ssh mn5gran@10.64.57.18 "adb shell ifconfig"
    # Start Traffic
    Log To Console    ue pdu IP: ${output},start straffic...
    Run Keyword And Continue On Failure    power_ue.Start Traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_tput}
    ...    duration=1200    ue_type=${ue_type}    iperf_type=via_command    protocol=udp
    Sleep    1s
    power_ue.Start Traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_tput}    duration=1200
    ...    ue_type=${ue_type}    protocol=udp    buffer_size=1400B    process_num=${2}    seg_size=1350    window=16M
    Sleep    5s
    # ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    filter=L2Lo
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=10s    check_source=aasyslog
    # Check Tput For CA UE
    ${cell_list}    Create List    ${611844096}    ${611844100}
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${DL_EXPECT}
    ...    target_avg_percent=${TARGET_AVG_PERCENT}    ue_index=${ue_index}    check_source=aasyslog
    ...    cells=${cell_list}    actCarrierAggregation=${true}
    # Check Tput For Non CA UE
    # ${cell_list}    Create List    ${611844098}
    # Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${DL_EXPECT}
    # ...    target_avg_percent=${TARGET_AVG_PERCENT}    ue_index=${ue_index}    check_source=aasyslog    cells=${cell_list}
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cell_list}
    ...    ultarget_throughput=${UL_EXPECT}    dltarget_throughput=${DL_EXPECT}    actCarrierAggregation=${true}
    Set Test Variable    ${all_tp}
    ${dl_avg}    Set Variable    ${all_tp[1][0]['average']}
    ${ul_avg}    Set Variable    ${all_tp[0][0]['average']}
    Should Be True    ${dl_avg}>=${DL_EXPECT}
    power_ue.Stop Traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop Traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}
    [teardown]    Power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

