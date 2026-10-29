# *** Settings ***
# Suite Setup       Common Suite Setup And Setup BTS env
# Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
# Test Setup        Common Test Setup And Start To Capture Logs
# Test Teardown     Common Test Teardown And Stop Capture Logs
# Force Tags        team-VRF3_8    owner-lixia.zhou    release-SBTS24R3    tl-7_5_UTE5G402T2403
# Resource          ./resources/CB013303_resource.robot
# 
# *** Variables ***
# ${EMIL_FLAG}    False
# 
# *** Test Cases ***
# CB013303-SR-C1_03_SCell addition before associated nonGBR DRB setup when both of PCell and SCells activate actDrbBlerTargetForBR
#     adjust_pa_all_ports_max_value
#     Block other cells
#     log    step: attach with 3cc + dlul traffic    console=True
#     adjust_pa_for_cell    cell_id=12    value=0
#     delta commission parameters    ${DELTA_C1_03_1}
#     Prepare and attach UE
#     Unblock NRCell10
#     Unblock NRCell11
#     Prepare and attach UE
#     Start UL And DL traffic    send_traffic_ul=200M    send_traffic_dl=1000M
#     adjust pa for cell    cell_id=12    value=60
#     ${ttitrace_log_path}    Capture Gnb Ttitrace For A While    tag=1_attach    cell_id=12,10,11     decode_flag=True
#     Check Link Adaptation    
#     ...                      ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25    
#     ...                      cell_ids=12,10,11
#     ...                      mcstable=QAM256
#     Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25
#     ...                      cell_ids=12
#     ...                      mcstable=QAM256
#     
#     log    step: add 5qi8, use DRB level LA with profile1    console=True
#     add 5qi bearer    5qi=8
#     ${ttitrace_log_path}    Capture Gnb Ttitrace For A While    tag=add_5qi8    cell_id=12,10,11     decode_flag=True
#     Check Link Adaptation    
#     ...                      ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.5    
#     ...                      cell_ids=12,10,11
#     ...                      mcstable=QAM256
#     Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.8
#     ...                      cell_ids=12
#     ...                      mcstable=QAM256
#     
#     log    step: del 5qi8, keep same because no linked profile    console=True
#     del 5qi bearer    5qi=8
#     ${ttitrace_log_path}    Capture Gnb Ttitrace For A While    tag=del_5qi8    cell_id=12,10,11     decode_flag=True
#     Check Link Adaptation    
#     ...                      ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25    
#     ...                      cell_ids=12,10,11
#     ...                      mcstable=QAM256
#     Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25
#     ...                      cell_ids=12
#     ...                      mcstable=QAM256
# 
#     #[Teardown]    Run Keywords    Stop UL And DL traffic
#     #...                           Detach UE
#     #...                           Common Test Teardown And Stop Capture Logs
# 
# *** Keywords ***
# Block other cells
#     Block NRCell1
#     Block NRCell2
#     Block NRCell10
#     Block NRCell11
#     Block NRCell13
# 
# 
#    