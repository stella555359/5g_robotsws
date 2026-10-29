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
...			CB008717-DE PM Counters for sub-feature D and E
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
...            [09.08.2023] - Created TC
...            [03.08.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#file:review=888034/promote=true/version=6434636)

Resource    ./resources/CB008717-common_keywords.robot
Library     ./resources/message_verifiers.py

Suite Setup  Run Setup  ute-ca=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/config/D/3c_FDD_n66_FR2_n260_n261_NRDC.lua
${SCFC}=                   Krakow/CB008717/D/SCFC_FS_D_B1c_FDD_n66_n260_n261.xml
${AP_XML}=                 Krakow/CB008717/D/iphy_FS_3c_n66_n260_n261.xml

*** Test Cases ***
CB008717-DE-PM1-3_NRDC_Intra-gNB_S-Node_Addition_failure_procedure_due_to_RRC_Guard_Timer_timeout_and_lack_of_nr-SCG-Response
    [Tags]    DE-PM1-3
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  Test verify unsuccessful establishment of NR-DC Intra-gNB S-Node Addition procedure on PCell, due to RRC Reconfiguration Complete
    ...  is NOT received by MN from the UE. Additionally, case with RRC Reconfiguration Complete is received by MN from the UE but with
    ...  missing scg_Response IE is covered.
    ...  The motivation is to monitor how unsuccessful the S-Node Addition procedure is from PCell perspective.
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
    ...
    ...  POSTCONDITION:
    ...  - UE1 has not established MN-terminated split bearer
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
    ...       *REQUIREMENTS IN SCOPE: 5G_PM_845, 5G_PM_1171
    ...       *BACKLOG ID: FCA_5G_L2L3-151466
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
    ...        [03.08.2023] - Approved by (Agnieszka Wlodarczyk, https://collab.ext.net.nokia.com/ui#file:review=888034/promote=true/version=6434636)

    [Setup]  Prepare test environment DE-PM1-3

    #Wait for new PM Counter collecting period

    Attach UE1 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE1, gNB2 and AMF1
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

    Attach UE2 without ICS to gNB2 cell2
    Set expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 87
    Verify expected messages flows for A4 measurement configuration for UE2, gNB2 and AMF1

    Execute egate command    cmd=ue_nr_rrc_reconf_param id=2 if_contains=any action=donot_send_scgNrResponse

    Set expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1
    UE2 sends A4 measId=1 with CELL-2: rsrp1=100 rsrq1=40 and CELL-3: rsrp2=85 rsrq2=31
    Verify expected messages flows for A4 measurement based PSCell addition for UE2, gNB2 and AMF1

    Verify in ReconfigurationComplete for UE2 that message does not contain encoded RRCReconfigurationComplete for SCG


    #Wait for new PM Counter collecting period
    #Verify that NRDC_IA_MN_CU_ADD_REQ is equal to 2 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RESP is equal to 2 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_ATT is equal to 2 for NRCELL-2
    #Verify that IA_NRDC_MN_CU_DRB_STP_SUC is equal to 1 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_RCF_CMPL is equal to 1 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_REJ is equal to 0 for NRCELL-2
    #Verify that NRDC_IA_MN_CU_ADD_TEXP is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_NOR_NRDC is equal to 0 for NRCELL-2
    #Verify that NG_FLOW_REL_ABN_NRDC is equal to 0 for NRCELL-2

    [Teardown]  Cleanup after test DE-PM1-3
