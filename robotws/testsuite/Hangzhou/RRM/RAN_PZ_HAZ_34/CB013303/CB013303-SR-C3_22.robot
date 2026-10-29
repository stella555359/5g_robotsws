# *** Settings ***
# Documentation
# ...    author: Jiang Huabao
# ...    contact: huabao.jiang@nokia-sbell.com
# ...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
# Suite Setup       Common Suite Setup And Setup BTS env
# Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
# Test Setup        Common Test Setup And Start To Capture Logs
# Test Teardown     Common Test Teardown And Stop Capture Logs
# Force Tags        release-SBTS24R3    tl-7_5_UTE5G402T2406
# Resource          ./resources/CB013303_resource.robot
# 
# *** Variables ***
# ${EMIL_FLAG}    False
# 
# *** Test Cases ***
# CB013303_SR_C3_22_Intra-DU HO with multiple associated non-GBR DRBs in TDD FR1 cell
#     adjust_pa_all_ports_max_value
# 
#     log    step: attach with 5qi5 6 7 + add 5qi8 + uldl traffic, bler apply P1    console=True
#     adjust_pa_for_cell    cell_id=1    value=0
#     Prepare and attach UE
#     add 5qi bearer    5qi=8
#     start ul and dl traffic    send_traffic_ul=200M    send_traffic_dl=500M
#     adjust pa for cell    cell_id=1    value=65
#     ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=1_attachAdd5qi8    cell_id=1    decode_flag=True
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.5
#     ...                      mcstable=QAM64
#     ...                      cell_ids=1
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.8
#     ...                      mcstable=QAM64
#     ...                      cell_ids=1
# 
#     log    step: ue ho from cell1 to cell3, bler still aplly P1    console=True
#     adjust pa for cell    cell_id=3    value=60
#     adjust pa stepwise for cell    cell_id=1    start_value=65    end_value=80    step=5    interval=5
#     ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=2_HO    cell_id=3    decode_flag=True
#     Get UE RNTI
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.5
#     ...                      mcstable=QAM64
#     ...                      cell_ids=3
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.8
#     ...                      mcstable=QAM64
#     ...                      cell_ids=3
# 
#     log    step: release 5qi6, bler apply P2 which associated 5qi8    console=True
#     del 5qi bearer  5qi=6
#     ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=3_del5qi6   cell_id=3    decode_flag=True
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.08
#     ...                      stepdown=0.3
#     ...                      mcstable=QAM64
#     ...                      cell_ids=3
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.08
#     ...                      stepdown=0.5
#     ...                      mcstable=QAM64
#     ...                      step_tolerance=90%
#     ...                      cell_ids=3
# 
#     log    step: release 5qi8, bler apply cell level    console=True
#     del 5qi bearer  5qi=8
#     ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=4_del5qi8   cell_id=3    decode_flag=True
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25
#     ...                      mcstable=QAM64
#     ...                      cell_ids=3
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25
#     ...                      mcstable=QAM64
#     ...                      step_tolerance=90%
#     ...                      cell_ids=3
# 
#     log    step: lock unlock cell3 and ue attach to cell3, bler apply P1
#     adjust pa for cell    cell_id=1    value=127
#     Block NRCell3
#     Unblock NRCell3
#     Prepare and attach UE
#     start ul and dl traffic    send_traffic_ul=200M    send_traffic_dl=500M
#     adjust pa for cell    cell_id=3    value=60
#     ${ttitrace_log_path}    capture gnb ttitrace for a while   tag=1_attach    cell_id=3    decode_flag=True
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.5
#     ...                      mcstable=QAM64
#     ...                      cell_ids=3
#     check link adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.8
#     ...                      mcstable=QAM64
#     ...                      cell_ids=3
# 
#     [Teardown]    Run Keywords    Stop UL and DL traffic
#     ...                           Detach UE
#     ...                           Common Test Teardown And Stop Capture Logs
# 
# *** Keywords ***
# 
# 
# 
