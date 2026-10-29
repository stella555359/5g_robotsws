# *** Settings ***
# Suite Setup       Run keywords    Setup Commission SCF    AND    robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Documentation    author：Zhouqun Wang
# ...              contact: zhouqun.wang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# #Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/xiaomi.robot
# Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007053_E/Resources/CB007053_common.robot
# Variables         testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007053_E/Resources/CB007053_para.py
# 
# *** Variables ***
# ${GNB_PB_ASIK_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
# ${GNB_PB_ASIK_PORT}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
# 
# 
# *** Test Cases ***
# [1]CB007053_07_4_BB_cell_set_type_CB007053-E_supports_up_to_4x100MHz_4T4R_or_2T2R_NR_TDD_FR1_cells_in_half_ASOE
#     [Tags]    23R2
#     [Setup]
#     Check BTS Should Be Normal
#     Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_07}
#     Xiaomi12 Attach and Verify attach
#     start power ue traffic ul and dl      ul_throughput=60M      dl_throughput=150M
#     Check xiaomi UE throughput      ul_throughput=30    dl_throughput=100
#     stop multi power ue traffic ul and dl
#     [Teardown]   run keywords     detach multi power ue    AND    CI_interface.Common Case Teardown
# 
# [1]CB007053_22_Online_Cell_Addition_Deletion_with_L3_call_CB007053-E_ASOE
#     [Tags]    23R2
#     [Setup]
#     Check BTS Should Be Normal
#     Start wireshark capture from gNB     filename=CB007053_22
#     Xiaomi12 Attach and Verify attach
#     start power ue traffic ul and dl      ul_throughput=30    dl_throughput=100
#     Online Cell addition deletion
#     Check xiaomi UE throughput      ul_throughput=30    dl_throughput=100
#     Stop wireshark capture from gNB     filename=CB007053_22
#     Check wireshark log data should be empty    pacp_filename=CB007053_22    txt_filename=CB007053_22    filter=f1ap
#     ...    command=grep UEContextReleaseComplete
#     [Teardown]   run keywords     detach multi power ue    AND    CI_interface.Common Case Teardown
# 
# 
# 
# *** Keywords ***
# Get all xiaomi12 pointer variable
#     Set Suite Variable    ${home}    3
#     Set Suite Variable    ${airplane}    932 1633
#     Set Suite Variable    ${close_task}   717 2920
#     Set Suite Variable    ${Home_button}    3
#     Set Suite Variable    ${swipe}    1300 2700 1300 2700
#     Set Suite Variable    ${open_iperf_location}    500 2050
#     Set Suite Variable    ${iperf_button}    730 300
#     Set Suite Variable    ${iperf_space}    800 550
#     Set Suite Variable    ${5G}    900 960
#     Set Suite Variable    ${ue_type}    xiaomi
#     Set Suite Variable    ${brand}    xiaomi
# 
# Xiaomi12 Attach and Verify attach
#    [Arguments]    ${ue_index}=${0}
#    unlock the screen and click airplane    ue_index=${0}
# #   Start DL date      dl_throughput=${dl_data_xiaomi}    ue_index=${0}
# #   ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60s    ignore_time=5s
# #   ${cell_list}    create list    ${cell_id}
# #   power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
# #   ...    cells=${cell_list}    target_throughput=${dltarget_tp}
# 
# unlock the screen and click airplane
#     [Documentation]   Check UE if need awake
#     [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cygwin
#     Get all xiaomi12 pointer variable
#     csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
#     ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
#     ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
#     csn.send_command   connection=${connection}
#     ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
#     sleep   2s
#     ${output}   csn.read_output   connection=${connection}
#     Run Keyword If   ${output.lower().count('mawake=false')}>0
#     ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
#     csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
#     sleep    2s
#     csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
#     sleep   2s
#     csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
#     sleep   4s
#     csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}
#     Commercial_mobile_phone_adb_common_keywords.Commercial UE click AIRPLANE once      serial_number=90c99bee    Home_button=${Home_button}
#     ...    swipe=${swipe}    airplane=${airplane}       close_task=${close_task}
#     [Teardown]
