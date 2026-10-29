*** Settings ***
Documentation     Place for Viavi (Cobham) keywords to trigger NSA Call

Library    taf.ue.tm500.rci    WITH NAME    rci
Library    taf.transport.ssh   WITH NAME    ssh


*** Variables ***
${COBHAM IP}           ${tl.ues[0].tma_host.addr}
${COBHAM CMD PORT}     ${tl.ues[0].tma_command_port}
${RADIO_TYPE}          ${tl.gnbs[0].dus[0].rus[0].radio_type}
${SCRIPT DIR}          ${CURDIR}/tma_scripts

${CELL_SEARCH_4G}      FORW 0x00 Ok MTE SETMUERADIOCONTEXTCELL: RETURN CODE:0 SUCCEEDED
${CELL_SEARCH_5G}      FORW 0x00 Ok MTE NRSETMUERADIOCONTEXTCELL: RETURN CODE:0 SUCCEEDED
${ATTACH_4G_5G}        CMPI L2 Random Access Complete :UE Id:


*** Keywords ***
Prepare Cobham Connection
    [Documentation]    Establishes a connection to the command port of TMA
    ...                application, ensures that TMA itself is connected to the
    ...                rest of the hardware, and resets the simulator to its
    ...                starting state.
    rci.Connect To     ${COBHAM IP}    ${COBHAM CMD PORT}
    rci.Send Script    ${SCRIPT DIR}/${RADIO_TYPE}/connect_and_reset.txt

Attach
    [Documentation]    Sends NAS mode and attach scripts to TMA
    [Arguments]        ${cell_search_script_name}=cell_search.txt
    ...                ${attach_script_name}=attach.txt
    ${cell_search_result}=   rci.Send Script    ${SCRIPT DIR}/${RADIO_TYPE}/${cell_search_script_name}
    Should contain     ${cell_search_result}    ${CELL_SEARCH_4G}
    Should contain     ${cell_search_result}    ${CELL_SEARCH_5G}
    sleep              7
    ${attach_result}=        rci.Send Script    ${SCRIPT DIR}/${RADIO_TYPE}/${attach_script_name}
    Should contain x times   ${attach_result}   ${ATTACH_4G_5G}   count=2
    sleep              7

Detach
    [Documentation]    Sends detach script to TMA
    rci.Send Script    ${SCRIPT DIR}/detach.txt
    sleep              7

Close Cobham Connection
    [Documentation]    Resets the simulator, makes TMA application disconnect
    ...                from it, and closes the connection to the TMA.
    rci.Send Script    ${SCRIPT DIR}/reset_and_disconnect.txt
    rci.Disconnect
