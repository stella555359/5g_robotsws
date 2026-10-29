# *** Settings ***
# Suite Setup      robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Documentation    author：shushu huang
# ...              contact: shushu.huang@nokia-sbell.com
# ...              squad group: mmw_SG_03
# 
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          ./Resources/CB008953_common.robot
# Variables         ./Resources/CB008953_para.py
# 
# *** Variables ***
# ${GNB_PB_ASIK_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
# ${GNB_PB_ASIK_PORT}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
# 
# 
# *** Test Cases ***
# [1]CB008953_A_8_NR_TDD_CPRI_configuration_4_radios_with_2_NR_carriers_per_radio_with_ASOE_09
#     [Setup]  Check BTS Should Be Normal
#     Scf commission and wait on-air    scf_name=SCF_CB008953_config8.xml
#     attach power ue
#     start power ue traffic ul and dl      ul_throughput=30M    dl_throughput=200M
#     Check power ue Tput    ul_throughput=30    dl_throughput=200
#     stop multi power ue traffic ul and dl
#     [Teardown]   run keywords     detach multi power ue    AND    CI_interface.Common Case Teardown
# 
# 
# 
# *** Keywords ***
