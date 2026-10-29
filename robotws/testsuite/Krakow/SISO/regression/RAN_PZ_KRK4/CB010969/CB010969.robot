*** Settings ***
Documentation
...    author: Agata Sidlo
...    contact: agata.sidlo@nokia.com
...    description: CB010969 testsuite

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/l3_call/call_manager.robot
Library     taf/rfrl/bts/devices/du/sw_update.py
Library     taf/rfrl/bts/devices/du/commissioning.py
Library     taf/rfrl/bts/devices/du/du_operations.py
Library     taf/selenium/sbts/interface.py
Library     ./resources/common_keywords.py

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    resources/variables.py


Suite Setup         Common Suite Setup For Asir
Suite Teardown      Common Suite Teardown
Test Teardown       Common Postconditions

*** Variables ***
@{additional_allowed_alarms}
...    Diagnostic files collected
...    WiFi Configuration Issue

*** Test Cases ***
General_SiSo_reset_ASiR_config_via_ASiR_WebEM
    [Setup]    Common Preconditions With Commissioning    asir_hub=${bool_true}    prefix_tag=CB010969-ED-B1
    Reset Asir Configuration    cancel=${bool_true}
    Reset Asir Configuration    save_logs=${bool_true}
    Perform Asir Commissioning And Wait For Onair

Manual_SiSo_SM_BTS_Site_Reset
    [Setup]    Common Preconditions With Commissioning    asir_hub=${bool_true}    prefix_tag=CB010969-ED-B4
    ${ue_1}    common_keywords.Prepare UE
    L3 Call Dl    ue=${ue_1}    cells=${cells}

    Site Reset    cancel=${bool_true}
    Site Reset
    L3 Call Dl    ue=${ue_1}    cells=${cells}

    Site Reset    cancel=${bool_true}
    Site Reset
    L3 Call Dl    ue=${ue_1}    cells=${cells}

    Site Reset    cancel=${bool_true}
    Site Reset
    L3 Call Dl    ue=${ue_1}    cells=${cells}

    Site Reset    cancel=${bool_true}
    Site Reset
    L3 Call Dl    ue=${ue_1}    cells=${cells}

General_SiSo_Commissioning_BTS_Template_Commissioning
    [Setup]    Test Setup With Config Reset
    Log To Console    Reset config done, starting commissioning...
    ${SW_RELEASE}    Get Variable Value    $SW_RELEASE
    Commission Bts    version=${SW_RELEASE}
    Perform Asir Commissioning And Wait For Onair    scf_path=B5    expected_cell_amount=${int_8}
    Verify Default Allowed Alarms on gNB
    Verify Cell Mapping Info
    Sbts Selenium Modify Parameters    list_parameters=${timeZone_param}    timeout=${int_300}    version=${SW_RELEASE}
    ...    virtual_enable=${bool_true}    browser=${browser}
    Sleep    5s
    Check If Bts Resets And Wait For Onair
    Verify Default Allowed Alarms on gNB
    Verify Correct Parameter Is Set    version=${SW_RELEASE}
    Verify Plan Activation When Wrong Param Set    version=${SW_RELEASE}
    Verify Cell Mapping Info


*** Keywords ***
Test Setup With Config Reset
    Common Preconditions
    gnbscf.Reset Configuration    timeout=900    wait_for_admin_connection=${bool_false}
    Wait For LMP

Common Preconditions With Commissioning
    [Arguments]    ${asir_hub}    ${prefix_tag}
    Perform Full Commissioning and Wait for onAir
    ...                         prefix_tag=${prefix_tag}
    ...                         asir_hub=${asir_hub}
    Common Preconditions

Common Suite Setup For Asir
    Perform Full Commissioning and Wait for onAir
    ...                         prefix_tag=CB010969-ED-B5
    ...                         asir_hub=${bool_true}
    ${sw_release}    Get Release
    Set Suite Variable    $SW_RELEASE    ${sw_release}
    Update Ru Sw If Needed
    Load Asir Scf If Not Present
    Common Suite Setup
