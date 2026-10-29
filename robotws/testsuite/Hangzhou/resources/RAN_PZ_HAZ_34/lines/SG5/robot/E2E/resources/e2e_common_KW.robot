*** Settings ***
Documentation    This is common keywords for siso related case steps used in team
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot

*** Variables ***

*** Keywords ***
Check file not Exist in RU
    [Arguments]  ${log_name}=123.txt    ${ru_index}=1
    connect to common unit master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${output}    csn.execute    command=${sudo} ls -l /tmp/${log_name}    connection=RU_${ru_index}
    sleep  2
    log    ${output}
    Should Contain      ${output}      No such file or directory
    [Return]  run keywords  csn.disconnect   connection=RU_${ru_index}    AND
    ...    csn.Disconnect   connection=ASIK Master

Cell block and unblock under specify RU
    [Arguments]   ${cell_list_under_RU}   ${with_call}=${with_call}   ${with_peak}=${with_peak}   ${duration}=${call_duration}
    FOR  ${block_id}  IN  @{cell_list_under_RU}
        ${operate_list}    create list    ${block_id}
        run keyword if   ${with_call}    Get UE From Init File and Make call    cell_list=${operate_list}
        ...    with_peak=${with_peak}    duration=${duration}
        Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        run keyword if   ${with_call}    Get UE From Init File and Make call    cell_list=${operate_list}
        ...    with_peak=${with_peak}    duration=${duration}
    END

#Get RU type
#    [Arguments]  ${ru_index}=1
#    ${ru_info}   COAM get ru detial info by ru index  ru_index=${ru_index}
#    ${ru_type}   set variable  &{ru_info}[productName]
#    [Return]  ${ru_type}
