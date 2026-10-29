*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/scf_operation.robot

*** Variables ***

*** Keywords ***
General_SiSo_Loopback_for_C_U_Plane_transport_connectivity_check_alarm_management_trigger
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] to Check if cOAM BTS receives proper alarms according to connectivity conditions
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.26.2021 - - Created
    ...    *******************
    ...    Notice: There is a NOKIA 1830 TPS switch between RU and BBU, This case does not apply
    ...    if you are using a different switch.
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${CABLINK_id}=2
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${dist_name}    set variable     MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-${CABLINK_id}
    ${currect_value}    selenium_coam.Get Parameter Value    dist_name=${dist_name}
    ...    filter_param=Second endpoint port identifier
    ${new_value}       set variable if      '${currect_value}'=='${1}'    ${2}    ${1}
    ${modify_params}    Get EndpointPortId modify parameters list    new_value=${new_value}    dist_name=${dist_name}
    Modify Parameters In SCF From Webem And Commission    modify_params=${modify_params}
    sleep    300s
    log to console  \n Wait For Fault 61009 Present
    Wait until keyword succeeds    10min    10s    Expect Fault Should Present    faultId=${61009}
    Wait Until Keyword Succeeds    5min    30s    Cell Status Info Should Be Disabled    bs_blocked=Unblocked    cell_type=nr
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    Wait until keyword succeeds    10 min    30 sec   Expect Fault Should Absent    faultId=${61009}
    ...    AND    Selenium Logout And Close Browser

Get EndpointPortId modify parameters list
    [Arguments]    ${new_value}    ${dist_name}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=${dist_name}
    ...    filter_param=Second endpoint port identifier  p_name=secondEndpointPortId  value=${new_value}
    append to list  ${modify_params}  ${item}
    [Return]  ${modify_params}
