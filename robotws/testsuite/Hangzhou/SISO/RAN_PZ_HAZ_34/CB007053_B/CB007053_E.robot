# *** Settings ***
# Suite Setup       Run keywords     Setup Commission SCF_CB007053_08    AND    robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# Documentation    author：Zhouqun Wang
# ...              contact: zhouqun.wang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
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
# #7053-E
# [1]CB007053_08_BB_cell_set_type_CB007053-E_combined_mode
#     [Tags]    23R2
#     [Setup]
#     Check BTS Should Be Normal
#     Modify Common parameter via Coam    input_list=${GNB_MODIFY_Parameter_08}
#     attach power ue
#     start power ue traffic ul and dl      ul_throughput=60M    dl_throughput=200M
#     Check power ue Tput    ul_throughput=30    dl_throughput=100
#     stop multi power ue traffic ul and dl
#     [Teardown]   run keywords     detach multi power ue    AND    CI_interface.Common Case Teardown
# 
# *** Keywords ***
