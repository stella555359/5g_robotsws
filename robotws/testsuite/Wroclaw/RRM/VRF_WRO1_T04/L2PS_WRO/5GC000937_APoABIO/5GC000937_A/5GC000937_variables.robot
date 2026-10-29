*** Settings ***
Documentation
...    copyright: Nokia

*** Variables ***
${UE_CONTEXT_SETUP_REQUEST_BWP_SWITCHING_DELAY}=    f1ap.UEContextSetupRequest_element && nr-rrc.bwp_SwitchingDelay == 0
${UE_CONTEXT_SETUP_REQUEST_BWP_SAME_NUMEROLOGY}=    f1ap.UEContextSetupRequest_element && nr-rrc.bwp_SameNumerology == 0
${OLD_RRC_RECONFIGURATION_PDCCH_TDRA_K0_6}=    SEPARATOR=
...    ((((nr-rrc.rrcReconfiguration_element) && (nr-rrc.k0 == 6)) &&
...    (nr-rrc.mappingType == 0)) && (nr-rrc.startSymbolAndLength == 86))
${RRC_RECONFIGURATION_PDCCH_TDRA_K0_6}=    SEPARATOR=
...    ((((nr-rrc.rrcReconfiguration_element && !nr-rrc.rrcReconfiguration) && (nr-rrc.k0 == 6)) &&
...    (nr-rrc.mappingType == 0)) && (nr-rrc.startSymbolAndLength == 86))
${RRC_RECONF}=    (nr-rrc.rrcReconfiguration_element && !nr-rrc.rrcReconfiguration)
