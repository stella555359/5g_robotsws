*** Settings ***
Documentation
...            [Author]         "Vimala"

*** Variables ***
${MEMORY_THRESHOLD}     100
${CPU_THRESHOLD}        100
${pcap_name}=           /home/ute/Downloads/1_20250911T125032.pcap.gz


*** Keywords ***
Check CPU Memory Usage For MyProcess
    Setup Remote Access    remote_device=user    timeout=30    alias=default
    ${output}=    Remote Command Execute    command=ps -C TAS -o %cpu,%mem --no-headers    alias=default
    ${cpu_TAS}=    Evaluate    float(str($output).strip().split()[0])
    ${mem_TAS}=    Evaluate    float(str($output).strip().split()[1])
    Log    CPU: ${cpu_TAS}, MEM: ${mem_TAS}
    ${output}=    Remote Command Execute    command=ps -C trs_fpb -o %cpu,%mem --no-headers    alias=default
    ${cpu_trs_fpb}=    Evaluate    float(str($output).strip().split()[0])
    ${mem_trs_fpb}=    Evaluate    float(str($output).strip().split()[1])
    Log    CPU: ${cpu_trs_fpb}, MEM: ${mem_trs_fpb}
    ${output}=    Remote Command Execute    command=ps -C trs_em_main -o %cpu,%mem --no-headers    alias=default
#    ${cpu_trs_em_main}=    Evaluate    float(str($output).strip().split()[0])
#    ${mem_trs_em_main}=    Evaluate    float(str($output).strip().split()[1])
#    Log    CPU: ${cpu_trs_em_main}, MEM: ${mem_trs_em_main}
    @{lines}=    Split To Lines    ${output}

    FOR    ${line}    IN    @{lines}
        ${cpu}    ${mem}=    Split String    ${line}
        Log    CPU: ${cpu}%, MEM: ${mem}%
        ${cpu_f}=    Evaluate    float(${cpu})
        ${mem_f}=    Evaluate    float(${mem})
        Should Be True    ${mem_f} < ${MEMORY_THRESHOLD}    msg=memory usage ${mem_f}% exceeds threshold
        Should Be True    ${cpu_f} < ${CPU_THRESHOLD}    msg=CPU usage ${cpu_f}% exceeds threshold
    END
#    Should Be True    ${mem} < 90
    Teardown Remote Access    alias=default

Get Memory And CPU Usage Before
    Setup Remote Access    remote_device=user    timeout=30    alias=default
    ${before_output}=    Remote Command Execute
    ...    command=ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 11
    ...    alias=default
    Teardown Remote Access    alias=default
    RETURN    ${before_output}

#    Log    BEFORE:\n${before_output}
#    ${before_output}=    Set Variable    ${before.stdout}
#    ${before}=    Run Process    bash    -c    ${PS_CMD}    stdout=PIPE    shell=True
Get Memory And CPU Usage After
    ${after}=    Run Process    bash    -c    ${PS_CMD}    stdout=PIPE    shell=True
    ${after_output}=    Set Variable    ${after.stdout}
    Log    AFTER:\n${after_output}
    RETURN    ${after_output}

Compare Process Lists
    [Arguments]    ${before_output}    ${after_output}
    ${before_lines}=    Split String    ${before_output}    \n
    ${after_lines}=    Split String    ${after_output}    \n
    FOR    ${i}    IN RANGE    1    11
        ${b_line}=    Get From List    ${before_lines}    ${i}
        ${a_line}=    Get From List    ${after_lines}    ${i}
        ${b_parts}=    Split String    ${b_line}
        ${a_parts}=    Split String    ${a_line}
        ${pid}=    Get From List    ${b_parts}    0
        ${b_mem}=    Get From List    ${b_parts}    2
        ${b_cpu}=    Get From List    ${b_parts}    3
        ${a_mem}=    Get From List    ${a_parts}    2
        ${a_cpu}=    Get From List    ${a_parts}    3
        ${mem_diff}=    Evaluate    float(${a_mem}) - float(${b_mem})
        ${cpu_diff}=    Evaluate    float(${a_cpu}) - float(${b_cpu})
        Log    PID: ${pid} | Mem Diff: ${mem_diff} | CPU Diff: ${cpu_diff}
    END

Make 5G Calls
    Traffic Capture Start    capture_device=vm_eth3_interface
#    Perform Call Setup
    Trigger UE Calls
    ${pcap_name}=    Traffic Capture Stop
#    ${pcap_name}=/home/ute/Downloads/1_20250911T125032.pcap.gz
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=Verify_SA_Calls    filter_file_name=traffic_filters.json

Perform Call Setup
    Call Setup    5g=device4:data    parallel=${False}    verify_attach=${False}    attach=${False}    timeout=180

Trigger UE Calls
    [Documentation]    Start 5G/TWAMP/BFD calls
    Configure Ue    5g=device4:data    command=ue_register    id=1
    Sleep    5
    Configure Ue    5g=device4:data    command=set_pdu_param    ue=1    pdu=1    trf_type=internal
    Sleep    5
    Configure Ue    5g=device4:data    command=ue_pdu_session_setup    pdu=1    gw=1    ue=1
    Sleep    5
    FOR    ${i}    IN RANGE    1    9
        Configure Ue    5g=device4:data    command=trf_data_start    ue=1    pdu=1    qfi=1    dir=dl    mbps=175
        Sleep    10
    END
    Configure Ue    5g=device4:data    command=trf_data_start    ue=1    pdu=1    qfi=1    dir=ul    mbps=50
    Log    Calls started

Stop Calls
    [Documentation]    Stop calls after test
    Configure Ue    5g=device4:data    command=ue_deregister    id=1    ue_deregister_type=switch off
    Log    Calls stopped

CRL Download success
    Wait Until Keyword Succeeds
    ...    5 min
    ...    30
    ...    Verify Alarm
    ...    faultid=${crl_update_failure}
    ...    occurrences=${0}
    ...    should_exist=${False}

Make 4G Calls
    Configure UE
    ...    lte=sim_enb:data
    ...    command=ue_attach id=1
    ...    cell=11
    ...    selected_plmn=${operator_plmn}[${plmn_index}]
    sleep    5
    Configure UE    lte=sim_enb:data    command=trf_data_start    ue=1    dir=ul    Mbps=20    protocol=udp
    sleep    5
    Configure UE    lte=sim_enb:data    command=trf_data_start    ue=1    dir=dl    Mbps=20    protocol=udp
    sleep    5

Stop 4G Calls
    Configure UE    lte=sim_enb:data    command=trf_data_stop    ue=1    dir=dl    trf_id=1    protocol=udp
