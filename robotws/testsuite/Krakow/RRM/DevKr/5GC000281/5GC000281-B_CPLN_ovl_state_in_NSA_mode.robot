*** Settings ***
Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
    ...    CONFIGS_Krakow/5GC000281/trunk/config.yml

Documentation
...
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
...                     - Michal Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...                      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:  5GC000281 CFAM
...                   https://nokia.sharepoint.com/:w:/r/sites/5Gdoc/AS_Tech_Spec/CFAMs/5GC0200-5GC0399/5GC000281%20C-plane%20overload%20protection
...                   /CP1%20Material/CP1%20CFAM%205GC000281%20ReviewVersion.docx?d=w3980c65d39b7415ba4af1304c8f5dd56&csf=1&web=1&e=zZH0vi
...
...      HISTORY:
...         [12.11.2020] - Created TC

Resource    ./resources/5GC000281_B_keywords.robot

Suite Setup   Prepare test suite for NSA CPLANE Overload Testing

*** Variables ***
${lua_cfg_file}=    ${CURDIR}/config/NSA/egate_1c_2g_NSA.lua
${platform}=        ASIK

*** Test Cases ***
5GC000281-B-1_SgNBAddition_rejected_in_CPLN_ovl_state
    [Tags]    B1
    ...    GQC_PLAN:FEATURE:5GC000281
    ...    GQC_PLAN:FEATURE:5GC000281-B
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info==
    ...  Test case purpose is to validate gNB working in CPLANE overload state.
    ...  Verification if when 5GC000281 is turn on and ovlNsaAddRej is TRUE then for gNB in NSA mode all incomming
    ...  SgNBAdditionRequests for new UEs are rejected due to overload.
    ...
    ...  == Precondition: ==
    ...  gNB classical - real hardware - ABIL + ASIK
    ...	 NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  UE - Airphone simulator
    ...  eNB - simulated MeNB by WTS
    ...
    ...  eNB up and running
    ...  eNB establish ENDC_X2 connection with gNB
    ...  gNB up and running with one NSA cell OnAir
    ...  UE1 attached to eNB with installed B1-NR meas object related to gNB nrcell
    ...  UE2 attached to eNB with installed B1-NR meas object related to gNB nrcell
    ...  UE3 attached to eNB with installed B1-NR meas object related to gNB nrcell
    ...  gNB not in CPLANE overload state
    ...  NRBTS-actCuOvlProt is set to TRUE
    ...  NRBTS-ovlNsaAddRej is set to TRUE
    ...  NRCELL-cellDepType is set to NSA
    ...  NRDRB - nsa3xBearerAllowed is set to TRUE
    ...
    ...
    ...  TESTING TOOLS: AirPhone, EPCSIM, UTE
    ...
    ...  TEST ENVIRONMENT: gNB classicBTS in NSA mode
    ...         HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  REQUIREMENTS COVERAGE:
    ...         REQUIREMENTS IN SCOPE: 5G_RAN_USR_17358, 5G_RAN_CP_12360144, 5G_RAN_CP_12360154, 5G_RAN_CP_12360787,
    ...                                5G_RAN_CP_12360462, 5G_RAN_CP_12361124, 5G_RAN_CP_12360458
    ...
    ...  REQUIRED LOGS:  X2AP
    ...
    ...  == AUTHORS ==
    ...              - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...              - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  == MAINTAINER ==
    ...               I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...  REFERENCES:
    ...             Related CFAM US:
    ...                     5GC000281-B:#US1 Incomming SgNBAddition rejections (for new UEs) due to overload
    ...  HISTORY:
    ...         [12.11.2020]  - Created TC
    ...         [4.12.2020]  - Implementation start

    [Setup]  Prepare test environment B1
    eNB triggers SCG establishment for UE1 with NRCELL_1 on gNB2
    Verify that SCG establishment for UE1 with NRCELL_1 on gNB2 succeed

    Perform CPLANE OVL activation via R&D mechanism

    eNB triggers SCG establishment for UE2 with NRCELL_1 during Overload on gNB2
    Verify that gNB2 sends X2AP:SgNBAdditionRequestReject with cause: Control Processing Overload

    Set gNB parameter ovlNsaAddRej to FALSE

    eNB triggers SCG establishment for UE3 with NRCELL_1 on gNB2
    Verify that countermeasures are not active and SCG establishment for UE3 with gNB2 succeed

    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55110C00034     3    X2_SGNB_ADD_REQ_REC
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

    Verify Last Counters In File
    ...    M55112C00010     1    X2_SGNB_ADD_REQ_REJ_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

    Verify Last Counters In File
    ...    M55112C05501     1    X2_SGNB_ADD_PREP_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

    [Teardown]  Cleanup after test B1

5GC000281-B-3_SgNBModification_rejected_in_CPLN_ovl_state
    [Tags]    B3
    ...    GQC_PLAN:FEATURE:5GC000281-B
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
    ...  gNB classical - real hardware - ABIL + ASIK
    ...	 NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  UE - Airphone simulator
    ...  eNB - simulated MeNB by WTS
    ...  eNB_tgt - simulated MeNB by WTS
    ...
    ...  eNB up and running
    ...  eNB establish ENDC_X2 connection with gNB
    ...  eNB_tgt establish ENDC_X2 connection with gNB
    ...  eNB connected to eNB_tgt via X2 link
    ...  gNB up and running with one NSA cell OnAir
    ...  UE1 attached to eNB with installed B1-NR meas object related to gNB nrcell
    ...  UE2 attached to eNB with installed B1-NR meas object related to gNB nrcell
    ...  UE3 attached to eNB with installed B1-NR meas object related to gNB nrcell
    ...  gNB not in CPLANE overload state
    ...  NRBTS-actCuOvlProt is set to TRUE
    ...  NRBTS-ovlNsaAddRej is set to FALSE
    ...  NRBTS-ovlNsaLteHoRej is set to FALSE
    ...  NRBTS-ovlNsaErabRej is set to TRUE
    ...  NRBTS-actMultiDrbNSA is set to TRUE
    ...  NRBTS-actInterMeNBMobility is set to TRUE
    ...  NRBTS-actIntraMeNBMobility is set to TRUE
    ...  NRCELL-cellDepType is set to NSA
    ...  NRDRB-nsa3xBearerAllowed is set to TRUE
    ...
    ...  TESTING TOOLS: AirPhone, EPCSIM, UTE
    ...
    ...  TEST ENVIRONMENT: gNB classicBTS in NSA mode
    ...         HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  REQUIREMENTS COVERAGE:
    ...         REQUIREMENTS IN SCOPE: 5G_RAN_USR_17361, 5G_RAN_USR_17362, 5G_RAN_CP_12360691, 5G_RAN_CP_12360782,
    ...                                5G_RAN_CP_12356878
    ...
    ...  REQUIRED LOGS:  X2AP
    ...
    ...  == AUTHORS ==
    ...              - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...              - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  == MAINTAINER ==
    ...               I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...             Related CFAM US:
    ...              5GC000281-B:#US4 SgNB Modification Request (from MeNB for additional E-RAB additions) rejections due to overload
    ...              5GC000281-B:#US5 SgNB Modification Request from Intra LTE HO rejections due to overload
    ...              5GC000281-B:#US6 SgNB Addition Request from Inter LTE HO rejections due to overload
    ...  HISTORY:
    ...         [16.11.2020]  - Created TC

    [Setup]  Prepare test environment B3

    UE1 attach to sim_eNB
    eNB triggers SCG establishment for UE1 with NRCELL_1 on gNB2
    Verify that SCG establishment for UE1 with NRCELL_1 on gNB2 succeed

    UE2 attach to sim_eNB
    eNB triggers SCG establishment for UE2 with NRCELL_1 on gNB2
    Verify that SCG establishment for UE2 with NRCELL_1 on gNB2 succeed

    UE3 attach to sim_eNB
    eNB triggers SCG establishment for UE3 with NRCELL_1 on gNB2
    Verify that SCG establishment for UE3 with NRCELL_1 on gNB2 succeed


    Trigger SgNB Modification Procedure from eNB for SCG Configuration Change for UE2

    Verify that eNB sends X2AP:SgNBModificationRequest after SCG Configuration Change for UE2
    Verify that gNB sends X2AP:SgNBModificationRequestAcknowledge after SCG Configuration Change for UE2


    UE1 triggers intra-eNB handover

    Verify that eNB sends X2AP:SgNBModificationRequest with new SgNB Security Key IE for UE1
    Verify that gNB sends X2AP:SgNBModificationRequestAcknowledge after intra-eNB handover procedure for UE1
    Verify that eNB sends X2AP:SgNBReconfigurationComplete after intra-eNB handover procedure for UE1


    UE1 triggers inter-eNB handover from eNB_1 to eNB_2

    Verify that eNB_2 sends X2AP:SgNBAdditionRequest after inter-eNB handover procedure for UE1
    Verify that gNB sends X2AP:SgNBAdditionRequestAcknowledge to eNB_2 after inter-eNB handover procedure for UE1
    Verify that eNB_1 sends X2AP:SgNBReleaseRequest after inter-eNB handover procedure for UE1
    Verify that gNB sends X2AP:SgNBReleaseRequestAcknowledge to eNB_1 after inter-eNB handover procedure for UE1
    Verify that eNB_2 sends X2AP:SgNBReconfigurationComplete after inter-eNB handover procedure for UE1


    eNB_1 triggers SgNBModificationRequest to add additional split bearer for UE2
    Verify that gNB sends X2AP:SgNBModificationRequestAcknowledge after add additional split bearer for UE2
    Verify that eNB_1 sends X2AP:SgNBReconfigurationComplete after add additional split bearer for UE2

    Perform CPLANE OVL activation via R&D mechanism


    UE1 triggers inter-eNB handover from eNB_2 to eNB_1

    Verify that eNB_1 sends X2AP:SgNBAdditionRequest after inter-eNB handover procedure for UE1
    Verify that gNB sends X2AP:SgNBAdditionRequestAcknowledge to eNB_1 after inter-eNB handover procedure for UE1
    Verify that eNB_2 sends X2AP:SgNBReleaseRequest after inter-eNB handover procedure for UE1
    Verify that gNB sends X2AP:SgNBReleaseRequestAcknowledge to eNB_2 after inter-eNB handover procedure for UE1
    Verify that eNB_1 sends X2AP:SgNBReconfigurationComplete after inter-eNB handover procedure for UE1


    eNB_1 triggers SgNBModificationRequest to release additional split bearer for UE2
    Verify that gNB sends X2AP:SgNBModificationRequestAcknowledge after release of additional split bearer for UE2
    Verify that eNB_1 sends X2AP:SgNBReconfigurationComplete after release of additional split bearer for UE2


    eNB_1 triggers SgNBModificationRequest for UE2 when cplane ovl is activate
    Verify that gNB after requesting split bearer sends X2AP:SgNBModificationRequestReject with cause: Control Processing Overload for UE2

    Set gNB parameter ovlNsaAddRej to ENABLED

    UE1 triggers inter-eNB handover from eNB_1 to eNB_2

    Verify that eNB_2 sends X2AP:SgNBAdditionRequest after inter-eNB handover procedure for UE1
    Verify that gNB sends X2AP:SgNBAdditionRequestAcknowledge to eNB_2 after inter-eNB handover procedure for UE1
    Verify that eNB_1 sends X2AP:SgNBReleaseRequest after inter-eNB handover procedure for UE1
    Verify that gNB sends X2AP:SgNBReleaseRequestAcknowledge to eNB_1 after inter-eNB handover procedure for UE1
    Verify that eNB_2 sends X2AP:SgNBReconfigurationComplete after inter-eNB handover procedure for UE1


    Set gNB parameter ovlNsaLteHoRej to ENABLED

    UE1 triggers inter eNB handover from eNB_2 to eNB_1

    Verify that eNB_1 sends X2AP:SgNBAdditionRequest after inter eNB handover procedure for UE1
    Verify that gNB sends X2AP:SgNBAdditionRequestReject after inter eNB handover procedure for UE1 with cause: Control Processing Overload


    UE3 triggers intra eNB handover

    Verify that eNB_1 sends X2AP:SgNBModificationRequest for UE3
    Verify that gNB after intra-enb handover sends X2AP:SgNBModificationRequestReject with cause: Control Processing Overload for UE3
    Verify that eNB_1 sends X2AP:SgNBReleaseRequest after intra eNB handover procedure for UE3
    Verify that gNB sends X2AP:SgNBReleaseRequestAcknowledge to eNB_1 after intra eNB handover procedure for UE3
    Verify that eNB_1 sends X2AP:UEContextRelease after intra eNB handover procedure for UE3

    Wait For Next Full Pm Interval

    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55128C01501     2    X2_HO_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File

    Verify Last Counters In File
    ...    M55112C05502     1    NX2CC_BEARER_FAIL_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55112C03503     1    X2_SGNB_ADD_REQ_REJ_INTRENB_HO
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55112C04001     6    X2_SGNB_MOD_REQ_RECEIVED
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55112C03001     4    NX2CC_BEARER_ADD_ATT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

    [Teardown]  Run keywords
                ...   Perform CPLANE OVL deactivation via R&D mechanism
                ...   AND   Detach UE1
                ...   AND   Detach UE2
                ...   AND   Detach UE3

5GC000281-B-4_SgNBModification_rejected_in_CPLN_ovl_state_with_PCMD_generation
    [Tags]    B4
    ...    GQC_PLAN:FEATURE:5GC000281-B
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
    ...  gNB classical - real hardware - ABIL + ASIK
    ...	 NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  UE - Airphone simulator
    ...  eNB - simulated MeNB by WTS
    ...  eNB_tgt - simulated MeNB by WTS
    ...  TCE instance simulated in VM
    ...
    ...  eNB up and running
    ...  eNB establish ENDC_X2 connection with gNB
    ...  eNB_tgt establish ENDC_X2 connection with gNB
    ...  eNB connected to eNB_tgt via X2 link
    ...  gNB up and running with one NSA cell OnAir
    ...  UE1 attached to eNB with installed B1-NR meas object related to gNB nrcell
    ...  UE2 attached to eNB with installed B1-NR meas object related to gNB nrcell
    ...  UE3 attached to eNB with installed B1-NR meas object related to gNB nrcell
    ...  gNB not in CPLANE overload state
    ...  NRBTS-actCuOvlProt is set to TRUE
    ...  NRBTS-ovlNsaAddRej is set to FALSE
    ...  NRBTS-ovlNsaLteHoRej is set to TRUE
    ...  NRBTS-ovlNsaErabRej is set to TRUE
    ...  NRBTS-actMultiDrbNSA is set to TRUE
    ...  NRBTS-actInterMeNBMobility is set to TRUE
    ...  NRBTS-actIntraMeNBMobility is set to TRUE
    ...  NRCELL-cellDepType is set to NSA
    ...  NRDRB-nsa3xBearerAllowed is set to TRUE
    ...  NRBTS-actCellTraceReport is set to TRUE (Interaction with 5GC001778)
    ...  NRBTS/NRCTRRLTS/NRMTRACECU-actPCMDReporting is set to TRUE
    ...  NRBTS/NRCTRLTS/NRMTRACECU-actCellTraceReportingCU is set to TRUE
    ...  MRBTS/MNL/TCEADM/TCE configured
    ...  gNB established connection to TCE
    ...
    ...  TESTING TOOLS: AirPhone, EPCSIM, UTE
    ...
    ...  TEST ENVIRONMENT: gNB classicBTS in NSA mode
    ...         HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  REQUIREMENTS COVERAGE:
    ...         REQUIREMENTS IN SCOPE: 5G_RAN_USR_17361, 5G_RAN_USR_17362,  5G_RAN_CP_12360691,  5G_RAN_CP_12360782,
    ...                                5G_RAN_CP_12356878
    ...
    ...  REQUIRED LOGS:  X2AP
    ...
    ...  == AUTHORS ==
    ...              - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...              - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  == MAINTAINER ==
    ...               I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...  REFERENCES:
    ...             Related CFAM US:
    ...              5GC000281-B:#US4 SgNB Modification Request (from MeNB for additional E-RAB additions) rejections due to overload
    ...              5GC000281-B:#US5 SgNB Modification Request from Intra LTE HO rejections due to overload
    ...              5GC000281-B:#US6 SgNB Addition Request from Inter LTE HO rejections due to overload
    ...  HISTORY:
    ...         [07.01.2020]  - Created TC

    [Setup]  Run keywords
    ...                            Prepare test environment B4
    ...                     AND    Start PCMD message collection

    [Teardown]  Run keywords
    ...                            Detach UE1
    ...                     AND    Stop PCMD message collection
    ...                     AND    Perform CPLANE OVL deactivation via R&D mechanism
    ...                     AND    Teardown test environment B4

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

5GC000281-B-2_NR_MeasResult_rejected_in_CPLN_ovl_state
    [Tags]    B2
    ...    GQC_PLAN:FEATURE:5GC000281-B
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  == Info==
    ...  Test case purpose is to validate gNB working in CPLANE overload state.
    ...  Verification if when 5GC000281 is turn on and ovlNsaMeasDiscard is TRUE then all incomming NSA measurments
    ...  reports for attached UEs are rejected due to overload.
    ...
    ...  == Precondition: ==
    ...  gNB classical - real hardware - ABIL + ASIK
    ...  gNB_tgt - simulated gNB with nr_cell_1_n78 and nr_cell_2_n7
    ...	 NRCELL simulated on AEQA radio module - NR_BAND: n78
    ...  UE - Airphone simulator
    ...  eNB - simulated MeNB by WTS
    ...
    ...  eNB up and running
    ...  eNB establish ENDC_X2 connection with gNB
    ...  gNB up and running with one NSA cell OnAir
    ...  gNB not in CPLANE overload state
    ...  NRBTS-actCuOvlProt is set to TRUE
    ...  NRBTS-ovlNsaAddRej is set to FALSE
    ...  NRBTS-ovlNsaMeasDiscard is set to TRUE
    ...  NRBTS-ovlNsaLteHoRej is set to TRUE
    ...  NRCELL-cellDepType is set to NSA
    ...  NRDRB-nsa3xBearerAllowed is set to TRUE
    ...  NRBTS-srb3SupportEnbled is set to FALSE
    ...  NRBTS-actIntraFreqIntraGnbMobilityNSA is set to TRUE
    ...  NRBTS-actIntraFreqInterGnbMobilityNSA3x is set to TRUE
    ...  NRBTS-actInterFreqIntraGnbMobilityNSA is set to TRUE
    ...  NRBTS-actInterFreqInterGnbMobilityNSA is set to TRUE
    ...  NRCELL-a3MeasEnabled
    ...  NRCELL-a5MeasEnabled
    ...  UE1 attached to eNB with SCG etablished to gNB nrcell and A3/A5 measurments active (added during SgNBAddition procedure)
    ...  UE2 attached to eNB with SCG etablished to gNB nrcell and A3/A5 measurments active (added during SgNBAddition procedure)
    ...
    ...  TESTING TOOLS: AirPhone, EPCSIM, UTE
    ...
    ...  TEST ENVIRONMENT: gNB classicBTS in NSA mode
    ...         HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  REQUIREMENTS COVERAGE:
    ...         REQUIREMENTS IN SCOPE: 5G_RAN_USR_17360, 5G_RAN_USR_17490, 5G_RAN_CP_12356796, 5G_RAN_CP_12356797,
    ...                                5G_RAN_CP_12360870, 5G_RAN_CP_12360874, 5G_RAN_CP_12360873, 5G_RAN_CP_12360876
    ...
    ...  REQUIRED LOGS:  X2AP
    ...
    ...  == AUTHORS ==
    ...              - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...              - Michal Szymakowski <michal.szymakowski@nokia.com>
    ...  == MAINTAINER ==
    ...               I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  REFERENCES:
    ...             Related CFAM US:
    ...                     5GC000281-A:#US2 Deactivation
    ...                     5GC000281-B:#US2 NSA measurement report discarding due to overload - no SRB3
    ...                     5GC000281-B:#US3 NSA measurement report discarding due to overload - SRB3
    ...                     5GC000281-B:#US8 Deactivation of C-plane overload protection - countermeasures are no longer applied
    ...  HISTORY:
    ...         [12.11.2020]  - Created TC

    [Setup]  Prepare test environment B2

    Expect Measurement Report for UE1
    Expect UE1 inter_gNB HO from gNB2 to gNB_tgt
    UE1 sends A3 measResult for nr_cell_1 from gNB_tgt with value above offset defined for PSCell
    Verify that inter-gNB intra-frequency handover execution for UE1 succeed

    Perform CPLANE OVL activation via R&D mechanism

    Expect Measurement Report ignoring for UE2
    UE2 sends A3 measResult for nr_cell_1 from gNB_tgt with value above offset defined for PSCell
    Verify that gNB2 ignores Meas Report and does NOT send F1AP:UEContextModificationRequest for UE2
    Verify that gNB2 ignores Meas Report and does NOT send X2AP:SgNBChangeRequired for UE2
    Verify that gNB2 ignores Meas Report and does NOT send X2AP:SgNBModificationRequired for UE2

    UE1 and UE2 triggers detach procedure from eNB
    Verify that SCG release performed for UE1 and UE2

    Set gNB parameter srb3SupportEnbled to TRUE
    UE3 and UE4 attach to eNB with SCG establishment and SRB3 activation

    Expect Measurement Report ignoring recieved via SRB3 for UE3
    UE3 sends A3 measResult for nr_cell_1 from gNB_tgt with value above offset defined for PSCell
    Verify that gNB2 ignores Meas Report and does NOT send F1AP:UEContextModificationRequest for UE3

    Set gNB parameter actCuOvlProt to FALSE

    Expect Measurement Report via SRB3 for UE3
    Expect UE3 inter_gNB HO from gNB2 to gNB_tgt
    UE3 sends A3 measResult for nr_cell_1 from gNB_tgt with value above offset defined for PSCell
    Verify measurement send via SRB3 from UE3
    Verify that inter-gNB intra-frequency handover execution for UE3 succeed

    Expect Measurement Report via SRB3 for UE4
    Expect UE4 inter_gNB HO from gNB2 to gNB_tgt
    UE4 sends A3 measResult for nr_cell_1 from gNB_tgt with value above offset defined for PSCell
    Verify measurement send via SRB3 from UE4
    Verify that inter-gNB intra-frequency handover execution for UE4 succeed

    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55130C00001     2    SRB3C_SETUP_ATT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

    Verify Last Counters In File
    ...    M55124C04502     2    NRRCC_MEAS_NSA_DISCARD_OVLCP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

    Verify Last Counters In File
    ...    M55113C00504     3    NF1CC_UL_RRC_MSG_TRANSFER_SRB3
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}

    [Teardown]  run keywords
                ...   Perform CPLANE OVL deactivation via R&D mechanism
                ...   AND  Set gNB parameter srb3SupportEnbled to FALSE
                ...   AND  Detach UE1 and UE2
                ...   AND  Detach UE3 and UE4

*** Keywords ***

