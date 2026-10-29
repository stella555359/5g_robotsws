*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/vendor.robot

*** Variables ***

*** Keywords ***
General_Enabling_microDTXAdvanced_on_AVQC
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Enabling microDTXAdvanced on AVQC or AVQL radio
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.12.2023 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    # WESTLAKE-11050 actMicroDTX and actMicroDTXAdvanced become hidden parameter in SBTS25R1 CB013258,
    # adapt the hidden parameter value change by vendor file from SBTS25R1 version
    Run Keyword If    '${stream}'>='SBTS25R1'    Enabling_Hidden_microDTXAdvanced_on_AVQC    version=${stream}
    ...    ELSE    Enabling_Normal_microDTXAdvanced_on_AVQC    version=${stream}

Enabling_Normal_microDTXAdvanced_on_AVQC
    [Arguments]    ${version}
    Selenium Login And Disable Screen Lock    version=${version}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=false
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=true
    ${disable_power_value}   Get the real time power value  object_names=RMOD    interval=15min

    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=true
    ${enable_power_value}   Get the real time power value  object_names=RMOD    interval=15min

    Calculate_Power_Saving_Percent    disable_power_value=${disable_power_value}    enable_power_value=${enable_power_value}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Enabling_Hidden_microDTXAdvanced_on_AVQC
    [Arguments]    ${version}
    ${disable_parameters_dict}    Create Dictionary    actMicroDTXAdvanced=false    actMicroDTX=true
    Modify Vendor File And Full Commissioning    vendor_parameter_dict=${disable_parameters_dict}
    Selenium Login And Disable Screen Lock    version=${version}
    ${disable_power_value}   Get the real time power value  object_names=RMOD    interval=15min

    ${enable_parameters_dict}    Create Dictionary    actMicroDTXAdvanced=true
    Modify Vendor File And Full Commissioning    vendor_parameter_dict=${enable_parameters_dict}
    Selenium Login And Disable Screen Lock    version=${version}
    ${enable_power_value}   Get the real time power value  object_names=RMOD    interval=15min
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

    Calculate_Power_Saving_Percent    disable_power_value=${disable_power_value}    enable_power_value=${enable_power_value}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Calculate_Power_Saving_Percent
    [Arguments]    ${disable_power_value}    ${enable_power_value}
    ${p_value}    Evaluate    "%.4f" % ((${disable_power_value}-${enable_power_value})/${disable_power_value})
    ${per_value}    Evaluate    ${p_value}*100
    log to console   \n Power Saving Percent:${per_value}%
    should be true      0 < ${p_value}
