*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REPEAT_TIME}    1

*** Keywords ***
CM__Lock_And_Unlock_Cell_During_Cell_Block_And_Unblock_Via_WebEM
    [Documentation]    [CASE MRT]: CM__Lock_And_Unlock_Cell_During_Cell_Block_And_Unblock_Via_WebEM
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Lock one NR/LTE cell via webEM and block one NR/LTE cell via webEM in parallel
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 21.09.2024 - Xu Yuyan - New case.
    Set Tags    CM    UI    AUTHOR-yuyan.xu@nokia-sbell.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Randomly Select One Cell
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        Log To Console    Repeat Time: ${index}
        Step 2: Block Cell And Set AdministrativeState As Locked
        Step 3: Unblock Cell And Set AdministrativeState As Unlocked
        Step 4: Check SBTS Status
    END

Step ${index}: Randomly Select One Cell
    Log To Console    Step ${index}: Randomly Select One Cell
    ${rat_type}    Evaluate    random.choice(["nr","lte"])    modules=random, sys
    ${cell_list}    coam.Get Cell List
    ${not_have_nr}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${cell_list['cells']}    nr
    ${not_have_lte}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${cell_list['cells']}    lte
    ${rat_type}    Run Keyword If    ${not_have_lte}    Set Variable    nr
    ...    ELSE IF    ${not_have_nr}    Set Variable    lte
    ...    ELSE    Set Variable    ${rat_type}
    ${cells_list}    Set Variable    ${cell_list['cells']['${rat_type}']}
    ${selected_cell}    Evaluate    random.choice(${cells_list})    modules=random, sys
    Set Test Variable    ${selected_cell_DN}    ${selected_cell['id']['configuration']}
    Set Test Variable    ${selected_cell_R}    ${selected_cell['id']['internal']}
    Set Test Variable    ${rat_type}
    Set Test Variable    ${MRBTS_DN}    ${selected_cell_DN.split("/")[0]}


Step ${index}: Block Cell And Set AdministrativeState As Locked
    Log To Console    Step ${index}: Block Cell:${selected_cell_DN} And Set AdministrativeState As Locked
    ${value}    Set Variable If    "${rat_type}"=="lte"    locked    Locked
    selenium_sbts.set_parameter_value    dist_name=${selected_cell_DN}
    ...    filter_param=Administrative state    abbr=administrativeState    new_value=${value}
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan    activate_plan_despite_errors=True
    selenium_sbts.block_cell    cell_idx=${selected_cell_DN.split("-")[-1]}    technology=${rat_type.upper()}
    #check status
    ${NRcell_state}    Set Variable
    ...    administrativeState=Locked, operationalState=disabled, availabilityStatus="off line", blockingState=Blocked
    ${LTEcell_state}    Set Variable
    ...    administrativeState=locked, operationalState=disabled, availabilityStatus="off line", blockingState=Blocked
    Run Keyword If    "${rat_type}"=="nr"    coam.assert    NRCEL    ${selected_cell_R}    ${NRcell_state}    timeout=120
    ...    ELSE    coam.assert    LNCEL    ${selected_cell_R}    ${LTEcell_state}    timeout=120

Step ${index}: Unblock Cell And Set AdministrativeState As Unlocked
    Log To Console    Step ${index}: Unblock Cell:${selected_cell_DN} And Set AdministrativeState As Unlocked
    ${value}    Set Variable If    "${rat_type}"=="lte"    unlocked    Unlocked
    selenium_sbts.set_parameter_value    dist_name=${selected_cell_DN}
    ...    filter_param=Administrative state    abbr=administrativeState    new_value=${value}
    selenium_sbts.validate_plan
    selenium_sbts.activate_plan    activate_plan_despite_errors=True
    selenium_sbts.unblock_cell    cell_idx=${selected_cell_DN.split("-")[-1]}    technology=${rat_type.upper()}
    #check status

Step ${index}: Check SBTS Status
    Log To Console    Step ${index}: Check SBTS Status
    Wait Until Keyword Succeeds    10 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms


SetUp
    Log To Console    SetUp
    Common Test Setup SBTS
    Selenium Login    https://192.168.255.129

CaseTearDown
    Log To Console    Tear Down
    Run Keyword If Test Failed    coam.perform_commissioning    bts_id=${MRBTS_DN.split("-")[-1]}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    timeout=600
    Common Test Teardown SBTS
    Selenium Logout

