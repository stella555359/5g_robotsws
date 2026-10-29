*** Settings ***
Resource   ../resources_570/preconditions.robot


*** Variables ***


*** Keywords ***
Verify 5G NSA Attach
    [Arguments]    ${ue}=UE_1
    Sleep   5s     time to check if atach is stable
    ${CELL_INFO}   ue.Get UE Info   ${ue}  CELL_INFO
    Should Be Equal   ${CELL_INFO}[cellType]   LTENR       ${ue} not attached to 5G NSA   values=False
    Should Be Equal   ${CELL_INFO}[nrState]    CONNECTED   ${ue} not attached to 5G NSA   values=False
    ${nr_cell}   Set Variable If   '${CELL_INFO}[nrPci]' == '-1'  'not presented'   ${CELL_INFO}[nrPci]
    Log To Console   \n ${ue} attached to 5G NSA:
    Log To Console   ${SPACE} 4G cell state: CONNECTED, Physical cell ID: ${CELL_INFO}[ltePci], RSRP: ${CELL_INFO}[lteDbm] dBm
    Log To Console   ${SPACE} 5G cell state: CONNECTED, Physical cell ID: ${nr_cell}, RSRP: ${CELL_INFO}[nrDbm] dBm
    [Return]   ${CELL_INFO}[ltePci]  ${CELL_INFO}[nrState]

Verify 4G Attach
    [Arguments]    ${ue}=UE_1
    ${CELL_INFO}   ue.Get UE Info   ${ue}  CELL_INFO
    Should Contain   ${CELL_INFO}[cellType]   LTE   ${ue} not attached to LTE   values=False
    ${pci}   Set Variable If   '${CELL_INFO}[cellType]' == 'LTENR'  ${CELL_INFO}[ltePci]   ${CELL_INFO}[pci]
    ${dbm}   Set Variable If   '${CELL_INFO}[cellType]' == 'LTENR'  ${CELL_INFO}[lteDbm]   ${CELL_INFO}[dbm]
    Run Keyword If   '${CELL_INFO}[cellType]' == 'LTENR'
    ...   Should Not Be Equal   ${CELL_INFO}[nrState]    CONNECTED   ${ue} still attached to 5G NSA   values=False
    Log To Console   \n ${ue} attached to LTE:
    Log To Console   ${SPACE} 4G cell state: CONNECTED, Physical cell ID: ${pci}, RSRP: ${dbm} dBm
    [Return]   ${pci}

