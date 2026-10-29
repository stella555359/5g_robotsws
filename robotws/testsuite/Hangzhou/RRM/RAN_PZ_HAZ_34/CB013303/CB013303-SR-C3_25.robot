*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
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
CB013303-SR-C3_25_Re-establishment with Service-aware BLER Target associated DRB
    adjust_pa_all_ports_max_value

    log    step: attach + add 5qi3 + uldl traffic, check peak tput    console=True
    adjust_pa_for_cell    cell_id=11    value=0
    attach and check peak tput    cell_id=11
#    add 5qi bearer    5qi=3
#    Capture Ttitrace And Check bler    cell_id=11    tag=1_attach
#
#    log    step: adjust PA, check la from NRPDSCHBRLA-1 and NRPUSCHBRLA-1    console=True
#    start to capture gnb ttitrace    tag=2_adjust_pa    cell_id=11
#    adjust pa stepwise for cell    cell_id=11    start_value=0    end_value=40
#    ${ttitrace_log_path}    stop capture gnb ttitrace   tag=2_adjust_pa   decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM256
#
#    log    step: reestablish to other cell, check la not change    console=True
#    adjust_pa_for_cell    cell_id=21    value=0
#    adjust_pa_for_cell    cell_id=11    value=127
#    start to capture gnb ttitrace    tag=3_reestablish    cell_id=21
#    adjust pa stepwise for cell    cell_id=21    start_value=20    end_value=60
#    ${ttitrace_log_path}    stop capture gnb ttitrace   tag=3_reestablish   decode_flag=True
#    Get UE RNTI
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM256
#
#    log    step: del 5qi3, check la from NRPDSCHBRLA-2 and NRPUSCHBRLA-2    console=True
#    del 5qi bearer    5qi=3
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=4_del_5qi3    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.08
#    ...                      stepdown=0.3
#    ...                      mcstable=QAM64
#    ...                      ibler=6%-10%
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.08
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM256
#    ...                      ibler=6%-10%
#
#    log    step: del 5qi6, check la from cell    console=True
#    del 5qi bearer    5qi=6
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=5_del_5qi6    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64
#    ...                      ibler=8%-12%
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM256
#    ...                      ibler=8%-12%

    [Teardown]    Run Keywords    Stop UL and DL traffic
    ...                           Detach UE
    ...                           Common Test Teardown And Stop Capture Logs
