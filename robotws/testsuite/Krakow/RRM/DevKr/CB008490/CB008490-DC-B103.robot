*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces counters allowing to monitor network events and capacity in inter-gNB NR-DC use cases
...
...      == TEST SET NAME ==
...      CB008490-DC PSCell Addition (PM counters)
...
...      == TESTING SPLIT ==
...      CB008490-SR-DC-B101 NR-DC User Capacity and Capability
...      CB008490-SR-DC-B102 Admission Control Counters
...      CB008490-SR-DC-B103 Inter-gNB NR-DC PSCell Addition Counters
...
...      == TESTING SCOPE ==
...      CB008490-SR-DC-B101 NR-DC User Capacity and Capability
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1260
...
...      == HISTORY ==
...      [16.10.2024] - Create Test Suite
...      [10.07.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=914589)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490_pm_counters.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_D_B301_MN_1xAWEUB_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B301_SN_1xAWEUB.xml
${AP_XML}=                Krakow/CB008490/iphy_1cell_n78_3cells_n257_1xAWEUB.xml
&{NRCELL_ID_TO_PHYSCELL_ID}=  1=50  2=52  3=53  4=54
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7

${yaml_DC}=           ${CURDIR}/config/yaml/DC_B103.yaml

*** Test Cases ***
CB008490-SR-DC-B103
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...    CB008490-SR-DC-B103 Unsuccessful PSCell Addition - RAC failed at gNB CU
    ...    Purpose of this test case is to verify SN gNB behavior during SNodeAddition procedure after failed RAC at SN gNB CU.
    ...
    ...  == PRECONDITION ==
    ...    MN gNB and SN gNB configured according to CB008490-B common preconditions and CB008490-GA#B1
    ...    SN gNB hosts three NRDC Cells (nrDcCell-1, nrDcCell-2, nrDcCell-3) on band n257 in the same cell group:
    ...     - nrDcCell-1 is NRCELL-2 with PCI = 52 and nrCellIdentity = 49154
    ...     - nrDcCell-2 is NRCELL-3 with PCI = 53 and nrCellIdentity = 49155
    ...     - nrDcCell-3 is NRCELL-4 with PCI = 54 and nrCellIdentity = 49156
    ...
    ...    RAC parameters are configured in SN gNB for:
    ...     - nrDcCell-1:
    ...      * NRCELL.maxNumOfNrDcSnUsers = default value
    ...      * NRCELL.maxNumOfNrDcSnNonGBRBearers = 2
    ...     - nrDcCell-2:
    ...      * NRCELL.maxNumOfNrDcSnUsers = 1
    ...      * NRCELL.maxNumOfSCellAlloc = 1
    ...      * NRCELL.maxNumOfNrDcSnNonGBRBearers = default value
    ...     - nrDcCell-3:
    ...      * NRCELL.maxNumOfNrDcSnUsers = default value
    ...      * NRCELL.maxNumOfNrDcSnNonGBRBearers = default value
    ...    RAC parameters are configured in SN gNB for cell group:
    ...     - NRCELLGRP.maxNumOfNrDcSnUsersCGRP = default value
    ...     - NRCELLGRP.maxNumOfNrDcSnNonGBRBearersCGRP = default value
    ...    Common RAC parameters are configured in SN gNB:
    ...     - NRCELL.maxNumOfUsersPerNRCell = default value
    ...     - NRDU.maxNumOfRrcConUEsPerDU = default value
    ...    PSCell load balancing is disabled in cells:
    ...     - NRCELL.ccLoadThreshold = 100 for all cells
    ...    UE1 is connected to MN gNB SA cell with A4 measurements for PSCell candidate NR frequency configured,
    ...    with PDU session eligible for NR-DC splitting with single splitable defaultDRB bearer
    ...
    ...  == POSTCONDITION ==
    ...    NR-DC is established for UE1 and UE2
    ...    NR-DC is not established for UE3 and UE4
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_PM_1645; 5G_RAN_USR_RRM_23692; 5G_RAN_USR_RRM_23694
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-DC PMO#4: Counters for failures during preparation phase of Inter-gNB NR-DC PSCell Addition - Procedure#1
    ...
    ...  == HISTORY ==
    ...  [16.10.2024] - Create Test Suite
    ...  [10.07.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=914589)

    [Setup]    Prepare test environment CB008490-DC-B103

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 52 for SN gNB3

    Attach UE2 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE2, MN gNB2, SN gNB3
    UE2 sends A4 measurement with id=1 and PCIs [53]
    Verify expected flows for SNodeAddition for UE2, MN gNB2, SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 53 for SN gNB3

    Attach UE3 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition failed at CU for SN gNB3
    UE3 sends A4 measurement with id=1 and PCIs [52]
    Verify expected messages flows for SNodeAddition failed at CU for SN gNB3
    Verify that SNodeAdditionRequestReject contains cause:radioNetwork:no-radio-resources-available for SN gNB3
    Deregister UE3

    Attach UE4 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition failed at CU for SN gNB3
    UE4 sends A4 measurement with id=1 and PCIs [53]
    Verify expected messages flows for SNodeAddition failed at CU for SN gNB3
    Verify that SNodeAdditionRequestReject contains cause:radioNetwork:no-radio-resources-available for SN gNB3
    Deregister UE4

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter on bts_id=1: NRCELL-1 NRDC_MN_A4_MEASUR_ACT (M55116C00037) is equal 4
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_ADD_REQ (M55116C00038) is equal 4
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_REJ (M55116C00045) is equal 2
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_REJ_RRNA (M55116C00040) is equal 2
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_ADD_ACK (M55116C00048) is equal 2
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_ADD_TEXP (M55116C00046) is equal 0

    ...  Check RTPM counter on bts_id=2: NRCELL-2 NRDC_SN_CU_AC_ATT (M55138C00071) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-2 NRDC_SN_CU_AC_SUC (M55138C00073) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-2 NRDC_SN_DU_AC_ATT (M55139C00032) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-2 IE_NRDC_SN_SNODE_ADD_REQ (M55116C00039) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-2 IE_NRDC_SN_SNODE_ADD_ACK (M55116C00047) is equal 1

    ...  Check RTPM counter on bts_id=2: NRCELL-3 NRDC_SN_CU_AC_ATT (M55138C00071) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-3 NRDC_SN_CU_AC_SUC (M55138C00073) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-3 NRDC_SN_DU_AC_ATT (M55139C00032) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-3 IE_NRDC_SN_SNODE_ADD_REQ (M55116C00039) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-3 IE_NRDC_SN_SNODE_ADD_ACK (M55116C00047) is equal 1

    [Teardown]    Basic cleanup

*** Keywords ***
Attach UE${ue_id:\d+} and add initial PDU session to MN gNB NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1

Set expected flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_id:\d+}, SN gNB${sn_id:\d+}
    Set expected messages flows for SNodeAddition for SN gNB${sn_id}
    Set expected messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Set expected not failed messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Set expected not failed messages flows for SNodeAddition for SN gNB${sn_id}

Verify expected flows for SNodeAddition for UE${ue_id:\d+}, MN gNB${mn_id:\d+}, SN gNB${sn_id:\d+}
    Verify expected messages flows for SNodeAddition for SN gNB${sn_id}
    Verify expected messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Verify expected not failed messages flows for SNodeAddition for UE${ue_id}, MN gNB${mn_id}
    Verify expected not failed messages flows for SNodeAddition for SN gNB${sn_id}

Set expected messages flows for SNodeAddition failed at CU for SN gNB${sn_gnb_id:\d+}
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparationFailure
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} E1AP bearerContextSetup
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} F1AP uEContextSetupFailure
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} E1AP bearerContextRelease
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNStatusTransfer

Verify expected messages flows for SNodeAddition failed at CU for SN gNB${sn_gnb_id:\d+}
    PASS FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNGRANnodeAdditionPreparationFailure
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} E1AP bearerContextSetup
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} F1AP uEContextSetupFailure
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} E1AP bearerContextRelease
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} XNAP xnUAddressIndication
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    FAIL FLOW[timeout=3]: gNB${sn_gnb_id} XNAP sNStatusTransfer
