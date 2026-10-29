*** Settings ***
Resource   Common.robot

*** Variables ***


*** Keywords ***
CB009927 L3 Call
    ${ue_type_res}   Run Keyword And Ignore Error   Get power UE type
    ${ue_type}   Run Keyword If   '${ue_type_res[0]}'=='FAIL'   Set Variable   ${tl.ues[${ue_index}].capabilities[1]}
    ...  ELSE   Set Variable   ${ue_type_res[1]}

    power_ue.Prepare UE   ue_type=${ue_type}   ue_index=${ue_index}

    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    run keyword if  not '${mode_status}'=='1'   power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}



    Run Keyword If   "${TESTLINE_TYPE}"=="CLASSICAL"   power_ue.UE Attach   ue_type=${ue_type}   ue_index=${ue_index}   retry=${0}
    ...   ELSE IF   "${TESTLINE_TYPE}"=="CLOUD"   power_UE_Cloud.UE Attach    ue_index=${ue_index}   retry=${0}

    Sleep   5s
    power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}
