*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot

*** Variables ***
${CM_EDITOR_PORT}
${ORIGIN_PARA}
${ROW}
${COLUMN}
${TREE_PATH}
${EDITED_PARA}   Send_To_Network
${table_name}   Vertical actual table

*** Keyword ***
CM_Activating_configuration_changes_with_Send_To_Network_Test_Case
    Step1: Open CM Editor In Send To Network
    Step2: Expand Actual Configuration And Click Tree Node
    Step3: Modify Table Value And CM Send To Network
    Step4: Check Table Value Was Changed In CM Editor
    Step5: Check Value In WebUI

Step1: Open CM Editor In Send To Network
    ${CM_EDITOR_PORT}   Open CM Application   app_name=CM Editor
    Set Test Variable   ${CM_EDITOR_PORT}

Step2: Expand Actual Configuration And Click Tree Node
    Select Main Window
    ${TREE_PATH}    CM Get Tree Path   tree_name=navigationTree   tree_path_header=Actual Configuration|PLMN-PLMN
    Set Test Variable   ${TREE_PATH}
    Log To Console   ${TREE_PATH}
    # Set Test Variable   ${TREE_PATH}   Actual Configuration|PLMN-PLMN|${MO_NAME} ${MO_NAME}
    ${tree_path_tmp}   Set Variable   ${TREE_PATH}|${MO_NAME} ${MO_NAME}
    Expand Tree Node and Select node in CM application
    ...   tree_name=navigationTree
    ...   node_path=${TREE_PATH}|${MO_NAME} ${MO_NAME}
    ...   component_name=${table_name}

Step3: Modify Table Value And CM Send To Network
    Check Check Box   identifier=parameters.by.actual.view.modify
    ${ORIGIN_PARA}   ${ROW}   ${COLUMN}   Get Table Cell Value and Position
    ...   table_name=${table_name}   search_key=Parameter   search_value=BTS name   target_key=Actual value
    Set Table Cell Value and Verify   table_name=${table_name}   row_id=${ROW}   column_id=${COLUMN}   target_value=${EDITED_PARA}
    Set Test Variable   ${ROW}
    Set Test Variable   ${COLUMN}
    Set Test Variable   ${ORIGIN_PARA}
    Execute Send To Network And Verify The Status   tree_path=${TREE_PATH}|${MO_NAME} ${MO_NAME}   mo_name=${MO_NAME}
    Sleep   5s

Step4: Check Table Value Was Changed In CM Editor
    Select Main Window
    Expand Tree Node and Select node in CM application
    ...   tree_name=navigationTree
    ...   node_path=${TREE_PATH}|${MO_NAME} ${MO_NAME}
    ...   component_name=${table_name}
    ${modified_para}   Get Table Cell Value   identifier=${table_name}   row=${ROW}   columnIdentifier=${COLUMN}
    Should Be Equal   ${EDITED_PARA}   ${modified_para}

Step5: Check Value In WebUI
    All Check Configuration Values   dist_name=${MO_NAME}   parameter=btsName   expect_value=${EDITED_PARA}

Case Setup: Send To NetWork
    Log To Console    \nStart To Send To NetWork Case Setup!
    Run Keyword And Ignore Error   Common Case Setup
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${true}

Case Teardown: Send To NetWork
    Log To Console    Start To Send To NetWork Case Teardown!
    Select Main Window
    Expand Tree Node and Select node in CM application
    ...   tree_name=navigationTree
    ...   node_path=${TREE_PATH}|${MO_NAME} ${MO_NAME}
    ...   component_name=${table_name}
    Check Check Box   identifier=parameters.by.actual.view.modify
    Set Table Cell Value and Verify   table_name=${table_name}   row_id=${ROW}   column_id=${COLUMN}   target_value=${ORIGIN_PARA}
    Execute Send To Network And Verify The Status   tree_path=${TREE_PATH}|${MO_NAME} ${MO_NAME}   mo_name=${MO_NAME}
    Close Java Application by Remote Port   remote_port=${CM_EDITOR_PORT}
    Run Keyword And Ignore Error   Common Case Teardown
