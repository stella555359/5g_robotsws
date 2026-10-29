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
CB013303_SR_D1_01_Service-aware BLER Target feature interworking with Optimized Target BLER on TDD FR1 cell when MAD algorithm applied
    [Documentation]    How to calculate MAD due to need multiply factor. need split mcs<20, and mcs>=20 by adjust PA.
    adjust_pa_all_ports_max_value

    log    step: attach + dl traffic, check peak throughput and bler    console=True
    adjust pa for cell    cell_id=21    value=0
    # Prepare and attach UE
    # start dl traffic    send_traffic=600M
	attach and check peak tput    cell_id=21
#    Capture Ttitrace And Check bler    cell_id=21    tag=1_attach

#    log    step: adjust PA, check la from NRPDSCHBRLA-1 with mcs>=20    console=True
#    adjust pa for cell    cell_id=21    value=15
#    start to capture gnb ttitrace    tag=2_adjust_pa    cell_id=21
#    adjust pa stepwise for cell    cell_id=21    start_value=15    end_value=38
#    ${ttitrace_log_path}    stop capture gnb ttitrace   tag=2_adjust_pa   decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.08
#    ...                      stepdown=0.25
#    ...                      stepup=mad
#    ...                      mcstable=QAM256
#
#    log    step: adjust PA, check la from NRPDSCHBRLA-1 with mcs<20    console=True
#    adjust pa for cell    cell_id=21    value=45
#    start to capture gnb ttitrace    tag=3_adjust_pa    cell_id=21
#    adjust pa stepwise for cell    cell_id=21    start_value=45    end_value=60
#    ${ttitrace_log_path}    stop capture gnb ttitrace   tag=3_adjust_pa   decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.08
#    ...                      stepdown=0.25
#    ...                      stepup=mad
#    ...                      mcstable=QAM256
#    ...                      ibler=6%-10%
#
#    log    step: add 5qi8, check la from NRPDSCHBRLA-2 and not apply MAD    console=True
#    add 5qi bearer    5qi=8
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=4_add_5qi8    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.16
#    ...                      mcstable=QAM256
#    ...                      ibler=3%-7%

    [Teardown]    Run Keywords    Stop DL traffic
    ...                           Detach UE
    ...                           Common Test Teardown And Stop Capture Logs


