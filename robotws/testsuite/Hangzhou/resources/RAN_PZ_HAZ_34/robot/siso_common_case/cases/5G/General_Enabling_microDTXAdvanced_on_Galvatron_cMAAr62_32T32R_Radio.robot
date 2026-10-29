*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/vendor.robot

*** Variables ***

*** Keywords ***
General_Enabling_microDTXAdvanced_on_Galvatron_cMAAr62_32T32R_Radio
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Enabling microDTXAdvanced on Galvatron cMAAr62 32T32R Radio
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 27.06.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    # WESTLAKE-10384 actMicroDTX and actMicroDTXAdvanced become hidden parameter in SBTS25R1 CB013258,
    # adapt the hidden parameter value change by vendor file from SBTS25R1 version
    Run Keyword If    '${stream}'>='SBTS25R1'    Enabling_Hidden_microDTXAdvanced    ru_index=${ru_index}
    ...    ELSE    Enabling_Normal_microDTXAdvanced    version=${stream}    ru_index=${ru_index}

Enabling_Normal_microDTXAdvanced
    [Arguments]    ${version}    ${ru_index}=${1}
    Selenium Login And Disable Screen Lock    version=${version}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=false
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=true
    ${disable_power_value}   Get RMOD Power Measurement    ru_index=${ru_index}

    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=true
    ${enable_power_value}   Get RMOD Power Measurement    ru_index=${ru_index}

    Calculate_actMicroDTXAdvanced_Power_Saving_Percent    disable_power_value=${disable_power_value}    enable_power_value=${enable_power_value}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Enabling_Hidden_microDTXAdvanced
    [Arguments]    ${ru_index}=${1}    ${connection}=GNB_OAM    ${gnb_index}=0
    log to console   \n disable Power Saving mode
    ${disable_parameters_dict}    Create Dictionary    actMicroDTXAdvanced=false    actMicroDTX=true
    Modify Vendor File And Full Commissioning    vendor_parameter_dict=${disable_parameters_dict}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${disable_power_value}   Get RMOD Power Measurement    ru_index=${ru_index}

    log to console   \n enable Power Saving mode
    ${enable_parameters_dict}    Create Dictionary    actMicroDTXAdvanced=true
    Modify Vendor File And Full Commissioning    vendor_parameter_dict=${enable_parameters_dict}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${enable_power_value}   Get RMOD Power Measurement    ru_index=${ru_index}

    Calculate_actMicroDTXAdvanced_Power_Saving_Percent    disable_power_value=${disable_power_value}    enable_power_value=${enable_power_value}

Calculate_actMicroDTXAdvanced_Power_Saving_Percent
    [Arguments]    ${disable_power_value}    ${enable_power_value}
    ${p_value}    Evaluate    "%.4f" % ((${disable_power_value}-${enable_power_value})/${disable_power_value})
    ${per_value}    Evaluate    ${p_value}*100
    log to console   \n Power Saving Percent:${per_value}%
    should be true      0 < ${p_value} < 0.03
