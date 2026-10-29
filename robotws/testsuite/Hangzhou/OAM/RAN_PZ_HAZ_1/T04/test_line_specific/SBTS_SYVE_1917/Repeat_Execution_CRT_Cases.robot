*** Settings ***
Documentation     This test suite to local execute robot test cases in a loop for Folder SyVe and CM
...               Author: Xu Yuyan
Library           OperatingSystem
Library           String
Library           Collections

*** Variables ***
${SRNCLAB}      SRNCLAB1013    # Netact info defined in NetActs.py under Variables folder
${testline_id}    1894
${Repeat}    1

*** Test Cases ***
MRT_TA_Repeat_Cases
    [Tags]    Repeat
    Cases Execution


*** Keywords ***
Cases Execution
    ${Cases_Dic}    Create Dictionary
    ...    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting.robot=SyVe
    ...    SyVe_CM_CB012145_004_Verify_Duration_of_Pre-activate_Delta_Plan_with_Validation_Scope_Setting.robot=SyVe
    ...    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification.robot=SyVe
    ...    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.robot=SyVe
    ...    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot=SyVe
    ...    SyVe_CM_RP002956_5G_Online_Recommission_via_NetAct.robot=SyVe
    ...    SyVe_CM_CB012145_009_RP002956_5G_Online_Recommission_via_NetAct.robot=SyVe
    ...    SyVe_CM_CB012145_009_SBTS_Configuration_changes_from_NetAct_with_online_modification.robot=SyVe
    ...    CM__CB007010-A_006_Verify_Inactivity_Timeout_Between_NetConf_Operations.robot=CM
    ...    CM__CB012803_CB012663_CM_Verify_Duration_via_WebEM.robot=CM
    Set Test Variable    ${Cases_Dic}
    ${cases_list}    Get Dictionary Keys    ${Cases_Dic}
    FOR    ${case_name}    IN    @{cases_list}
        Log    \nCase:${case_name}    console=${True}
        Repeat Execution    ${case_name}    ${Cases_Dic["${case_name}"]}
    END

Repeat Execution
    [Arguments]    ${case_name}    ${sub_folder}
    Log    Start repeat executing......    console=${True}
    FOR    ${index}    IN RANGE    1    ${${Repeat}+1}
        Log    Round:${index}   console=${True}
        ${output}    Run    bash ../Variables/repeat_cases.sh ${case_name} ${sub_folder} ${index} ${testline_id} ${SRNCLAB}
        ${result_list}    Get Regexp Matches    ${output}    \\d test, \\d passed, \\d failed
        ${pass_num}    Get Regexp Matches    ${result_list[0]}    \\d passed
        ${fail_num}    Get Regexp Matches    ${result_list[0]}    \\d failed
        ${result}    Set Variable If    "${pass_num[0]}"=="0 passed" and "${fail_num[0]}"!="0 failed"    Failed    Pass
	    Log    ${case_name}_R${index}:${result}    console=${True}
	END