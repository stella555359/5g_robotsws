*** Settings ***
Documentation    Cloud alarms keywords.
...              Authors:    Patryk Tatarek, Jagoda Kubacka
...              Contact:    patryk.tatarek@nokia.com, jagoda.kubacka@nokia.com

Resource    ../connections/connections.robot
Resource    taf/rfrl/cbts/robot/vcu/vcu_fm.robot
Resource    taf/rfrl/cbts/robot/vdu/vdu_fm.robot
Resource    taf/rfrl/cbts/robot/webem_operations.robot

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin

*** Keywords ***

#################################################### Main  Keywords ####################################################

Get Active Alarms From BTS
    [Documentation]    Description:    Return a list of all active alarms
    ...                Input:          hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Output:         List of active alarms on chosen hw
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    ${alarms}=         Run Keyword If    '${hw_type}'=='vCU'    Get Active Alarms From vCU    pre-conn=${pre-connection}
    ...                ELSE IF           '${hw_type}'=='vDU'    Get Active Alarms from vDU    pre-conn=${pre-connection}
    ...                ELSE               FAIL                  hw_type doesn't exist
    [Return]           ${alarms}

No Alarm Should be Active
    [Documentation]    Description:    Check if there is no active alarm on choosen hw
    ...                Input:          hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    ${alarms}=         Run Keyword If    '${hw_type}'=='vCU'    Get Active Alarms From vCU    pre-conn=${pre-connection}
    ...                ELSE IF           '${hw_type}'=='vDU'    Get Active Alarms from vDU    pre-conn=${pre-connection}
    ...                ELSE               FAIL                  hw_type doesn't exist
    Should Be True     "${alarms["total"]}"=="0"

Get Historical Alarms From BTS
    [Documentation]    Description:    Return a list of all historical alarms
    ...                Input:          hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Output:         List of historical alarms on chosen hw
    ...                Author:         julia.wijas@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    ${alarms}=         Run Keyword If    '${hw_type}'=='vCU'    Get Historical Alarms From vCU    pre-conn=${pre-connection}
    ...                ELSE IF           '${hw_type}'=='vDU'    Get Historical Alarms from vDU    pre-conn=${pre-connection}
    ...                ELSE               FAIL                  hw_type doesn't exist
    [Return]           ${alarms}

Get Cell ID
    [Documentation]    Description:    Get cells ID
    ...                Author:         julia.wijas@nokia.com
    [Arguments]        ${hw_type}=${NONE}     ${connection}=${NONE}
    ${cell_ID}=        Run Keyword If        '${hw_type}'=='vCU'    vcu_admin.get_cells_statuses
    ...                                                             connection=${connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.get_vdu_cells_status
    ...    ELSE        FAIL                  hw_type doesn't exist
    @{cells_ID}=       Create List
    FOR    ${cell}     IN    @{cell_ID}
        ${cell_ID}=    Get From Dictionary    ${cell}    id
        Append To List       ${cells_ID}    ${cell_ID}
    END
    [Return]           ${cells_ID}

Lock Cell
    [Documentation]    Description:    Lock cell with specified id
    ...                Author:         julia.wijas@nokia.com
    [Arguments]        ${cells_ID}    ${connection}   ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    vcu_admin.lock_cells
    ...                                      cell_ids=${cells_ID}
    ...                                      connection=${connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.lock_cells
    ...                                      cell_id_list=${cells_ID}
    ...                                      vdu_connection=${connection}
    ...    ELSE        FAIL                  hw_type doesn't exist
    Log    Cell with ID: ${cells_ID} is locking        console=true

Unlock Cell
    [Documentation]    Description:    Unlock cell with specified id
    ...                Author:         julia.wijas@nokia.com
    [Arguments]        ${cells_ID}    ${connection}   ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    vcu_admin.unlock_cells
    ...                                      cell_ids=${cells_ID}
    ...                                      connection=${connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.unlock_cells
    ...                                      cell_id_list=${cells_ID}
    ...                                      vdu_connection=${connection}
    ...    ELSE        FAIL                  hw_type doesn't exist
    Log    Cell with ID: ${cells_ID} is unlocking     console=true

################################################ Supplementary Keywords ################################################

_Get Active Alarms From vCU
    [Arguments]      ${pre-conn}=${NONE}
    ${temp_conn}=    Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...              ELSE    Set Variable      ${pre-conn}
    ${list}=         vcu_admin.get_active_alarms    connection=${temp_conn}
    [Return]         ${list}
    [Teardown]       Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                            connection=${temp_conn}    hw_type=vCU

_Get Active Alarms from vDU
    [Arguments]      ${pre-conn}=${NONE}
    ${temp_conn}=    Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...              ELSE    Set Variable      ${pre-conn}
    ${list}=         vdu_admin.vdu_get_active_alarms    vdu_connection=${temp_conn}
    [Return]         ${list}
    [Teardown]       Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                            connection=${temp_conn}    hw_type=vDU

_Get Historical Alarms From vCU
    [Arguments]      ${pre-conn}=${NONE}
    ${temp_conn}=    Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...              ELSE    Set Variable      ${pre-conn}
    ${list}=         vcu_admin.get_historical_alarms    connection=${temp_conn}
    [Return]         ${list}
    [Teardown]       Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                            connection=${temp_conn}    hw_type=vCU

_Get Historical Alarms from vDU
    [Arguments]      ${pre-conn}=${NONE}
    ${temp_conn}=    Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...              ELSE    Set Variable      ${pre-conn}
    ${list}=         vdu_admin.vdu_get_historical_alarms    vdu_connection=${temp_conn}
    [Return]         ${list}
    [Teardown]       Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                            connection=${temp_conn}    hw_type=vDU
