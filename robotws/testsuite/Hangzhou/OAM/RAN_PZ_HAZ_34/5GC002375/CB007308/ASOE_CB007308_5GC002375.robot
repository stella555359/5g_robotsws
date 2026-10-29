# *** Settings ***
# Documentation  Author: Lin Zhe
# ...            Contact: zhe.1.lin@nokia-sbell.com
# Resource  .${/}..${/}resources${/}case_steps.robot
# Variables   .${/}..${/}..${/}libraries${/}global_vars.py
# Resource   .${/}..${/}resources${/}decode.robot
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup       Suite Setup for CB007308
# Suite Teardown    Suite Teardown for CB007308
# 
# 
# Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASKEY_SA_ASOEB1_3xAZQJ
#     ...   SBTS00    CRT_UTE    PY36
# 
# *** Variables ***
# ${ASIK_EIF2_VLAN1655}    192.168.100.56
# ${ASIK_EIF3_VLAN1655}    192.168.100.57
# 
# *** Test Cases ***
# [1]CB007308-5G-AE_003_CP_Syscom_messages_can_be_activated_and_deactivated_via_Emil_for_Classical_BTS_on_ASOE_EIF2_port
# 
#     [Tags]   AUTHOR_zhe.1.lin@nokia-sbell.com
#     [Timeout]    90min
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#                ...   AND    Add Interface and Backup SCF    port=EIF2
#                ...   AND    Cplane and Uplane log Setup    operation=sleep    vlan_ip=${ASIK_EIF2_VLAN1655}
#     Check Trace File Recieved    file_list=${emil_log_file_list}    host=${ASIK_EIF2_VLAN1655}
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1]CB007308-5G-AE_004_U-Plane_Trace_by_TTI_Trace_Analyses_Tool_to_Decode_for_Classical_BTS_on_ASOE_EIF2_port
#     [Tags]   AUTHOR_zhe.1.lin@nokia-sbell.com
#     [Timeout]    60 min
#     [Setup]   robot_common_operations.Common Case Setup
#     Check Trace File Recieved    file_list=${sherpa_log_file_list}    host=${ASIK_EIF2_VLAN1655}
#     [Teardown]    run keywords    Cplane and Uplane log Teardown
#      ...   AND    Delete Interface by perform SCF
#      ...   AND    robot_common_operations.Common Case Teardown
# 
# [1]CB007308-5G-AE_005_CP_Syscom_messages_can_be_activated_and_deactivated_via_Emil_for_Classical_BTS_on_ASOE_EIF3_port
# 
#     [Tags]   AUTHOR_zhe.1.lin@nokia-sbell.com
#     [Timeout]    90min
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#                ...   AND    Add Interface and Backup SCF    port=EIF3
#                ...   AND    Cplane and Uplane log Setup    operation=sleep    vlan_ip=${ASIK_EIF3_VLAN1655}
#     Check Trace File Recieved    file_list=${emil_log_file_list}    host=${ASIK_EIF3_VLAN1655}
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1]CB007308-5G-AE_006_U-Plane_Trace_by_TTI_Trace_Analyses_Tool_to_Decode_for_Classical_BTS_on_ASOE_EIF3_port
#     [Tags]   AUTHOR_zhe.1.lin@nokia-sbell.com
#     [Timeout]    60 min
#     [Setup]    robot_common_operations.Common Case Setup
#     Check Trace File Recieved    file_list=${emil_log_file_list}    host=${ASIK_EIF3_VLAN1655}
#     [Teardown]    run keywords    Cplane and Uplane log Teardown
#                   ...   AND    Delete Interface by perform SCF
#                   ...   AND    robot_common_operations.Common Case Teardown