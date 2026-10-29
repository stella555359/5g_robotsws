*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modified by: Kamil Szczesniak
...                contact: kamil.szczesniak@nokia.com
...                Test suite for basic UUF OAM Tests in loop:

Force Tags         QCD_MN_RAN    QCP_RAN_VRF    QC_43307    CA_VRF_WRO3    PY39

Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Variables        ../../../resources/common/mail_list.py
Resource           ../../../resources/common/uuf_keywords.robot

Suite Setup        Set Initial And Candidate

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${EMPTY}
${CANDIDATE}                      ${EMPTY}
${RESET_ITERATION}                20
@{CUSTOM_ALLOWED_ALARMS}
@{TEMPORARY_ALLOWED_ALARMS}
${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     43307
${QC_PROJECT}                     RAN_VRF
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 BUCKET_1_3_RESET_UUFWRO3_RFRL2

&{NODE_MRAT}                node_alias=2xASIL            testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL}         target_sw=${CANDIDATE}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                         temporary_allowed_alarms=${TEMPORARY_ALLOWED_ALARMS}

@{NODES}                    ${NODE_MRAT}


*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_Bucket_1_3
    [Timeout]   100h
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE_MRAT}
    ...    ${RESET_ITERATION}
    ...    report=${True}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}

*** Keywords ***

Set Initial And Candidate
    ${candidate_sw}      Get Target SW
    Set to dictionary    ${NODE_MRAT}    source_sw=${candidate_sw}    target_sw=${candidate_sw}
