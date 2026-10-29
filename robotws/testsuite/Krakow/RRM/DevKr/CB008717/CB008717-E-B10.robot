*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
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
...      CFAM Leader        : Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
...                           Michal Szymakowski    (Nokia - PL/Krakow) <michal.szymakowski@nokia.com>
...                           Grzegorz Szymik       (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
...                           Adrianna Zenczak      (Nokia - PL/Krakow) <adrianna.zenczak@nokia.com>
...
...      REFERENCES:    CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=0
...                     FTS link:              http://nok.it/CB008717_FTS
...                     FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
...
...       HISTORY:
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
...
...         [05.04.2023] - Create Test Suite
...         [13.04.2023] - Create Test Case E-B10
...         [19.04.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=882121)
...         [12.05.2023] - Migration to new AP_LO


Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/E/3c_3_amf_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-E-B10_UE_release_without_bearer_takeback_due_to_AMF_reselection_failure
    [Tags]    E-B10
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  This user scenario describes the gNB behavior when UE1 configured with NR-DC is released due to AMF reselection failure. The gNB should
    ...  release MN and SN UE Contexts in CU and DU together with all allocated resources.
    ...  UE1 is attached to gNB and NR-DC is setup successfully. Then gNB-CU-CP-MN detects that NG-C link with AMF becomes INACTIVE upon SCTP
    ...  failure. UE1 sends RRC: ULInformationTransfer. The gNB-CU-CP-MN tries to proceed it and tries to send NGAP: UplinkNASTransport but message
    ...  cannot be sent to 5GCore due to AMF reselection failure. Therefore, the gNB should trigger release for UE1 and UE1 is successfully
    ...  transmitted from RRC-CONNECTED to RRC-IDLE.
    ...
    ...  PRECONDITION:
    ...  - One FR2 cell (NRBTS/NRCELL-1) is active in pure NR-DC-SN mode of operation
    ...  - One FR1 cell (NRBTS/NRCELL-2) is active in pure SA mode of operation with enabled NR-DC
    ...  - One FR2 cell (NRBTS/NRCELL-3) is active in pure NR-DC-SN mode of operation
    ...  - NRBTS/NRCELL-1 simulated on AEUD radio module - NR_BAND: n260 (TDD)
    ...  - NRBTS/NRCELL-1 channel bandwidth: 100MHz (TDD)
    ...  - NRBTS/NRCELL-2 simulated on AHLOA radio module - NR_BAND: n66 (FDD)
    ...  - NRBTS/NRCELL-2 channel bandwidth: 20MHz (TDD)
    ...  - NRBTS/NRCELL-3 simulated on AEUD radio module - NR_BAND: n261 (TDD)
    ...  - NRBTS/NRCELL-3 channel bandwidth: 100MHz (TDD)
    ...  - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2254267
    ...  - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 260
    ...  - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrp
    ...  - NRBTS/NRCELL-1/NRHOIF-2/ssbFrequency is set to 2078011
    ...  - NRBTS/NRCELL-1/NRHOIF-2/freqBandIndicatorNR is set to 261
    ...  - NRBTS/NRCELL-1/NRHOIF-2/a4MeasNrDcEnabled is set to rsrp
    ...  - NRBTS/actUserPreemption is set to true (CB008698 is enabled)
    ...  - NRBTS/NRCELL-2/maxNumOfRrcSA is set to 1
    ...  - NRBTS/NRCELL-2/numOfRadioResReservForTempUse is set to 1
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
    ...  - UE: Airphone AP_LO (ASIL + 2xABIO)
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_15323; 5G_RAN_USR_RRM_15467
    ...       *BACKLOG ID: FCA_5G_L2L3-98475
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Grzegorz Szymik    (Nokia - PL/Krakow) <grzegorz.szymik@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS     (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
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
    ...  [07.04.2023] - Create first Test Case shape
    ...  [13.04.2023] - Final TC shape
    ...  [19.04.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=882121)
    ...  [19.04.2023] - Add TC to CRT
    ...  [12.05.2023] - Migration to new AP_LO
    ...  [22.11.2023] - Add counter coverage from -DE part

    [Setup]  Prepare test environment E-B10

    Lock NG-C link to AMF2

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for gNB2

    Lock NG-C link to AMF1

    Set expected message flows for UE1 Context Release due to AMF reselection failure for gNB2
    Trigger UE1 to send RRC ULInformationTransfer
    Verify expected message flows for UE1 Context Release due to AMF reselection failure for gNB2

    Verify in F1AP UEContextReleaseCommand that cause:misc:unspecified is present for MN context UE1
    Verify in F1AP UEContextReleaseCommand that RRCContainer is present for MN context UE1
    Verify in F1AP UEContextReleaseCommand that cause:misc:unspecified is present for SN context UE1
    Verify in F1AP UEContextReleaseCommand that RRCContainer is not present for SN context UE1
    Verify in BearerContextReleaseCommand that cause:misc:unspecified is present for gNB2

    # CB008717-DE
    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 1 for NRCELL-2
    #Verify that SUM_UE_NRDC_CAP is in range (0, 100) for NRCELL-2
    #Verify that MAX_UE_NRDC_MN_CU is equal to 1 for NRCELL-2
    #Verify that SUM_UE_NRDC_MN_CU is in range (0, 100) for NRCELL-2
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 1 for NRCELL-2

    #Wait for new PM Counter collecting period
    #Verify that MAX_UE_NRDC_CAP is equal to 0 for NRCELL-2
    #Verify that SUM_UE_NRDC_CAP is in range (0, 0) for NRCELL-2
    #Verify that MAX_UE_NRDC_MN_CU is equal to 0 for NRCELL-2
    #Verify that SUM_UE_NRDC_MN_CU is in range (0, 0) for NRCELL-2

    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 0 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 0 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 0 for NRCELL-2

    [Teardown]  Cleanup after test E-B10
