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
...         [01.08.2022] - Create Test Suite

Resource    ./../resources/CB008379-common_keywords.robot
Resource    ./../resources/CB008379-verify_imports.robot

Force Tags    CONFIGURED    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup
...     Run Setup

*** Variables ***
${LUA_CFG}=                             ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${yaml_actDataForwardingForVoNr_NG}=    ${CURDIR}/config/yaml_config/actDataForwardingForVonr_NG_activated.yaml
${yaml_actDataForwardingForVoNr_XN}=    ${CURDIR}/config/yaml_config/actDataForwardingForVonr_Xn_activated.yaml
${yaml_enable_emergency}=               ${CURDIR}/config/yaml_config/emergency_call.yaml
${yaml_enable_interho}=                 ${CURDIR}/../../resources/yaml_config/inter_gnb_ho.yaml
${yaml_enable_ngho}=                    ${CURDIR}/../../resources/yaml_config/NG_handover.yaml

*** Test Cases ***
CNI85011-B Robustness TC1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful intra-frequency inter-gNB XN handover with direct data forwarding
    ...     for multiple UEs with VoNR, GBR and emergency call
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
    ...  - NRBTS/NRCELL.actNonVoNRGBRService = true
    ...  - NRBTS/NRCELL.a5MeasEnabled = rsrp
    ...  - NRBTS/NRCELL.actDataForwardingForVoNr = 1 (Xn_activated)
    ...  - NRBTS/NRCELL.actVoNR = true
    ...  - NRBTS/NRCELL.actEnhancedVoNR = true
    ...  - NRBTS/NRCELL.actCDrx = disabled
    ...  - NRBTS/NRDRB_5QI objects are configured for 5QI-1,2,3,4,72,128
    ...  - NRBTS/NRDRB.endMarkerTimer = 2000
    ...  - NRBTS/NRCELL.actEmergencyCall = true
    ...  - NRBTS/NRCELL.arpPrioEmergencyCall = 1
    ...  - NRBTS/NRCELL.numOfRadioResReservForEmergency = 2
    ...  - NRBTS/NRCELL.numOfDrbsReservForEmergency = 2
    ...  - NRBTS/NRDU.numOfDrbsReservForEmergency = 4
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
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17374
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
    ...         - Robustness test with multiple UEs with VoNR, GBR and emergency call
    ...
    ...  == HISTORY ==
    ...     [15.07.2022]  - Created TC

    [Tags]  B-1

    Prepare test environment B-1

    Log to console      1/5
    Repeat Successful inter-gNB intra-frequency XN Handover with VoNR and 5QI2 for emergency call UE1

    Log to console      2/5
    Repeat Successful inter-gNB intra-frequency XN Handover with VoNR and 5QI2 for emergency call UE2

    Log to console      3/5
    Repeat Successful inter-gNB intra-frequency XN Handover with VoNR and 5QI3 for emergency call UE3

    Log to console      4/5
    Repeat Successful inter-gNB intra-frequency XN Handover with VoNR and 5QI72 for emergency call UE4

    Log to console      5/5
    Repeat Successful inter-gNB intra-frequency XN Handover with VoNR and 5QI128 for emergency call UE5

    [Teardown]   Cleanup after test B-1


CNI85011-B Robustness TC2
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful intra-frequency inter-gNB NG handover with direct data forwarding
    ...     for multiple UEs with VoNR, GBR and emergency call
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
    ...  - NRBTS.actIntraNrNgHo = sourceAndTarget
    ...  - NRBTS.handoverAllowedSA = XnHoNotAllowed
    ...  - NRBTS/NRCELL.actNonVoNRGBRService = true
    ...  - NRBTS/NRCELL.a5MeasEnabled = rsrp
    ...  - NRBTS/NRCELL.actDataForwardingForVoNr = 2 (NG_activated)
    ...  - NRBTS/NRCELL.actVoNR = true
    ...  - NRBTS/NRCELL.actEnhancedVoNR = true
    ...  - NRBTS/NRCELL.actCDrx = disabled
    ...  - NRBTS/NRDRB_5QI objects are configured for 5QI-1,2,3,4,72,128
    ...  - NRBTS/NRDRB.endMarkerTimer = 2000
    ...  - NRBTS/NRCELL.actEmergencyCall = true
    ...  - NRBTS/NRCELL.arpPrioEmergencyCall = 1
    ...  - NRBTS/NRCELL.numOfRadioResReservForEmergency = 2
    ...  - NRBTS/NRCELL.numOfDrbsReservForEmergency = 2
    ...  - NRBTS/NRDU.numOfDrbsReservForEmergency = 4
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
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_17375
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
    ...         - Robustness test with multiple UEs with VoNR, GBR and emergency call
    ...
    ...  == HISTORY ==
    ...     [15.07.2022]  - Created TC

    [Tags]  B-2

    Prepare test environment B-2

    Log to console      1/5
    Repeat Successful inter-gNB intra-frequency NG Handover with VoNR and 5QI2 for emergency call UE1

    Log to console      2/5
    Repeat Successful inter-gNB intra-frequency NG Handover with VoNR and 5QI3 for emergency call UE2

    Log to console      3/5
    Repeat Successful inter-gNB intra-frequency NG Handover with VoNR and 5QI4 for emergency call UE3

    Log to console      4/5
    Repeat Successful inter-gNB intra-frequency NG Handover with VoNR and 5QI72 for emergency call UE4

    Log to console      5/5
    Repeat Successful inter-gNB intra-frequency NG Handover with VoNR and 5QI128 for emergency call UE5

    [Teardown]   Cleanup after test B-2


*** Keywords ***
Prepare test environment B-1
    Configure       ${yaml_enable_interho}
    Configure       ${yaml_actDataForwardingForVoNr_XN}
    Configure       ${yaml_enable_emergency}
    Set GBR data forwarding for XN Handover to on for simulated gNB3
    Set actNonVoNRGBRService flag to True

Prepare test environment B-2
    Configure       ${yaml_enable_interho}
    Configure       ${yaml_enable_ngho}
    Configure       ${yaml_actDataForwardingForVoNr_NG}
    Configure       ${yaml_enable_emergency}
    Set NG based handover for simulated gNB3
    Set indirect data forwarding for AMF1 to on

Cleanup after test B-1
    Detach and kill UEs from 1 to 5

Cleanup after test B-2
    Detach and kill UEs from 1 to 5

Repeat Successful inter-gNB intra-frequency XN Handover with VoNR and 5QI${5qi_gbr:\d+} for emergency call UE${ue_id:\d+}
    Emergency UE${ue_id} attach to gNB2 cell1
    Verify that Establishment Cause IE set to emergency for UE${ue_id}

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [1,${5qi_gbr}] and delete QoS flows with 5QI from list []

    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI3 and wait 5 seconds

    UE${ue_id} triggers Inter-gNB Handover from real gNB2 to simulated gNB3 by sending A3 measurement
    Sleep  10

    Perform inter-gNB handover from sim gNB3 to gNB2 for UE${ue_id} with 5QI1, 5QI5 and 5QI${5qi_gbr}

    Verify that XNAP Inter-gNB Handover was completed successfully for UE${ue_id} with 5QI1, 5QI5 and 5QI${5qi_gbr} QoS flows
    Verify data forwarding for 5QI1, 5QI${5qi_gbr} and 5QI5 during successfull XN Handover for UE${ue_id}
    Verify that PathSwitchRequest contains 3 QoS flows for UE${ue_id}


Repeat Successful inter-gNB intra-frequency NG Handover with VoNR and 5QI${5qi_gbr:\d+} for emergency call UE${ue_id:\d+}
    Emergency UE${ue_id} attach to gNB2 cell1
    Verify that Establishment Cause IE set to emergency for UE${ue_id}

    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [1,${5qi_gbr}] and delete QoS flows with 5QI from list []

    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI3 and wait 5 seconds

    UE${ue_id} triggers Inter-gNB Handover from real gNB2 to simulated gNB3 by sending A3 measurement
    Sleep  10

    UE${ue_id} triggers successful NG HO from simulated_gNB to real_gNB

    Verify that pdu session with 5QI1, 5QI${5qi_gbr} and 5QI5 QoS flows during NG Handover for UE${ue_id}
    Verify data forwarding for 5QI1, 5QI${5qi_gbr} and 5QI5 during successfull NG Handover for UE${ue_id}

    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Run keyword and ignore error    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI3
