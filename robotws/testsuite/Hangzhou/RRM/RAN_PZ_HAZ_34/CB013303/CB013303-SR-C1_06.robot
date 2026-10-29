*** Settings ***
Documentation
...    author: Jiang Huabao
...    contact: huabao.jiang@nokia-sbell.com
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
CB013303-SR-C1_06_SCell addition before associated non-CA eligible DRB setup when one of SCell deactivate actDrbBlerTargetForBR
    [Documentation]
    ...    testcase name:CB013303-SR-C1_06_SCell addition before associated non-CA eligible DRB setup
    ...    when PCell activate actDrbBlerTargetForBR and one of SCell deactivate actDrbBlerTargetForBR
    adjust pa all ports max value

    log    step: check peak throughput    console=True
    adjust pa for cell    cell_id=21    value=0
    # prepare and attach UE
	attach and check peak tput    cell_id=21

#	log    step: add 2scells + adjust PA, la from cell    console=True
#    adjust pa for cell    cell_id=11    value=0
#    adjust pa for cell    cell_id=31    value=0
#    # start ul and dl traffic    send_traffic_ul=200M    send_traffic_dl=1500M
#    adjust pa stepwise for cell    cell_id=21    start_value=20    end_value=60    step=5
#    adjust pa stepwise for cell    cell_id=11    start_value=20    end_value=56    step=5
#    adjust pa stepwise for cell    cell_id=31    start_value=20    end_value=60    step=5
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=1_attach    cell_id=11,21,31    decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64
#    ...                      cell_ids=11,21,31
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64
#    ...                      cell_ids=21
#
#    log    step: add 5qi8 with not FR1 CA eligible associated to P1, Pcell mapping P1, SCELL mapping cell level    console=True
#    add 5qi bearer    5qi=8
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=2_add_5qi8    cell_id=21,11,31    decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    ...                      cell_ids=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64
#    ...                      cell_ids=11,31
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM64
#    ...                      cell_ids=21
#
#
#    log    step: delete 5qi8, all cell mapping cell level    console=True
#    del 5qi bearer  5qi=8
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=3_del_5qi8    cell_id=21,11,31    decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64
#    ...                      cell_ids=11,21,31
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64
#    ...                      cell_ids=21
#
#    log    step: add 5qi3 associated to P2, Pcell mapping P2, SCELL mapping cell level   console=True
#    add 5qi bearer    5qi=3
#    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=4_add_5qi3    cell_id=21,11,31    decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.08
#    ...                      stepdown=0.3
#    ...                      mcstable=QAM64
#    ...                      cell_ids=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64
#    ...                      cell_ids=11,31
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.08
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    ...                      cell_ids=21
#
#
#    log    step: delete 5qi3, all cells apply cell level targert bler    console=True
#    del 5qi bearer  5qi=3
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=5_del_5qi3    cell_id=21,11,31    decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64
#    ...                      cell_ids=11,21,31
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      targetbler=0.1
#    ...                      stepdown=0.25
#    ...                      mcstable=QAM64
#    ...                      cell_ids=21

    [Teardown]    Run Keywords    Stop UL And DL traffic
    ...                           Detach UE
    ...                           Common Test Teardown And Stop Capture Logs
