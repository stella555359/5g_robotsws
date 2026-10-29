*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces mobility and non-basic measurements scenarios with inter-gNB NR-DC enabled:
...      - for incoming HO
...      - for ICS
...      - for retry timer related handling
...      - for IWK with RRC-Inactive
...
...      == TEST SET NAME ==
...      CB008490-M: Incoming mobility and non-basic measurement scenarios/legacy interactions
...
...      == TESTING SPLIT ==
...      For incoming HO:
...      CB008490-SR-M-B101 A2 MeasReport queued during PSCell Addition and during TakeBack
...      CB008490-SR-M-B102 Intra gNB HO with MFBI - mobillity measurements activated on UE when DU changed band to alternative
...
...      For ICS:
...      CB008490-SR-M-B1101 UE Cap Enquiry during not optimized ICS to cell with disabled NRDC
...      CB008490-SR-M-B1201 ICS optimized with non eligible PDU gNB blocks A3 A5 A2 for FWA
...      CB008490-SR-M-B1201 ICS not optimized with A2 redirection support gNB blocks A2 A3 A5
...      CB008490-SR-M-B1202 ICS optimized with MFBI gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1202 ICS optimized with MRL gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1302 Blocking mobility measurements and allowing A2 for redirection during PDU Session Setup
...
...      For retry timer related handling:
...      CB008490-SR-M-B1701 A4retryTimer restart when no NRDC eligible PDU on UE
...      CB008490-SR-M-B1702 A4 measurement configuration blocked when CB008490 disabled
...      CB008490-SR-M-B1702 A4 measurement configuration blocked when proper NRADJNRCELL not found
...      CB008490-SR-M-B1801 A4 for NRDC after TakeBack activated after A4RetryTimer expiry
...
...      == TESTING SCOPE ==
...      CB008490-SR-M-B1801 A4 for NRDC after TakeBack activated after A4RetryTimer expiry
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Grzegorz Szymik       <grzegorz.szymik@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1260
...
...      == HISTORY ==
...      [15.04.2024] - Create Test Suite
...      [10.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=909618)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot
Resource    resources/CB008490_pm_counters.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup       Run Keywords    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_GA_ABIP.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7

*** Test Cases ***
CB008490-SR-M-B1801_A4_for_NRDC_after_TakeBack
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the gNB behavior that:
    ...     - A4 retryTimer is restarted during successful NR-DC PSCell addition
    ...     - A4 NR-DC measurements are activated for UE after A4 retryTimer expiry after TakeBack
    ...
    ...  == PRECONDITION ==
    ...  - MN gNB and SN gNB configured according to CB008490-B common preconditions and CB008490-GA#B1.
    ...  - NRCELL-1.A4RetryTimer = 10
    ...  - NRPMRNL/NRPMQAP profiles are configured for MN NRBTS-2 and SN NRBTS-3:
    ...     NRBTS
    ...       actNrpmqapProfiles: 'true'
    ...       actNrpmqapProfiles: 'true'
    ...     NRPMRNL
    ...       miNrSaCuNrpmqap: '5min'
    ...       miNrMaxCellCuNrpmqap: '5min'
    ...       miNrRSACU: '5min'
    ...       miNrCUCM: '5min'
    ...     NRPMQAP
    ...       actCplaneCounters: 'true'
    ...       cfgProfType: 'SA'
    ...
    ...  == POSTCONDITION ==
    ...     NR-DC towards SN gNB is setup for UE1
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
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_24231
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-M#B18: Upon successful NR-DC PSCell addition, A4 retryTimer is started additionally.
    ...         And A4 retryTimer is restarted upon A4 retryTimer expiry if NR-DC PScell is configured for UE already.
    ...
    ...  == HISTORY ==
    ...      [22.03.2024] - Create Test Suite
    ...      [10.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=908161)

    [Setup]    Prepare test environment CB008490-M-B1801

    Omit when SKIP_COUNTERS present
    ...  Wait until PM counter files are ready and saved for gNBs

    Attach UE1 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE1 and AMF1

    Set expected messages flows for SNodeAddition for SN gNB3
    Set expected messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Set expected not failed messages flows for SNodeAddition for SN gNB3

    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition

    Verify expected messages flows for SNodeAddition for SN gNB3
    Verify expected messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for UE1, MN gNB2
    Verify expected not failed messages flows for SNodeAddition for SN gNB3

    Omit when SKIP_COUNTERS present
    ...  Wait until PM counter files are ready and saved for gNBs

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55156C00005 - MAX_UE_NRDC_MN_CU equals 1
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55138C00039 - SUM_UE_NRDC_MN_CU is above 1
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55195C00001 - MAX_UE_NRDC_MN_CU_PMQAP equals 1
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55161C00004 - SUM_UE_NRDC_MN_CU_PMQAP is above 1
    ...  Verify counter value on NRBTS-3 NRCELL-2 for M55156C00030 - MAX_UE_NRDC_SN_CU equals 1
    ...  Verify counter value on NRBTS-3 NRCELL-2 for M55138C00040 - SUM_UE_NRDC_SN_CU is above 1
    ...  Verify counter value on NRBTS-3 NRPMQAP-1 for M55195C00002 - MAX_UE_NRDC_SN_CU_PMQAP equals 1
    ...  Verify counter value on NRBTS-3 NRPMQAP-1 for M55161C00006 - SUM_UE_NRDC_SN_CU_PMQAP is above 1
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55161C00014 - DENOM_CPUE_1SEC_PMQAP is above 1
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55125C00029 - NG_FLOW_REL_NOR_NRDC equals 0
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55125C00030 - NG_FLOW_REL_ABN_NRDC equals 0

    Expect that A4 measurements are not configured after retryTimer eq 10 expiry for UE1
    Verify that A4 measurements are not configured after retryTimer eq 10 expiry for UE1

    Add QoS flows with 5QI from list [9] from NRDC splitted PDU1 at UE1 and expect TakeBack occured

    Expect that A4 measurements are activated after A4 retryTimer expiry for UE1
    Verify that A4 measurements are activated after A4 retryTimer expiry for UE1

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Wait For Next Full Pm Interval
    ...  Wait until PM counter files are ready and saved for gNBs

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55156C00005 - MAX_UE_NRDC_MN_CU equals 0
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55138C00039 - SUM_UE_NRDC_MN_CU equals 0
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55195C00001 - MAX_UE_NRDC_MN_CU_PMQAP equals 0
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55161C00004 - SUM_UE_NRDC_MN_CU_PMQAP equals 0
    ...  Verify counter value on NRBTS-3 NRCELL-2 for M55156C00030 - MAX_UE_NRDC_SN_CU equals 0
    ...  Verify counter value on NRBTS-3 NRCELL-2 for M55138C00040 - SUM_UE_NRDC_SN_CU equals 0
    ...  Verify counter value on NRBTS-3 NRPMQAP-1 for M55195C00002 - MAX_UE_NRDC_SN_CU_PMQAP equals 0
    ...  Verify counter value on NRBTS-3 NRPMQAP-1 for M55161C00006 - SUM_UE_NRDC_SN_CU_PMQAP equals 0
    ...  Verify counter value on NRBTS-2 NRPMQAP-1 for M55161C00014 - DENOM_CPUE_1SEC_PMQAP is above 1
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55125C00029 - NG_FLOW_REL_NOR_NRDC equals 0
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55125C00030 - NG_FLOW_REL_ABN_NRDC equals 0

    [Teardown]  Basic cleanup

