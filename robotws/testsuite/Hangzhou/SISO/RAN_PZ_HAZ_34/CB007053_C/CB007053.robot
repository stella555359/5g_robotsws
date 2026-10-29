# *** Settings ***
# Suite Setup      Run keywords    Check BTS Should Be Normal    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Documentation    author：Pengliang Wu
# ...              contact: pengliang.wu@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          ./Resources/CB007053_common.robot
# Variables         ./Resources/CB007053_para.py
# 
# *** Variables ***
# ${gNB_PB_ip}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
# ${gNB_PB_port}           ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
# ${L3_Call_cell_2}        NRCELL-2
# ${L3_Call_cell_7}        NRCELL-7
# ${Used_BBMOD}            BBMOD-1
# 
# *** Test Cases ***
# 
# [1]CB007053_06_BB cell set type CB007053-C combined mode
#     [Tags]    23R2    Trunk
#     Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
#     Setup Commission SCF    combine_mode=Combine_
#     ${L3_call_cell_list}    create list    ${L3_Call_cell_2}    ${L3_Call_cell_7}
#     L3 Call    nrcell_index_list=${L3_call_cell_list}    ul_throughput=30M    dl_throughput=200M    expected_ul=30    expected_dl=200    time=1m
#     [Teardown]   Run keywords    Run Keyword And Ignore Error    detach multi power ue    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# 
# [1]CB007053_14_BBMOD lock unlock after BTS power off power on with L3 call CB007053-C ABIO
#     [Tags]    23R2    Trunk
#     Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
#     Setup Commission SCF
#     Power Off pDU    pdu_ip=${gNB_PB_ip}    pdu_port=${gNB_PB_port}
#     Power On pDU    pdu_ip=${gNB_PB_ip}    pdu_port=${gNB_PB_port}
#     sleep    5min
#     Check BTS Should Be Normal
#     ${L3_call_cell_list}    create list    ${L3_Call_cell_2}
#     L3 Call    nrcell_index_list=${L3_call_cell_list}    ul_throughput=30M    dl_throughput=200M    expected_ul=30    expected_dl=200    time=1m
#     Lock and Unlock BBMOD    BBMOD_index=${Used_BBMOD}    file_path=${OUTPUT_DIR}/${TEST NAME}
#     L3 Call    nrcell_index_list=${L3_call_cell_list}    ul_throughput=30M    dl_throughput=200M    expected_ul=30    expected_dl=200    time=1m
#     [Teardown]   Run keywords    Run Keyword And Ignore Error    detach multi power ue    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# 
# [1]CB007053_16_Online Cell Addition Deletion with L3 call CB007053-C ABIO
#     [Tags]    23R2    Trunk
#     Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
#     Setup Commission SCF
#     ${L3_call_cell_list}    create list    ${L3_Call_cell_2}
#     L3 Call    nrcell_index_list=${L3_call_cell_list}    ul_throughput=30M    dl_throughput=200M    expected_ul=30    expected_dl=200    time=1m
#     NRCELL Deletion and Addition
#     L3 Call    nrcell_index_list=${L3_call_cell_list}    ul_throughput=30M    dl_throughput=200M    expected_ul=30    expected_dl=200    time=1m
#     [Teardown]   Run keywords    Run Keyword And Ignore Error    detach multi power ue    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
