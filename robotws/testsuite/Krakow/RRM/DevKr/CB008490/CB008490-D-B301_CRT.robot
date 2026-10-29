*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces additional scenarios during PSCell Addition.
...
...      == TEST SET NAME ==
...      CB008490-SR-D-B301 Admission Control (SN)
...
...      == TESTING SPLIT ==
...      CB008490-SR-D-B101 Measurement handling (MN)
...      CB008490-SR-D-B201 Interactions handling (MN)
...      CB008490-SR-D-B301 Admission Control (SN)
...      CB008490-SR-D-B401 Security procedures in PSCell Addition (MN and SN)
...      CB008490-SR-D-B501 Data Transmission
...
...      == TESTING SCOPE ==
...      CB008490-SR-D-B301 Admission Control (SN)
...         1.	CB008490-SR-D-B301_1 Successful RAC in PSCell and selection of not fully loaded NRDC cell
...         2.	CB008490-SR-D-B301_3 Unsuccessful PSCell Addition - RAC failed at gNB DU
...         3.	CB008490-SR-D-B301_4 PSCell Load Balancing - selected PSCell is not on A4 measurement list
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
...      [02.02.2024] - Create Test Suite
...      [12.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=905958)
...      [05.04.2024] - Merge TCs 1, 3 and 4 into single one

Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD

Suite Setup    Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_4c_n78_n257_TDD_SA.cfg
${SCF_gnb2_MN}=           Krakow/CB008490/scf_D_B301_MN_1xAWEUB_GMC.xml
${SCF_gnb3_SN}=           Krakow/CB008490/scf_D_B301_SN_1xAWEUB.xml
${AP_XML}=                Krakow/CB008490/iphy_1cell_n78_3cells_n257_1xAWEUB.xml
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7
${yaml_B301_CRT_1}=           ${CURDIR}/config/yaml/B301_CRT_1.yaml
${yaml_B301_CRT_2}=           ${CURDIR}/config/yaml/B301_CRT_2.yaml
${SKIP_COUNTERS}=         ${FALSE}


*** Test Cases ***
CB008490-SR-D-B301_1_3_4
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...    Merged testcases from file CB008490-D-B301.robot:
    ...      1.	CB008490-SR-D-B301_1 Successful RAC in PSCell and selection of not fully loaded NRDC cell
    ...      2.	CB008490-SR-D-B301_3 Unsuccessful PSCell Addition - RAC failed at gNB DU
    ...      3.	CB008490-SR-D-B301_4 PSCell Load Balancing - selected PSCell is not on A4 measurement list
    ...
    ...  == PRECONDITION ==
    ...    See preconditions of corresponding test cases
    ...
    ...  == POSTCONDITION ==
    ...    NR-DC is established for UEs 1-4
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
    ...  REQUIREMENTS IN SCOPE:    5G_RAN_USR_RRM_23691;5G_RAN_USR_RRM_23695;5G_RAN_USR_RRM_23696
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - US CB008490-D#B10: NR-DC PSCell RAC (successful admission)
    ...
    ...  == HISTORY ==
    ...    [02.02.2024] - Create Test Suite
    ...    [12.03.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=905958)
    ...

    [Setup]    Prepare test environment CB008490-D-B301_CRT

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    # CB008490-SR-D-B301_1 Successful RAC in PSCell and selection of not fully loaded NRDC cell
    # NRCELL-2 NRDC_SN_CU_AC_ATT++, NRDC_SN_CU_AC_SUC++
    Attach UE1 and add initial PDU session to MN gNB NRCELL-1
    Add to UE1 PDU1 session QoS flows with 5QI from list [8] and delete QoS flows with 5QI from list [] via amf
    Set expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    UE1 sends A4 measurement with id=1 and PCIs [52]
    Verify expected flows for SNodeAddition for UE1, MN gNB2, SN gNB3
    Verify sdap-Config for all DRBs
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-2 for SN gNB3
    Verify in UEContextSetupRequest candidateCellInfoListMN for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 52 for SN gNB3

    # NRCELL-2/3 NRDC_SN_CU_AC_ATT++, NRCELL-3 NRDC_SN_CU_AC_SUC++
    Attach UE2 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE2, MN gNB2, SN gNB3
    UE2 sends A4 measurement with id=1 and PCIs [52,53]
    Verify expected flows for SNodeAddition for UE2, MN gNB2, SN gNB3
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-3 for SN gNB3
    Verify in UEContextSetupRequest candidateCellInfoListMN for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 53 for SN gNB3

    # NRCELL-2/3/4 NRDC_SN_CU_AC_ATT++, NRCELL-4 NRDC_SN_CU_AC_SUC++, NRDC_SN_DU_AC_ATT++
    Attach UE3 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE3, MN gNB2, SN gNB3
    UE3 sends A4 measurement with id=1 and PCIs [52,53,54]
    Verify expected flows for SNodeAddition for UE3, MN gNB2, SN gNB3
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-4 for SN gNB3
    Verify in UEContextSetupRequest candidateCellInfoListMN for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 54 for SN gNB3

    # CB008490-SR-D-B301_3 Unsuccessful PSCell Addition - RAC failed at gNB DU
    # NRCELL-4 NRDC_SN_CU_AC_ATT++, NRDC_SN_CU_AC_SUC++, NRDC_SN_DU_AC_ATT++, NRDC_SN_DU_AC_REJ_RRCUE_CELL++
    Attach UE4 and add initial PDU session to MN gNB NRCELL-1
    Set expected messages flows for SNodeAddition failed at DU for SN gNB3
    UE4 sends A4 measurement with id=1 and PCIs [54]
    Verify expected messages flows for SNodeAddition failed at DU for SN gNB3

    Verify that SNodeAdditionRequestReject contains cause:radioNetwork:no-radio-resources-available for SN gNB3
    Verify that UEContextSetupFailure contains cause:radioNetwork:no-radio-resources-available for SN gNB3
    Verify that E1AP:BearerContextReleaseCommand contains cause:radioNetwork:no-radio-resources-available for SN gNB3
    Verify that E1AP:BearerContextReleaseCommand has 3 IEs for SN gNB3
    Verify that E1AP:BearerContextReleaseComplete has 3 IEs for SN gNB3

    Trigger UE4 to send deregister request

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter on bts_id=1: NRCELL-1 NG_FLOW_REL_NOR_NRDC (M55125C00029) is equal 0
    ...  Check RTPM counter on bts_id=1: NRCELL-1 NRDC_MN_A4_MEASUR_ACT (M55116C00037) is equal 4
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_ADD_REQ (M55116C00038) is equal 4
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_REJ (M55116C00045) is equal 1
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_REJ_RRNA (M55116C00040) is equal 1
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_ADD_ACK (M55116C00048) is equal 3
    ...  Check RTPM counter on bts_id=1: NRCELL-1 IE_NRDC_MN_SNODE_ADD_TEXP (M55116C00046) is equal 0
    ...  Check RTPM counter on bts_id=2: NRCELL-2 NRDC_SN_CU_AC_ATT (M55138C00071) is equal 3
    ...  Check RTPM counter on bts_id=2: NRCELL-2 NRDC_SN_CU_AC_SUC (M55138C00073) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-3 NRDC_SN_CU_AC_ATT (M55138C00071) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-3 NRDC_SN_CU_AC_SUC (M55138C00073) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-4 NRDC_SN_CU_AC_ATT (M55138C00071) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-4 NRDC_SN_CU_AC_SUC (M55138C00073) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-4 NRDC_SN_DU_AC_ATT (M55139C00032) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-4 NRDC_SN_DU_AC_REJ_RRCUE_CELL (M55139C00028) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-4 NRDC_SN_DU_AC_REJ_PUCCH_CELL (M55139C00022) is equal 0
    ...  Check RTPM counter on bts_id=2: NRCELL-4 IE_NRDC_SN_SNODE_ADD_REQ (M55116C00039) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-4 IE_NRDC_SN_SNODE_ADD_ACK (M55116C00047) is equal 1

    # CB008490-SR-D-B301_4 PSCell Load Balancing - selected PSCell is not on A4 measurement list
    Configure   ${yaml_B301_CRT_2}    bts_id=2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    # NRCELL-2/4 NRDC_SN_CU_AC_ATT++, NRDC_SN_CU_AC_SUC++, NRCELL-4 NRDC_SN_CU_AC_LB++
    Attach UE4 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE4, MN gNB2, SN gNB3
    UE4 sends A4 measurement with id=1 and PCIs [54]
    Verify expected flows for SNodeAddition for UE4, MN gNB2, SN gNB3
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-2 for SN gNB3
    Verify in UEContextSetupRequest candidateCellInfoListMN for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 52 for SN gNB3

    # NRCELL-3/4 NRDC_SN_CU_AC_ATT++, NRDC_SN_CU_AC_SUC++, NRCELL-4 NRDC_SN_CU_AC_LB++
    Attach UE5 and add initial PDU session to MN gNB NRCELL-1
    Set expected flows for SNodeAddition for UE5, MN gNB2, SN gNB3
    UE5 sends A4 measurement with id=1 and PCIs [54]
    Verify expected flows for SNodeAddition for UE5, MN gNB2, SN gNB3
    Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-3 for SN gNB3
    Verify in UEContextSetupRequest candidateCellInfoListMN for SN gNB3
    Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is 53 for SN gNB3

    Trigger UEs from 1 to 5 to send deregister request

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Check RTPM counter on bts_id=2: NRCELL-2 NRDC_SN_CU_AC_ATT (M55138C00071) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-2 NRDC_SN_CU_AC_SUC (M55138C00073) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-2 NRDC_SN_CU_AC_LB (M55138C00072) is equal 0
    ...  Check RTPM counter on bts_id=2: NRCELL-3 NRDC_SN_CU_AC_ATT (M55138C00071) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-3 NRDC_SN_CU_AC_SUC (M55138C00073) is equal 1
    ...  Check RTPM counter on bts_id=2: NRCELL-3 NRDC_SN_CU_AC_LB (M55138C00072) is equal 0
    ...  Check RTPM counter on bts_id=2: NRCELL-4 NRDC_SN_CU_AC_ATT (M55138C00071) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-4 NRDC_SN_CU_AC_SUC (M55138C00073) is equal 2
    ...  Check RTPM counter on bts_id=2: NRCELL-4 NRDC_SN_CU_AC_LB (M55138C00072) is equal 2
    ...  Check RTPM counter on bts_id=1: NRCELL-1 NG_FLOW_REL_NOR_NRDC (M55125C00029) is equal 6

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

Verify sdap-Config for all DRBs
    Run Keyword And Continue On Failure
    ...    Verify in SNodeAdditionRequest and SNodeAdditionRequestAcknowledge sdap-Config for all DRBs    gnb=3    rdDisableSDAPheaderSa=${False}
    Run Keyword And Continue On Failure
    ...    Verify in BearerContextSetupRequest sdap-Config for all DRBs    gnb=3    rdDisableSDAPheaderSa=${False}
