*** Settings ***
Documentation    This file is for  for siso cloud related cases
...              Please do not modify the file without notification to author
...              Author: Wang jiangrong
...              Contact: jiangrong.wang@nokia-sbell.com
...              Squard: HZ SG7

#Resource    ${CURDIR}/../../../../resources/common/cloudbts_nsa.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/asod.robot


*** Variables ***
${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${RU_ALIAS}             rf_alias
${RU_ADDR}              ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${RU_USER}              ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${RU_PASSWORD}          ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
${RU_PDU_IP}            ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${RU_PDU_PORT}          ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

*** Keywords ***
Check if Cell Administrative State is Locked
    [Documentation]
    ...    this KW is to check cell's administrative status is locked
    [Arguments]  ${Cell}=1
    ${CellStatus}=    Get Status on Cell     ${Cell}
    ${CellAdministrativeState}=    get from dictionary   ${CellStatus}  administrativeState
    Should Be Equal As Strings    ${CellAdministrativeState}     Locked    ignore_case=${True}

Check if Cell Administrative State is Unlocked
    [Documentation]
    ...    this KW is to check cell's administrative status is unlocked
    [Arguments]  ${Cell}=1
    ${CellStatuses}=    Get Status on Cell     ${Cell}
    ${CellAdministrativeState}=    get from dictionary   ${CellStatuses}  administrativeState
    Should Be Equal As Strings    ${CellAdministrativeState}     Unlocked    ignore_case=${True}

Cell Group Lock
    [Documentation]
    ...    this KW is to lock cell group
    sm.lock_cells    operation=Lock  rap_id=1    cell_group_idx=0
    wait until keyword succeeds     60s     10s     Check if cell administrative state is locked

Cell Group Unlock
    [Documentation]
    ...    this KW is to unlock cell group
    sm.unlock_cells  operation=Unlock  rap_id=1    cell_group_idx=0
    wait until keyword succeeds     60s     10s     Check if Cell Administrative State is Unlocked

RU unlock
    [Documentation]
    ...    this KW is to unlock Ru
    [Arguments]  ${RU}=1
    Create Session to WebUI
    megazone_client.unlock_frm    frm_id=${RU}    timeout=30
    [Teardown]   Close Webui Session

Verify ${Status} Status on RU ${RU}
    [Documentation]  ${Status} value:Unlocked; Locked
    ${RUstatuses}=  Get Status on RU    ${RU}
    ${RUoperationalState}=    get from dictionary   ${RUstatuses}  operationalState
    ${RUproceduralStatus}=    get from dictionary   ${RUstatuses}  proceduralStatus
    ${RUavailabilityStatus}=    get from dictionary   ${RUstatuses}  availabilityStatus
    ${RUadministrativeState}=    get from dictionary   ${RUstatuses}  administrativeState
    should be equal  ${RUoperationalState}     enabled  ignore_case=true
    should be equal  ${RUproceduralStatus}     configured   ignore_case=true
    should be equal  ${RUavailabilityStatus}     online     ignore_case=true
    should be equal  ${RUadministrativeState}    ${Status}    ignore_case=true

Get Status on RU
    [Documentation]
    ...    this KW is to get RU status
    [Arguments]  ${RU_id}=1
    Create Session to WebUI
    ${RU_status}=     create dictionary
    ${RU_availablityStatus}=  megazone_client.get_frm   frm_id=${RU_id}    attribute=availabilityStatus
    ${RU_proceduralStatus}=   megazone_client.get_frm   frm_id=${RU_id}    attribute=proceduralStatus
    ${RU_operationalState}=   megazone_client.get_frm   frm_id=${RU_id}    attribute=operationalState
    ${RU_administrativeState}=   megazone_client.get_frm   frm_id=${RU_id}     attribute=administrativeState
    set to dictionary    ${RU_status}    availabilityStatus  ${RU_availablityStatus}
    set to dictionary    ${RU_status}    proceduralStatus  ${RU_proceduralStatus}
    set to dictionary    ${RU_status}    operationalState  ${RU_operationalState}
    set to dictionary    ${RU_status}    administrativeState  ${RU_administrativeState}
    Close Webui Session
    [Return]  ${RU_status}
    [Teardown]   Close Webui Session

Get Status on Cell
    [Arguments]  ${Cell_id}=1
    Create Session to WebUI
    ${Cell_status}=     create dictionary
    ${Cell_availablityStatus}=  megazone_client.get_cell_specific_info  ${Cell_id}   attribute=availabilityStatus
    ${Cell_operationalState}=   megazone_client.get_cell_specific_info  ${Cell_id}   attribute=operationalState
    ${Cell_proceduralStatus}=   megazone_client.get_cell_specific_info  ${Cell_id}   attribute=proceduralStatus
    ${Cell_administrativeState}=   megazone_client.get_cell_specific_info   ${Cell_id}   attribute=administrativeState
    set to dictionary    ${Cell_status}    availabilityStatus  ${Cell_availablityStatus}
    set to dictionary    ${Cell_status}    operationalState  ${Cell_operationalState}
    set to dictionary    ${Cell_status}    proceduralStatus  ${Cell_proceduralStatus}
    set to dictionary    ${Cell_status}    administrativeState  ${Cell_administrativeState}
    [Return]  ${Cell_status}
    [Teardown]  Close Webui Session

Create Session to WebUI
    Wait Until Keyword Succeeds    360 s    5 s    megazone_client.create_session     base_url=${WEBUI_URL}

Close Webui Session
    megazone_client.teardown_session
    

