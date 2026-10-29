*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS23R3   SKIPRUN
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
...      CB008717-EB#B1
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
...            [15.09.2023] - Created TC
...            [15.09.2023] - Review closed

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/DE/3c_3_amf_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-DE-NRDC_establishment_interaction_with_CB008225_RRC_INACTIVE
    [Tags]    DE-Exploratory
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...    This user scenario describes the gNB behaviour for UE in RRC_INACTIVE state that is successfully transitioned
    ...    to RRC_CONNECTED state. After successful resume procedure NR-DC A4 measurement configuration is performed for
    ...    FWA UE with NR-DC eligible PDU session.
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
    ...  - NRBTS/NRCELL-2.ranAC = 0
    ...  - NRBTS/NRCELL-3.actNrDualConnectivity = 'disabled'
    ...  - NRBTS/NRPMRNL.miNrCCD = '5min'
    ...  - NRBTS/NRPMRNL.miNrUeState = '5min'
    ...  - NRBTS.actRrcInactState = 'intra-gNB'
    ...  - NRBTS.drbRrcInactInactivityTimerSA = 5
    ...  - NRBTS.maxUeRrcInactTime = 60
    ...  - NRBTS.rrcInactIMMSteeringEnabled = 'false'
    ...  - NRBTS.rrcInactLocationReportEnabled = 'false'
    ...  - NRBTS.rrcInactPreferredStateEnabled = 'false'
    ...  - NRBTS.tRanPagingGuard = 4
    ...  - NRBTS.act3gppBL23R1 = 'true'
    ...
    ...  POSTCONDITION:
    ...  - UE1 is in RRC_CONNECTED state
    ...  - UE2 is in IDLE mode
    ...	 - counters are properly incremented after the test
    ...
    ...  TESTING TOOLS: AirPhone, 5GCSim, UTE
    ...
    ...  TEST ENVIRONMENT:
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIB + ABIO + ABIO)
    ...  - UE: Airphone AP_LO_FS
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE: 5G_PM_787
    ...       *BACKLOG ID: FCA_5G_L2L3-195350
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
    ...        [15.09.2023] - Created TC
    ...        [15.09.2023] - Review closed

    [Setup]  Prepare test environment DE-exploratory

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1

    Wait until UE1 goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA

    UE1 triggers RRCResume procedure to NRCELL-2

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1
    Verify that UE1 was successfully configured NR-DC for gNB2

    #Wait for new PM Counter collecting period
    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 1 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 1 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 1 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 1 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 1 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-2
    #Verify that MAX_UE_NRDC_CAP is equal to 1 for NRCELL-2
    #Verify that MAX_UE_NRDC_MN_CU is equal to 1 for NRCELL-2
    #Verify that SUM_UE_NRDC_CAP is in range (5, 100) for NRCELL-2

    [Teardown]  Cleanup after test DE-exploratory

*** Keywords ***
Wait until UE${ue_id:\d+} goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    EXPECT FLOW[timeout=15]: gNB2 E1AP bearerContextInactivityNotification
    EXPECT FLOW[timeout=15]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=15]: gNB2 F1AP uEContextRelease
    EXPECT FLOW[timeout=15]: UE_${ue_id} NR-RRC RRCRelease

    PASS FLOW[timeout=15]: gNB2 E1AP bearerContextInactivityNotification
    PASS FLOW[timeout=15]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=15]: gNB2 F1AP uEContextRelease
    PASS FLOW[timeout=15]: UE_${ue_id} NR-RRC RRCRelease

    ${bearer_ctx_inact_notify}=     Get Flow Name
    ...     procedure=bearerContextInactivityNotification
    ...     device=gNB2
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     uE-Activity eq 'not-active'
    ...     message_alias=BearerContextInactivityNotification
    ...     flow_alias=${bearer_ctx_inact_notify}

    ${rrc_release}=     Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (suspendConfig is present) and (ran-NotificationAreaInfo is present)
    ...     message_alias=RRCRelease
    ...     flow_alias=${rrc_release}

UE${ue_id:\d+} triggers RRCResume procedure to NRCELL-${cell_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    Execute egate command   cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mo_Data
    Execute egate command   cmd=ue_nr_rrc_resume id=${ue_id}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
