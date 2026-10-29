*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   common.robot


*** Variables ***
${ue_index}   ${0}


*** Keywords ***
Simple UE Prepare
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE   ue_type=${ue_type}   ue_index=${ue_index}
    Sleep   5s
    power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}
    Sleep   10s

Simple UE Attach
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.UE Attach    ue_type=${ue_type}   ue_index=${ue_index}   retry=${0}   log_type=none
    Sleep   10s


Simple UE Detach
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}
    Sleep   10s
