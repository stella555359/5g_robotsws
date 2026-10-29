*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modified by: Kamil Szczesniak
...                contact: kamil.szczesniak@nokia.com
...                Test suite for basic UUF OAM Tests in loop:

Force Tags         CIT    QCD_MN_RAN    QCP_RAN_VRF    QC_43290    CA_VRF_WRO3

Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot

Suite Setup        Set Candidate

*** Variables ***
@{CUSTOMERS}                      Generic
${CANDIDATE}                      ${EMPTY}
${RESET_ITERATION}                5
${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     43290
${QC_PROJECT}                     RAN_VRF
${REPORT_COMMENT}                 ASIB_4G_RESET_UUFWRO3

&{enb1}                     node_alias=ASIL_MRAT         testline_object=${tl.enbs[0]}
...                         source_sw=${CANDIDATE}         target_sw=${CANDIDATE}

@{NODES}                    ${enb1}

*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_ASIB_4G_RESET
    [Timeout]   100h
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    ${NODES}
    ...    ${enb1}
    ...    ${RESET_ITERATION}
    ...    report=${True}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}

*** Keywords ***
Set Candidate
    ${candidate_sw}      Get Target SW
    Set to dictionary    ${enb1}    source_sw=${candidate_sw}    target_sw=${candidate_sw}
