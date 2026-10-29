*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: jack.zeng@nokia-sbell.com


Variables   ./TMO_Data.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007834/resources/CB007834_5G_A_common_keyword.robot

*** Variables ***
${attached_lcrid}    103
${ul_expect_throughput}    0
${dl_expect_throughput}    0
${dl_throughput}    10M
${ul_throughput}    10M
${ue_type}    ${tl.ues[0].capabilities[0]}
${ue_index}     0

#*** Test Cases ***
#[1]E2E_gNB_SW_Upgrade_loops_with_WebUI
#    [Documentation]    This user scenario to test
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    1 hour
#    [Setup]    sleep   5s
#    Adjust gNB_RU Attenuation for L3_call
#    Start_L3_call_and_check_Tput


*** Keywords ***
Start_L3_call_and_check_Tput
    [Documentation]    This user scenario to verify L3Call is ok and Tput for UL and DL besed on TMO configuration.
    ...                Author: jack.zeng@nokia-sbell.com
    [Arguments]    ${lcrid}=${attached_lcrid}    ${dl_throughput}=${dl_throughput}    ${ul_throughput}=${ul_throughput}
    Run Keyword And Ignore Error     CB007834_5G_A_common_keyword.Locked LTE cell
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI4.0
    Attach and check power UE    ue_type=${ue_type}
    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${lcrid}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}
    Power UE Start UL traffic    ul_throughput=${ul_throughput}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${log}   cells=${list_of_cell_ids}
    ...    target_throughput=${ul_expect_throughput}
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...    log=${log}   cells=${list_of_cell_ids}    target_throughput=${dl_expect_throughput}
    Stop UL DL data transfer
    power_ue.UE Detach    ue_type=${ue_type}
    Run Keyword And Ignore Error     UnLocked LTE cell
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error     ute_ue._stop_using_ue    ue_alias=UE_${ue_index}    AND
    ...    Run Keyword And Ignore Error     UnLocked LTE cell    AND
    ...    Run Keyword And Ignore Error    Tear down the connections


Adjust gNB_RU Attenuation for L3_call
    [Documentation]    This user scenario to Adjust gNB_RU Attenuation for L3_call
    ...                Author: jack.zeng@nokia-sbell.com
    [Arguments]    ${att_value}=${20}
    CB007834_5G_A_common_keyword.Adjust gNB_RU Attenuation    cell103_value=${att_value}