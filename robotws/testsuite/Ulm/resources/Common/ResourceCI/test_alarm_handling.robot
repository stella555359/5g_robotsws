*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real classical TL.
...   It verifies proper function of KWs in alarm_handling.robot for classical deployments.

Library     Collections
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin          WITH NAME   admin
Library     ../python/alarm_handling.py      WITH NAME   alarm_py
Library     ../python/robot_json_helper.py   WITH NAME   json_helper_py

Resource    ../alarm_handling.robot
Resource    ../testline.robot
Resource    ../connect.robot
Resource    ../gnb.robot

Test Setup  Setup Log Dir

*** Test Cases ***
Test Get Active And Historic Alarms With Different Sessions
    [TAGS]              ALARM
    FOR   ${al_type}   IN   Active   Historic
        FOR   ${session}   IN RANGE   2
            ${oam_alias}   connect.Setup OAM Http Session  node_type=gnb  node_id=0
            IF   '${al_type}'=='Active'
                ${alarms}     Run Keyword   admin.Get ${al_type} Alarms   connection=${oam_alias}

                # check here 'with_historic' argument handling of KW 'Get All Alarms From Node'
                ${alarms_dup}  alarm_handling.Get All Alarms From Node
                ...   node_id=0  node_type=gnb  time_sort=${True}  with_historic=${False}

                Should Be Equal As Integers   ${{ len(${alarms}) }}   ${{ len(${alarms_dup}) }}
                ...   Error in 'Get All Alarms From Node' with 'with_historic=${False}'!

            ELSE IF   '${al_type}'=='Historic'
                ${alarms}     Run Keyword   admin.Get ${al_type} Alarms
                ...                         timeout=60   load_history=true   connection=${oam_alias}
            END
            connect.Teardown OAM Http Session  node_type=gnb  node_id=0
            ${alarms}   alarm_py.Filter Alarms   ${alarms}   exclude_raw=alarmId:7220 faultId:4334
                        ...   log=${True}   label=${al_type} alarm
            json_helper_py.Dump Json To File   ${alarms}   filename=${TARGET_DIR}/${al_type}_alarms_session${session}.json
            ${alarms}   Set Variable   ${None}
        END
    END


Test Is Alarm Active With Predefined Alarm File
    [Documentation]     Load a json file and check a given predefined alarm or alarm set is active.
    ...                 It also verfies a 'non active alarm' is properly processed.
    [TAGS]              ALARM
    ${alarms}   json_helper_py.Load Json From File   ${CURDIR}/alarms_by_observation_time.json

    ${fault_bfd_down_ingress}   Set Variable   61605
    ${is_active}    alarm_py.Is Alarm Active    ${alarms}    faultId:${fault_bfd_down_ingress}    log=${TRUE}
    Should Not Be True    ${is_active}    Alarm faultId:${fault_bfd_down_ingress} should not be active

    ${is_active}    alarm_py.Is Alarm Active    ${alarms}    faultId:61649    log=${TRUE}
    Should Be True    ${is_active}    Alarm faultId:61649 should be active

    # get all alarmId and faultId and filter/remove them from list
    ${fault_ids}   alarm_py.Get Fault Or Alarm Ids   alarm_list=${alarms}   key_name=faultId
    ${filtered_alarms}   alarm_py.Filter Alarms  ${alarms}  ${fault_ids}
    ...   log=${P_console}   label=INFO

    # after we filtered the alarm the previously active alarm must Not be active
    ${is_active}    alarm_py.Is Alarm Active    ${filtered_alarms}    faultId:61649    log=${TRUE}
    Should Not Be True    ${is_active}    Alarm faultId:61649 should not be active after filtering


Test Count Active Alarms with And Without Filter
    [Documentation]     Load a json file and count the number of predefined alarms with and without filter.
    [TAGS]              ALARM
    ${alarms}   json_helper_py.Load Json From File   ${CURDIR}/alarms_by_observation_time.json

    ${nbr}    alarm_py.Count Active Alarms    alarm_list=${alarms}    filter_raw=faultId:61605    log=${TRUE}
    Should Be Equal As Integers    ${nbr}    ${0}   Alarm faultId:61605 should not be found

    ${nbr}    alarm_py.Count Active Alarms    alarm_list=${alarms}    filter_raw=faultId:61649    log=${TRUE}
    Should Be Equal As Integers    ${nbr}    ${1}   Alarm faultId:61649 should be found

    # get all alarmId and faultId and filter/remove them from list
    ${fault_ids}   alarm_py.Get Fault Or Alarm Ids   alarm_list=${alarms}   key_name=faultId
    ${filtered_alarms}   alarm_py.Filter Alarms  ${alarms}  ${fault_ids}
    ...   log=${P_console}   label=INFO

    # after we filtered the alarm the previously active alarm must Not be active
    ${nbr}    alarm_py.Count Active Alarms    alarm_list=${filtered_alarms}    filter_raw=faultId:61649    log=${TRUE}
    Should Be Equal As Integers    ${nbr}    ${0}   Alarm faultId:61649 should not be found after filtering


Test Filter Alarms By Observation Time With Predefined Alarm File
    [Documentation]     Load a json file and check that the observation time of all included alarms
    ...                 are before and none are after the current system timestamp
    [TAGS]              ALARM
    ${alarms}   json_helper_py.Load Json From File   ${CURDIR}/alarms_by_observation_time.json

    ${currTime}   alarm_py.Get Current Timestamp MS

    ${alarms_before}   alarm_py.Get Alarms Before   timestamp_ms=${currTime}   alarms=${alarms}   log=${True}
    ${alarms_after}   alarm_py.Get Alarms After     timestamp_ms=${currTime}   alarms=${alarms}   log=${True}
    Should Be Equal As Integers   ${{ len(${alarms}) }}   ${{ len(${alarms_before}) }}   Error in 'Get Alarms Before'!
    Should Be Empty   ${alarms_after}   Error in 'Get Alarms After'!


Test Get Fault Or Alarm IDs From Alarm List
    [Documentation]     Load a predefined json file with 10 active alarms.
    ...                 Retrieve a list of tuples to be used for alarm filtering
    ...                 in KW `Check For New Alarms`.
    ${alarms}   json_helper_py.Load Json From File   ${CURDIR}/alarms_by_observation_time.json

    ${alarm_ids}   alarm_py.Get Fault Or Alarm Ids   alarm_list=${alarms}   key_name=alarmId
    ${fault_ids}   alarm_py.Get Fault Or Alarm Ids   alarm_list=${alarms}   key_name=faultId

    IF  len('${alarm_ids}') == ${0} or len('${fault_ids}') == ${0}
    ...  Fail  Error in KW Get Fault Ids!

    ${filtered_alarms}   alarm_py.Filter Alarms  ${alarms}  ${fault_ids}
    ...   log=${P_console}   label=INFO

    IF  len(${filtered_alarms}) != ${0}
    ...  Fail  Error in KW Filter Alarms!


Test Check For New Alarms With Same Predefined Alarm File
    [Documentation]     Load a predefined json file with 10 active alarms.
    ...                 Check no new alarm and no cleared alarms are found if we compare
    ...                 the data with itself.
    [TAGS]              ALARM
    ${alarms}   json_helper_py.Load Json From File   ${CURDIR}/alarms_by_observation_time.json

    ${cleared_alarms}  ${new_alarms}  alarm_py.Check For New Alarms  ${alarms}  ${alarms}
    ...   console_log=${P_console}

    alarm_handling.Log Alarm List  ${cleared_alarms}   ERROR
    alarm_handling.Log Alarm List  ${new_alarms}    ERROR

    # verify KW 'Log Alarm List' works currectly
    IF  len(${cleared_alarms}) != ${0}
    ...  Fail  Cleared alarm lists should be empty!

    IF  len(${new_alarms}) != ${0}
    ...  Fail  New active alarm lists should be empty!


Test Check For New Cleared Alarm With Predefined Alarm Files
    [Documentation]     Load 2 predefined json files, first with FID 49 active, second with FID49 cleared.
    ...                 Check no new alarm and 1 cleared alarms are found if we compare them.
    [TAGS]              ALARM
    ${alarms_after_block}     json_helper_py.Load Json From File   ${CURDIR}/alarms_after_block.json
    ${alarms_after_unblock}   json_helper_py.Load Json From File   ${CURDIR}/alarms_after_unblock.json

    ${cleared_alarms}  ${new_alarms}  alarm_py.Check For New Alarms
    ...   ${alarms_after_block}   ${alarms_after_unblock}

    alarm_handling.Log Alarm List  ${cleared_alarms}   INFO
    alarm_handling.Log Alarm List  ${new_alarms}       ERROR

    # verify KW 'Log Alarm List' works currectly
    IF  len(${cleared_alarms}) != ${1}
    ...  Fail  Cleared alarm lists should be 1!

    IF  len(${new_alarms}) != ${0}
    ...  Fail  New active alarm lists should be empty!


Test Check Alarm Filtering For Cleared Alarm With Predefined Alarm Files
    [Documentation]     Load 2 predefined json files, first with FID 49 active, second with FID49 cleared.
    ...                 Compare both lists and apply filter for cleared alarm, so no cleared
    ...                 alarm detection is expected in that case.
    [TAGS]              ALARM
    ${alarms_after_block}     json_helper_py.Load Json From File   ${CURDIR}/alarms_after_block.json
    ${alarms_after_unblock}   json_helper_py.Load Json From File   ${CURDIR}/alarms_after_unblock.json

    # verify eclude works for cleared alarms
    ${cleared_alarms}  ${_}  alarm_py.Check For New Alarms  ${alarms_after_block}  ${alarms_after_unblock}
    ...   exclude_cleared_alarms=faultId:49 faultId:7107
    ...   exclude_active_alarms=${EMPTY}
    ...   console_log=${P_console}

    alarm_handling.Log Alarm List  ${cleared_alarms}   ERROR
    IF  len(${cleared_alarms}) != ${0}
    ...  Fail  cleared alarm list should be empty (cleared alarm excluded)


Test Check Alarm Filtering For New Alarm With Predefined Alarm File
    [Documentation]     Load 1 predefined json file with FID 49 active.
    ...                 Create another alarm list by removing the active alarm FID 49.
    ...                 Compare both lists and apply filter for new alarm, so no new
    ...                 alarm detection is expected in that case.
    [TAGS]              ALARM
    ${alarms_after_block}     json_helper_py.Load Json From File   ${CURDIR}/alarms_after_block.json
    ${alarms_after_unblock}   Get Slice From List   ${alarms_after_block}   end=-1
    # verify eclude works for new active alarms
    ${_}  ${new_alarms}  alarm_py.Check For New Alarms  ${alarms_after_block}  ${alarms_after_unblock}
    ...   exclude_cleared_alarms=${EMPTY}
    ...   exclude_active_alarms=faultId:49 faultId:7107
    ...   console_log=${P_console}

    alarm_handling.Log Alarm List  ${new_alarms}   ERROR
    IF  len(${new_alarms}) != ${0}
    ...  Fail  New alarm list should be empty (active alarm excluded)


Test Check For New Alarms With Cell Block And Unblock Action
    [Documentation]     Check alarms after real cell block/unblock action on gnb.
    [TAGS]              ALARM
    ${alarms_before_block}  alarm_handling.Get All Alarms From Node  node_id=0  node_type=gnb
    ...   time_sort=${True}   with_historic=${True}   targetfile=${TARGET_DIR}/alarms_before_block.json
    OperatingSystem.File Should Not Be Empty   path=${TARGET_DIR}/alarms_before_block.json

    # -----------------------------------------------------------------------------------

    ${oam_alias}   connect.Setup OAM Http Session  node_type=gnb  node_id=0
    ${cell_list}   testline.Get All Ids Of Class   class=NRCEL    alias=${oam_alias}
    Set Test Variable   ${CELL_LIST}   ${cell_list}

    ${refTime_beforeBlock}   alarm_py.Get Current Timestamp MS

    # force the new alarm by blocking a single cell
    Log To Console   ${\n}Block now cell ${cell_list}[0] to trigger alarm ...
    admin.Block Cell  dist_name=${cell_list}[0]  connection=${oam_alias}

    Sleep  10s

    ${cells_info}   admin.Get Cells Info   connection=${oam_alias}
    ${cells_state}  gnb.Generate Cells Status Dictionary   data_structure=${cells_info}
    Log To Console  ${\n}${cell_list}[0] blockingState: ${cells_state['${cell_list}[0]']['status']['blockingState']}

    # fetch alarms after blocking cell action
    ${alarms_after_block}  alarm_handling.Get All Alarms From Node  node_id=0  node_type=gnb
    ...   time_sort=${True}   with_historic=${True}   targetfile=${TARGET_DIR}/alarms_after_block.json   log_level=TRACE
    OperatingSystem.File Should Not Be Empty   path=${TARGET_DIR}/alarms_after_block.json

    # compare alarms before and after block cell, new alarm is expected
    ${_}  ${new_alarms}  alarm_py.Check For New Alarms  ${alarms_before_block}  ${alarms_after_block}
    ...   console_log=${P_console}
    IF  len(${new_alarms}) == ${0}
    ...  Fail  case1: new alarm list should not be empty!

    # verify KW 'Log Alarm List' raises an error exception for new cell blocked alarm (FID49)
    Log To Console  ${\n}An error should be raised now for the new cell blocked alarm:
    Run Keyword And Expect Error    Unexpected new/cleared alarm(s) detected!
    ...   alarm_handling.Log Alarm List  ${new_alarms}   ERROR

    # verify exclude works for active alarms
    ${_}  ${new_alarms}  alarm_py.Check For New Alarms  ${alarms_before_block}  ${alarms_after_block}
    ...   ${EMPTY}  exclude_active_alarms=faultId:49 faultId:7107   console_log=${P_console}
    IF  len(${new_alarms}) != ${0}
    ...  Fail  new alarm list should be empty (active alarm excluded)!

    ${refTime_afterBlock}   alarm_py.Get Current Timestamp MS

    # -----------------------------------------------------------------------------------

    Log To Console   ${\n}Unblock now cell ${cell_list}[0] to clear alarm ...
    admin.Unblock Cell  dist_name=${cell_list}[0]  connection=${oam_alias}

    Sleep  10s

    ${cells_info}   admin.Get Cells Info   connection=${oam_alias}
    ${cells_state}  gnb.Generate Cells Status Dictionary   data_structure=${cells_info}
    Log To Console  ${\n}${cell_list}[0] blockingState: ${cells_state['${cell_list}[0]']['status']['blockingState']}

    # fetch alarms after unblock action
    ${alarms_after_unblock}   alarm_handling.Get All Alarms From Node  node_id=0  node_type=gnb
    ...   time_sort=${True}   with_historic=${True}   targetfile=${TARGET_DIR}/alarms_after_unblock.json   log_level=TRACE
    OperatingSystem.File Should Not Be Empty   path=${TARGET_DIR}/alarms_after_unblock.json

    ${cleared_alarms}  ${new_alarms}  alarm_py.Check For New Alarms  ${alarms_after_block}  ${alarms_after_unblock}
    ...   console_log=${P_console}

    alarm_handling.Log Alarm List  ${cleared_alarms}   INFO

    IF  len(${cleared_alarms}) == ${0}
    ...  Fail  case2: cleared alarm list should not be empty

    IF  len(${new_alarms}) != ${0}
    ...  Fail  case2: new alarm lists should be empty

    [Teardown]   Run Keyword If Test Failed   Recover Cell


*** Keywords ***
Setup Log Dir
    ${target_dir}   testline.Get Test Case Log Directory
    Set Test Variable   ${TARGET_DIR}   ${target_dir}


Recover Cell
    ${oam_alias}   connect.Setup OAM Http Session  node_type=gnb  node_id=0
    ${cells_info}   admin.Get Cells Info   connection=${oam_alias}
    ${cells_state}  gnb.Generate Cells Status Dictionary   data_structure=${cells_info}
    IF   '${cells_state['${CELL_LIST}[0]']['status']['blockingState']}' == 'Blocked'
        Log To Console  ${\n}${CELL_LIST}[0] is still blocked, unblock it now!
        admin.Unblock Cell  dist_name=${CELL_LIST}[0]  connection=${oam_alias}
        Sleep  10s
    END
