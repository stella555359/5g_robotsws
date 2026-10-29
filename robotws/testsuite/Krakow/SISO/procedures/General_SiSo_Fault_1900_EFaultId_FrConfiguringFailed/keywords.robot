*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot

*** Keywords ***
Get Cell Dist Name for pMax Change
    ${dist_name}  Get Random Cell Dist Name
    [Return]    ${dist_name}

Save current pMax value
    ${pmax_original_value}    Get pMax value
    [Return]    ${pmax_original_value}

Change pMax to unexpected value
    [Arguments]    ${dist_name}    ${pmax_test_value}
     Perform Configuration Parameter Recommissioning On gNB   dist_name=${dist_name}
    ...    param_name=pMax   param_value=${pmax_test_value}   skip_parameter_relation_errors=true
    ...    timeout=300

Restore pMax to original value
    [Arguments]    ${dist_name}    ${pmax_original_value}    ${timeout_reset_RU}
    Perform Configuration Parameter Recommissioning On gNB   dist_name=${dist_name}
    ...    param_name=pMax  param_value=${pmax_original_value['value']}   skip_parameter_relation_errors=true
    ...    timeout=300
    Reset All Radio Units on gNB    timeout=${timeout_reset_RU}
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    Verify gNB Configuration Parameters Have Expected Values    param_dict=${pmax_original_value['dict']}
