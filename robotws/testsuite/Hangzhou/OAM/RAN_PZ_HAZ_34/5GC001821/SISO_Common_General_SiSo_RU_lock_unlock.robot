# *** Settings ***
# Documentation    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# Resource   ./Resource/702.robot
# Resource   ./Resource/common.robot
# 
# Force Tags   SG_07   CA_5G_Siso   CRT   AUTHOR_yin.4.chen@nokia-sbell.com
# ...    PY36
# Suite Setup   Suite Setup Steps
# Suite Teardown   Suite Teardown Steps
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]General_SiSo_RU_lock_unlock
#     [Setup]   Case Setup
#     [Timeout]   2h
# #    Set Common Test Tag   case_key=ru_lock_unlock
#     General SiSo RU Lock Unlock
#     Wait Until Keyword Succeeds   3x   10s   Data Transfer Conducted
#     [Teardown]   Case Teardown: Ru Lock Unlock
# 
# *** Keywords ***
# General SiSo RU Lock Unlock
#     Connect to gnb coam via ssl
#     ${ru_index_list}   Get RU index list
#     Set Test Variable   ${RU_INDEX_LIST}
#     :FOR   ${ru_index}   IN   @{RU_INDEX_LIST}
#          Perform RU lock via rest api   ru_idx=${ru_index}   timeout=${300}
#          Wait Until Keyword Succeeds    180 sec    3 sec    RU Should Be Locked    ru_index=${ru_index}
#          # Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Disabled    cell_idx=${ru_index}    cell_group_idx=${index}
#     END
#     :FOR   ${ru_index}   IN   @{RU_INDEX_LIST}
#          Perform RU unlock via rest api    ru_idx=${ru_index}   timeout=${300}
#          Wait Until Keyword Succeeds   240 sec    3 sec   RU Should Be Unlocked    ru_index=${ru_index}
#         # Wait Until Keyword Succeeds    600 sec    60 sec    Cell Should Be Enabled    cell_idx=${ru_index}    cell_group_idx=${index}
#     END
#     Wait Until Keyword Succeeds   600 sec   5 sec   COAM Check GNB cell on air
# 
# Case Teardown: Ru Lock Unlock
#     :FOR   ${ru_index}   IN   @{RU_INDEX_LIST}
#          ${status}   Run Keyword And Return Status   RU Should Be Unlocked   ru_index=${ru_index}
#          Run Keyword Unless   ${status}   Run Keywords
#          ...   Perform RU unlock via rest api    ru_idx=${ru_index}   timeout=${300}   AND
#          ...   Wait Until Keyword Succeeds   240 sec    3 sec   RU Should Be Unlocked    ru_index=${ru_index}
#     END
#     Wait Until Keyword Succeeds   600 sec   5 sec   COAM Check GNB cell on air
#     Run Keyword And Ignore Error   COAM Teardown gnb connections
#     Run Keyword And Ignore Error   Case Teardown
