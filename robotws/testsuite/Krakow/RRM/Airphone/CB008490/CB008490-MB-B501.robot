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
${SCF_gnb2_MN}=           Krakow/CB008490/scf_SN_GA_ABIO.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_MN_GA_ABIO_3xsimSN_GMC.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n257_n78.xml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7
${SKIP_COUNTERS}=         ${FALSE}

*** Test Cases ***
CB008490-SR-MB-B501 SN gNB rejects SNodeAdditionRequest in overload state
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Purpose of this test case is to verify behaviour of SN gNB after reception of SNodeAdditionRequest while SN gNB is in overload state.
    ...
    ...  == PRECONDITION ==
    ...     MN gNB NRBTS.gnbOvlProtMode = classical
    ...     MN gNB NRBTS.cuOvlHa.ovlNsaAddRej = enabled
    ...     UE1 is connected to MN gNB SA cell with A4 measurements for PSCell candidate NR frequency configured
    ...     MN gNB is not in overload state
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
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_24255
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-MB#B5: SN gNB rejects incoming XnAP: SNodeAdditionRequest due to overload
    ...
    ...  == HISTORY ==
    ...  [25.04.2024] - Create Test Suite
    ...  [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=910871)

    [Setup]    Prepare test environment CB008490-MB-501 on real gNBs

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Perform CPLANE OVL activation via R&D mechanism    # on SN

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition Reject for SN gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition Reject for SN gNB3
    Verify that SNodeAdditionRequestReject contains cause:misc:control-processing-overload for SN gNB3

    Perform CPLANE OVL deactivation via R&D mechanism
    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_REJ_OVL (M55116C00042) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-2 IE_NRDC_SN_SNODE_ADD_REQ (M55116C00039) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-2 IE_NRDC_SN_SNODE_ADD_ACK (M55116C00047) is equal 1

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
