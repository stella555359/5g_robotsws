*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces successful procedure of inter-gNB NR-DC UE bulk release.
...
...      == TEST SET NAME ==
...      CB008490-Q: Other Interactions
...
...      == TESTING SPLIT ==
...     	CB008490-Q#B1: Graceful shutdown of NR-DC-SN cell (OAM-triggered)
...     	CB008490-Q#B2: Energy saving: NR-DC-SN cell switch off (stepwise, first cell deactivation)
...     	CB008490-Q#B3: Energy saving: NR-DC-SN cells switch off (stepwise, with the last cell deactivation)
...     	CB008490-Q#B4: Energy saving: NR-DC-SN cells switch off (one-shot)
...     	CB008490-Q#B5: Energy saving: NR-DC-SN cell switch on (stepwise)
...     	CB008490-Q#B6: Energy saving: NR-DC-SN cells switch on (one-shot)
...     	CB008490-Q#B7: Forced NR-DC-SN cell switch off and on (based on time of day and voltage)
...     	CB008490-Q#B8: Extended NR-DC-SN cell range
...     	CB008490-Q#B9: Support refServCellIndicator IE in RRCReconfiguration message when configuring CB012118 B1 measurement to UE in NR-DC mode
...     	CB008490-Q#B10: SCGFailureInformation received from the UE due to unsuccessful Random Access during SNode Addition
...     	CB008490-Q#B11 Interworking with Active Queue Management with PI2 discarding
...     	CB008490-Q#B12: Co-existence of NR-DC with emergency / HPA sessions

...
...      == TESTING SCOPE ==
...      CB008490-Q: Other Interactions
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek 			<tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1038
...
...      == HISTORY ==
...      [21.03.2025] - Create Test Suite
...      [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)
...
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot
Resource    resources/CB008490_pm_counters.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO/CLOUD_5G_I_MP_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/M/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/M/sfc_3cells_n78_n78_n257_simSN_GMC.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7
${yaml_A2_redirection}=   ${CURDIR}/config/yaml/A2_redirection.yaml
${A2_redirect_ssb_freq}=  633312
${a4retrytimer_toleration}=    2

*** Test Cases ***
CB008490-SR-Q-B9 Support refServCellIndicator IE in RRCReconfiguration message when configuring CB012118 B1 measurement to UE in NR-DC mode
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This US covers the gNB behavior, when configuring B1 measurement for CB012118 voice fallback redirection
    ...  to LTE purpose to UE in NR-DC mode.
    ...
    ...  == PRECONDITION ==
    ...  MN and SN gNBs are configured for NR-DC
    ...  NRBTS.actRedirect set to true
    ...  NRBTS.actNormVCFallback set to true
    ...  NRCELL.voiceFBMode set to redirection
    ...  NRCELL.actCDrx set to TRUE
    ...  NRBTS.actVoFallBackLteB1MeaBaRedir set to TRUE
    ...  NRBTS.actVoNR set to false
    ...  NRBTS.NRHOIR. b1MeasRedirectEnabled is set to rsrp

    ...
    ...  == POSTCONDITION ==
    ...  UE1 is redirected to LTE
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - sim gNB as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_29009
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-Q#B9: Support refServCellIndicator IE in RRCReconfiguration message when configuring
    ...  CB012118 B1 measurement to UE in NR-DC mode
    ...
    ...  == HISTORY ==
    ...    [21.03.2025] - Create Test Suite
    ...    [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)

    [Setup]  Prepare test environment CB008490-Q-B9

    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    Set expected messages for UE1 redirection to LTE
    Add to UE1 PDU1 session QoS flows with with 5QI-1
    Verify expected messages for UE1 redirection to LTE

    Verify that RRC:RRCReconfiguration contains refServCellIndicator:pCell, gNB2 for UE1
    Verify that NGAP PDUSessionResourceModifyResponse contains cause:radioNetwork:ims-voice-eps-fallback-or-rat-fallback-triggered, gNB2

    [Teardown]  CB008490-Q-B9 cleanup


*** Test Cases ***
CB008490-SR-Q-B12 Co-existence of NR-DC with emergency, HPA sessions
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario covers co-existence of PDU sessions containing QoS Flows qualified as emergency or HPA
    ...  ones on the UE qualified as NR-DC allowed (with or without actually established NR-DC). Emergency / High Priority Access
    ...  calls are handled on MN as if the UE was not NR-DC eligible / not operating in NR-DC.
    ...
    ...  == PRECONDITION ==
    ...  MN and SN gNBs are configured for NR-DC
    ...  MN - NRBTS.NRCELL.actEmergencyCall is set to true
    ...  MN - NRBTS.NRCELL.emergencyCallLimServ is set to true
    ...  In Emergency profile, ARPlist[3] for non GBR QoS flow is set to 3
    ...  Radio Admission Control limits / current traffic in the PCell allows establishment of only emergency DRBs
    ...
    ...  == POSTCONDITION ==
    ...  UE1 is redirected to LTE
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - sim gNB as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_29557
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...  - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...  - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-Q#B12: Co-existence of NR-DC with emergency / HPA sessions
    ...
    ...  == HISTORY ==
    ...    [21.03.2025] - Create Test Suite
    ...    [06.03.2025]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=929684)

    [Setup]  Prepare test environment CB008490-Q-B12

    Prepare NrDc UE1 candidate with 1 PDU sessions with 1 non-GBR and 1 signalling QoS Flow on NRCELL-1

    Set expected messages flows to check UECapabilityEnquiry request did not occure for UE1
    Set expected messages flows to check non NR-DC eligible PDU Session established for the UE1
    Set expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE1

    Trigger UE1 idle mode exit

    Verify that expected message flows for UECapabilityEnquiry request did not occure for UE1
    Verify expected messages flows to check non NR-DC eligible PDU Session established for the UE1
    Verify expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE1

    Verify that initial PDU session for UE1 contains 2 qos flows
    Verify that A4 measurements are not configured for UE1 in RRCReconfiguration message
    Get occurence time of RRCReconfiguration after ICS for UE1

    Expect that A4 measurements are not configured after retryTimer eq 10 expiry for UE1
    Verify that A4 measurements are not configured after retryTimer eq 10 expiry for UE1

    Expect that A4 measurements are configured after adding eligible PDU session for UE1
    Reset QoS Flow settings on SMF
    Add to UE1 second PDU session after ICS
    Verify that A4 measurements are configured after adding eligible PDU session for UE1
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements installation for UE1 and verify if difference is equal 20s

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    [Teardown]  CB008490-Q-B12 cleanup

*** Keywords ***
Add to UE${ue_id:\d+} ${session_type:(initial|second|third)} emergency PDU session after ICS
    EXPECT FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration

    ${pdu_id}    Get From Dictionary    ${session_name_to_pdu}   ${session_type}
    Execute egate command  cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Run keyword and continue on failure
    ...     Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${current_gw_id} nwslice=1 request_type=initial-emergency-request
    ...     pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID
    ${current_gw_id}     Evaluate  ${current_gw_id} + 1
    Set Test Variable    ${current_gw_id}

    PASS FLOW[timeout=10]: AMF1 NGAP pDUSessionResourceSetup
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
