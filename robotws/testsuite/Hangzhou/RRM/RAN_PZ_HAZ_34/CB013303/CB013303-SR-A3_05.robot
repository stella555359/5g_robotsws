*** Settings ***
Documentation
...    author: Zhong rebecca
...    contact: rebecca.zhong@nokia-sbell.com
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
CB013303-SR-A3_05_Scheduling of multiple 5G UEs with multiple non-GBR and GBR bearers using DRB specific BLER target in DL and UL on TDD FR1 cell
	adjust pa all ports max value

    log    step: UE1 attach with associated 5qi-6 DRB, check peak throughput   console=True
    adjust_pa_for_cell    cell_id=21    value=0
    # prepare and attach UE
    # start ul and dl traffic    send_traffic_ul=200M    send_traffic_dl=600M
	attach and check peak tput    cell_id=21

#    log    step: adjust PA, check la from NRPDSCHBRLA-1    console=True
#    start to capture gnb ttitrace    tag=1_attach_5qi6    cell_id=21
#    adjust pa stepwise for cell    cell_id=21    start_value=20    end_value=60
#    ${ttitrace_log_path}    stop capture gnb ttitrace   tag=1_attach_5qi6   decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM64
#
#    log    step: add 5qi-3, check la from BRLA-2    console=True
#    add 5qi bearer    5qi=3
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=2_add_5qi3     cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.08
#    ...                      stepdown=0.3
#    ...                      mcstable=QAM64
#    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.08
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#
#    log    step: add 5qi-9, check la from BRLA-2 no changes    console=True
#    add 5qi bearer    5qi=9
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=3_add_5qi9    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.08
#    ...                      stepdown=0.3
#    ...                      mcstable=QAM64
#    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.08
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#
#    log    step: del 5qi-3, check la from BRLA-1    console=True
#    del 5qi bearer    5qi=3
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=4_del_5qi3    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM64
#
#    log    step: del 5qi-9, check la from BRLA-1 no changes    console=True
#    del 5qi bearer    5qi=9
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=5_del_5qi9    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM64
#
#    log    step: UE2 attach with associated 5qi-6 DRB, start dl/ul traffic and make bler, la from BRLA-1    console=True
#    adjust_pa_for_cell    cell_id=21    value=0
#    prepare and attach UE    ue_id=2
#    start ul and dl traffic    ue_id=2    send_traffic_ul=200M    send_traffic_dl=600M
#    start to capture gnb ttitrace    tag=ue2_attach_5qi6    cell_id=21
#    adjust pa stepwise for cell    cell_id=21    start_value=20    end_value=60
#    ${ttitrace_log_path}    stop capture gnb ttitrace   tag=ue2_attach_5qi6   decode_flag=True
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      rnti=${UE2_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      rnti=${UE2_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM64
#
#    log    step: ue1 add 5qi-3 again, check la from BRLA-2    console=True
#    add 5qi bearer    5qi=3    ue_id=1
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=ue1_add_5qi3     cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.08
#    ...                      stepdown=0.3
#    ...                      mcstable=QAM64
#    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.08
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#
#
#    log    step: ue2 add 5qi-4 again, check la from BRLA-1    console=True
#    add 5qi bearer    5qi=4    ue_id=2
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=ue2_add_5qi4     cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      rnti=${UE2_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      rnti=${UE2_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM64
#
#
#    delta commission parameters    ${DELTA_A3_05_1}
#
#    log    step: UE1 del 5qi-3, check la from old BRLA-1    console=True
#    del 5qi bearer    5qi=3    ue_id=1
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=ue1_del_5qi3    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      rnti=${UE1_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM64
#
#    delta commission parameters    ${DELTA_A3_05_2}
#
#    log    step: UE2 del 5qi-4, check la from old BRLA-1    console=True
#    del 5qi bearer    5qi=4    ue_id=2
#    ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=ue2_del_5qi4    cell_id=21
#    check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#    ...                      rnti=${UE2_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.5
#    ...                      mcstable=QAM64
#    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#    ...                      rnti=${UE2_RNTI}
#    ...                      targetbler=0.05
#    ...                      stepdown=0.8
#    ...                      mcstable=QAM64


    [Teardown]    Case Teardown


*** Keywords ***
Case Teardown
    Stop UL And DL traffic    ue_id=1
#    Stop UL And DL traffic    ue_id=2
    Detach UE    ue_id=1
#    Detach UE    ue_id=2
    Common Test Teardown And Stop Capture Logs


