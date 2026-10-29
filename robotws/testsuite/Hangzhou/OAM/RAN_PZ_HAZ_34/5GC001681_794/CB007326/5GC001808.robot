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
# 
# Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASKEY_SA_ASOEB1_3xAZQJ
#     ...   SBTS00    CRT_UTE    PY36
# 
# Suite Setup    Run Keywords   common.Common Setup    AND
# ...  run keyword and continue on failure    Cplane log Setup
# #Suite Setup      Cplane log Setup
# Suite Teardown    Cplane and Uplane log Teardown
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC001808_A_RRC Xn and Ng interface trace can be filtered for Classical_SA BTS
#     [Tags]
#     [Timeout]    60min
#     [Setup]    robot_common_operations.Common Case Setup
#     Check Xn Msg in the Log    log_path=${output_txt_path}
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1]5GC001808_A_ZMQ traces via EMil for Classical_SA BTS
#     [Tags]
#     [Timeout]    60min
#     [Setup]    robot_common_operations.Common Case Setup
#     Check Zmq Msg in the Log    log_path=${output_txt_path}
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1.0] 5GC001808_C_ CP-NRT Syscom messages can be activated and deactivated via Emil for Classical_SA BTS
#     [Timeout]    60min
#     [Setup]    robot_common_operations.Common Case Setup
#     Check CP-NRT Syscom messages    log_path=${output_txt_path}
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1.0] 5GC001808_C_ CP-RT Syscom messages can be activated and deactivated via Emil for Classical_SA BTS
#     [Timeout]    60min
#     [Setup]    robot_common_operations.Common Case Setup
#     Check CP-RT Syscom messages    log_path=${output_txt_path}
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1.0] 5GC001808_C_ CP-IF Syscom messages can be activated and deactivated via Emil for Classical_SA BTS
#     [Timeout]    60min
#     [Setup]    robot_common_operations.Common Case Setup
#     Check CP-IF Syscom messages    log_path=${output_txt_path}
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# 
# 
# *** Keywords ***
