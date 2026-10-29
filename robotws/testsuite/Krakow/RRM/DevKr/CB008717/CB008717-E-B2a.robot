*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation
...
...      INTRODUCTION:
...         CB008717-A NR-DC Cell Activation for a Secondary Node
...         CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...         CB008717-C UE Release due to AMF Context Release
...         CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...         CB008717-E UE Release without bearer takeback
...         CB008717-G Cell Management for Secondary Node
...         CB008717-H Configuration and Reception of A4 measurements
...         CB008717-I Successful Measurement based PSCell Addition
...         CB008717-J Interaction with event A4
...         CB008717-M Mobilty on PCell
...
...      TEST SET NAME:  CB008717-E
...
...      TESTING SCOPE:
...      CB008717-E UE Release without bearer takeback
...
...      CONTACTS:
...      CFAM Leader        :
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...                           Malgorzata Konior     (Nokia - PL/Krakow) <malgorzata.konior@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Adrianna Zenczak      (Nokia - PL/Krakow) <adrianna.zenczak@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                           Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=0
...                     FTS link:              http://nok.it/CB008717_FTS
...                     FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
...
...       HISTORY:
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...
...               [15.03.2023] - Created TC
...               [09.03.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=879707)

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Suite Setup  Run Setup  ute-ca=True  GBR_nonGBR=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-E-B2a1_NRDC_UE_release_due_to_user_inactivity
    [Tags]    E-B2a-1
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  This user scenario describes the gNB behavior for the release of MN and SN UeContexts in CU and DU together
    ...  with all allocated resources when user inactivity is detected by gNB.
    ...  During the test UE1 is configured with established NR-DC. After UE1 is inactive and no DL/UL data is transferred
    ...  for longer time (drbInactivityTimerSA and srbInactivityTimer timers expired), UE1 is successfully transmitted
    ...  from RRC-CONNECTED to RRC-IDLE.
    ...
    ...  PRECONDITION:
    ...  - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...  - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...  - One FR1 cell (NRBTS/NRCELL-3) is active in pure SA mode of operation with enabled NR-DC
    ...  - NRBTS/NRCELL-1 simulated on AEUD radio module - NR_BAND: n260 (TDD)
    ...  - NRBTS/NRCELL-1 channel bandwidth: 100MHz (TDD)
    ...  - NRBTS/NRCELL-2 simulated on AHLOA radio module - NR_BAND: n66 (FDD)
    ...  - NRBTS/NRCELL-2 channel bandwidth: 20MHz (TDD)
    ...  - NRBTS/NRCELL-3 simulated on AEUD radio module - NR_BAND: n261 (TDD)
    ...  - NRBTS/NRCELL-3 channel bandwidth: 100MHz (TDD)
    ...  - NRBTS/NRCELL-1/NRHOIF-1.ssbFrequency = '2254267'
    ...  - NRBTS/NRCELL-1/NRHOIF-1.freqBandIndicatorNR = '260'
    ...  - NRBTS/NRCELL-1/NRHOIF-1.a4MeasNrDcEnabled = 'rsrp'
    ...  - NRBTS/NRCELL-1/NRHOIF-2.ssbFrequency = '2078011'
    ...  - NRBTS/NRCELL-1/NRHOIF-2.freqBandIndicatorNR = '261'
    ...  - NRBTS/NRCELL-1/NRHOIF-2.a4MeasNrDcEnabled = 'rsrp'
    ...  - NRBTS/NRCELL-1.actNrDualConnectivity = 'disabled'
    ...  - NRBTS/NRCELL-2.actNrDualConnectivity = 'intra-gNB_intra-DU_FR1-FR2'
    ...  - NRBTS/NRCELL-3.actNrDualConnectivity = 'disabled'
    ...  - NRBTS.activityNotificationLevelSA = 'ue'
    ...  - NRBTS.drbInactivityTimerSA = 10
    ...  - NRBTS.srbInactivityTimerSA = 10
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-IDLE state
    ...  - Release cause is set correctly for SN Context in F1AP: UEContextReleaseCommand
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_15323;5G_RAN_USR_RRM_15615
    ...       *BACKLOG ID: FCA_5G_L2L3-98474
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=0
    ...  FTS link:              http://nok.it/CB008717_FTS
    ...  FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
    ...
    ...  HISTORY:
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...        [23.01.2023] - Created TC
    ...        [09.03.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=879707)

    [Setup]  Prepare test environment E-B2-1

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Add to UE1 second PDU session after ICS
    Add to UE1 PDU2 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list []
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for gNB2

    Set expected message flows for UE1 Context Release due to user inactivity to gNB2 with AMF1
    Verify expected messages flows for UE1 Context Release due to user inactivity to gNB2 with AMF1

    Verify in BearerContextInactivityNotification that ActivityInformation is set to uE-Activity:not-active for UE1 and gNB2
    Verify in NGAP UEContextReleaseRequest,UEContextReleaseCommand cause:radioNetwork:user-inactivity is present for AMF1
    Verify in both MN and SN context F1AP UeContextReleaseCommand that cause:radioNetwork:normal-release is present for gNB2
    Verify in F1AP UEContextReleaseCommand that RRCContainer is present for MN and is not present for SN context UE1
    Verify in BearerContextReleaseCommand that cause:radioNetwork:normal-release is present for gNB2

    [Teardown]  Cleanup after test E-B2-1


CB008717-E-B2a2_NRDC_UE_release_due_to_user_inactivity_not_IMMSteering_candidate
    [Tags]    E-B2a-2    SKIPRUN
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  This user scenario describes the gNB behavior for the release of MN and SN UeContexts in CU and DU together
    ...  with all allocated resources when user inactivity is detected by gNB. Test verify that gNB is not consider
    ...  UE with NR-DC as candidate for Idle Mode Mobility functionality.
    ...  During the test UE1 is configured with established NR-DC. After UE1 is inactive and no DL/UL data is transferred
    ...  for longer time (drbInactivityTimerSA timer expires), UE1 is successfully transmitted from RRC-CONNECTED to RRC-IDLE.
    ...  Additional UE2 is attached to SA cell without establishing NR-DC. After UE2 is inactive and no DL/UL data is transferred
    ...  for longer time (drbInactivityTimerSA timer expires), UE2 is successfully transmitted from RRC-CONNECTED to RRC-IDLE.
    ...  Verify that in RRC: RRCRelease to UE2 cellReselectionPriorities IE is included, according to legacy behaviour.
    ...
    ...  PRECONDITION:
    ...  - One FR1 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...  - One FR2 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...  - One FR1 cell (NRBTS/NRCELL-3) is active in pure SA mode of operation with enabled NR-DC
    ...  - NRBTS/NRCELL-1 simulated on AEUD radio module - NR_BAND: n260 (TDD)
    ...  - NRBTS/NRCELL-1 channel bandwidth: 100MHz (TDD)
    ...  - NRBTS/NRCELL-2 simulated on AHLOA radio module - NR_BAND: n66 (FDD)
    ...  - NRBTS/NRCELL-2 channel bandwidth: 20MHz (TDD)
    ...  - NRBTS/NRCELL-3 simulated on AEUD radio module - NR_BAND: n261 (TDD)
    ...  - NRBTS/NRCELL-3 channel bandwidth: 100MHz (TDD)
    ...  - NRBTS/NRCELL-1/NRHOIF-1.ssbFrequency = '2254267'
    ...  - NRBTS/NRCELL-1/NRHOIF-1.freqBandIndicatorNR = '260'
    ...  - NRBTS/NRCELL-1/NRHOIF-1.a4MeasNrDcEnabled = 'rsrp'
    ...  - NRBTS/NRCELL-1/NRHOIF-2.ssbFrequency = '2078011'
    ...  - NRBTS/NRCELL-1/NRHOIF-2.freqBandIndicatorNR = '261'
    ...  - NRBTS/NRCELL-1/NRHOIF-2.a4MeasNrDcEnabled = 'rsrp'
    ...  - NRBTS/NRCELL-1.actNrDualConnectivity = 'disabled'
    ...  - NRBTS/NRCELL-2.actNrDualConnectivity = 'intra-gNB_intra-DU_FR1-FR2'
    ...  - NRBTS/NRCELL-3.actNrDualConnectivity = 'disabled'
    ...  - NRBTS.activityNotificationLevelSA = 'ue'
    ...  - NRBTS.actIdleMMSteering = 'true'
    ...  - NRBTS.actMobilityProfile = 'false'
    ...  - NRBTS/NRCELL-2.idleMMSteeringPercentageOfUes = '100'
    ...  - NRBTS/NRCELL-2.idleMMSteeringAlgo = 'non CA aware'
    ...  - NRBTS/NRCELL.idleMMSteeringWRRenabled = 'true'
    ...  - NRBTS.drbInactivityTimerSA = 10
    ...  - NRBTS.srbInactivityTimerSA = 10
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-IDLE state
    ...  - Release cause is set correctly for SN Context in F1AP: UEContextReleaseCommand for UE1
    ...  - cellReselectionPriorities IE is not included in RRC:RRCRelease for UE1
    ...  - UE2 is in RRC-IDLE state
    ...  - Release cause is set correctly for SN Context in F1AP: UEContextReleaseCommand for UE2
    ...  - cellReselectionPriorities IE is not included in RRC:RRCRelease for UE2
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_15323;5G_RAN_USR_RRM_15615
    ...       *BACKLOG ID: FCA_5G_L2L3-98474
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=0
    ...  FTS link:              http://nok.it/CB008717_FTS
    ...  FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
    ...
    ...  HISTORY:
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...        [22.03.2023] - Created TC
    ...        [04.04.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=879709)

    [Setup]  Prepare test environment E-B2-2

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Add to UE1 second PDU session after ICS
    Add to UE1 PDU2 session QoS flows with 5QI from list [4] and delete QoS flows with 5QI from list []
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for gNB2

    Set expected message flows for UE1 Context Release due to user inactivity to gNB2 with AMF1
    Verify expected messages flows for UE1 Context Release due to user inactivity to gNB2 with AMF1

    Verify in BearerContextInactivityNotification that ActivityInformation is set to uE-Activity:not-active for UE1 and gNB2
    Verify in NGAP UEContextReleaseRequest,UEContextReleaseCommand cause:radioNetwork:user-inactivity is present for AMF1
    Verify in both MN and SN context F1AP UeContextReleaseCommand that cause:radioNetwork:normal-release is present for gNB2
    Verify in F1AP UEContextReleaseCommand that RRCContainer is present for MN and is not present for SN context UE1
    Verify in BearerContextReleaseCommand that cause:radioNetwork:normal-release is present for gNB2
    Verify in RRCRelease that cellReselectionPriorities IE is not included for UE1

    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
#    Add to UE2 initial PDU session with ICS
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    EXPECT FLOW[timeout=15]: UE_2 NR-RRC RRCRelease
    Wait for UE2 to enter IDLE state
    Verify in RRCRelease that cellReselectionPriorities IE is included for UE2

    [Teardown]  Cleanup after test E-B2-2
