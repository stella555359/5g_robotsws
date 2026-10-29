*** Settings ***
Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

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
...      == MAINTAINER ==
...                      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      REFERENCES:  5GC000281 CFAM
...                   https://nokia.sharepoint.com/:w:/r/sites/5Gdoc/AS_Tech_Spec/CFAMs/5GC0200-5GC0399/5GC000281%20C-plane%20overload%20protection
...                   /CP1%20Material/CP1%20CFAM%205GC000281%20ReviewVersion.docx?d=w3980c65d39b7415ba4af1304c8f5dd56&csf=1&web=1&e=zZH0vi
...
...      HISTORY:
...         [30.08.2021] - Created TC instance for ASOE
...         [26.05.2022] - Airphone APoABIO switch

Resource    ./resources/5GC000281_B_keywords.robot

Suite Setup   Prepare test suite for NSA CPLANE Overload Testing

*** Variables ***
&{TOPOLOGY_TO_LUA}=     CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD=${CURDIR}/config/NSA/egate_2c_2g_NSA.lua
...        CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE=${CURDIR}/config/NSA/egate_TDD_2c_FDD_2c_2g_NSA.lua
...        CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ=${CURDIR}/config/NSA/egate_TDD_2c_FDD_2c_2g_NSA.lua
...        CLOUD_5G_O_E_AP_LOO:VARIANT_PRIVATE_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_4_CELLS=${CURDIR}/config/NSA/egate_TDD_2c_FDD_2c_2g_NSA.lua
${LUA_CFG}=    ${CURDIR}/config/NSA/egate_2c_2g_NSA.lua
${GNB_PLATFORM_TYPE}=       ASOE

*** Test Cases ***
CB007326_5GC000281_SgNBAddition_rejected_in_CPLN_ovl_state_ASOE
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info==
    ...  Test case purpose is to validate gNB working in CPLANE overload state.
    ...  Verification if when 5GC000281 is turn on and ovlNsaAddRej is TRUE then for gNB in NSA mode all incomming
    ...  SgNBAdditionRequests for new UEs are rejected due to overload.
    ...
    ...  == Precondition: ==
    ...  gNB classical - real hardware - ABIL + ASIK;
    ...	 NRCELL simulated on AEQA radio module - NR_BAND: n78;
    ...  UE - Airphone simulator;
    ...  eNB - simulated MeNB by WTS;
    ...
    ...  eNB up and running;
    ...  eNB establish ENDC_X2 connection with gNB;
    ...  gNB up and running with one NSA cell OnAir;
    ...  UE1 attached to eNB with installed B1-NR meas object related to gNB nrcell;
    ...  UE2 attached to eNB with installed B1-NR meas object related to gNB nrcell;
    ...  UE3 attached to eNB with installed B1-NR meas object related to gNB nrcell;
    ...  gNB not in CPLANE overload state;
#    ...  NRBTS-actCuOvlProt is set to TRUE;    Parameter removed in 24R2
    ...  NRBTS-gnbOvlProtMode is set to CLASSICAL;
    ...  NRBTS-ovlNsaAddRej is set to TRUE;
    ...  NRCELL-cellDepType is set to NSA;
    ...  NRDRB - nsa3xBearerAllowed is set to TRUE;
    ...
    ...
    ...  TESTING TOOLS: AirPhone, EPCSIM, UTE
    ...
    ...  TEST ENVIRONMENT: gNB classicBTS in NSA mode
    ...         HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78;
    ...
    ...  REQUIREMENTS COVERAGE:
    ...         REQUIREMENTS IN SCOPE: 5G_RAN_USR_17358; 5G_RAN_CP_12360144; 5G_RAN_CP_12360154; 5G_RAN_CP_12360787;
    ...                                5G_RAN_CP_12360462; 5G_RAN_CP_12361124; 5G_RAN_CP_12360458;
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
    ...         [12.11.2020] - Created TC
    ...         [04.12.2020] - Implementation start
    ...         [30.08.2021] - ASOE parity
    ...         [26.05.2022] - Airphone APoABIO switch

    [Setup]  run keywords
    ...       Start egate collection    AND
    ...       Prepare test environment B1


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

    [Teardown]  run keywords
    ...       Cleanup after test B1   AND
    ...       Stop egate collection
