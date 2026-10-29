*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces successful procedure of inter-gNB NR-DC UE bulk release.
...
...      == TEST SET NAME ==
...      CB008490-EB: Bulk UE release
...
...      == TESTING SPLIT ==
...      CB008490-EB#B101 NG Full/Partial Reset - AMF initiated - MN side
...      CB008490-EB#B102 XNAP: Reset Request reception - SN side
...      CB008490-EB#B103 NG Partial Reset - AMF initiated  concurrency (SCT only)
...      CB008490-EB#B201 NG Full/Patrial Reset - gNB initiated - MN side
...      CB008490-EB#B202 XNAP: Reset Request sending from SN side
...      CB008490-EB#B301 Partial Reset - Dropped Xn link
...      CB008490-EB#B302 Pool Failure - SDL
...
...      == TESTING SCOPE ==
...      CB008490-EB: Bulk UE release
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
...      [08.07.2024] - Create Test Suite
...      [23.07.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=915535)
...

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_2c_n78_n257_TDD_SA_multiUE.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scf_MN_GA_ABIP_3xsimSN_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_SN_GA_ABIP.xml
${AP_XML}=                Krakow/CB008490/iphy_2cells_n78_n257.xml

${BBMOD_GNB_DIST_NAME}=    MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1

*** Test Cases ***
CB008490-SR-EB-B202_SN_side_gNB_partial_reset_users_from_impacted_cell
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...    This user scenario describes the gNB behaviour for UE with established inter-gNB NR-DC connection during gNB initiated
    ...    NG Partial Reset procedure to reset/re-initialize the NG interface.
    ...    Trigger for NG Reset is receiving XnAP Reset Request from SN gNB.
    ...
    ...  == PRECONDITION ==
    ...    Common preconditions to all CB008490-E User Scenarios (5G_RAN_USR_RRM_23633)
    ...    UE1 with configured inter-gNB NR-DC in SN gNB#1
    ...
    ...  == POSTCONDITION ==
    ...    NR-DC is established for UE1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode as MN
    ...  - gNB classical BTS in NR-DC-SN mode as SN
    ...  - gNB module MN (ASIL + ABIO / ASIM + ABIP)
    ...  - gNB module SN (ASIL + ABIO / ASIM + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_25650
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-EB#B2 NG Full/Partial Reset - gNB initiated
    ...
    ...  == HISTORY ==
    ...  [08.07.2024] - Create Test Suite
    ...  [23.07.2024]  - Review closed (https://collab.ext.net.nokia.com/ui#review:id=915535)
    ...  [07.08.2025] - CNI-144225 - added backgorund UEs with real capabilities

    [Setup]    Prepare test environment CB008490-EB-B202

    Attach background UEs 11-40 and start traffic

    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3

    Set expected messages flows for F1 Link drop for gNB3
    Set expected messages flows for XN Link drop for UE1, MN gNB2
    Drop F1 SCTP connection on SN gNB
    Verify expected messages flows for F1 Link drop for gNB3
    Verify expected messages flows for XN Link drop for UE1, MN gNB2

    Verify that E1AP Reset contains cause:transport:unspecified, gNB3
    Verify that XNAP ResetRequest ResetRequestTypeInfo contains 'partialReset', gNB2
    Verify that XNAP ResetRequest contains cause:transport:transport-resource-unavailable, gNB2
    Verify that E1AP Reset contains cause:transport:unspecified, gNB2
    Verify that F1AP Reset contains cause:transport:unspecified, gNB2
    Verify that NGAP NGReset contains cause:radioNetwork:release-due-to-ngran-generated-reason, gNB2
    Verify that NGAP NGReset ResetType contains 'partOfNG-Interface', gNB2

    Set expected messages flows for F1 Link setup for SN gNB3
    Restore F1 SCTP connection on SN gNB
    Verify expected messages flows for F1 Link setup for SN gNB3
    Wait Until Keyword Succeeds  60s  10s
    ...    Object attributes should be    NRCELL-2    operationalState=enabled    bts_id=2

    Set expected message flows for UE1 reestablishment via RRC Setup
    Execute egate command    cmd=amf_ue_ics_param id=1 ue=1 indexToRFSP=1
    Trigger UE1 reestablishment via RRC Setup
    Verify expected message flows for UE1 reestablishment via RRC Setup

    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3

    [Teardown]    EB-202 cleanup


*** Keywords ***
Attach UE${ue_id:\d+} and add initial PDU session to MN gNB NRCELL-${cell_id:\d+}
    Attach UE${ue_id} without ICS to gNB2 cell${cell_id}
    Set expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1
    Add to UE${ue_id} initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE${ue_id} and AMF1

Attach background UEs ${start_ue}-${end_ue} and start traffic
    ${end_ue}    Evaluate    ${end_ue} + 1
    FOR   ${ue}   IN RANGE    ${start_ue}    ${end_ue}
        ${ue}    Convert to String    ${ue}
        Attach UE${ue} to gNB2 cell1 with ICS and PDU session setup after ICS
        Run 5Mbps UL and DL traffic on UE${ue} PDU1 QFI1 and wait 1 seconds
    END
    sleep    5

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
