*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup BTS env    scf=SCFC_1_TMO_nonSrsBm.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS24R3    tl-7_5_UTE5G402T2404
Resource          ./resources/CB013303_resource.robot

*** Variables ***
${EMIL_FLAG}    False
${PCELL_MAX_PA_VALUE}    80
${SCELL_MAX_PA_VALUE}    70

*** Test Cases ***
CB013303-SR-C2_16_UL SCell addition before associated nonGBR DRB setup when both of PCell and SCells activate actDrbBlerTargetForBR
    adjust pa all ports max value
    Block NRCell2

    ${step_1_info}    Catenate    step: attach to TDD PCell with associated 5qi-6 DRB, blind add FDD SCell,
    ...    start dl/ul traffic and make bler then check la from NRPDSCHBRLA-1 and NRPUSCHBRLA-1 on PCell and SCell
	log   ${step_1_info}    console=True
    # Ajust MCS Att    value=20
    adjust_pa_for_cell    cell_id=1    value=30
    adjust_pa_for_cell    cell_id=10    value=40
    prepare and attach UE with CGACT    get_spark_license=${True}
    start ul and dl traffic    send_traffic_ul=300M    send_traffic_dl=1000M
    adjust pa stepwise for cell    cell_id=10    start_value=40    end_value=${SCELL_MAX_PA_VALUE}
    # Ajust MCS Att Stepwise    start_value=30    end_value=${PCELL_MAX_PA_VALUE}
    adjust pa stepwise for cell    cell_id=1    start_value=30    end_value=${PCELL_MAX_PA_VALUE}
    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=1_attach_5qi6    cell_id=1,10,12    decode_flag=True
    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
    ...                      targetbler=0.05
    ...                      stepdown=0.5
    ...                      cell_ids=1,10,12
    ...                      mcstable=QAM256
    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
    ...                      targetbler=0.05
    ...                      stepdown=0.8
    ...                      cell_ids=1    # ,10
    ...                      mcstable=QAM256

    log    step: add 5qi8, la from NRPDSCHBRLA-2 and NRPUSCHBRLA-2    console=True
    add 5qi bearer    5qi=8
    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=2_add_5qi8    cell_id=1,10,12    decode_flag=True
    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
    ...                      targetbler=0.08
    ...                      stepdown=0.3
    ...                      cell_ids=1,10,12
    ...                      mcstable=QAM256
    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
    ...                      targetbler=0.08
    ...                      stepdown=0.5
    ...                      cell_ids=1    # ,10
    ...                      mcstable=QAM256

    log    step: release 5qi6 and 5qi8, la from cell level configuration    console=True
    del 5qi bearer    5qi=6
    del 5qi bearer    5qi=8
    ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=3_del_5qi6_5qi8    cell_id=1,10,12    decode_flag=True
    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
    ...                      targetbler=0.1
    ...                      stepdown=0.25
    ...                      cell_ids=1,10,12
    ...                      mcstable=QAM256
    Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
    ...                      targetbler=0.1
    ...                      stepdown=0.25
    ...                      cell_ids=1    # ,10
    ...                      mcstable=QAM256
    [Teardown]    Run Keywords    Stop UL And DL traffic
    ...                           Detach UE
    ...                           Unblock NRCell2
    ...                           Common Test Teardown And Stop Capture Logs

# *** Keywords ***
