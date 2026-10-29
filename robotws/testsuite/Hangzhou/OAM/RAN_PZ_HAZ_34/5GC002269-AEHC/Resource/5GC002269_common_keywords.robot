*** Settings ***
Documentation     author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

#Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.hw.optical_switch    WITH NAME    fiberswitch
#Resource          ../../../../../resources/sites/Ulm/Common/connect.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${DU_IP}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Keywords ***
Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${alias}
    ${conn}    set variable    ${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

check Cell after Locked
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=cOAM_admin
    ...    ${operationalState}=Disabled    ${availabilityStatus}=Dependency    ${administrativeState}=Locked
    ${subcell_status}=    Get GNB Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   ${operationalState}
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  ${availabilityStatus}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  ${administrativeState}

Switch fiber channels and verify fiber channels status
    [Arguments]  ${cross_connection_setting}
    ...    ${vendor}=${tl.optical_switches[0].__class__.__name__}
    ...    ${model}=${tl.optical_switches[0].model}
    ...    ${addr}=${tl.optical_switches[0].addr}
    ...    ${port}=4001
    fiberswitch.setup_optical_switch    optical_switch=${vendor}    alias=switch1    model=${model}    addr=${addr}   port=${port}
    fiberswitch.get_optical_switch_channels    optical_switch_device=switch1
    fiberswitch.set_optical_switch_channels    settings=${cross_connection_setting}    optical_switch_device=switch1
    sleep      2s
    fiberswitch.get_optical_switch_channels    optical_switch_device=switch1
    [Teardown]    fiberswitch.teardown     optical_switch_device=switch1

Get Alarm Info
    [Arguments]   ${timeout}    ${connection}=cOAM_admin
    sleep    10s
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=cOAM_admin
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
         ${fault_id}    get from dictionary    ${item}    faultId
         ${fault_name}    get from dictionary    ${item}    faultName
         append to list    ${fault_id_list}    ${fault_id}
         append to list    ${fault_name_list}    ${fault_name}
    END
    [Return]    ${fault_name_list}    ${fault_id_list}

Get GNB Cell Status
    [Arguments]  ${cell_idx}   ${cell_group_idx}   ${timeout}=10   ${connection}=cOAM_admin
    ${subcells_status}    coam.get_subcells_status   timeout=${timeout}    connection=${connection}
    ${status_dict}   Catenate   'operationalState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["operationalState"]}',
    ...                         'availabilityStatus':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["availabilityStatus"]}',
    ...                         'administrativeState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["administrativeState"]}'
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=    coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir