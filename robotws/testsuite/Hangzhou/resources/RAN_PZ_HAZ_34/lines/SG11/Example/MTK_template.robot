*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG11/Resources/Common_lib_variable.robot

*** Variables ***
${UL_THROUGHPUT}    150
${DL_THROUGHPUT}    600
${UL_EXPECT}        50
${DL_EXPECT}        400
${target_avg_percent}     0.98

*** Test Cases ***
MTK_L3Call
    ${ue_type}    ue.Translate Power Ue Type From Testline    ue_index=${0}
    Set Test Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
    #UE attach
    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify Attach    ue_type=${ue_type}    ue_index=${0}
    ${rc}    ${output}=    Run And Return Rc And Output    sshpass -p "nokia123@" ssh mn5gran@10.64.57.18 "adb shell ifconfig"
    # Start traffic
    log to console    ue pdu IP: ${output},start straffic...
    Run Keyword And Continue On Failure    power_ue.Start Traffic    ue_index=${0}    direction=ul    throughput=${UL_THROUGHPUT}
    ...    duration=1200    ue_type=${ue_type}    iperf_type=via_command    protocol=udp
    Sleep    1s
    power_ue.Start Traffic    ue_index=${0}    direction=dl    throughput=${DL_THROUGHPUT}    duration=1200
    ...    ue_type=${ue_type}    protocol=udp    buffer_size=1400B    process_num=${2}    seg_size=1350    window=16M
    Sleep    5s
    # ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    filter=L2Lo
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=10s    check_source=aasyslog
    # Check Tput for CA UE
    ${cell_list}    Create List    ${611844096}    ${611844100}
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${DL_EXPECT}
    ...    target_avg_percent=${target_avg_percent}    ue_index=${0}    check_source=aasyslog    cells=${cell_list}    actCarrierAggregation=${True}
    # Check Tput for Non CA UE
    # ${cell_list}    Create List    ${611844098}
    # Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${DL_EXPECT}
    # ...    target_avg_percent=${target_avg_percent}    ue_index=${0}    check_source=aasyslog    cells=${cell_list}
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cell_list}
    ...    ultarget_throughput=${UL_EXPECT}    dltarget_throughput=${DL_EXPECT}    actCarrierAggregation=${true}
    Set Test Variable    ${all_tp}
    ${dl_avg}    Set Variable    ${all_tp[1][0]['average']}
    ${ul_avg}    Set Variable    ${all_tp[0][0]['average']}
    Should Be True    ${dl_avg}>=${DL_EXPECT}
    power_ue.Stop Traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop Traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
    [teardown]    Power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

