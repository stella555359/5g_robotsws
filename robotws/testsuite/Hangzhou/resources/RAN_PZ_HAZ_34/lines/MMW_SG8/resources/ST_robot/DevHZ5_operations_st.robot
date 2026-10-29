*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_7
Resource    ../common_robot/DevHZ5_common_resource.robot

*** Keywords ***
Add 5QI Bearer
    [Arguments]    ${5qi}    ${ue_id}=1
    ${imsi}    set variable    ${tl.ues[${${ue_id}-1}].imsi}
    dynamic_rule_submit    imsi=${imsi}    rule=ADD-5QI${5qi}-XK
    sleep    5s

Del 5QI Bearer
    [Arguments]    ${5qi}    ${ue_id}=1
    ${imsi}    set variable    ${tl.ues[${${ue_id}-1}].imsi}
    dynamic_rule_submit    imsi=${imsi}    rule=DEL-5QI${5qi}-XK
    sleep    5s

Add QCI Bearer
    [Arguments]    ${qci}    ${ue_id}=1
    ${imsi}    set variable    ${tl.ues[${${ue_id}-1}].imsi}
    dynamic_rule_submit    imsi=${imsi}    rule=ADD-5QI${qci}-XK
    sleep    5s

Del QCI Bearer
    [Arguments]    ${qci}    ${ue_id}=1
    ${imsi}    set variable    ${tl.ues[${${ue_id}-1}].imsi}
    dynamic_rule_submit    imsi=${imsi}    rule=DEL-5QI${qci}-XK
    sleep    5s



