*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REPEAT_TIME}    1

*** Keywords ***
CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Documentation]    [CASE CRT]: CM__LTE_Cell_Addition_And_Deletion_Via_Parameter_Editor
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Delete and add one LTE cell via parameter editor, can repeat run on one selected cell
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.11.2024 - Xu Yuyan - New case due to CB012236 webem change.
    Set Tags    CM    UI    AUTHOR-yuyan.xu@nokia-sbell.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Randomly Select One LTE Cell
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        Log To Console    Repeat Time: ${index}
        Step 2: Delete Selected LTE Cell
        Step 3: Check Selected LTE Cell Should Not Be Exist
        Step 4: Check All RATs Should Not Restart After Delete
        Step 5: Add Selected LTE Cell
        Step 6: Check Selected LTE Cell Should Be Exist
        Step 7: Check All RATs Should Not Restart After Add
    END

Step ${index}: Randomly Select One LTE Cell
    Log To Console    Step ${index}: Randomly Select One LTE Cell
    ${cell_list}    coam.Get Cell List
    ${cells_list}    Set Variable    ${cell_list['cells']['lte']}
    ${selected_cell}    Evaluate    random.choice(${cells_list})    modules=random, sys
    Set Test Variable    ${selected_cell_DN}    ${selected_cell['id']['configuration']}
    Set Test Variable    ${MRBTS_DN}    ${selected_cell_DN.split("/")[0]}

Step ${index}: Delete Selected LTE Cell
    Log To Console    Step ${index}: Delete Selected LTE Cell
    ${lcrId}    LTE Cell Deletion Via Selenium    ${selected_cell_DN}
    Set Test Variable    ${lcrId}
    Wait Until Keyword Succeeds    10 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Check Selected LTE Cell Should Not Be Exist
    Log To Console    Step ${index}: Check Selected LTE Cell Should Not Be Exist
    ${cell_existed}    Run Keyword And Return Status    Wait Until Keyword Succeeds    30s    15s
    ...    selenium_sbts.get_cell_info    cell_idx=${selected_cell_DN.split("/")[-1].split("-")[-1]}    technology=LTE
    Should Not Be True    ${cell_existed}

Step ${index}: Check All RATs Should Not Restart After Delete
    Log To Console    Step ${index}: Check All RATs Should Not Restart After Delete
    Verify SBTS Online State From IMS2    ${BTSFiles}/InfoModel_log_for_delete_lte_cell.ims2

Step ${index}: Add Selected LTE Cell
    Log To Console    Step ${index}: Add Selected LTE Cell
    LTE Cell Addition Via Selenium    ${selected_cell_DN}    ${lcrId}    ${BTS_scf_initial}
    Wait Until Keyword Succeeds    10 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Check Selected LTE Cell Should Be Exist
    Log To Console    Step ${index}: Check Selected LTE Cell Should Be Exist
    ${cell_existed}    Run Keyword And Return Status    Wait Until Keyword Succeeds    2min    15s
    ...    selenium_sbts.get_cell_info    cell_idx=${selected_cell_DN.split("/")[-1].split("-")[-1]}    technology=LTE
    Should Be True    ${cell_existed}

Step ${index}: Check All RATs Should Not Restart After Add
    Log To Console    Step ${index}: Check All RATs Should Not Restart After Add
    Verify Cells State Changed From IMS2    ${BTSFiles}/InfoModel_log_for_add_lte_cell.ims2    ${selected_cell_DN.split("/")[-1]}

Set Up
    Log To Console    Set Up
    Common Test Setup SBTS
    Selenium Login    https://192.168.255.129

TearDown
    Log To Console    TearDown
    Run Keyword If Test Failed    coam.perform_commissioning    bts_id=${MRBTS_DN.split("-")[-1]}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    timeout=600
    Common Test Teardown SBTS
    Selenium Logout

