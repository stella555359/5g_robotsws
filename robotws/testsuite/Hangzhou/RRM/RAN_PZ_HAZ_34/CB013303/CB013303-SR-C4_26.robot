*** Settings ***
Documentation
...    author: Xiang Kang
...    contact: kang.xiang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup BTS env    scf=SCFC_1_SANSA.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS24R3    tl-7_5_UTE5G402T2405
Resource          ./resources/CB013303_resource.robot

*** Variables ***
${EMIL_FLAG}    False

*** Test Cases ***
CB013303-SR-C4_26_SgNB addition with multiple associated non-GBR DRBs with NSA 3x UE on TDD FR1 cell
	log    step: check peak throughput on cell11
	adjust_pa_all_ports_max_value
	attach and check peak tput    cell_id=11
#	Stop UL And DL traffic
#	Detach UE
#
#    log    step: attach to LTE cell    console=True
#	adjust_pa_all_ports_max_value
#    adjust_pa_for_cell    cell_id=33    value=20
#    adjust_pa_for_cell    cell_id=21    value=20
#    Prepare and attach UE    attach_mode=5G_NSA
#
#    log    step: add qci8 and send traffic    console=True
#    add qci bearer    qci=8
#    start ul and dl traffic    send_traffic_ul=200M    send_traffic_dl=600M    ue_mode=NSA
#
#    log    step: adjust PA, check la from NRPDSCHBRLA-1 and NRPUSCHBRLA-1    console=True
#    start to capture gnb ttitrace    tag=2_adjust_pa    cell_id=21
#    adjust pa stepwise for cell    cell_id=21    start_value=20    end_value=50
#    ${ttitrace_log_path}    stop capture gnb ttitrace   tag=2_adjust_pa   decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    ...                      ibler=0%-7%
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM64
#
#    log    step: del qci6, check la from NRPDSCHBRLA-2 and NRPUSCHBRLA-2    console=True
#    del qci bearer    qci=6
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=3_del_qci6    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.08
#    ...                      stepdown=0.3
#    ...                      mcstable=QAM64
#    ...                      ibler=6%-10%
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.08
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#
#    log    step: del qci8 and check la from cell    console=True
#    del qci bearer    qci=8
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=4_del_qci8    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64
#    ...                      ibler=8%-12%
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64

    [Teardown]    Run Keywords    Stop UL And DL traffic
    ...                           Detach UE
    ...                           Common Test Teardown And Stop Capture Logs
