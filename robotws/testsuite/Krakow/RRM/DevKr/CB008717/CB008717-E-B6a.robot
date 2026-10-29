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
...               [24.02.2023] - Created TC
...               [12.04.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=880704)

Resource    ./resources/CB008717-common_keywords.robot

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-E-B6a_NRDC_UE_release_due_to_PDCP_count_rollover
    [Tags]    E-B6a
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  This user scenario describes the gNB behavior for the successful transition of UE with established NR-DC connection
    ...  (with established MN-terminated split bearer) to RRC IDLE due to PDCP count rollover.
    ...  During the test UE is configured with established NR-DC. In the next step gNB-CU-UP detects PDCP Count roll over
    ...  (reaching a margin before actual roll-over).  It should transmit UE successfully from RRC-CONNECTED to RRC-IDLE.
    ...
    ...  PRECONDITION:
    ...  - One FR2 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...  - One FR1 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...  - One FR2 cell (NRBTS/NRCELL-3) is active in pure SA mode of operation with enabled NR-DC
    ...  - NRBTS/NRCELL-1 simulated on AEUD radio module - NR_BAND: n260 (TDD)
    ...  - NRBTS/NRCELL-1 channel bandwidth: 100MHz (TDD)
    ...  - NRBTS/NRCELL-2 simulated on AHLOA radio module - NR_BAND: n66 (FDD)
    ...  - NRBTS/NRCELL-2 channel bandwidth: 20MHz (FDD)
    ...  - NRBTS/NRCELL-3 simulated on AEUD radio module - NR_BAND: n261 (TDD)
    ...  - NRBTS/NRCELL-3 channel bandwidth: 100MHz (TDD)
    ...  - NRBTS/NRCELL-1/NRHOIF-1/ssbFrequency is set to 2254267
    ...  - NRBTS/NRCELL-1/NRHOIF-1/freqBandIndicatorNR is set to 260
    ...  - NRBTS/NRCELL-1/NRHOIF-1/a4MeasNrDcEnabled is set to rsrp
    ...  - NRBTS/NRCELL-1/NRHOIF-2/ssbFrequency is set to 2078011
    ...  - NRBTS/NRCELL-1/NRHOIF-2/freqBandIndicatorNR is set to 261
    ...  - NRBTS/NRCELL-1/NRHOIF-2/a4MeasNrDcEnabled is set to rsrp
    ...  - NRBTS/NRCELL-1.actNrDualConnectivity = 'disabled'
    ...  - NRBTS/NRCELL-2.actNrDualConnectivity = 'intra-gNB_intra-DU_FR1-FR2'
    ...  - NRBTS/NRCELL-3.actNrDualConnectivity = 'disabled'
    ...  - NRBTS.keyRefrMarg = '4294967295'
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
    ...        https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Krakow/RRM/DevKr/CB008717
    ...
    ...        [24.02.2023] - Created TC
    ...        [12.04.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=880704)

    [Setup]  Prepare test environment E-B6a

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
#    Add to UE1 initial PDU session with ICS
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for gNB2

    Set expected message flows for deletion UE1 Context by gNB2 due to PDCP count rollover, with AMF1
    Run 5Mbps DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    Verify expected messages flows for deletion UE1 Context by gNB2 due to PDCP count rollover, with AMF1

    Verify in E1AP BearerContextModificationRequired that cause:radioNetwork:pPDCP-Count-wrap-around is present for gNB2
    Verify in NGAP UEContextReleaseRequest,UEContextReleaseCommand cause:radioNetwork:up-confidentiality-protection-not-possible is present for AMF1
    Verify in F1AP UEContextReleaseCommand that cause:radioNetwork:normal-release is present for MN context UE1
    Verify in F1AP UEContextReleaseCommand that RRCContainer is present for MN context UE1
    Verify in F1AP UEContextReleaseCommand that cause:radioNetwork:unspecified is present for SN context UE1
    Verify in F1AP UEContextReleaseCommand that RRCContainer is not present for SN context UE1
    Verify in BearerContextReleaseCommand that cause:radioNetwork:normal-release is present for gNB2

    [Teardown]  Cleanup after test E-B6a
