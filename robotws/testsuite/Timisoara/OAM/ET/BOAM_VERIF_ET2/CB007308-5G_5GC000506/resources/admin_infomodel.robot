*** Settings ***
Documentation
...              Author:
...              Maintainer: szymon.swic@nokia.com

Library    String
Library    taf.sbts.oam.coam.admin
Library    Collections
Resource   admin.robot

*** Variables ***
${ADMIN_INFOMODEL_BTS_HOST}=    192.168.255.129
${ADMIN_ALIAS}=              default

*** Keywords ***
ADMIN INFOMODEL Check If BTS Is OnAir
    ${actual_status}    ADMIN INFOMODEL Get BTS Status

    Should Be Equal
    ...    first=${actual_status}
    ...    second=OnAir

ADMIN INFOMODEL Check If BTS Is Configured
    ${actual_status}    ADMIN INFOMODEL Get BTS Status

    Should Be Equal
    ...    first=${actual_status}
    ...    second=Configured

ADMIN INFOMODEL Check If BTS Is NotCommissioned
        ${actual_status}    ADMIN INFOMODEL Get BTS Status

    Should Be Equal
    ...    first=${actual_status}
    ...    second=NotCommissioned


ADMIN INFOMODEL Check If Cell Is In Online State
    [Arguments]    ${cell_id}
    #...            ${cell_type}=nr
    ...            ${timeout}=100
    ...            ${connection}=${ADMIN_ALIAS}
    ${output}=    taf.sbts.oam.coam.admin.Get Cell Specific Info
    ...    cell_id=${cell_id}
    ...    timeout=${timeout}
    ...    connection=${connection}
    should be equal   ${output['status']['availabilityStatus']}    Online

ADMIN INFOMODEL Check If All Cells Are In Online State
    FOR    ${cell_index}    IN    @{OUT_LNCELS_IDS_LIST}
        ADMIN INFOMODEL Check If Cell Is In Online State    ${cell_index}
    END

ADMIN INFOMODEL Check If All Cells Are Not In Online State
    FOR    ${cell_index}    IN    @{OUT_LNCELS_IDS_LIST}
        ADMIN INFOMODEL Check If Cell Is Not In Online State    ${cell_index}
    END

ADMIN INFOMODEL Check If Cell Is Not In Online State
    [Arguments]    ${cell_id}
    #...            ${cell_type}=nr
    ...            ${timeout}=100
    ...            ${connection}=${ADMIN_ALIAS}
    ${output}=    taf.sbts.oam.coam.admin.Get Cell Specific Info
    ...    cell_id=${cell_id}
    ...    timeout=${timeout}
    ...    connection=${connection}
    should not be equal   ${output['status']['availabilityStatus']}    Online

ADMIN INFOMODEL Check If Cell Is In Offline State
    [Arguments]    ${cell_id}
    #...            ${cell_type}=nr
    ...            ${timeout}=100
    ...            ${connection}=${ADMIN_ALIAS}
    ${output}=    taf.sbts.oam.coam.admin.Get Cell Specific Info
    ...    cell_id=${cell_id}
    ...    timeout=${timeout}
    ...    connection=${connection}
    should be equal   ${output['status']['availabilityStatus']}    Offline

ADMIN INFOMODEL Is Rmod operational
    [Arguments]  ${component_id}
    ${ru_statuses}  ADMIN Get RU Statuses    ${component_id}
    ${result}  run keyword and return status  should be equal  ${ru_statuses['operationalState']}    Enabled
    [Return]  ${result}

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

ADMIN INFOMODEL Get BTS Status
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState

    [Return]  ${actual_value}

