# *** Settings ***
# Suite Setup      Run keywords    Setup Commission SCF    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Documentation    author：Shanshan Zhang
# ...              contact: shanshan.zhang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          ./Resources/CB007053_common.robot
# Variables         ./Resources/CB007053_para.py
# 
# *** Variables ***
# ${GNB_PB_ASIK_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
# ${GNB_PB_ASIK_PORT}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
# 
# 
# *** Test Cases ***
# [1]CB007053_03_3 BB cell set type CB007053-B supports up to 3 x 100MHz 4T4R or 2T2R NR TDD FR1 cells in half ASOE
#     [Tags]    23R2
#     [Setup]  Check BTS Should Be Normal
# #    Modify Common parameter via Coam    input_list=${GNB_MODIFY_Parameter_03}
#     attach power ue
#     start power ue traffic ul and dl      ul_throughput=30M    dl_throughput=200M
#     Check power ue Tput    ul_throughput=30    dl_throughput=200
#     stop multi power ue traffic ul and dl
#     [Teardown]   run keywords     detach multi power ue    AND    CI_interface.Common Case Teardown
# 
# 
# [1]CB007053_13_RF lock unlock after BTS power off power on with L3 call CB007053-B ASOE
#     [Tags]    23R2
#     [Setup]  Check BTS Should Be Normal
#     Run Keyword And Ignore Error    robot_common_operations.Common case setup
#     Power Off pDU     pdu_ip=${GNB_PB_ASIK_IP}    pdu_port=${GNB_PB_ASIK_PORT}
#     sleep    5s
#     Power On pDU      pdu_ip=${GNB_PB_ASIK_IP}    pdu_port=${GNB_PB_ASIK_PORT}
#     Wait Until Keyword Succeeds    15min    30s    Check BTS Should Be Normal
#     run keyword and continue on failure    All RU Locked and check status
#     run keyword and continue on failure    All RU UnLocked and check status
#     Wait Until Keyword Succeeds    15min    30s    Check BTS Should Be Normal
#     attach power ue
#     start power ue traffic ul and dl      ul_throughput=30M    dl_throughput=200M
#     Check power ue Tput    ul_throughput=10    dl_throughput=100
#     stop multi power ue traffic ul and dl
#     [Teardown]   run keywords     detach multi power ue    AND    CI_interface.Common Case Teardown
# 
# [1]CB007053_15_Online Cell Addition Deletion with L3 call CB007053-B ASOE
#     [Tags]    23R2
#     [Setup]  Check BTS Should Be Normal
#     Start wireshark capture from gNB     filename=CB007053_15
#     attach power ue
#     start power ue traffic ul and dl      ul_throughput=30M   dl_throughput=200M
#     Online Cell addition deletion
#     Check power ue Tput    ul_throughput=10    dl_throughput=100    time=1m
#     Stop wireshark capture from gNB     filename=CB007053_15
#     Check wireshark log data should be empty    pacp_filename=CB007053_15    txt_filename=CB007053_15    filter=f1ap
#     ...    command=grep UEContextReleaseComplete
#     [Teardown]   run keywords     detach multi power ue    AND    CI_interface.Common Case Teardown
# 
# *** Keywords ***
