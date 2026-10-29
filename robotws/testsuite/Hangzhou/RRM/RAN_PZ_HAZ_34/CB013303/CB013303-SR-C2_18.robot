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
# CB013303-SR-C2_18_UL SCell addition after associated nonGBR DRB setup when PCell deactivate actDrbBlerTargetForBR
#     adjust_pa_all_ports_max_value
#     Block other cells
#     log    step: attach with 2cc + dlul traffic, modify scell FAF true,use drbLevel la; modify pcell FAF false,use cellLevel la     console=True
#     adjust_pa_for_cell    cell_id=2    value=0
#     adjust_pa_for_cell    cell_id=10    value=0
#     adjust_pa_for_cell    cell_id=1    value=0
#     delta commission parameters    ${DELTA_C2_18_1}
#     Prepare and attach UE
#     Start UL And DL traffic    send_traffic_ul=1000M    send_traffic_dl=1000M
#     adjust pa for cell    cell_id=2    value=40
#     adjust pa for cell    cell_id=10    value=65
#     ${ttitrace_log_path}    Capture Gnb Ttitrace For A While    tag=1_attach    cell_id=10,2     decode_flag=True
#     Check Link Adaptation    
#     ...                      ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.5    
#     ...                      cell_ids=2
#     Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.05
#     ...                      stepdown=0.8
#     ...                      cell_ids=2
#     Check Link Adaptation    
#     ...                      ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25   
#     ...                      cell_ids=10
#     Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25
#     ...                      cell_ids=10
#     log    step: del 5qi6, both use cell level la in dl and ul    console=True
#     del 5qi bearer    5qi=6
#     ${ttitrace_log_path}    Capture Gnb Ttitrace For A While    tag=del_5qi6    cell_id=10,2     decode_flag=True
#     Check Link Adaptation    
#     ...                      ${ttitrace_log_path}/ttiTrace_dl.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25    
#     ...                      cell_ids=10,2
#     Check Link Adaptation    ${ttitrace_log_path}/ttiTrace_ul.csv
#     ...                      targetbler=0.1
#     ...                      stepdown=0.25
#     ...                      cell_ids=10,2
#     [Teardown]    Run Keywords    Stop UL And DL traffic
#     ...                           Detach UE
#     ...                           Unblock other cells
#     ...                           Common Test Teardown And Stop Capture Logs
# 
# *** Keywords ***
# Block other cells
#     Block NRCell1
#     Block NRCell11
#     Block NRCell12
#     Block NRCell13
# 
# Unblock other cells
#     Unblock NRCell1
#     Unblock NRCell11
#     Unblock NRCell12
#     Unblock NRCell13
# 
# 
#    