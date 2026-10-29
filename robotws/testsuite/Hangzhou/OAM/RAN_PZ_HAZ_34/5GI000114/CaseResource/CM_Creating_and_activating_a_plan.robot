*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot

*** Variables ***

*** Keyword ***
CM_Creating_and_activating_a_plan
    Step1: Open CM Editor in CM Operation
    Step2: Create a new configuration plan and select MO
    Step3: Change parameters of existing object in the plan
    Step4: Open CM Operations Manager and Provision
    Step5: Check the Changes in CM Editor and WebUI

Step1: Open CM Editor in CM Operation
    Open CM Application   CM Editor

Step2: Create a new configuration plan and select MO
    ${current_date}   Get Current Date
    ${DATE_STR}   Convert Date   ${current_date}   %Y%m%d%H%M
    ${NEW_PLAN_NAME}   Set Variable   Plan_${DATE_STR}
    Set Test Variable    ${NEW_PLAN_NAME}
    Create a new configuration plan   new_plan_name=${NEW_PLAN_NAME}
    ${TREE_PATH}    CM Get Tree Path   tree_name=navigationTree   tree_path_header=Opened Plans|${NEW_PLAN_NAME}|Managed Objects|PLMN-PLMN
    Set Test Variable   ${TREE_PATH}
    ${tree_path_tmp}   Set Variable   ${TREE_PATH}|${MO_NAME} ${MO_NAME}
    Expand Tree Node and Select node in CM application   tree_name=navigationTree
    ...   node_path=${tree_path_tmp}   component_name=Vertical plan and actual table

Step3: Change parameters of existing object in the plan
    ${PLAN_VALUE}   Set Variable   PLMN-PLMN/MRBTS-TEST
    Set Test Variable   ${PLAN_VALUE}
    ${ORIGIN_PARAMETER}   ${row_id}   ${column_id}   Get Table Cell Value and Position   table_name=Vertical plan and actual table
    ...   search_key=Parameter   search_value=BTS name   target_key=Actual value
    ${actual_cell_value}   ${row}   ${column}   Get Table Cell Value and Position   table_name=Vertical plan and actual table
    ...   search_key=Parameter   search_value=BTS name   target_key=Planned value
    Set Table Cell Value and Verify   table_name=Vertical plan and actual table   row_id=${row}   column_id=${column}   target_value=${PLAN_VALUE}
#    ${ORIGIN_PARAMETER}   ${row}   ${column}   Modify Table Cell Value   Vertical plan and actual table   Parameter   BTS name   Actual value
#    ...  Planned value   ${PLAN_VALUE}
    Set Test Variable    ${ORIGIN_PARAMETER}
    Sleep    5s

Step4: Open CM Operations Manager and Provision
    Open CM Application   CM Operations Manager
    Sleep    5s
    Execute CM Provision in Operations Manager   plan_name=${NEW_PLAN_NAME}

Step5: Check the Changes in CM Editor and WebUI
    Switch to Application   alias=CM Editor
    Check if the Modified Parameter is Right in CM Editor Plan
    ...   modified_parameter=${PLAN_VALUE}   key=Parameter   value=BTS name   table_name=Vertical plan and actual table
    ...   column_name=Actual value   Tree_name=navigationTree
    ...   Root_Folder=${TREE_PATH}|${MO_NAME} ${MO_NAME}
    All Check Configuration Values   dist_name=${MO_NAME}   parameter=btsName   expect_value=${PLAN_VALUE}
    Wait Until Keyword Succeeds   1m   5s   swing.Select Main Window
    Wait Until Keyword Succeeds   1m   5s   Menu Item Should Exist   menuPath=File

Case Setup: CM_Creating_and_activating_a_plan
    Login NetAct Start Page and Remove File

Case Teardown: CM_Creating_and_activating_a_plan
    Do CM Provision Recovery   plan_name=${NEW_PLAN_NAME}   origin_parameter=${ORIGIN_PARAMETER}
    Close CM Application   CM Operations Manager
    Close CM Application   CM Editor
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
    Run Keyword And Ignore Error   Common Case Teardown
