*** Settings ***
Documentation     Author: debbie.wang@nokia-sbell.com
...               get/set TL(gNB or eNB) info or status

Library    Collections
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Resource       login_logout.robot


*** Keywords ***
Check GNB ENB cell on air
    [Documentation]  Description: Check if GNB is in cell on air status
    [Arguments]    ${gNB_ip}    ${connection}=GNB_OAM
    Login BaseStation By Admin     hostname=${gNB_ip}    connection=${connection}
    ${bts_status}    admin.get_bts_statuses    connection=${connection}
    ${gnb_cell_status}    Set variable  ${bts_status['proceduralState']}
    Should be equal as strings    ${gnb_cell_status}    OnAir    msg=GNB or ENB is not on air, Current status is ${gnb_cell_status}
    [Teardown]    Logout BaseStation by Admin    connection=${connection}

Get Cell Status
    [Documentation]   Description: return cell status info DICT.
    ...                            Key are availabilityStatus,administrativeState,operationalState
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${cell_idx}   Convert To Integer   ${cell_idx}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    Login BaseStation By Admin     hostname=${gNB_ip}    connection=${connection}
    ${subcells_status}    admin.get_subcells_status   timeout=${timeout}    connection=${connection}
    ${status_dict}   Catenate   'operationalState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["operationalState"]}',
    ...                         'availabilityStatus':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["availabilityStatus"]}',
    ...                         'administrativeState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["administrativeState"]}'
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}
    [Teardown]    Logout BaseStation by Admin    connection=${connection}

Get Transport Counters
    [Documentation]    get transport counter from COAM
    [Arguments]    ${hostname}    ${username}    ${password}    ${counter_id}    ${alias}=GNB_OAM
    Login BaseStation By Selenium    hostname=${hostname}    username=${username}    password=${password}    alias=${alias}
    ${counters}    selenium_coam.get_transport_counters    counter_id=${counter_id}    coam=${alias}
    ${values_list}    Get Dictionary Values   ${counters}
    [Return]    ${values_list}
    [Teardown]    Logout BaseStation by Selenium    alias=${alias}


