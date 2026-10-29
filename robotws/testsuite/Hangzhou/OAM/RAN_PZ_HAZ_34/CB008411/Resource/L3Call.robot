*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
Spark MultiUE L3Call
    [Arguments]   ${ue_index}=${1}
    # ${ue_type_res}   Run Keyword And Ignore Error   Get power UE type
    # ${ue_type}   Run Keyword If   '${ue_type_res[0]}'=='FAIL'   Set Variable   ${tl.ues[${ue_index}].capabilities[1]}
    # ...  ELSE   Set Variable   ${ue_type_res[1]}
    ${ue_type}   Set Variable   sigspark_multiUE
    Log To Console   UE Type: ${ue_type}

    power_ue.Prepare UE   ue_type=${ue_type}   ue_index=${ue_index}   multiue_traffic_config=${MultiUECFG}
    # ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}

    power_ue.UE Attach   ue_type=${ue_type}   ue_index=${ue_index}   retry=${0}
    # Wait Until Keyword Succeeds   3x   2m   Preparation and execution for andriod UE Attach   ue_index=${ue_index}   retry=${0}
    Sleep   5s
    power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}


