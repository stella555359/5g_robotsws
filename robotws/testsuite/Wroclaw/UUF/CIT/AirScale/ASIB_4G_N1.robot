*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modified by: Kamil Szczesniak
...                contact: kamil.szczesniak@nokia.com
...                Test suite for basic UUF OAM Tests in loop:


Force Tags         CIT    QCD_MN_RAN    QCP_RAN_VRF    QC_43291    CA_VRF_WRO3

Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot

Suite Setup        Set Initial And Candidate

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${EMPTY}
${CANDIDATE}                      ${EMPTY}
${UPGRADE_ITERATION}              1
${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     43291
${QC_PROJECT}                     RAN_VRF
${REPORT_COMMENT}                 ASIB_4G_N1_UUFWRO3

&{NODE}                     node_alias=ASIL_MRAT         testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL}         target_sw=${CANDIDATE}

@{NODES}                    ${NODE}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_ASIB_4G_N1
    [Timeout]   100h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE}
    ...    ${UPGRADE_ITERATION}
    ...    report=${True}
    ...    report_comment=${REPORT_COMMENT}
    ...    restore_to_target_sw=${False}
    ...    customers_list=${CUSTOMERS}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}

*** Keywords ***

Set Initial And Candidate
    ${initial_sw}        Get Source SW
    ${candidate_sw}      Get Target SW
    Set to dictionary    ${NODE}    source_sw=${initial_sw}    target_sw=${candidate_sw}