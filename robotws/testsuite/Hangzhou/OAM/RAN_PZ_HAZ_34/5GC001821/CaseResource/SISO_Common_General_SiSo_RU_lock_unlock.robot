*** Settings ***
Documentation    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
Resource   ../Resource/702.robot
Resource   ../Resource/common.robot

*** Variables ***

*** Keywords ***
Test_Case_General_SiSo_RU_lock_unlock
#    Set Common Test Tag   case_key=ru_lock_unlock
    General SiSo RU Lock Unlock Keyword
    Wait Until Keyword Succeeds   3x   10s   Data Transfer Conducted

General SiSo RU Lock Unlock Keyword
    Connect to gnb coam via ssl

    ${ru_index_list}   Get RU index list
    Set Test Variable   ${RU_INDEX_LIST}
    FOR   ${ru_index}   IN   @{RU_INDEX_LIST}
        Perform RU lock via rest api   ru_idx=${ru_index}   timeout=${300}
        Wait Until Keyword Succeeds    180 sec    3 sec    RU Should Be Locked    ru_index=${ru_index}
        # Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Disabled    cell_idx=${ru_index}    cell_group_idx=${index}
    END
    FOR   ${ru_index}   IN   @{RU_INDEX_LIST}
        Perform RU unlock via rest api    ru_idx=${ru_index}   timeout=${300}
        Wait Until Keyword Succeeds   240 sec    3 sec   RU Should Be Unlocked    ru_index=${ru_index}
        # Wait Until Keyword Succeeds    600 sec    60 sec    Cell Should Be Enabled    cell_idx=${ru_index}    cell_group_idx=${index}
    END
    Wait Until Keyword Succeeds   600 sec   5 sec   COAM Check GNB cell on air

Case Setup: RU_lock_unlock
    Case Setup

Case Teardown: RU_lock_unlock
    FOR   ${ru_index}   IN   @{RU_INDEX_LIST}
        ${status}   Run Keyword And Return Status   RU Should Be Unlocked   ru_index=${ru_index}
        run keyword if  not ${status}   Run Keywords
        ...   Perform RU unlock via rest api    ru_idx=${ru_index}   timeout=${300}   AND
        ...   Wait Until Keyword Succeeds   240 sec    3 sec   RU Should Be Unlocked    ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds   600 sec   5 sec   COAM Check GNB cell on air
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error   COAM Teardown gnb connections
    Run Keyword And Ignore Error   Case Teardown
