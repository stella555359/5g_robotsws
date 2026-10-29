*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CNI-85011: Data forwarding of VoNR packets during HO
...			The main purpose of this CNI is to support data forwarding for VoNR DRB (i.e. 5QI-1) during inter gNB handover
...			Lack of data forwarding for VoNR causes packet losses and has considerable impact to voice quality during handover
...
...      == TEST SET NAME ==
...         CNI-85011 Data forwarding of VoNR packets during HO
...
...      == TESTING SPLIT==
...         CNI-85011-B1 Successful Intra-gNB handover with reduced packet loss for VoNR
...			CNI-85011-B2 Successful Inter-gNB handover via XN with data forwarding for VoNR packets
...			CNI-85011-B3 Successful Intra-NR Inter-gNB handover via NG with data forwarding for VoNR packets
...
...      == AUTHORS ==
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CNI-85011 CFAM
...
...      == HISTORY ==
...         [24.06.2022] - Create Test Suite

Resource    ./../resources/CB008379-common_keywords.robot
Resource    ./../resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup
...     Run Setup

*** Variables ***
${LUA_CFG}=                                     ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${emergency_call}=                              ${CURDIR}/config/yaml_config/emergency_call.yaml
${intra_gNB_HO_A5}=                             ${CURDIR}/config/yaml_config/intra_gNB_HO_A5.yaml
${yaml_actDataForwardingForVonr_activated}=     ${CURDIR}/config/yaml_config/actDataForwardingForVonr_Xn_and_NG_activated.yaml
${yaml_enable_intraho}=                         ${CURDIR}/../../resources/yaml_config/intra_gnb_ho.yaml

*** Test Cases ***
CNI85011-B1 Successful intra-gNB intra-frequency A3 based handover for VoNR
    [Tags]    B1-1    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful intra-frequency intra-gNB handover with reduced packet loss
    ...     for VoNR DRB. Due to environment limitations test does not cover check of "Buffered PDCP SDUs/PDUs shall
    ...     be sent to UE via target cell".
    ...     Handover is based on A3 measurement with 5QI-1 and 5QI-5
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIO + ASIL
    ...  - gNB2 up and running with two SA cell OnAir
    ...	 - NRCELL-1 simulated on AEQE radio module - NR_BAND: n78
    ...	 - NRCELL-2 simulated on AEQE radio module - NR_BAND: n78
    ...  - Both cell1 and cell2 have NRCELL/NRREL object, which indicates relation to neighbor cell
    ...  - NRCELL-1 and NRCELL-2 have the same frequencies
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrp' for all cells
    ...  - NRBTS.actIntraFreqHoSA = true
    ...  - NRBTS/NRCELL.actNonVoNRGBRService = true
    ...  - NRBTS/NRCELL.actDataForwardingForVoNr = Xn_and_NG_activated
    ...  - NRBTS/NRCELL.actVoNR = true
    ...  - NRBTS/NRCELL.actEnhancedVoNR = true
    ...  - NRBTS/NRCELL.actCDrx = disabled
    ...  - NRBTS/NRDRB_5QI objects are configured for 5QI-1 and 5QI-5
    ...  - RLC mode = RLC UM
    ...  - PDCP SN size = 12 bit
    ...  - UE - Airphone simulator
    ...  - UE is VoNR capable in FR1
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio modules - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17372
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - USCNI-85011#B1: Successful Intra-gNB handover with reduced packet loss for VoNR DRB
    ...
    ...  == HISTORY ==
    ...     [24.06.2022]  - Created TC


    Prepare test environment B1-1

    Attach UE-1 to gNB2 cell1 with ICS during single PDU session setup
    Add to UE1 PDU1 session QoS flows with 5QI from list [1] and delete QoS flows with 5QI from list []
    Run 5MBps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE1 PDU1 QFI2 and wait 5 seconds

    Perform intra-frequency intra-gNB handover from gNB2 cell1 to cell2 for UE1

    Verify in RRCReconfiguration that UE1 2 DRBs were added
    On failure        Stop and verify 5MBps UL and DL traffic on UE1 PDU1 QFI2
    On failure        Stop and verify 5MBps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]   Cleanup after test B1-1


CNI85011-B1 Successful intra-gNB intra-frequency A5 based handover for VoNR belongs to emergency call
    [Tags]    B1-2    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful intra-frequency intra-gNB handover with reduced packet loss
    ...     for VoNR DRB. Due to environment limitations test does not cover check of "Buffered PDCP SDUs/PDUs shall
    ...     be sent to UE via target cell".
    ...     Handover is based on A5 measurement with 5QI-1 and 5QI-5
    ...     5QI-1 belongs to an emergency call
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIO + ASIL
    ...  - gNB2 up and running with two SA cell OnAir
    ...	 - NRCELL-1 simulated on AEQE radio module - NR_BAND: n78
    ...	 - NRCELL-2 simulated on AEQE radio module - NR_BAND: n78
    ...  - Both cell1 and cell2 have NRCELL/NRREL object, which indicates relation to neighbor cell
    ...  - NRCELL-1 and NRCELL-2 have the same frequencies
    ...  - NRBTS/actIntraFreqHoSA is set to true
    ...  - NRBTS/NRCELL/a5MeasEnabled is set to 'rsrp' for all cells
    ...  - NRBTS/NRCELL.actNonVoNRGBRService = true
    ...  - NRBTS/NRCELL.actDataForwardingForVoNr = Xn_and_NG_activated
    ...  - NRBTS/NRCELL.actVoNR = true
    ...  - NRBTS/NRCELL.actEnhancedVoNR = true
    ...  - NRBTS/NRCELL.actEmergencyCall = true
    ...  - NRBTS/NRCELL.arpPrioEmergencyCall = 1
    ...  - NRBTS/NRCELL.numOfRadioResReservForEmergency = 2
    ...  - NRBTS/NRCELL.numOfDrbsReservForEmergency = 2
    ...  - NRBTS/NRDU.numOfDrbsReservForEmergency = 4
    ...  - NRBTS/NRDRB_5QI objects are configured for 5QI-1 and 5QI-5
    ...  - NRBTS/NRDRB.endMarkerTimer = 500
    ...  - AMF supports Emergency services
    ...  - RLC mode = RLC UM
    ...  - PDCP SN size = 12 bit
    ...  - UE - Airphone simulator
    ...  - UE is VoNR capable in FR1
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio modules - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17372
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - USCNI-85011#B1: Successful Intra-gNB handover with reduced packet loss for VoNR DRB
    ...         - Alternate Scenario: 5QI-1 may belong to an emergency call
    ...
    ...  == HISTORY ==
    ...     [24.06.2022]  - Created TC

    Prepare test environment B1-2

    Emergency UE1 attach to gNB2 cell1
    Verify that Establishment Cause IE set to emergency for UE1

    Add to UE1 PDU1 session QoS flows with 5QI from list [1] and delete QoS flows with 5QI from list []
    Run 5MBps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE1 PDU1 QFI2 and wait 5 seconds

    Perform intra-gNB A5 handover from gNB2 cell1 to cell2 for UE1

    Verify in RRCReconfiguration that UE1 2 DRBs were added
    On failure        Stop and verify 5MBps UL and DL traffic on UE1 PDU1 QFI2
    On failure        Stop and verify 5MBps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]   Cleanup after test B1-2

*** Keywords ***
Prepare test environment B1-1
    Set actNonVoNRGBRService parameter for both cells
    Configure       ${yaml_enable_intraho}
    Configure       ${yaml_actDataForwardingForVonr_activated}

Prepare test environment B1-2
    Set actNonVoNRGBRService parameter for both cells
    Set up emergency ICS for UE1
    Configure       ${intra_gNB_HO_A5}
    Configure       ${emergency_call}

Cleanup after test B1-1
    Detach and kill UE1

Cleanup after test B1-2
    Detach and kill UE1
