*** Settings ***
Documentation  This suite contains PM change intervals TC.

Resource    ../../PM/test_resources/PM__Measurements_Interval_Change_From_Longer_To_Shorter.robot


*** Variables ***
${SCF_ID}  01
${HW_LOCATION_CODE}  Timisoara


*** Test Cases ***
PM__PM__Measurements_Interval_Change_From_Longer_To_Shorter
    [Tags]     QC_***
    [Setup]    Run Keywords    PM__Measurements_Interval_Change_From_Longer_To_Shorter.TC Setup
    ...    AND    Modify Resource Search Order    PM__Measurements_Interval_Change_From_Longer_To_Shorter
    ...    AND    Set Library Search Order    PM__Measurements_Interval_Change_From_Longer_To_Shorter
    TC__PM__Measurements_Interval_Change_From_Longer_To_Shorter
    [Teardown]    Run Keywords    PM__Measurements_Interval_Change_From_Longer_To_Shorter.TC Teardown
    ...    AND    Restore Resource Search Order