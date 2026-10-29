*** Settings ***
Documentation
...    Author: Lv Feng
...    Maintainer: Zhou Zhiqiang, Du Ning
...    Contact: zhiqiang.q.zhou@nokia-sbell.com, ning.du@nokia-sbell.com
...    Common KWs use to operate the UE and Traffic
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/03.+Module+of+Traffic+UE+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test/

Resource    ./library/_Traffic_UE_Operation.robot
Library    ./library/_Traffic_UE_Operation.py

*** Keywords ***
Traffic UE Operation
    [Arguments]    ${operation}
    ...            ${ue_index}=0
    ...            &{kwargs}
    [Documentation]     Controls UE to manage traffics
    ...   https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/03.+Module+of+Traffic+UE+Operation
    ...   | Input Parameters | Man. |                  Description                              |
    ...   |     operation    | yes  | attach, detach, reboot, get, set,                         |
    ...   |                  |      | start voice call, stop voice call,                        |
    ...   |                  |      | start traffic, stop traffic,                              |
    ...   |                  |      | check average tput, check peak tput                       |
    ...   |                  |      | send cmd                                                  |
    ...   |     ue_index     | yes  | index of the ue of interest in tl.ues[]                   |
    ...   |      kwargs      | yes  | other keyword arguments varies according to operation     |
    ${ue_config}    parse_ue_config    ${ue_index}
    Run Keyword And Return    _Traffic_UE_Operation.${ue_config.ue_type}.${operation}    ${ue_config}    &{kwargs}