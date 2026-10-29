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
...         [15.07.2022] - Create Test Suite

Resource    ./../resources/CB008379-common_keywords.robot
Resource    ./../resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup
...     Run Setup

*** Variables ***
${LUA_CFG}=                                 ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${yaml_actDataForwardingForVoNr_NG}=        ${CURDIR}/config/yaml_config/actDataForwardingForVonr_NG_activated.yaml
${yaml_actDataForwardingForVoNr_XN}=        ${CURDIR}/config/yaml_config/actDataForwardingForVonr_Xn_activated.yaml
${yaml_enable_interho}=                     ${CURDIR}/../../resources/yaml_config/inter_gnb_ho.yaml
${yaml_enable_ngho}=                        ${CURDIR}/../../resources/yaml_config/NG_handover.yaml

*** Test Cases ***
CNI85011-B Unsuccessful inter-gNB intra-frequency A3 based handover via XN handover for VoNR
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful intra-frequency inter-gNB handover with unsuccessfull
    ...     data forwarding via Xn-U.
    ...     Data forwarding of the buffered PDCP SDUs/PDUs (incl. End-Marker) of 5QI-1 DRB shall not be performed
    ...     over Xn-U data forwarding tunnel between source node and the target node.
    ...     NRBTS/NRCELL.actDataForwardingForVoNr flag is disabled for XN handover type on target cell
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIO + ASIL
    ...  - gNB2 up and running with two SA cell OnAir
    ...	 - NRCELL-1 simulated on AEQE radio module - NR_BAND: n78
    ...	 - NRCELL-2 simulated on AEQE radio module - NR_BAND: n78
    ...  - simulated gNB3 is up and running with one cell
    ...  - MRBTS-1/NRBTS-1/NRADJGNB-0 is configured for adjacent gNB3
    ...  - MRBTS-1/NRBTS-1/NRADJNRCELL-1 is configured for adjacent gNB3 Cell1
    ...  - Neighbour gNB3 has Ng connection to the AMF that the UE1 is connected to
    ...  - gNB2 Cell1 has NRCELL/NRREL object, which indicates relation to gNB2 neighbor cell
    ...  - NRBTS.actIntraFreqHoSA = true
    ...  - NRBTS/NRDRB.endMarkerTimer = 2000
    ...  - NRBTS/NRDRB_5QI objects are configured for 5QI-1 and 5QI-5
    ...  - NRBTS/NRCELL.actNonVoNRGBRService = true
    ...  - NRBTS/NRCELL.a3MeasEnabled is set to 'rsrpAndRsrq'
    ...  - NRBTS/NRCELL.actDataForwardingForVoNr = 2 (Ng_activated)
    ...  - NRBTS/NRCELL.actVoNR = true
    ...  - NRBTS/NRCELL.actEnhancedVoNR = true
    ...  - NRBTS/NRCELL.actCDrx = disabled
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
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_1503
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - USCNI-85011#B2: Successful Inter-gNB handover via Xn with data forwarding for VoNR packets
    ...         - Eploratory test with actDataForwardingForVoNr flag set to Ng_activated for XN handover type
    ...
    ...  == HISTORY ==
    ...     [15.07.2022]  - Created TC

    [Tags]  B-1

    Prepare test environment B-1

    Attach UE1 with one PDU session and traffic to real gNB then HO to sim gNB3 with 1 nonGBR and 1 GBR 5QI1 QoS flow

    Perform inter-gNB handover from simulated gNB3 to gNB2 for UE1 with 5QI1

    Verify that handoverRequest message contains pdu session with default and 5QI1 QoS flow for UE1
    Verify that PathSwitchRequest contains 2 QoS flows for UE1
    Verify lack of VoNR data forwarding during successfull XN Handover for UE1

    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE1 PDU1 QFI2
    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]   Cleanup after test B-1


CNI85011-B Unsuccessful inter-gNB intra-frequency A5 based handover via NG handover for VoNR
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful intra-gNB handover via NG with
    ...     Data forwarding of the buffered PDCP SDUs/PDUs (incl. End-Marker) of 5QI-1 DRB shall not be performed
    ...     NRBTS/NRCELL.actDataForwardingForVoNr flag is disabled for NG handover type on target cell
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIO + ASIL
    ...  - gNB2 up and running with two SA cell OnAir
    ...	 - NRCELL-1 simulated on AEQE radio module - NR_BAND: n78
    ...	 - NRCELL-2 simulated on AEQE radio module - NR_BAND: n78
    ...  - simulated gNB3 is up and running with one cell
    ...  - MRBTS-1/NRBTS-1/NRADJGNB-0 is configured for adjacent gNB3
    ...  - MRBTS-1/NRBTS-1/NRADJNRCELL-1 is configured for adjacent gNB3 Cell1
    ...  - Neighbour gNB3 has Ng connection to the AMF that the UE1 is connected to
    ...  - gNB2 Cell1 has NRCELL/NRREL object, which indicates relation to gNB2 neighbor cell
    ...  - NRBTS.actIntraFreqHoSA = true
    ...  - NRBTS/NRDRB.endMarkerTimer = 2000
    ...  - NRBTS/NRDRB_5QI objects are configured for 5QI-1 and 5QI-5
    ...  - NRBTS/NRCELL.actNonVoNRGBRService = true
    ...  - NRBTS/NRCELL.a3MeasEnabled is set to 'rsrpAndRsrq'
    ...  - NRBTS/NRCELL.actDataForwardingForVoNr = 1 (Xn_activated)
    ...  - NRBTS/NRCELL.actVoNR = true
    ...  - NRBTS/NRCELL.actEnhancedVoNR = true
    ...  - NRBTS/NRCELL.actCDrx = disabled
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
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_1503
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - USCNI-85011#B3: Successful Intra-NR Inter-gNB handover via NG with data forwarding for VoNR packets
    ...         - Eploratory test with actDataForwardingForVoNr flag set to Xn_activated for NG handover type
    ...
    ...  == HISTORY ==
    ...     [15.07.2022]  - Created TC

    [Tags]  B-2

    Prepare test environment B-2

    Attach UE1 with one PDU session and traffic to real gNB then HO to sim gNB3 with 1 nonGBR and 1 GBR 5QI1 QoS flow

    UE1 triggers successful NG HO from simulated_gNB to real_gNB

    Verify that pdu session with default and 5QI1 QoS flow during NG Handover for UE1
    Verify lack of data forwarding for successfull NG Handover for UE1

    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE1 PDU1 QFI2
    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]   Cleanup after test B-2

*** Keywords ***
Prepare test environment B-1
    Configure   ${yaml_enable_interho}
    Configure   ${yaml_actDataForwardingForVoNr_NG}
    Set GBR data forwarding for XN Handover to on for simulated gNB3
    Set actNonVoNRGBRService flag to True

Prepare test environment B-2
    Configure   ${yaml_enable_interho}
    Configure   ${yaml_enable_ngho}
    Configure   ${yaml_actDataForwardingForVoNr_XN}
    Set actNonVoNRGBRService flag to True
    Set NG based handover for simulated gNB3
    Set indirect data forwarding for AMF1 to on

Cleanup after test B-1
    Detach and kill UE1

Cleanup after test B-2
    Detach and kill UE1
