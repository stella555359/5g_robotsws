# 
# *** Settings ***
# Documentation
# ...    author: Han Ruiyu
# ...    contact: ruiyu.han@nokia-sbell.com
# ...    squad group: NSB MN 5G&SC 5G Pz Verf CN 07 SG
# Library    OperatingSystem
# Library   Collections
# Library   String
# Library     ..${/}libraries${/}snapshot_files.py
# Variables          ..${/}libraries${/}dcap_server_1.py
# Variables          ..${/}libraries${/}sherpa_server_1.py
# Library   taf.transport.ssh   WITH NAME   csn
# Resource           ..${/}resources${/}emil${/}emil.robot
# Resource           ..${/}resources${/}dcap.robot
# Resource           ..${/}resources${/}test_port.robot
# Resource   ..${/}resources${/}case_steps.robot
# Variables   ..${/}..${/}libraries${/}global_vars.py
# Resource   ..${/}resources${/}decode.robot
# Resource   ..${/}resources${/}tshark.robot
# Resource   ..${/}resources${/}sherpa.robot
# Resource   ..${/}resources${/}emil${/}emil.robot
# Resource   ..${/}resources${/}emil${/}test_emil.robot
# Resource   ..${/}resources${/}snapshot.robot
# Resource   ..${/}resources${/}coam.robot
# Resource   ..${/}resources${/}call.robot
# Resource   ..${/}resources${/}call.robot
# Resource   ..${/}..${/}common${/}taf_coam.robot
# Library   ..${/}libraries${/}ui_operation.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/coam.robot
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001681_794/resources/case_steps.robot
# 
# Force Tags   SG_07   CA_5G_OAM    CRT_UTE   master_classicalbts_all   5G_RAN
# ...    PY36
# ...   5G_RAN_TDD   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEQN_NETACT   STATE_SW_UPLOADED
# ...   AUTHOR_johnny.1.jiang@nokia-sbell.com   RAN_5G   RAN_5G_TDD   SBTS00
# 
# Suite Setup    Run Keywords   common.Common Setup    AND
# ...  run keyword and continue on failure    Cplane log Setup
# #Suite Setup      Cplane log Setup
# Suite Teardown    Cplane and Uplane log Teardown
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# 
# *** Test Cases ***
# [1]5GC001681_A_X2_ZMQ_C_CP-NRT_CP-RT_CP-IF_CP-UE_COAM_via_Emil_for_ABIP
#     [Timeout]    60min
#     [Setup]    robot_common_operations.Common Case Setup
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# #    SA ENV
#     Check SA Msg in the Log    log_path=${output_txt_path}
# #    NSA ENV
# #    Check NSA Msg in the Log    log_path=${output_txt_path}
#     [Teardown]  Collect Snapshot and Screenshot If Case Failed
# 
# #[1]5GC001681_A_RRC_Xn_and_Ng_interface_trace_can_be_filtered_for_ABIP
# #    [Timeout]    60min
# #    [Setup]
# #    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# ##    SA ENV
# #    Check Xn Msg in the Log    log_path=${output_txt_path}
# #    [Teardown]
# #
# #[1]5GC001681_A_ZMQ_traces_via_EMil_for_ABIP
# #    [Timeout]    60min
# #    [Setup]
# #    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# ##    SA ENV
# #    Check Zmq Msg in the Log    log_path=${output_txt_path}
# #    [Teardown]
# #
# #[1]5GC001681_C_CP-NRT_Syscom_messages_can_be_activated_and_deactivated_via_Emil_for_ABIP
# #    [Timeout]    60min
# #    [Setup]
# #    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# ##    SA ENV
# #    Check CP-NRT Syscom messages    log_path=${output_txt_path}
# #    [Teardown]
# #
# #[1]5GC001681_C_CP-RT_Syscom_messages_can_be_activated_and_deactivated_via_Emil_for_ABIP
# #    [Timeout]    60min
# #    [Setup]
# #    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# ##    SA ENV
# #    Check CP-RT Syscom messages    log_path=${output_txt_path}
# #    [Teardown]
# #
# #[1]5GC001681_C_CP-IF_Syscom_messages_can_be_activated_and_deactivated_via_Emil_for_ABIP
# #    [Timeout]    60min
# #    [Setup]
# #    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# ##    SA ENV
# #    Check CP-IF Syscom messages    log_path=${output_txt_path}
# #    [Teardown]
# #
# #[1]5GC001681_C_COAM_module_Syscom_messages_can_be_activated_and_deactivated_via_Emil_for_ABIP
# #    [Timeout]    60min
# #    [Setup]
# #    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# ##    SA ENV
# #    Check COAM Syscom messages   log_path=${output_txt_path}
# #    [Teardown]
# #
# #[1]5GC001681_C_CP-Ue_Syscom_messages_can_be_activated_and_deactivated_via_Emil_for_ABIP
# #    [Timeout]    60min
# #    [Setup]
# #    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# ##    SA ENV
# #    Check CP-UE Syscom messages    log_path=${output_txt_path}
# #    [Teardown]  Collect Snapshot and Screenshot If Case Failed
# 
# [1]CB008325_5GC001681_ABIP_CRT
#     [Setup]    robot_common_operations.Common Case Setup
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
# 
