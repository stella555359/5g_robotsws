*** Settings ***
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
...                     FTS link:              http://nok.it/CB008083_FTS
...                     FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
...
...       HISTORY:
...               History, current status and TC description is available in repository:
...               https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008083
...
...               [24.02.2023] - Created TC
...               [19.05.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=880704)

Resource    ./resources/CB008717-common_keywords.robot

Force Tags    CRT    RAN_5G    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-E-EC2_UE_Release_due_to_RRC_Guard_Timer_timeout_during_MN_terminated_split_bearer_addition
    [Tags]    E-EC2
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  This user scenario describes the release of MN and SN UE Contexts in CU and DU together with all allocated resources
    ...  when UE configured with NR-DC is released due to RRC Guard Timer timeout during during PSCell addition.
    ...  During the test UE starts PSCell addition procedure, but it is unsuccessful due to RRC Guard Timer expiration
    ...  detected by gNB-CU-CP-MN. It should transmit UE successfully from RRC-CONNECTED to RRC-IDLE.
    ...
    ...
    ...  PRECONDITION:
    ...  - NRBTS/timerRRCGuard is set to 1000
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC-IDLE state
    ...  - Signalling connections for the UE1 are removed
    ...  - Internal resources allocated in gNB-CU-CP, gNB-CU-UP and gNB-DU are released
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_KLLL (ASIK + 3xABIL)
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15323; 5G_RAN_USR_RRM_15468
    ...       *BACKLOG ID: FCA_5G_L2L3-98477
    ...
    ...  REQUIRED LOGS: NGAP, NRRRC, PCAP
    ...
    ...  CONTACTS:
    ...  Test owner         : Adrianna Zenczak      (Nokia - PL/Krakow) <adrianna.zenczak@nokia.com>
    ...  ET team            : I_EXT_ETK4_GMS        (Nokia - PL/Krakow) <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...  CFAM link:             https://gates.nsn-net.net/view/00025f8e#o=0
    ...  FTS link:              http://nok.it/CB008717_FTS
    ...  FOT meeting minutes:   https://confluence.ext.net.nokia.com/display/M5FC/FOT+-+CB008717
    ...
    ...  HISTORY:
    ...        History, current status and TC description is available in repository:
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008083
    ...
    ...        [24.02.2023] - Created TC
    ...        [19.05.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=880704)

    [Setup]  Prepare test environment E-EC2

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1

    Set expected message flows for deletion UE1 Context by gNB2 due to expiration of RRC Guard Timer, with AMF1
    Set delay RRCReconfigurationComplete by 4000ms for UE1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for deletion UE1 Context by gNB2 due to expiration of RRC Guard Timer, with AMF1

    Verify in NGAP UEContextReleaseRequest,UEContextReleaseCommand cause:radioNetwork:radio-connection-with-ue-lost is present for AMF1
    Verify in BearerContextReleaseCommand that cause:radioNetwork:normal-release is present for gNB2
    Verify in F1AP UEContextReleaseCommand that cause:radioNetwork:normal-release is present for MN context UE1
    Verify in F1AP UEContextReleaseCommand that cause:radioNetwork:unspecified is present for SN context UE1

    [Teardown]  Cleanup after test E-EC2
