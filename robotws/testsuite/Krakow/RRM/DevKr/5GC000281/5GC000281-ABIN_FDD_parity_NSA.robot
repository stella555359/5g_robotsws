*** Settings ***
Documentation
...      INTRODUCTION:  5GC000281: CPLANE OVERLOAD PROTECTION
...                     Feature introduce new functions with gNB support CPLANE overload protection mechanism aimed at
...                     critical resource exhaustion and avoiding any software crash in gNB-CU.
...
...      TEST SET NAME: 5GC000281
...
...      TESTING SPLIT: 5GC000281-B - NSA Counter measures and associated PM Counters and parameters
...                     5GC000281-B-a Incoming NSA addition rejections
...                     5GC000281-B-b NSA measurement report discards
...                     5GC000281-B-c SgNB Modifiaction Request from MeNB for additional E-RAB additions
...                     5GC000281-B-d SgNB Modifiaction Request from from Inter LTE HO
...                     5GC000281-C - SA Counter measures and associated PM Counters and parameters
...                     5GC000281-C-a Incoming SA Call RRC Call Rejection for non-emergency
...                     5GC000281-C-b Measurement report discard for non-emergency for SA
...                     5GC000281-C-c PDU Session Resource Request for new E-RABs (for non-emergency UEs) for SA
...                     5GC000281-C-d XnAP:Handover Request rejection of non-emergency UEs
...                     5GC000281-C-e Beam Switch/Port modification Request refusal for both NSA and SA
...      == AUTHORS ==
...                     - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...                     - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      == MAINTAINER ==
...                      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:  5GC000281 CFAM
...                   https://nokia.sharepoint.com/:w:/r/sites/5Gdoc/AS_Tech_Spec/CFAMs/5GC0200-5GC0399/5GC000281%20C-plane%20overload%20protection
...                   /CP1%20Material/CP1%20CFAM%205GC000281%20ReviewVersion.docx?d=w3980c65d39b7415ba4af1304c8f5dd56&csf=1&web=1&e=zZH0vi
...
...      HISTORY:
...         [05.01.2022] - Created TC instance for ABIN FDD

Resource    ./resources/5GC000281_B_keywords.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD
    ...    CONFIGS_Krakow/5GC000281/configABIN_NSA.yml

Suite Setup   Prepare test suite for NSA CPLANE Overload Testing

*** Variables ***
${lua_cfg_file}=    ${CURDIR}/config/NSA/egate_2c_2g_NSA_n71.lua
${platform}=        ABIN

*** Test Cases ***
CB007271_5GC000281-B-4_SgNBModification_rejected_in_CPLN_ovl_state_with_PCMD_generation_ABIN_FDD
    [Tags]    B4    SKIPRUN
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  == Info==
    ...  Test case purpose is to validate gNB working in CPLANE overload state.
    ...  Verification if when 5GC000281 is turn on and ovlNsaErabRej/ovlNsaLteHoRej is TRUE then for gNB in NSA mode
    ...  incomming SgNBModificationRequests with additional split bearers addition or with information about intra-LTE HO
    ...  are rejected due to overload.
    ...
    ...  == Precondition: ==
    ...  gNB classical - real hardware - ABIN + ASIB;
    ...	 NRCELL simulated on AHLOA radio module - NR_BAND: n71;
    ...  UE - Airphone simulator;
    ...  eNB - simulated MeNB by WTS;
    ...  eNB_tgt - simulated MeNB by WTS;
    ...  TCE instance simulated in VM;
    ...
    ...  eNB up and running;
    ...  eNB establish ENDC_X2 connection with gNB;
    ...  eNB_tgt establish ENDC_X2 connection with gNB;
    ...  eNB connected to eNB_tgt via X2 link;
    ...  gNB up and running with one NSA cell OnAir;
    ...  UE1 attached to eNB with installed B1-NR meas object related to gNB nrcell;
    ...  UE2 attached to eNB with installed B1-NR meas object related to gNB nrcell;
    ...  UE3 attached to eNB with installed B1-NR meas object related to gNB nrcell;
    ...  gNB not in CPLANE overload state;
    ...  NRBTS-actCuOvlProt is set to TRUE;
    ...  NRBTS-ovlNsaAddRej is set to FALSE;
    ...  NRBTS-ovlNsaLteHoRej is set to TRUE;
    ...  NRBTS-ovlNsaErabRej is set to TRUE;
    ...  NRBTS-actMultiDrbNSA is set to TRUE;
    ...  NRBTS-actInterMeNBMobility is set to TRUE;
    ...  NRBTS-actIntraMeNBMobility is set to TRUE;
    ...  NRCELL-cellDepType is set to NSA;
    ...  NRDRB-nsa3xBearerAllowed is set to TRUE;
    ...  NRBTS-actCellTraceReport is set to TRUE; (Interaction with 5GC001778)
    ...  NRBTS/NRCTRLTS/NRMTRACECU-actPCMDReporting is set to TRUE;
    ...  NRBTS/NRCTRLTS/NRMTRACECU-actCellTraceReportingCU is set to TRUE;
    ...  MRBTS/MNL/TCEADM/TCE configured
    ...  gNB established connection to TCE
    ...
    ...  TESTING TOOLS: AirPhone, EPCSIM, UTE
    ...
    ...  TEST ENVIRONMENT: gNB classicBTS in NSA mode
    ...         HARDWARE ID:  gNB(ABIN + ASIB) with simulated AHLOA radio module - NR_BAND: n71;
    ...
    ...  REQUIREMENTS COVERAGE:
    ...         REQUIREMENTS IN SCOPE: 5G_RAN_USR_17361;5G_RAN_USR_17362; 5G_RAN_CP_12360691; 5G_RAN_CP_12360782;
    ...                                5G_RAN_CP_12356878;
    ...
    ...  REQUIRED LOGS:  X2AP
    ...
    ...  == AUTHORS ==
    ...              - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...              - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  == MAINTAINER ==
    ...               I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...  REFERENCES:
    ...             Related CFAM US:
    ...              5GC000281-B:#US4 SgNB Modification Request (from MeNB for additional E-RAB additions) rejections due to overload
    ...              5GC000281-B:#US5 SgNB Modification Request from Intra LTE HO rejections due to overload
    ...              5GC000281-B:#US6 SgNB Addition Request from Inter LTE HO rejections due to overload
    ...  HISTORY:
    ...         [05.01.2022]  - Created TC

    [Setup]  Run keywords
    ...                            Prepare test environment B4
    ...                     AND    Start PCMD message collection

    [Teardown]  Run keywords
    ...                            Detach UE1
    ...                     AND    Stop PCMD message collection
    ...                     AND    Perform CPLANE OVL deactivation via R&D mechanism

    UE1 attach to sim_eNB
    eNB triggers SCG establishment for UE1 with NRCELL_1 on gNB2
    Verify that SCG establishment for UE1 with NRCELL_1 on gNB2 succeed

    Wait 5 to collect all PCMD reports

    Verify that X2AP:SgNBAdditionRequest is traced with PCMD
    Verify that X2AP:SgNBAdditionRequestAcknowledge is traced with PCMD

    Perform CPLANE OVL activation via R&D mechanism

    eNB_1 triggers SgNBModificationRequest for UE1 when cplane ovl is activate
    Verify that gNB after requesting split bearer sends X2AP:SgNBModificationRequestReject with cause: Control Processing Overload for UE1

    Wait 5 to collect all PCMD reports

    Verify that X2AP:SgNBModificationRequest is traced with PCMD
    Verify that X2AP:SgNBModificationRequestReject is traced with PCMD
    Verify that X2AP:SgNBReleaseRequest is traced with PCMD
    Verify that X2AP:SgNBReleaseRequestAcknowledge is traced with PCMD
    Verify that X2AP:UEContextRelease is traced with PCMD
    Verify that PCMD menbInitiatedSgNBModRecord result is cplaneOverloadCausedFailure

    Clear collected PCMD reports

    eNB triggers SCG establishment for UE1 with NRCELL_1 on gNB2
    Verify that SCG establishment for UE1 with NRCELL_1 on gNB2 succeed

    Wait 5 to collect all PCMD reports

    Verify that X2AP:SgNBAdditionRequest is traced with PCMD
    Verify that X2AP:SgNBAdditionRequestAcknowledge is traced with PCMD

    UE1 triggers intra eNB handover
    Verify that gNB after intra-enb handover sends X2AP:SgNBModificationRequestReject with cause: Control Processing Overload for UE1

    Wait 5 to collect all PCMD reports
    Verify that X2AP:SgNBModificationRequest is traced with PCMD
    Verify that X2AP:SgNBModificationRequestReject is traced with PCMD
    Verify that X2AP:SgNBReleaseRequest is traced with PCMD
    Verify that X2AP:SgNBReleaseRequestAcknowledge is traced with PCMD
    Verify that X2AP:UEContextRelease is traced with PCMD
    Verify that sgNB_SecurityKey for UE1 is different between X2AP:SgNBAdditionRequest and X2AP:SgNBModificationRequest in PCMD
    Verify that PCMD menbInitiatedSgNBModRecord result is cplaneOverloadCausedFailure
