*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS23R3
...           CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation
...
...      INTRODUCTION:
...         CB008717-A NR-DC Cell Activation for a Secondary Node
...         CB008717-B Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers
...         CB008717-C UE Release due to AMF Context Release
...         CB008717-D Successful Blind PSCell Addition for UEs after ICS having only non-GBR bearers, additional content
...         CB008717-DE PM Counters for sub-feature D and E
...         CB008717-E UE Release without bearer takeback
...         CB008717-G Cell Management for Secondary Node
...         CB008717-H Configuration and Reception of A4 measurements
...         CB008717-I Successful Measurement based PSCell Addition
...         CB008717-J Interaction with event A4
...         CB008717-M Mobilty on PCell
...
...      TEST SET NAME:  CB008717-DE
...
...      TESTING SCOPE:
...      CB008717-DE PM Counters for sub-feature D and E
...
...      CONTACTS:
...      CFAM Leader        :
...      ET owner (LPO/APO) : Karolina Zwierz       (Nokia - PL/Krakow) <karolina.zwierz@nokia.com>
...      Entity Testing L3  : Konrad Krzyzak        (Nokia - PL/Krakow) <konrad.krzyzak@nokia.com>
...                           Agnieszka Wlodarczyk  (Nokia - PL/Krakow) <agnieszka.wlodarczyk@nokia.com>
...                           Karolina Sroczyk      (Nokia - PL/Krakow) <karolina.sroczyk@nokia.com>
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
...            [04.09.2023] - Created TC
...            [03.08.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=890163)

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-DE-PM3-3_NRDC_normal_release_initiated_by_gNB_and_abnormal_release_initiated_by_AMF
    [Tags]    DE-PM3-3
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  Test verifies how many QoS Flows are normally/abnormally released with NR-DC split bearer type from the PCell perspective.
    ...  This test cover scenario in which successful RRC release abnormal procedure is initiated by AMF(CB008717-C-B1a)
    ...  and then normal release by gNB (CB008717-E-B2a).
    ...  Test additionally extend this TC with PMI Ticket validations.
    ...
    ...  PRECONDITION:
    ...  - One FR2 cell (NRBTS/NRCELL-1) is active in pure SA mode of operation with enabled NR-DC
    ...  - One FR1 cell (NRBTS/NRCELL-2) is active in pure NR-DC-SN mode of operation
    ...  - One FR2 cell (NRBTS/NRCELL-3) is active in pure SA mode of operation with enabled NR-DC
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
    ...  - NRBTS/NRCELL-1.actNrDualConnectivity = 'disabled'
    ...  - NRBTS/NRCELL-2.actNrDualConnectivity = 'intra-gNB_intra-DU_FR1-FR2'
    ...  - NRBTS/NRCELL-3.actNrDualConnectivity = 'disabled'
    ...  - NRBTS/NRPMRNL.miNrCCD = '5min'
    ...  - NRBTS/NRPMRNL.miNrUeState = '5min'
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in IDLE mode
    ...  - UE2 is in IDLE mode
    ...	 - counters are properly incremented after the test
    ...  - PMI Ticket counter's values are correct
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO_FS
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_PM_782
    ...       *BACKLOG ID: FCA_5G_L2L3-163614
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
    ...        [09.08.2023] - Created TC
    ...        [03.08.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#review:id=890163)

    [Setup]  Prepare test environment DE-PM3-3

    #Wait for new PM Counter collecting period

    Prepare Pmi Tickets Config
    Start Collecting Pmi Tickets

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master Node for UE1 for gNB

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for NRCELL-2 for gNB2
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Secondary Node for UE1 for gNB

    Set in NGAP:UEContextRelease message Cause:RN_not_supported_5QI_value for UE1

    Set expected message flows for UE1 Release due to AMF1 Context Release with gNB2
    Trigger UE1 to send deregister request
    Verify expected message flows for UE1 Release due to AMF1 Context Release with gNB2
    Verify in NGAP UEContextReleaseCommand that cause:radioNetwork:not-supported-5QI-value is present for AMF1
    Verify in BearerContextReleaseCommand that cause:radioNetwork:normal-release is present for gNB2

    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    Verify that UE2 was successfully configured NR-DC for NRCELL-2 for gNB2

    Set expected message flows for UE2 Context Release due to user inactivity to gNB2 with AMF1
    Verify expected messages flows for UE2 Context Release due to user inactivity to gNB2 with AMF1

    Verify in BearerContextInactivityNotification that ActivityInformation is set to uE-Activity:not-active for UE2 and gNB2
    Verify in NGAP UEContextReleaseRequest,UEContextReleaseCommand cause:radioNetwork:user-inactivity is present for AMF1
    Verify in F1AP UEContextReleaseCommand that cause:radioNetwork:normal-release is present for MN context UE2
    Verify in F1AP UEContextReleaseCommand that RRCContainer is present for MN context UE2
    Verify in BearerContextReleaseCommand that cause:radioNetwork:normal-release is present for gNB2
    Verify in F1AP UEContextReleaseCommand that cause:radioNetwork:unspecified is present for SN context UE2
    Verify in F1AP UEContextReleaseCommand that RRCContainer is not present for SN context UE2


    Stop Collecting Pmi Tickets
    Verify Pmi Counters in Records   3612082192 eq 2    #    NRDC_IA_MN_CU_ADD_REQ
    Verify Pmi Counters in Records   3612082193 eq 2    #    NRDC_IA_MN_CU_ADD_RESP
    Verify Pmi Counters in Records   3612606484 eq 2    #    IA_NRDC_MN_CU_DRB_STP_ATT
    Verify Pmi Counters in Records   3612606485 eq 2    #    IA_NRDC_MN_CU_DRB_STP_SUC
    Verify Pmi Counters in Records   3612082196 eq 2    #    NRDC_IA_MN_CU_ADD_RCF_CMPL
    Verify Pmi Counters in Records   3612082194 eq 0    #    NRDC_IA_MN_CU_ADD_REJ
    Verify Pmi Counters in Records   3612082195 eq 0    #    NRDC_IA_MN_CU_ADD_TEXP
    Verify Pmi Counters in Records   3612672029 eq 1    #    NG_FLOW_REL_NOR_NRDC
    Verify Pmi Counters in Records   3612672030 eq 1    #    NG_FLOW_REL_ABN_NRDC


    #Wait for new PM Counter collecting period
    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 2 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 2 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 1 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 1 for NRCELL-2
    #Verify that MAX_UE_NRDC_CAP is equal to 1 for NRCELL-2
    #Verify that MAX_UE_NRDC_MN_CU is equal to 1 for NRCELL-2


    [Teardown]  Cleanup after test DE-PM3-3

*** Keywords ***
Set expected message flows for UE${ue_id:\d+} Release due to AMF${amf_id:\d+} Context Release with gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uplinkNASTransport
    EXPECT FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=3]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    EXPECT FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease

Verify expected message flows for UE${ue_id:\d+} Release due to AMF${amf_id:\d+} Context Release with gNB${gnb_id:\d+}
    PASS FLOW[timeout=10]: gNB${gnb_id} F1AP uLRRCMessageTransfer
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uplinkNASTransport
    PASS FLOW[timeout=10]: AMF${amf_id} NGAP uEContextRelease
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCRelease
    FAIL FLOW[timeout=3]: UE_${ue_id} NR-RRC 2*RRCReconfiguration
    PASS FLOW[timeout=10]: gNB${gnb_id} E1AP bearerContextRelease
