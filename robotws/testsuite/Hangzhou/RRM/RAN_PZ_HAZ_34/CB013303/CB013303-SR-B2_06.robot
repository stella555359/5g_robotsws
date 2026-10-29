*** Settings ***
Documentation
...    author: Xiang Kang
...    contact: kang.xiang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS24R3    tl-7_5_UTE5G402T2405
Resource          ./resources/CB013303_resource.robot

*** Variables ***
${EMIL_FLAG}    False

*** Test Cases ***
CB013303-SR-B2_06_Service-aware BLER Target feature interworking with high reliability DRB for 64QAM-MCS-TableAlt capable UE on TDD FR1 cell
    adjust_pa_all_ports_max_value

    log    step: attach + dl traffic, check peak throughput    console=True
    adjust pa for cell    cell_id=21    value=0
    # Prepare and attach UE
    # start ul and dl traffic    send_traffic_ul=200M    send_traffic_dl=600M
	attach and check peak tput    cell_id=21    SslotMCS=24

#    log    step: adjust PA, check la from NRPDSCHBRLA-1 and NRPUSCHBRLA-1    console=True
#    adjust pa for cell    cell_id=21    value=20
#    start to capture gnb ttitrace    tag=2_adjust_pa    cell_id=21
#    adjust pa stepwise for cell    cell_id=21    start_value=20    end_value=60
#    ${ttitrace_log_path}    stop capture gnb ttitrace   tag=2_adjust_pa   decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM256
#    ...                      ibler=3%-7%
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM256
#
#    log    step: add 5qi8, check la from NRPDSCHHRLA-1 and NRPUSCHHRLA-1    console=True
#    adjust pa stepwise for cell    cell_id=21    start_value=20    end_value=46
#    sleep    5s    wait singnal stability
#    add 5qi bearer    5qi=8
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=3_add_5qi8_dl    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.01
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64LOWSE
#    ...                      lamode=HIGHRELIABILITY
#    ...                      step_tolerance=30%
#    ...                      ibler=0%-3%
#
#    adjust pa stepwise for cell    cell_id=21    start_value=36    end_value=44
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=3_add_5qi8_ul    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.01
#    ...                      stepdown=2
#    ...                      mcstable=QAM64LOWSE
#    ...                      lamode=HIGHRELIABILITY
#    ...                      ibler=0%-3%
#
#    log    step: adjust attenuation make bler increase and mcs degrade than threshold    console=True
#    adjust pa stepwise for cell    cell_id=21    start_value=50    end_value=55    interval=3
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=4_adjust_pa_ul    cell_id=21
#    run keyword and ignore error    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM64LOWSE
#    Stop UL Traffic
#    adjust pa stepwise for cell    cell_id=21    start_value=56    end_value=68    interval=3
#    sleep    2s    wait singnal stability
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=4_adjust_pa_dl    cell_id=21
#    run keyword and ignore error    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64LOWSE
#
#    Start UL Traffic    send_traffic=200M
#    log    step: adjust attenuation make bler decrease and mcs upgrade than threshold    console=True
#    adjust pa stepwise for cell    cell_id=21    start_value=67    end_value=20    step=-2    interval=3
#    adjust pa stepwise for cell    cell_id=21    start_value=20    end_value=42    interval=3
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=5_adjust_pa_ul    cell_id=21
#    run keyword and ignore error    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.01
#    ...                      stepdown=2
#    ...                      mcstable=QAM64LOWSE
#    ...                      lamode=HIGHRELIABILITY
#    ...                      ibler=0%-2%
#    adjust pa stepwise for cell    cell_id=21    start_value=42    end_value=47    interval=3
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=5_adjust_pa_dl    cell_id=21
#    run keyword and ignore error    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.01
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64LOWSE
#    ...                      lamode=HIGHRELIABILITY
#    ...                      ibler=0%-2%
#
#    log    step: release 5qi8, check la from NRPDSCHBRLA-1 and NRPUSCHBRLA-1    console=True
#    del 5qi bearer    5qi=8
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=6_release_5qi8    cell_id=21
#    run keyword and ignore error    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM256
#    ...                      ibler=3%-7%
#    run keyword and ignore error    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM256
#    ...                      ibler=3%-7%

    [Teardown]    Run Keywords    Stop UL And DL traffic
    ...                           Detach UE
    ...                           Common Test Teardown And Stop Capture Logs


