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
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1260
...
...      == HISTORY ==
...      [25.06.2024] - Create Test Suite
...      [10.07.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=914589)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot
Resource    resources/CB008490_pm_counters.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/M/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/M/sfc_3cells_n78_n78_n257_simSN_GMC.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml

*** Test Cases ***
CB008490-SR-DC-B101 NR-DC User Capacity and Capability Counters after reestablishment during inter-gNB HO
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario aims to count number of users that are NR-DC capable in Inter-gNB use case. Test case verifies
    ...  that user capacity and capability counters are properly incremented after inter-gNB re-establishment during
    ...  Inter-gNB intra-freq HO (interaction with CB008574).
    ...
    ...  == PRECONDITION ==
    ...  - MN and SN gNB are configured as in CFAM CB008490-M Common Preconditions #1 5G_RAN_USR_RRM_23189 and #2 5G_RAN_USR_RRM_23190
    ...    with addition to:
    ...     - gNB2 (NRBTS-2) acting as MN and target gNB for inter-gNB HO:
    ...         - NRCELL-1 simulated on AEQE radio module - NR_BAND: n78 (PCI-50) - active in pure SA mode of operation
    ...         - NRCELL-1.actNrDualConnectivity is set to 'inter-gNB_FR1-FR2' (NR-DC enabled)
    ...    - gNB3 simulated on AirPhone acting as SN
    ...         - sim cell1 - NR_BAND: n257 (PCI-52)
    ...    - gNB4 simulated on AirPhone - source gNB for inter-gNB HO
    ...         - sim cell1 - NR_BAND: n78 (PCI-46)
    ...
    ...    - NRBTS-2.actInterGnbRREPreparedCell = true (CB008574)
    ...    - NRBTS-2.rrcReestabTypeSA = sameGNB (5GC000732)
    ...
    ...  == POSTCONDITION ==
    ...  - UE1 is in RRC-CONNECTED state on NRCELL-1 (MN-gNB2)
    ...  - A4 NR-DC measurements are activated for UE1
    ...  - A2/A3/A5 measurements for mobility purposes are not activated for UE1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  real gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78) in SA mode as MN
    ...  - sim gNB3 in NR-DC-SN mode as SN
    ...  - sim gNB4 in SA mode for inter-gNB HO
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_PM_787; 5G_RAN_USR_RRM_24316
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  CB008717: NR-DC user capability
    ...  CB008490-MB#B3 Interaction with CB008574 - RRC connection re-establishment under a prepared gNB (SA) during
    ...                         inter-gNB handover
    ...
    ...  == HISTORY ==
    ...  [25.06.2024] - Create Test Suite
    ...  [10.07.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=914589)
    ...  [02.12.2024] - add test case CB008490-SR-DB-B101_2

    [Setup]  Prepare test environment CB008490-DC-B101_1

    Attach UE1 to sim gNB4 cell1 with PDU session and indexToRFSP equal 1
    Set expected messages flows to check A4 activation without DRX after reestablishment for UE1
    Trigger UE1 XN HO with RRC Reestablishment from simulated gNB4 cell1 to real gNB2 NRCELL-1
    Verify expected messages flows to check A4 activation without DRX after reestablishment for UE1
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A2,A3,A5 measurements are not configured for UE1 in 2 out of 2 RRCReconfiguration message

    # CB008490-SR-DB-B101_2 - SN Counter reset after successful RRC Reestablishment to target cell under prepared gNB during XN HO
    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=7 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    Verify in RRCReconfiguration that sk-Counter is set to 0 for UE1

    Omit when SKIP_COUNTERS present
    ...  Wait until PM counters file is ready and saved for NRBTS-2

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55156C00004 - MAX_UE_NRDC_CAP equals 1
    ...  Verify counter value on NRBTS-2 NRCELL-1 for M55138C00038 - SUM_UE_NRDC_CAP is above 1

    [Teardown]  DC-B101_1 cleanup
