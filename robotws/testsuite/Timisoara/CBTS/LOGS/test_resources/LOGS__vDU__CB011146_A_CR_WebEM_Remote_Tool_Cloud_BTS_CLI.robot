*** Settings ***
Documentation
...  Tests for CB011146

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/LOGS_general.robot

*** Keywords ***

TC__LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Check legacy REST-API is working for :Get Cell List ; Get Cell Status; Get RMOD Status
    ...  ******************
    ...  *AUTHOR*: dan.moldovan@nokia.com

    Set Tags  CA-WebEM  OWNER-dan.moldovan@nokia.com  AUTHOR-dan.moldovan@nokia.com    GROUP_IN_CHARGE-TIM_7_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB11146-A



    Step 1: Get Cell List
    Step 2: Get Cell Status
    Step 3: Get RMOD Status

Step 1: Get Cell List
    [Documentation]
    ...   In this step GNCELL, WNCELL and LNCELL are checked

    Log    \nStep 1: Get Cell List    console=${True}
    sleep    4
    ${nr_cells_id}  Get List Of Nr Cells Id
    ${list_length}  Get Length  ${nr_cells_id}

    Run Keyword If  ${list_length}!=0    Log    LNCELL exist
    ...    ELSE  verdicts.Set Test Failed  TC need LTE cells  ${TRUE}

Step 2: Get Cell Status
    [Documentation]
    ...   In this step Get Cell Status for each cell is checked
    Log    \nStep 2: Get Cell Status    console=${True}
    sleep    4

#    ${cells_statuses}  vdu.Get Vdu Cells Status
    Check All Cells From VDU  availability_status=${ONLINE}

Step 3: Get RMOD Status
    [Documentation]
    ...  In this step test check if RMODs  vailability status

    Log     \nStep 3: Get RMOD Status  console=${True}
    sleep    4

    ${rmods_statuses}  vdu.Get Rmods Status

    FOR  ${rmod_statuses}  IN  @{rmods_statuses}
        ${rmod_dist_name}  Set Variable  ${rmod_statuses}[dist_names][config]

        Should Be Equal As Strings  ${rmod_statuses}[availability_status]  on line  ignore_case=True
        ...  msg=Availability status for ${rmod_dist_name} is not Online.
    END
    Log  RMODs are unlocked, online and enabled  console=true




Get List Of Nr Cells From The First Group
    ${nr_cells_id_list_from_first_group}  Create List
    ${nr_cells_groups_list}  Get List Of NRCELLGRP Ids
    ${first_nr_cell_group_id}  Get From List  ${nr_cells_groups_list}  0
    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_statuses}
        Run Keyword If  ${cell}[cell_group_id] == ${first_nr_cell_group_id}
        ...  Append To List  ${nr_cells_id_list_from_first_group}  ${cell}[id]
        ...  ELSE
        ...  Continue For Loop
    END

    [Return]  ${nr_cells_id_list_from_first_group}  ${first_nr_cell_group_id}

TC Setup
    Common VDU Setup
#    VDU WebEM Setup
#
#
TC Teardown
#    Run Keyword If Test Failed
#    ...  Delete Actual Delta Plan Via WebEM
#    VDU WebEM Teardown
    Common VDU Teardown
    Logs To Rotta Copy
