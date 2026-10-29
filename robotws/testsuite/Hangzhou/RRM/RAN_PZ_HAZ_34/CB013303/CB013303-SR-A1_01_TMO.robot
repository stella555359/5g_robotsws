# *** Settings ***
# Documentation
# ...    author: Zhang Yin
# ...    contact: yin.zhang@nokia-sbell.com
# ...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
# Suite Setup       Common Suite Setup And Setup BTS env
# Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
# Test Setup        Common Test Setup And Start To Capture Logs
# Test Teardown     Common Test Teardown And Stop Capture Logs
# Force Tags        release-SBTS24R3    tl-7_5_UTE5G402T2411
# Resource          ./resources/CB013303_resource.robot
# 
# *** Variables ***
# ${EMIL_FLAG}    False
# 
# *** Test Cases ***
# CB013303_SR_A1_01_Scheduling of one 5G UE with one non-GBR bearer using DRB specific BLER target in DL on TDD FR1 cell
#     delta commission parameters    ${DELTA_A1_01_1}
#     adjust_pa_all_ports_max_value
# 
#     log    step: attach + dl traffic, bler should be small    console=True
#     adjust_pa_for_cell    cell_id=1    value=0
#     Prepare and attach UE    get_spark_license=False
#     start dl traffic    send_traffic=600M
# 
#     log    step: adjust PA, check la from NRPDSCHBRLA-1    console=True
#     start to capture gnb ttitrace    tag=2_adjust_pa    cell_id=1
#     adjust pa stepwise for cell    cell_id=1    start_value=20    end_value=80
#     ${ttitrace_log_path}    stop capture gnb ttitrace   tag=2_adjust_pa   decode_flag=True
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.5
#     ...                      mcstable=QAM256
# 
#     log    step: add 5qi9, check la not change    console=True
#     add 5qi bearer    5qi=9
#     ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=3_add_5qi9    cell_id=1
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.5
#     ...                      mcstable=QAM256
# 
#     log    step: del 5qi6, check la from cell    console=True
#     del 5qi bearer    5qi=6
#     ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=4_del_5qi6    cell_id=1
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25
#     ...                      mcstable=QAM256
# 
#     log    step: add 5qi8, check la from NRPDSCHBRLA-2    console=True
#     add 5qi bearer    5qi=8
#     ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=5_add_5qi8    cell_id=1
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.08
#     ...                      stepdown=0.3
#     ...                      mcstable=QAM256
# 
#     log    step: delete NRDRB-6:nrPdschBRLaDN and change NRPDSCHBRLA-2, check la no change    console=True
#     delta commission parameters    ${DELTA_A1_01_2}
#     ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=6_online_change    cell_id=1
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.08
#     ...                      stepdown=0.3
#     ...                      mcstable=QAM256
# 
#     log    step: del 5qi8 and add again, check la from new NRPDSCHBRLA-2    console=True
#     del 5qi bearer    5qi=8
#     add 5qi bearer    5qi=8
#     ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=7_del_and_add_5qi8    cell_id=1
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.12
#     ...                      stepdown=0.6
#     ...                      mcstable=QAM256
# 
#     log    step: attach UE,add 5qi8 and start traffic, check la from new NRPDSCHBRLA-2    console=True
#     attach UE and add 5QI8 and start dl traffic
#     ${ttitrace_log_path}    capture gnb ttitrace for a while    tag=8_reattach_and_5qi8    cell_id=1
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.12
#     ...                      stepdown=0.6
#     ...                      mcstable=QAM256
# 
#     [Teardown]    Run Keywords    Stop DL traffic
#     ...                           Detach UE
#     ...                           Common Test Teardown And Stop Capture Logs
# 
# *** Keywords ***
# attach UE and add 5QI8 and start dl traffic
#     Stop DL traffic
#     adjust_pa_for_cell    cell_id=1    value=0
#     Prepare and attach UE    get_spark_license=False
#     add 5qi bearer    5qi=8
#     start dl traffic    send_traffic=600M
#     adjust pa stepwise for cell    cell_id=1    start_value=20    end_value=60
# 
# 
# 
