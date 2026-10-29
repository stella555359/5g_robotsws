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

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot
Library     resources/CplaneOverloadSetter.py

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_GA_ABIP.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7

*** Test Cases ***
CB008490-SR-MB-B701 MN gNB restarts a4RetryTimer when a4RetryTimer expires in overload state
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Purpose of this test case is to verify MN gNB exceptional handling to the a4RetryTimer expiry event while MN gNB is in overload state.
    ...
    ...  == PRECONDITION ==
    ...     MN gNB NRBTS.gnbOvlProtMode = classical
    ...     MN gNB NRBTS.cuOvlHa.ovlSaA4TimerDiscard = enabled
    ...     MN gNB NRBTS.NRCELL.a4PeriodicMeasControlSA.a4Fr2SupervisionTimer = 10000 (10s)
    ...     MN gNB NRBTS.NRCELL.a4PeriodicMeasControlSA.a4RetryTimer = 10000 (10s)
    ...     UE1 is connected to MN gNB SA cell, A4 measurements are deconfigured upon supervisionTimer expiry, a4RetryTimer is running
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
    ...  - gNB classical BTS in SA mode as SN - gNB_SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_24257
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-MB#B7: MN gNB restarts a4RetryTimer when a4RetryTimer expires while MN gNB is overloaded
    ...  - ALT#1: a4RetryTimer expires while MN gNB is overloaded and NR-DC PScell is configured for UE already
    ...
    ...  == HISTORY ==
    ...  [25.04.2024] - Create Test Suite
    ...  [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=910871)

    [Setup]    Prepare test environment CB008490-MB-701

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flow for A4 measurements deconfiguration after supervisionTimer expiry for UE1
    Verify expected messages flow for A4 measurements deconfiguration after supervisionTimer expiry for UE1
    Perform CPLANE OVL activation via R&D mechanism
    Expect that A4 measurements are not configured after retryTimer expiry for UE1    # retryTimer is restarted
    Verify that A4 measurements are not configured after retryTimer expiry for UE1
    Perform CPLANE OVL deactivation via R&D mechanism
    Set expected messages flow for A4 measurements configuration after retryTimer expiry for UE1
    Verify expected messages flow for A4 measurements configuration after retryTimer expiry for UE1

    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=2 for NR-DC PSCell addition
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3

    # ALT#1
    Perform CPLANE OVL activation via R&D mechanism
    Expect that A4 measurements are not configured after retryTimer expiry for UE1    # retryTimer is restarted
    Verify that A4 measurements are not configured after retryTimer expiry for UE1
    Perform CPLANE OVL deactivation via R&D mechanism
    Set expected messages flow for A4 measurements configuration after retryTimer expiry for UE1
    Add QoS flows with 5QI from list [9] from NRDC splitted PDU1 at UE1 and expect TakeBack occured
    Set expected messages flow for A4 measurements configuration after retryTimer expiry for UE1
    Verify expected messages flow for A4 measurements configuration after retryTimer expiry for UE1

    [Teardown]    MB-701 cleanup


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
