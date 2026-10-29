*** Settings ***
Documentation     This test suite to local execute robot test cases in a loop for Folder SyVe and CM
...               Author: Xu Yuyan
Library           OperatingSystem
Library           String
Library           Collections

*** Variables ***
${SRNCLAB}      SRNCLAB1013    # Netact info defined in NetActs.py under Variables folder
${testline_id}    1905
${Repeat}    10

*** Test Cases ***
MRT_TA_Repeat_Cases
    [Tags]    Repeat
    Cases Execution


*** Keywords ***
Cases Execution
    ${Cases_Dic}    Create Dictionary
    #...    CM__Lock_And_Unlock_LTE_Cell_During_Cell_Block_And_Unblock_Via_WebEM.robot=CM
    ...    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.robot=SyVe
    #...    CM__Lock_And_Unlock_NR_Cell_During_Cell_Block_And_Unblock_Via_WebEM.robot=CM
    #...    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.robot=SyVe
    #...    SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.robot=SyVe
    #...    SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.robot=SyVe   #remove wireshark
    #...    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot=SyVe   # need 4G 5G not have same RF
    #...    SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct.robot=SyVe
    #...    SRAN_SyVe_Provision_Plan_Containing_All_LTE_And_NR_Cells_Locking.robot=SyVe
    #...    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion.robot=SyVe
    #...    SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion.robot=SyVe
    #...    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.robot=CM
    #...    CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI.robot=CM
    #...    CM__NR_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot=CM
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