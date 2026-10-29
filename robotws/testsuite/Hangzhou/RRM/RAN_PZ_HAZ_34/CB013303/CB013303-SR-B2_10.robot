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
# CB013303-SR-B2_10_Check NRPDSCHBRLA and NRPUSCHBRLA counters for DL and UL transmissions using service aware BLER target
#     [Documentation]
#     ...    casename: CB013303-SR-B2_10_Check NRPDSCHBRLA and NRPUSCHBRLA counters for DL and UL transmissions
#     ...    using service aware BLER target during High reliability DRB is active
# 
#     clear counter files    wait=False
#     adjust pa all ports max value
# 
#     log    step: attach with 5qi5 6 7 + ul dl traffic + adjust PA, target bler apply BR P1, BR P1 related counter increse   console=True
#     adjust pa for cell    cell_id=3    value=0
#     prepare and attach UE
#     start ul and dl traffic    send_traffic_ul=200M    send_traffic_dl=600M
#     adjust pa for cell    cell_id=3    value=50
#     capture gnb ttitrace for a while    tag=1_attach    cell_id=3    decode_flag=False
#     check counters    ${CELL3_BR_PRFL1_INCREASE}
# 
#     log    step: add 5qi8, target bler apply HR P1, HR P1 lowse counters increase, HR P2 lowse Not increse    console=True
#     add 5qi bearer    5qi=8
#     adjust pa for cell    cell_id=3    value=60
#     clear counter files    wait=False
#     capture gnb ttitrace for a while    tag=2_add_5qi8    cell_id=3    decode_flag=False
#     ${counters}    combine lists
#     ...    ${CELL3_HR_PRFL1_INCREASE}        ${CELL3_HR_PRFL2_NOT_INCREASE}
#     ...    ${CELL3_BR_PRFL1_NOT_INCREASE}    ${CELL3_BR_PRFL2_NOT_INCREASE}
#     check counters    ${counters}
# 
#     log    step: turn up the attenuation make the lamode change from hr to br, apply BR P1 and P1 counters increase    console=True
#     adjust pa stepwise for cell    cell_id=3    start_value=63    end_value=76    step=3    interval=5
#     clear counter files    wait=False
#     capture gnb ttitrace for a while    tag=3_HR_BR    cell_id=3    decode_flag=False
#     ${counters1}    combine lists
#     ...    ${CELL3_BR_PRFL1_INCREASE}    ${CELL3_BR_PRFL2_NOT_INCREASE}
#     ...    ${CELL3_HR_PRFL2_NOT_INCREASE}    ${CELL3_HR_PRFL1_NOT_INCREASE}
#     check counters    ${counters1}
# 
#     log    step: turn down the attenuation make the lamode recovery from br to hr, apply HR P1 and P1 counter increase    console=True
#     adjust pa stepwise for cell    cell_id=3    start_value=50    end_value=60    step=5    interval=5
#     clear counter files    wait=False
#     capture gnb ttitrace for a while    tag=4_BR_HR    cell_id=3    decode_flag=False
#     check counters    ${CELL3_HR_PRFL1_INCREASE}
# 
#     log    step: del 5qi8 ,target bler apply BR P1, cell level lowse BR counter Not increase    console=True
#     adjust pa for cell    cell_id=3    value=50
#     clear counter files    wait=False
#     capture gnb ttitrace for a while    tag=4_BR_HR    cell_id=3    decode_flag=False
#     check counters    ${CELL3_BR_CELLLEVEL_NOT_INCREASE}
# 
#     [Teardown]    Run Keywords    Stop UL And DL traffic
#     ...                           Detach UE
#     ...                           Common Test Teardown And Stop Capture Logs
# 
# *** Keywords ***
# 
