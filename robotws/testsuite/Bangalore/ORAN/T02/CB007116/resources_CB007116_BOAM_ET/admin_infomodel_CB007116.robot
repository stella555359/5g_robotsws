*** Settings ***
Documentation
...     Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com; michal.laski@nokia.com
...     Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com; michal.laski@nokia.com

Library    String
Library    taf.sbts.oam.coam.admin
Library    Collections

*** Variables ***
${ADMIN_INFOMODEL_BTS_HOST}=    192.168.255.129
${ADMIN_ALIAS}=              default

*** Keywords ***
ADMIN INFOMODEL Check If BTS Is OnAir
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

ADMIN INFOMODEL Check If Cell Is In Online State
    [Arguments]    ${cell_id}
    ...            ${timeout}=100
    ...            ${connection}=${ADMIN_ALIAS}
    ${output}=    taf.sbts.oam.coam.admin.Get Cell Specific Info
    ...    cell_id=${cell_id}
    ...    timeout=${timeout}
    ...    connection=${connection}
    should be equal   ${output['status']['availabilityStatus']}    Online

ADMIN INFOMODEL Check If Cell Is In Offline State
    [Arguments]    ${cell_id}
    ...            ${timeout}=100
    ...            ${connection}=${ADMIN_ALIAS}
    ${output}=    taf.sbts.oam.coam.admin.Get Cell Specific Info
    ...    cell_id=${cell_id}
    ...    timeout=${timeout}
    ...    connection=${connection}
    should be equal   ${output['status']['availabilityStatus']}    Offline

ADMIN INFOMODEL Check If Rmod Fan Is '${expected_status}'
    Wait Until Keyword Succeeds  120  10
    ...    ADMIN INFOMODEL Check Fan Status  ${expected_status}

ADMIN INFOMODEL Check Rmod Fan Status
    [Arguments]   ${expected_status}
    ${output}=  taf.sbts.oam.coam.admin.get_rmod_fan_info
    should be equal   ${output['RMOD_R-2']['availabilityStatus']}    ${expected_status}

ADMIN INFOMODEL Check Cabinet Fan Status
    [Arguments]   ${expected_status}
    ${output}=    taf.sbts.oam.coam.admin.get_cabinets_fan_info
    should be equal   ${output['RMOD_R-1']['availabilityStatus']}    ${expected_status}

ADMIN INFOMODEL Check If Fan Is '${expected_status}'
    Wait Until Keyword Succeeds  120  10
    ...    ADMIN INFOMODEL Check Cabinet Fan Status  ${expected_status}

ADMIN INFOMODEL Get Parameter Value
    [Arguments]
    ...    ${dist_name}
    ...    ${dict_param}
    ${dict_value}    ADMIN Get Parameter
    ...    dist_name=${dist_name}
    ...    parameter=${dict_param}
    ${dict_value}    Get From Dictionary
    ...    dictionary=${dict_value}
    ...    key=${dict_param}
    [Return]    ${dict_value}

ADMIN INFOMODEL Check Parameter Value
    [Arguments]
    ...    ${dist_name}
    ...    ${dict_param}
    ...    ${value}
    ${dict_value}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name}
    ...    dict_param=${dict_param}
    ${dict_value}    Convert To String    ${dict_value}
    Should Match Regexp
    ...    string=${dict_value}
    ...    pattern=${value}

ADMIN INFOMODEL Check Parameter Value In Dictionary
    [Arguments]
    ...    ${dist_name}
    ...    ${dict_name}
    ...    ${dict_param}
    ...    ${value}
    ${dict_value}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=
    ${dict_value}    Get From Dictionary
    ...    dictionary=${dict_value}
    ...    key=${dict_name}
    ${dict_value}    Get From Dictionary
    ...    dictionary=${dict_value}
    ...    key=${dict_param}
    Should Match Regexp
    ...    string=${dict_value}
    ...    pattern=${value}

ADMIN Get Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=10
    ...            ${connection}=${ADMIN_ALIAS}
    ${out_parameters}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}