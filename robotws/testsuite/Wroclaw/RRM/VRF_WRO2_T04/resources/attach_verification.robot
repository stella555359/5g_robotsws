*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Library    ../../resources/cell_utility/cell_utility_backend.py
Resource   ../../resources/preconditions.robot


*** Keywords ***
Get NR PCI From Pcap File
    [Arguments]   ${pcap_file}
    ${cells}   get_primary_and_secondary_physcellids_from_attach_pcap  ${pcap_file}
    Set Test Variable   ${nr_pci}  ${cells}[0]
    [Return]   ${nr_pci}


Verify 5G NSA Attach
    [Documentation]   Taken info about LTE cell (and NR cell if available) from phone and about NR cell
    ...               from 'SgNBAdditionReqAck' message if pcap file as argument
    ...               and return lte and nr PCIs and nr cell state
    [Arguments]    ${ue_alias}=UE_1   ${pcap_file}=None  ${show_on_console}=True
    BuiltIn.Sleep   5s     time to check if atach is stable
    ${CELL_INFO}   Get UE Info   ${ue_alias}  CELL_INFO
    Should Be Equal   ${CELL_INFO}[cellType]   LTENR       ${ue_alias} not attached to 5G NSA   values=False
    ${nr_pci}   Set Variable If   '${CELL_INFO}[nrPci]' == '-1'  not presented   ${CELL_INFO}[nrPci]
    Run Keyword If  '${pcap_file}' != 'None'  Run Keyword   Get NR PCI From Pcap File   ${pcap_file}
    Set Test Variable   ${lte_pci}  ${CELL_INFO}[ltePci]
    Set Test Variable   ${nr_pci}
    Log   \n ${ue_alias} attached to 5G NSA:   console=${show_on_console}
    Log   ${SPACE} 4G cell state: CONNECTED, PCI: ${lte_pci}, RSRP: ${CELL_INFO}[lteDbm] dBm   console=${show_on_console}
    Log   ${SPACE} 5G cell state: CONNECTED, PCI: ${nr_pci}, RSRP: ${CELL_INFO}[nrDbm] dBm   console=${show_on_console}
    [Return]   ${lte_pci}  ${nr_pci}  ${CELL_INFO}[nrState]


Verify 5G SA Attach
    [Arguments]    ${ue}=UE_1   ${offset}=5s   ${show_on_console}=True
    BuiltIn.Sleep   ${offset}     time to check if atach is stable
    ${CELL_INFO}   Get UE Info   ${ue}  CELL_INFO
    Should Be Equal   ${CELL_INFO}[cellType]   NR     ${ue} not attached to 5G SA   values=False
    Should Be Equal As Strings   ${CELL_INFO}[isCellRegistered]   True     ${ue} not attached to 5G SA   values=False
    Log   \n UE: ${ue} pci: ${CELL_INFO}[pci], rsrp: ${CELL_INFO}[dbm]   console=${show_on_console}
    [Return]  ${CELL_INFO}[pci]


Verify 4G Attach
    [Arguments]    ${ue}=UE_1
    ${CELL_INFO}   Get UE Info   ${ue}  CELL_INFO
    Should Contain   ${CELL_INFO}[cellType]   LTE   ${ue} not attached to LTE   values=False
    ${pci}   Set Variable If   '${CELL_INFO}[cellType]' == 'LTENR'  ${CELL_INFO}[ltePci]   ${CELL_INFO}[pci]
    ${dbm}   Set Variable If   '${CELL_INFO}[cellType]' == 'LTENR'  ${CELL_INFO}[lteDbm]   ${CELL_INFO}[dbm]
    Run Keyword If   '${CELL_INFO}[cellType]' == 'LTENR'
    ...   Should Not Be Equal   ${CELL_INFO}[nrState]    CONNECTED   ${ue} still attached to 5G NSA   values=False
    Log To Console   \n ${ue} attached to LTE:
    Log To Console   ${SPACE} 4G cell state: CONNECTED, Physical cell ID: ${pci}, RSRP: ${dbm} dBm
    [Return]   ${pci}
