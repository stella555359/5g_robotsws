*** Variables ***
${XPATH_SCELL_ADD_DL_CA_SCELL_PCI}    //nr-rrc.sCellToAddModList//*/nr-rrc.sCellConfigCommon_element/
...    nr-rrc.downlinkConfigCommon_element/../nr-rrc.physCellId
${XPATH_SCELL_ADD_UL_CA_SCELL_PCI}    //nr-rrc.sCellToAddModList//*/nr-rrc.sCellConfigCommon_element/
...    nr-rrc.uplinkConfigCommon_element/../nr-rrc.physCellId
${XPATH_PDU_SESSION_RELEASE_CAUSE}    //ngap.PDUSessionResourceToReleaseItemRelCmd_element/ngap.pDUSessionResourceReleaseCommandTransfer//*/ngap.nas
${XPATH_PCELL_PCI}                    //*/nr-rrc.spCellConfig_element//*/nr-rrc.scramblingID0|nr-rrc.physCellId
${XPATH_PCELL_MAXRANK_CHANGE_UL}    //nr-rrc.sCellToAddModList/../nr-rrc.spCellConfig_element//*/nr-rrc.pusch_Config//*/nr-rrc.maxRank
${XPATH_PCELL_MAXRANK_CHANGE_DL}    //nr-rrc.sCellToAddModList/../nr-rrc.spCellConfig_element//*/nr-rrc.pdsch_Config//*/nr-rrc.maxRank


*** Keywords ***
Get xpath for filter pcell maxMIMO layers in RRC message
    [Documentation]    Author: Ding Binmei
    ...    Get xpath for pcell maxMIMO layers for both ul and dl
    [Arguments]    ${pcell_pci}
    ${xpath_pcell_spCellConfig_element_based_on_pci}    Set Variable
    ...    //*/nr-rrc.spCellConfig_element//*/nr-rrc.scramblingID0[@show='${pcell_pci}']/ancestor::nr-rrc.spCellConfig_element
    ${xpath_pcell_maxMIMO_layers_ul_sa}    Set Variable
    ...    ${xpath_pcell_spCellConfig_element_based_on_pci}//*/nr-rrc.pusch_ServingCellConfig//*/nr-rrc.maxMIMO_Layers
    ${xpath_pcell_maxMIMO_layers_ul_nsa}    Set Variable
    ...    ${xpath_pcell_spCellConfig_element_based_on_pci}//*/nr-rrc.pusch_ServingCellConfig//*/nr-rrc.maxMIMO_Layers
    ${xpath_pcell_maxMIMO_layers_ul}    Set Variable    ${xpath_pcell_maxMIMO_layers_ul_sa}|${xpath_pcell_maxMIMO_layers_ul_nsa}
    ${xpath_pcell_maxMIMO_layers_dl_sa}    Set Variable
    ...    ${xpath_pcell_spCellConfig_element_based_on_pci}//*/nr-rrc.pdsch_ServingCellConfig//*/nr-rrc.maxMIMO_Layers
    ${xpath_pcell_maxMIMO_layers_dl_nsa}    Set Variable
    ...    ${xpath_pcell_spCellConfig_element_based_on_pci}//*/nr-rrc.pdsch_ServingCellConfig//*/nr-rrc.maxMIMO_Layers
    ${xpath_pcell_maxMIMO_layers_dl}    Set Variable    ${xpath_pcell_maxMIMO_layers_dl_sa}|${xpath_pcell_maxMIMO_layers_dl_nsa}
    [Return]    ${xpath_pcell_maxMIMO_layers_ul}    ${xpath_pcell_maxMIMO_layers_dl}

Get xpath for filter scell maxMIMO layers in RRC message
    [Documentation]    Author: Ding Binmei
    ...    Get xpath for scell maxMIMO layers for both ul and dl
    [Arguments]    ${scell_pci}
    ${xpath_scell_SCellConfig_element_based_on_pci}    Catenate  SEPARATOR=${EMPTY}      //nr-rrc.sCellToAddModList//*/nr-rrc.SCellConfig_element
    ...    /nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId[@show='${scell_pci}']/ancestor::nr-rrc.SCellConfig_element
    ${xpath_scell_maxMIMO_layers_ul}    Set Variable
    ...    ${xpath_scell_SCellConfig_element_based_on_pci}//*/nr-rrc.pusch_ServingCellConfig//*/nr-rrc.maxMIMO_Layers
    ${xpath_scell_maxMIMO_layers_dl}    Set Variable
    ...    ${xpath_scell_SCellConfig_element_based_on_pci}//*/nr-rrc.pdsch_ServingCellConfig//*/nr-rrc.maxMIMO_Layers
    [Return]    ${xpath_scell_maxMIMO_layers_ul}    ${xpath_scell_maxMIMO_layers_dl}
