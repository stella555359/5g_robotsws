*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py  WITH NAME  coam_parameter
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/scf_comm_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/vendor.robot

*** Keywords ***
General_Power_Consumption_and_Power_Saving_percentage_measured_in_Idle_Load
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Power Saving percentage measured in Idle Load
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 28.10.2020 - - Created
    ...    -update ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1879?filter=-1
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Disable EE feature before this case
    # WESTLAKE-10384 actMicroDTX and actMicroDTXAdvanced become hidden parameter in SBTS25R1 CB013258,
    # adapt the hidden parameter value change by vendor file from SBTS25R1 version
    Run Keyword If    '${stream}'>='SBTS25R1'    Enabling_Hidden_actMicroDTX    ru_index=${ru_index}
    ...    ELSE    Enabling_Normal_actMicroDTX    ru_index=${ru_index}
    [Teardown]    run keywords
    ...    Commissioning SCF And Check On Air for Common    scf_path=${Case_SCF_Path}
    ...    AND   Run Keyword And Ignore Error    Selenium Logout And Close Browser

Disable EE feature before this case
    [Arguments]  ${gnb_index}=0    ${connection}=GNB_OAM
    log to console   \n Disable EE feature before this case
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${modify_params}  create list
    ${new_item1}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    parameter=actNrLBmMimoRTXPowerSaving    value=false
    ${new_item2}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    parameter=actNrMixedSOMethod    value=false
    ${new_item3}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    parameter=lbpsSOMethod    value=cell switch off
    ${new_item4}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    parameter=actNrLBRTXPowerSaving    value=false
    ${new_item5}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    parameter=actNrExtCellSOMethod    value=false
    ${lbpsLoadCalcMethod_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    parameter=lbpsLoadCalcMethod  value=Max(G, C, P)
    append to list  ${modify_params}    ${new_item1}       ${new_item2}    ${new_item3}    ${new_item4}    ${new_item5}
    ...   ${lbpsLoadCalcMethod_dic}
    ${delta_file}     coam_parameter.create_update_parameters_delta    parameters=${modify_params}    connection=${connection}
    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file['updated']}    connection=${connection}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Enabling_Normal_actMicroDTX
    [Arguments]    ${ru_index}=${1}
    log to console   \n enable Power Saving mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=false
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=true
    sleep  20
    ${enable_power_meassure}  Get RMOD Power Measurement    ru_index=${ru_index}

    log to console   \n disable Power Saving mode
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=false
    sleep  20
    ${disable_power_meassure}  Get RMOD Power Measurement    ru_index=${ru_index}

    Calculate_actMicroDTX_Power_Saving_Percent    disable_power_value=${disable_power_meassure}    enable_power_value=${enable_power_meassure}

Enabling_Hidden_actMicroDTX
    [Arguments]    ${ru_index}=${1}    ${connection}=GNB_OAM    ${gnb_index}=0
    log to console   \n disable Power Saving mode
    ${disable_parameters_dict}    Create Dictionary    actMicroDTX=false    actMicroDTXAdvanced=true
    Modify Vendor File And Full Commissioning    vendor_parameter_dict=${disable_parameters_dict}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${disable_power_meassure}  Get RMOD Power Measurement    ru_index=${ru_index}

    log to console   \n enable Power Saving mode
    ${enable_parameters_dict}    Create Dictionary    actMicroDTX=true
    Modify Vendor File And Full Commissioning    vendor_parameter_dict=${enable_parameters_dict}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${enable_power_meassure}  Get RMOD Power Measurement    ru_index=${ru_index}

    Calculate_actMicroDTX_Power_Saving_Percent    disable_power_value=${disable_power_meassure}    enable_power_value=${enable_power_meassure}

Calculate_actMicroDTX_Power_Saving_Percent
    [Arguments]    ${disable_power_value}    ${enable_power_value}
    ${p_value}    Evaluate    "%.4f" % ((${disable_power_value}-${enable_power_value})/${disable_power_value})
    ${per_value}    Evaluate    ${p_value}*100
    log to console   \n Power Saving Percent with idle load:${per_value}%
    should be true      0.13 < ${p_value} < 0.8
