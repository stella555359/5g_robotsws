*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      CB010936_Keywords.py
Library      taf.transport.ssh  WITH NAME  SSH
Library      ta5g_testline_management
Library      ta5g_ue_measurements
Library      ta5g_cell_operations
Library      ta5g_pm_counters
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_enb

*** Variables ***
${alias}=    VM

*** Keywords ***
Connect To VM
    SSH.Connect To    hostname=127.0.0.1    username=ute    alias=${alias}

Disconnect From The VM
    SSH.Disconnect    connection=${alias}

Start UDP DL L4S Traffic
    [Arguments]    ${port}    ${bandwidth}    ${duration}
    Connect To VM
    SSH.Send Command
    ...  command=iperf-l4s -s -u -e -p ${port} -i 1 -B 10.0.2.1 -b ${bandwidth} > ${OUTPUT_DIR}/${TEST_NAME}/iperf_${port}_DL.txt
    ...  connection=${alias}
    SSH.Send Command
    ...  command=iperf-l4s -c 1.2.4.2 -u --udp-l4s --trip-times -p ${port} -l 1400 -b ${bandwidth} -i 1 -t ${duration} -B 10.0.2.1
    ...  connection=${alias}
    Disconnect From The VM
    Log To Console    UDP DL L4S traffic on port ${port} with bandwidth ${bandwidth} started.

Start UDP DL Classic Traffic
    [Arguments]    ${port}    ${bandwidth}    ${duration}
    Connect To VM
    SSH.Send Command
    ...  command=iperf-l4s -s -u -e -p ${port} -i 1 -B 10.0.2.1 -b ${bandwidth} > ${OUTPUT_DIR}/${TEST_NAME}/iperf_${port}_DL.txt
    ...  connection=${alias}
    SSH.Send Command
    ...  command=iperf-l4s -c 1.2.4.2 -u --trip-times -p ${port} -l 1400 -b ${bandwidth} -i 1 -t ${duration} -B 10.0.2.1
    ...  connection=${alias}
    Disconnect From The VM
    Log To Console    UDP DL Classic traffic on port ${port} with bandwidth ${bandwidth} started.

Start UDP UL L4S Traffic
    [Arguments]    ${port}    ${bandwidth}    ${duration}
    Connect To VM
    SSH.Send Command
    ...  command=iperf-l4s -s -u -e -p ${port} -i 1 -B 10.0.2.1 -b ${bandwidth} > ${OUTPUT_DIR}/${TEST_NAME}/iperf_${port}_UL.txt
    ...  connection=${alias}
    SSH.Send Command
    ...  command=iperf-l4s -c 72.30.0.1 -u --udp-l4s --trip-times -p ${port} -l 1400 -b ${bandwidth} -i 1 -t ${duration} -B 10.0.2.1
    ...  connection=${alias}
    Disconnect From The VM
    Log To Console    UDP UL L4S traffic on port ${port} with bandwidth ${bandwidth} started.

Start UDP UL Classic Traffic
    [Arguments]    ${port}    ${bandwidth}    ${duration}
    Connect To VM
    SSH.Send Command
    ...  command=iperf-l4s -s -u -e -p ${port} -i 1 -B 10.0.2.1 -b ${bandwidth} > ${OUTPUT_DIR}/${TEST_NAME}/iperf_${port}_UL.txt
    ...  connection=${alias}
    SSH.Send Command
    ...  command=iperf-l4s -c 72.30.0.1 -u --trip-times -p ${port} -l 1400 -b ${bandwidth} -i 1 -t ${duration} -B 10.0.2.1
    ...  connection=${alias}
    Disconnect From The VM
    Log To Console    UDP UL Classic traffic on port ${port} with bandwidth ${bandwidth} started.

Stop Specific Traffic
    [Arguments]    ${port}
    Connect To VM
    SSH.Send Command
    ...  command=ps -ef | grep iperf-l4s | grep ${port} | awk '{print $2}' | xargs kill -9 $1 >/dev/null 2>&1
    ...  connection=${alias}
    Disconnect From The VM

Stop All Traffics
    Connect To VM
    SSH.Send Command
    ...  command=killall iperf-l4s
    ...  connection=${alias}
    Disconnect From The VM

Verify Average DL L4S Throughput On Port
    [Arguments]    ${port}    ${direction}    ${expected_throughput}    ${log_directory}
    ${avg_tput}=    Check Average Throughput    port=${port}    direction=${direction}    log_directory=${log_directory}
    Run Keyword And Continue On Failure
    ...    Should Be True    ${avg_tput} > ${expected_throughput}

Verify Average DL L4S Latency On Port
    [Arguments]    ${port}    ${direction}    ${max_latency}    ${log_directory}
    ${avg_latency}=    Check Average Latency    port=${port}    direction=${direction}    log_directory=${log_directory}
    Run Keyword And Continue On Failure
    ...    Should Be True    ${avg_latency} < ${max_latency}

Verify Average DL Classic Throughput On Port
    [Arguments]    ${port}    ${direction}    ${expected_throughput}    ${log_directory}
    ${avg_tput}=    Check Average Throughput    port=${port}    direction=${direction}    log_directory=${log_directory}
    Run Keyword And Continue On Failure
    ...    Should Be True    ${avg_tput} > ${expected_throughput}

Verify Average DL Classic Latency On Port
    [Arguments]    ${port}    ${direction}    ${min_latency}    ${log_directory}
    ${avg_latency}=    Check Average Latency    port=${port}    direction=${direction}    log_directory=${log_directory}
    Run Keyword And Continue On Failure
    ...    Should Be True    ${avg_latency} > ${min_latency}

Verify Average UL L4S Throughput On Port
    [Arguments]    ${port}    ${direction}    ${expected_throughput}    ${log_directory}
    ${avg_tput}=    Check Average Throughput    port=${port}    direction=${direction}    log_directory=${log_directory}
    Run Keyword And Continue On Failure
    ...    Should Be True    ${avg_tput} > ${expected_throughput}

Verify Average UL L4S Latency On Port
    [Arguments]    ${port}    ${direction}    ${max_latency}    ${log_directory}
    ${avg_latency}=    Check Average Latency    port=${port}    direction=${direction}    log_directory=${log_directory}
    Run Keyword And Continue On Failure
    ...    Should Be True    ${avg_latency} < ${max_latency}

Verify Average UL Classic Throughput On Port
    [Arguments]    ${port}    ${direction}    ${expected_throughput}    ${log_directory}
    ${avg_tput}=    Check Average Throughput    port=${port}    direction=${direction}    log_directory=${log_directory}
    Run Keyword And Continue On Failure
    ...    Should Be True    ${avg_tput} > ${expected_throughput}

Verify Average UL Classic Latency On Port
    [Arguments]    ${port}    ${direction}    ${min_latency}    ${log_directory}
    ${avg_latency}=    Check Average Latency    port=${port}    direction=${direction}    log_directory=${log_directory}
    Run Keyword And Continue On Failure
    ...    Should True    ${avg_latency} > ${min_latency}