# *** Settings ***
# 
# Resource    resources/common.robot
# Resource    resources/fault4383_kw.robot
# Resource    resources/fault4019_kw.robot
# Resource    resources/fault1901_kw.robot
# Library     ./resources/counter_ops.py
# Resource    ../5GC001821/Resource/702.robot
# 
# Documentation
# ...   authors: Ruiyu Han
# ...   contact: ruiyu.han@nokia-sbell.com
# ...   Feature CB007271-5GC000952
# ...   Current implementation requies ASIl and ABIN HW.
# 
# Force Tags   SG_07   CA_5G_Siso
# 
# Suite Setup     Suite Common Setup
# 
# Suite Teardown    Suite Common Teardown
# #Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# 
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# ${L3CALL_cellid}    2
# ${coam_alias}    COAM
# 
# *** Test Cases ***
# #[1]CB007271-5G-A_5GC000952_001_SMOD_recovery_scenarios_with_L3_call
# #   [Documentation]
# #   ...
# #   ...                      Fault: "4383" EFaultId_VirtualNodeNotRespondingAl
# #   ...                      SMOD autonomous reset as a recovery action
# #   ...                      AHPF radio unit
# #   [Timeout]    1h
# #   [Setup]  run keywords    Check All Components while OnAir   AND
# #   ...                      Expect Fault Should Absent   faultId=4383    connection=${coam_alias}   AND
# #   ...                      Wait Until Keyword Succeeds    3x    10s   Data Transfer Conducted   cell_index=${L3CALL_cellid}    AND
# #   ...                      Cleared reset counter    coam_alias=${coam_alias}
# #   Fault 4383 cycle SMOD
# #   assert restartCounter value     expected=1    alias=${coam_alias}
# #   Wait Until Keyword Succeeds    3x    10s   Data Transfer Conducted   cell_index=${L3CALL_cellid}
# #   [Teardown]  run keywords     Cleared reset counter    coam_alias=${coam_alias}  AND  run keyword if test failed    F
# ...ailed Operation case teardown
# 
# [1]CB007271-5G-A_5GC000952_004_5G_Autonomous_recovery_reset_counter_BBMOD
#    [Documentation]
#    ...                      Configuration:
#    ...                      Fault: "4019" EFaultId_KeepAliveStatusErrorAl
#    ...                      BBMOD autonomous reset as a recovery action counter
#    ...                      AHPF radio unit
#    [Timeout]    2h
#    run keywords    Check All Components while OnAir    AND
#    ...                      Expect Fault Should Absent   faultId=4019    connection=${coam_alias}
#    #   :FOR    ${INDEX}  IN RANGE    0   ${bbmod_num}
# #   \    Fault 4019 load counter BBMOD    ${INDEX}
#    Fault 4019 load counter BBMOD
#    #Fault 4019 counter overload BBMOD
#    wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
#    Expect Fault Should Absent   faultId=4019    connection=${coam_alias}
#    [Teardown]  run keywords    Check Extra Reset From Blackbox
#    ...   AND  run keyword if test failed    Failed Operation case teardown
# #
# #[1]CB007271-5G-A_5GC000952_005_5G_Radio_Unit_Fault_Recovery_with_L3_call
# #    [Documentation]
# #    ...                      Fault: "1901"
# #    ...                      RMOD autonomous reset as a recovery action
# #   ...                      AHPF radio unit
# #   [Timeout]    2h
# #   [Setup]  run keywords    Check All Components while OnAir    AND
# #   ...                      Expect Fault Should Absent   faultId=1901    connection=${coam_alias}    AND
# #    ...                      Wait Until Keyword Succeeds    3x    10s   Data Transfer Conducted   cell_index=${L3CALL_cellid}
# ##    :FOR    ${INDEX}  IN RANGE    0   ${ru_num}
# ##    \    Fault 1901 trigger once   ru_index=${INDEX}
# #    Fault 1901 trigger once    ru_index=${L3CALL_cellid}
# #    wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
# #    Wait Until Keyword Succeeds    3x    10s   Data Transfer Conducted   cell_index=${L3CALL_cellid}
# #    [Teardown]  run keyword if test failed    run keywords    Catch Snapshot COAM   AND
# #    ...                          run keyword and ignore error   wait until keyword succeeds    600    30
# #    ...                          Cancel Fault 1901 AHPF   ru_index=${L3CALL_cellid}   AND
# #    ...                          COAM Reset Site    AND
# #    ...                          wait until keyword succeeds   900    5    Check All Components while OnAir
# #
# [1]CB007271-5G-A_5GC000952_006_5G_Autonomous_recovery_reset_counter_RU
#     [Documentation]
#     ...                      Fault: "1901"
#     ...                      RMOD autonomous reset as a recovery action
#    ...                      AHPF radio unit
#    [Timeout]    2h
#     run keywords    Check All Components While OnAir  AND
# #    ...                      Wait Until Keyword Succeeds    3x    10s   Data Transfer Conducted   cell_index=${L3CALL_cellid}   AND
#     ...                      Expect Fault Should Absent   faultId=1901    connection=${coam_alias}
# #    :FOR    ${INDEX}  IN RANGE    0   ${ru_num}
# #    \    Fault 1901 cycle AHPF   ru_index=${INDEX}
#     Fault 1901 cycle AHPF    ru_index=${L3CALL_cellid}
#     wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
#     Expect Fault Should Absent   faultId=1901    connection=${coam_alias}
# #    Wait Until Keyword Succeeds    3x    10s   Data Transfer Conducted   cell_index=${L3CALL_cellid}
#     [Teardown]  run keywords    Check Extra Reset From Blackbox   AND
#     ...   run keyword if test failed    Reset RU CASE Teardown Operation
# 
# 
# [1]CB007271-5G-A_5GC000952_002_5G_Autonomous_recovery_reset_counter_SMOD
#    [Documentation]
#    ...                      Configuration:
#    ...                      Fault: "4383" EFaultId_VirtualNodeNotRespondingAl
#    ...                      SMOD autonomous reset as a recovery action counter
#    ...                      AHPF FDD
#    [Timeout]    2h
#    run keywords    Check All Components while OnAir   AND
#    ...                      Expect Fault Should Absent   faultId=4383    connection=${coam_alias}
# #   ...                      Cleared reset counter    coam_alias=${coam_alias}
#    Fault 4383 load counter SMOD
#    Connect to gnb coam via ssl   connection=${coam_alias}
# #   assert restartCounter value     expected=1    alias=${coam_alias}
# #   Fault 4383 4th SMOD
# ##   COAM Reset Site
# #   wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
# #   Expect Fault Should Absent   faultId=4383    connection=${coam_alias}
# #   assert restartCounter value     expected=0    alias=${coam_alias}
#    [Teardown]  run keyword if test failed    Failed Operation case teardown
# 
# #[1]CB007271-5G-A_5GC000952_003_BBMOD_recovery_scenario_with_L3_call
# #   [Documentation]
# #   ...                      Fault: "4019" EFaultId_KeepAliveStatusErrorAl
# #   ...                      BBMOD autonomous reset as a recovery action
# #   ...                      AHPF radio unit
# #   [Timeout]    2h
# #   [Setup]  run keywords    Check All Components while OnAir    AND
# #   ...                      Expect Fault Should Absent   faultId=4019    connection=${coam_alias}
# ##   :FOR    ${INDEX}  IN RANGE    0   ${bbmod_num}
# ##   \    Fault 4019 cycle BBMOD    ${INDEX}
# #   Fault 4019 cycle BBMOD
# #   Wait Until Keyword Succeeds    3x    10s   Data Transfer Conducted   cell_index=${L3CALL_cellid}
# #   [Teardown]  run keyword if test failed    Failed Operation case teardown
# #
# 
# CB007271-5G-A_5GC000952_Recovery_for_Classical_gNB
#     [Setup]    run keywords    Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     ...    AND      robot_common_operations.Common Case Setup
#     List Should Not Contain Value    ${ALL_TEST_STATUS}    FAIL
# 
# *** Keywords ***
# Reset RU CASE Teardown Operation
#     Catch Snapshot COAM
#     run keyword and ignore error   wait until keyword succeeds    600    30
#     ...                          Cancel Fault 1901 AHPF   ru_index=${L3CALL_cellid}
#     COAM Reset Site
#     wait until keyword succeeds   900    5    Check All Components while OnAir
# 
