*** Settings ***
Documentation
...              Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...              Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

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

ADMIN INFOMODEL Check If BTS Is Configured
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=Configured

ADMIN INFOMODEL Check If Cell Is In Online State
    [Arguments]    ${cell_id}
    ...            ${cell_type}=nr
    ...            ${timeout}=100
    ...            ${connection}=${ADMIN_ALIAS}
    ${output}=    taf.sbts.oam.coam.admin.Get Cell Specific Info
    ...    cell_id=${cell_id}
    ...    timeout=${timeout}
    ...    connection=${connection}
    should be equal   ${output['status']['availabilityStatus']}    Online

ADMIN INFOMODEL Check If Cell Is In Offline State
    [Arguments]    ${cell_id}
    ...            ${cell_type}=nr
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

ADMIN INFOMODEL Check ReasoningStatus Value
    [Arguments]
    ...    ${dist_name}
    ...    ${value}
    ${dict_value}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=
    ${dict_value}    Get From Dictionary
    ...    dictionary=${dict_value}
    ...    key=stateInfo
    ${dict_value}    Get From Dictionary
    ...    dictionary=${dict_value}
    ...    key=reasoningStatus
    list should contain value  ${dict_value}  ${value}

ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    [Arguments]
    ...    ${dist_name}
    ${dict_value}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=
    ${dict_value}    Get From Dictionary
    ...    dictionary=${dict_value}
    ...    key=stateInfo
    ${dict_value}    Get From Dictionary
    ...    dictionary=${dict_value}
    ...    key=reasoningStatus
    should be empty  ${dict_value}

ADMIN INFOMODEL Check AvailabilityStatus Value
    [Arguments]
    ...    ${dist_name}
    ...    ${value}
    ${dict_value}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=

    ${key_status}  Run Keyword And Return Status
    ...   Dictionary Should Contain Key  ${dict_value}  stateInfo
    Run Keyword If   '${key_status}' == 'True'   Check AvailabilityStatus with stateInfo    ${dict_value}   ${value}
    Run Keyword If   '${key_status}' == 'False'   Check AvailabilityStatus without stateInfo    ${dict_value}   ${value}

Check AvailabilityStatus with stateInfo
    [Arguments]    ${dict_value}   ${value}
    ${dict_value}    Get From Dictionary   dictionary=${dict_value}   key=stateInfo
    ${dict_value}    Get From Dictionary   dictionary=${dict_value}   key=availabilityStatus
    should be equal as strings  ${dict_value}  ${value}   ignore_case=true

Check AvailabilityStatus without stateInfo
    [Arguments]    ${dict_value}   ${value}
    ${dict_value}    Get From Dictionary   dictionary=${dict_value}   key=availabilityStatus
    should be equal as strings  ${dict_value}  ${value}   ignore_case=true


ADMIN INFOMODEL Check if Cell is in availabilityStatus Failed
    ${status}   Run Keyword And Return Status    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/NRBTS_R-1/NRCELL_R-1
    ...      value=Failed
    Run Keyword Unless   ${status}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/NRBTS_R-1/NRCELL_R-1
    ...      value=failed

ADMIN INFOMODEL Check if Cell is in availabilityStatus Online
    ${status}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/NRBTS_R-1/NRCELL_R-1
    ...      value=Online
    Run Keyword Unless   ${status}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/NRBTS_R-1/NRCELL_R-1
    ...      value=None

ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Offline
    [Arguments]      ${timeout}=30s
    ${status}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...      value=Offline
    Run Keyword Unless   ${status}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...      value=off line

ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Online
    [Arguments]      ${timeout}=30s
    ${status}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...      value=Online
    Run Keyword Unless   ${status}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...      value=None

ADMIN INFOMODEL Check if RMOD is in availabilityStatus NotInstalled
    [Arguments]      ${timeout}=30s
    ${status}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/RMOD_R-1
    ...      value=NotInstalled
    Run Keyword Unless   ${status}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/RMOD_R-1
    ...      value=not installed

ADMIN INFOMODEL Check if RMOD is in availabilityStatus Online
    [Arguments]      ${timeout}=30s
    ${status}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/RMOD_R-1
    ...      value=Online
    Run Keyword Unless   ${status}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/RMOD_R-1
    ...      value=None

ADMIN INFOMODEL Check AdministrativeState Value
    [Arguments]
    ...    ${dist_name}
    ...    ${value}
    ${dict_value}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=

    ${dict_value}    Get From Dictionary   dictionary=${dict_value}   key=administrativeState
    should be equal as strings  ${dict_value}  ${value}   ignore_case=true
