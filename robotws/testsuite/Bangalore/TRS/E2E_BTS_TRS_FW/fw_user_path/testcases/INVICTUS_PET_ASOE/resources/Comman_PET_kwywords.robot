*** Settings ***
Documentation
...            [Author]         "Vimala"

*** Variables ***
${MEMORY_THRESHOLD}     100
${CPU_THRESHOLD}        400
${pcap_name}=           /home/ute/Downloads/1_20250911T125032.pcap.gz
${ALIAS}                bts_1
${REMOTE_DEVICE}        user
${CPU_DELTA_LIMIT}      0.1
${MEM_DELTA_LIMIT}      0.1
${ITERATION_DELAY}      5s
${ITERATIONS}           5
${DELTA_THRESHOLD}      0.1


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
    Setup Remote Access    remote_device=user    timeout=30    alias=default
    ${output}=    Remote Command Execute    command=ps -C trs-ethloam-d -o %cpu,%mem --no-headers    alias=default
    ${cpu_TAS}=    Evaluate    float(str($output).strip().split()[0])
    ${mem_TAS}=    Evaluate    float(str($output).strip().split()[1])
    Log    CPU: ${cpu_TAS}, MEM: ${mem_TAS}
    ${output}=    Remote Command Execute    command=ps -C trs_em_main -o pid,%cpu,%mem --no-headers    alias=default
#    @{lines}=    Split To Lines    ${output}

#    FOR    ${line}    IN    @{lines}
#    ${cpu}    ${mem}=    Split String    ${line}
#    Log    CPU: ${cpu}%, MEM: ${mem}%
#    ${cpu_f}=    Evaluate    float(${cpu})
#    ${mem_f}=    Evaluate    float(${mem})
#    Should Be True    ${mem_f} < ${MEMORY_THRESHOLD}    msg=memory usage ${mem_f}% exceeds threshold
#    Should Be True    ${cpu_f} < ${CPU_THRESHOLD}    msg=CPU usage ${cpu_f}% exceeds threshold
#    END
    @{lines}=    Split To Lines    ${output}

    FOR    ${line}    IN    @{lines}
        ${pid}    ${cpu}    ${mem}=    Split String    ${line}
        Log    PID: ${pid}, CPU: ${cpu}%, MEM: ${mem}%

        ${cpu_f}=    Evaluate    float(${cpu})
        ${mem_f}=    Evaluate    float(${mem})

        Should Be True    ${cpu_f} < ${CPU_THRESHOLD}    msg=CPU usage ${cpu_f}% exceeds threshold for PID ${pid}
        Should Be True    ${mem_f} < ${MEMORY_THRESHOLD}    msg=Memory usage ${mem_f}% exceeds threshold for PID ${pid}
    END
    Teardown Remote Access    alias=default

Check TRS Processes Memory And CPU Stability
    [Documentation]    Monitor all trs processes and ensure CPU/memory deltas stay within limits
    ${CPU_THRESHOLD}=    Set Variable    400
    ${MEMORY_THRESHOLD}=    Set Variable    100
    ${prev_data}=    Create Dictionary
    FOR    ${iteration}    IN RANGE    3
        Log To Console    \n=== Iteration ${iteration} ===
        Setup Remote Access    remote_device=user    timeout=30    alias=bts_1
        ${output}=    Remote Command Execute
        ...    command=ps -eo pid,comm,%cpu,%mem --no-headers | grep trs
        ...    alias=bts_1
        Teardown Remote Access    alias=bts_1
        ${lines}=    Split To Lines    ${output}
        ${current_data}=    Create Dictionary

        FOR    ${line}    IN    @{lines}
            ${pid}    ${name}    ${cpu}    ${mem}=    Split String    ${line}
            ${cpu_f}=    Evaluate    float(${cpu})
            ${mem_f}=    Evaluate    float(${mem})

            Log To Console    PID=${pid}, Name=${name}, CPU=${cpu_f}%, MEM=${mem_f}%

            Should Be True    ${cpu_f} <= ${CPU_THRESHOLD}    msg=CPU usage ${cpu_f}% exceeds threshold for PID ${pid}
            Should Be True
            ...    ${mem_f} <= ${MEMORY_THRESHOLD}
            ...    msg=Memory usage ${mem_f}% exceeds threshold for PID ${pid}

            ${inner}=    Create Dictionary    name=${name}    cpu=${cpu_f}    mem=${mem_f}
            Set To Dictionary    ${current_data}    ${pid}=${inner}

            ${exists}=    Evaluate    str(${pid}) in ${prev_data}
            IF    ${exists}
                Compare Process Delta    ${pid}    ${cpu_f}    ${mem_f}    ${prev_data}
            END
        END

        ${prev_data}=    Copy Dictionary    ${current_data}
        Sleep    5s
    END

Compare Process Delta
    [Arguments]    ${pid}    ${cpu_f}    ${mem_f}    ${prev_data}
    ${prev_entry}=    Get From Dictionary    ${prev_data}    ${pid}
    ${prev_cpu}=    Get From Dictionary    ${prev_entry}    cpu
    ${prev_mem}=    Get From Dictionary    ${prev_entry}    mem

    ${cpu_delta}=    Evaluate    abs(${cpu_f} - ${prev_cpu})
    ${mem_delta}=    Evaluate    abs(${mem_f} - ${prev_mem})

    Log To Console    Comparing PID=${pid}: ?CPU=${cpu_delta}, ?MEM=${mem_delta}

    IF    ${cpu_delta} > ${DELTA_THRESHOLD}
        Fail    CPU delta ${cpu_delta} > ${DELTA_THRESHOLD} for PID ${pid}
    END
    IF    ${mem_delta} > ${DELTA_THRESHOLD}
        Fail    MEM delta ${mem_delta} > ${DELTA_THRESHOLD} for PID ${pid}
    END