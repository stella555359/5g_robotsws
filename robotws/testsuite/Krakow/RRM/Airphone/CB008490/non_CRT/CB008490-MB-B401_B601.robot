*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces additional scenarios during PSCell Addition.
...
...      == TEST SET NAME ==
...      CB008490-MB Incoming mobility and measurement scenarios (interaction with overload and reestablishment)
...
...      == TESTING SPLIT ==
...      For Reestablishment:
...      CB008490-SR-MB-B101 Start A4 retry timer after successful RRC Re-establishment to the same serving cell
...      CB008490-SR-MB-B102 Start A4 retry timer after successful RRC Re-establishment to the same serving cell - Blocking A4 retry timer starting
...      CB008490-SR-MB-B103 Start A4 retry timer after successful RRC Re-establishment to the same serving cell - Fallback to ICS
...      CB008490-SR-MB-B201 Start A4 retry timer after successful RRC Re-establishment to a different serving cell in same gNB
...         - Blocking A4 retry timer starting
...      CB008490-SR-MB-B203 Start A4 retry timer after successful RRC Re-establishment to a different serving cell in same gNB - Fallback to ICS
...      CB008490-SR-MB-B301 Interaction with CB008574 - RRC connection re-establishment under a prepared gNB (SA) during inter-gNB handover - XN Ho
...      CB008490-SR-MB-B302 CB008490-MB#B3 Interaction with CB008574 - RRC connection re-establishment under a prepared gNB (SA)
...         during inter-gNB handover - NG HO
...
...      For handling in overload status:
...      CB008490-SR-MB-B4: MN gNB discards received NR-DC A4 measurementReport while it is overloaded
...         1.	CB008490-MB#B401 Overload handling
...      CB008490-SR-MB-B5: SN gNB rejects incoming XnAP: SNodeAdditionRequest due to overload
...         1.	CB008490-MB#B501 Overload handling
...      CB008490-SR-MB-B6: MN gNB restarts a4SupervisionTimer when a4SupervisionTimer expires while MN gNB is overloaded
...         1.	CB008490-MB#B601 Overload handling
...      CB008490-SR-MB-B7: MN gNB restarts a4RetryTimer when a4RetryTimer expires while MN gNB is overloaded
...         1.	CB008490-MB#B701 Overload handling
...
...      == TESTING SCOPE ==
...      CB008490-MB#B401 Overload handling
...         1.	CB008490-SR-MB-B401 MN gNB discards NRDC A4 measurementReport in overload state
...      CB008490-MB#B501 Overload handling
...         1.	CB008490-SR-MB-B501 SN gNB rejects SNodeAdditionRequest in overload state
...      CB008490-MB#B601 Overload handling
...         1.  CB008490-SR-MB-B601 MN gNB restarts a4SupervisionTimer when a4SupervisionTimer expires in overload state
...      CB008490-MB#B701 Overload handling
...         1.  CB008490-SR-MB-B701 MN gNB restarts a4RetryTimer when a4RetryTimer expires in overload state
...
...      == CONTACTS ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/00025ee1#o=8981&hlt
...
...      == HISTORY ==
...      [25.04.2024] - Create Test Suite
...      [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=910871)
...      [17.06.2024] - merge TCs for CRT

Resource    ../resources/CB008490-common_keywords.robot
Resource    ../resources/CB008490_setup_and_teardowns.robot
Resource    ../resources/CB008490-flows_with_sim_gNB.robot
Library     ../resources/CplaneOverloadSetter.py

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/M/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/M/sfc_3cells_n78_n78_n257_simSN_GMC.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008490-SR-MB-B401 MN gNB discards NRDC A4 measurementReport in overload state
#    [Tags]    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Purpose of this test case is to verify MN gNB exceptional handling of NR-DC A4 measurementReport while MN gNB is in overload state.
    ...
    ...  == PRECONDITION ==
    ...     MN gNB NRBTS.gnbOvlProtMode = classical
    ...     MN gNB NRBTS.cuOvlHa.ovlSaMeasDiscard = enabled
    ...     MN gNB NRBTS.NRCELL.a4PeriodicMeasControlSA.a4Fr2SupervisionTimer = 10000 (10s)
    ...     UE1 is connected to MN gNB SA cell with A4 measurements for PSCell candidate NR frequency configured
    ...     MN gNB-CU-CP enters overload state according to 5GC000281
    ...
    ...  == POSTCONDITION ==
    ...    NR-DC established for UE1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - simulated gNB as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_24251
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-MB#B4: MN gNB discards received NR-DC A4 measurementReport while it is overloaded
    ...
    ...  == HISTORY ==
    ...  [25.04.2024] - Create Test Suite
    ...  [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=910871)

    [Setup]    Prepare test environment CB008490-MB-401

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Perform CPLANE OVL activation via R&D mechanism
    Expect that A4 measurements are ignored in overload state for UE1
    UE1 sends A4 measurement with id=1 and PCIs [52,53]
    Verify that A4 measurements are ignored in overload state for UE1
    Perform CPLANE OVL deactivation via R&D mechanism

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52,53]
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter: NRCELL-1 NRRCC_SA_MEAS_DISCARD_OVLCP (M55124C04503) is equal 1

    [Teardown]    MB-401 cleanup


CB008490-SR-MB-B601 MN gNB restarts a4SupervisionTimer when a4SupervisionTimer expires in overload state
    [Tags]    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Purpose of this test case is to verify MN gNB exceptional handling to the a4SupervisionTimer expiry event while
    ...    MN gNB is in overload state.
    ...
    ...  == PRECONDITION ==
    ...     MN gNB NRBTS.gnbOvlProtMode = classical
    ...     MN gNB NRBTS.cuOvlHa.ovlSaA4TimerDiscard = enabled
    ...     MN gNB NRBTS.NRCELL.a4PeriodicMeasControlSA.a4Fr2SupervisionTimer = 10000 (10s)
    ...     UE1 is connected to MN gNB SA cell with A4 measurements for PSCell candidate NR frequency configured, a4SupervisionTimer is running
    ...     MN gNB-CU-CP enters overload state according to 5GC000281
    ...
    ...  == POSTCONDITION ==
    ...    NR-DC established for UE1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - simulated gNB as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_24256
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - 	US CB008490-MB#B6: MN gNB restarts a4SupervisionTimer when a4SupervisionTimer expires while MN gNB is overloaded
    ...
    ...  == HISTORY ==
    ...  [25.04.2024] - Create Test Suite
    ...  [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=910871)

    [Setup]    Prepare test environment CB008490-MB-601

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Perform CPLANE OVL activation via R&D mechanism
    Expect that A4 measurements are not deconfigured after supervisionTimer expiry for UE1    # supervisionTimer is restarted
    Verify that A4 measurements are not deconfigured after supervisionTimer expiry for UE1
    Perform CPLANE OVL deactivation via R&D mechanism

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    [Teardown]    MB-401 cleanup


CB008490-SR-MB-B401_B601
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Merged testcases:
    ...     CB008490-SR-MB-B401 MN gNB discards NRDC A4 measurementReport in overload state
    ...     CB008490-SR-MB-B601 MN gNB restarts a4SupervisionTimer when a4SupervisionTimer expires in overload state
    ...
    ...  == PRECONDITION ==
    ...    See preconditions of corresponding test cases
    ...
    ...  == POSTCONDITION ==
    ...    See postconditions of corresponding test cases
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - simulated gNB as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_24251;5G_RAN_USR_RRM_24256
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-MB#B4: MN gNB discards received NR-DC A4 measurementReport while it is overloaded
    ...  - US CB008490-MB#B6: MN gNB restarts a4SupervisionTimer when a4SupervisionTimer expires while MN gNB is overloaded
    ...
    ...  == HISTORY ==
    ...  [25.04.2024] - Create Test Suite
    ...  [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=910871)

    [Setup]    Prepare test environment CB008490-MB-401

    # CB008490-SR-MB-B401 MN gNB discards NRDC A4 measurementReport in overload state
    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Perform CPLANE OVL activation via R&D mechanism
    Expect that A4 measurements are ignored in overload state for UE1
    UE1 sends A4 measurement with id=1 and PCIs [52,53]
    Verify that A4 measurements are ignored in overload state for UE1
    Perform CPLANE OVL deactivation via R&D mechanism

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52,53]
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter: NRCELL-1 NRRCC_SA_MEAS_DISCARD_OVLCP (M55124C04503) is equal 1

    Detach and kill UE1

    # CB008490-SR-MB-B601 MN gNB restarts a4SupervisionTimer when a4SupervisionTimer expires in overload state
    Configure cuOvlHa before B601

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Perform CPLANE OVL activation via R&D mechanism
    Expect that A4 measurements are not deconfigured after supervisionTimer expiry for UE1    # supervisionTimer is restarted
    Verify that A4 measurements are not deconfigured after supervisionTimer expiry for UE1
    Perform CPLANE OVL deactivation via R&D mechanism

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    [Teardown]    MB-401 cleanup


*** Keywords ***
Perform CPLANE OVL activation via R&D mechanism
    Set Overload High Threshold to 0
    Sleep  1

Perform CPLANE OVL deactivation via R&D mechanism
    Set Overload High Threshold to 40
    Sleep  1

Attach UE${ue_id:\d+} and add initial PDU session to MN gNB NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1

Configure cuOvlHa before B601
    ${config}    Catenate    [{'MOC': 'NRBTS', 'ID': '2', 'gnbOvlProtMode': 'classical'},
    ...                       {'MOC': 'NRBTS', 'ID': '2', 'cuOvlHa': [{'ovlSaA4TimerDiscard': 'enabled', 'ovlSaMeasDiscard': 'disabled'}]}]
    Configure    ${config}
