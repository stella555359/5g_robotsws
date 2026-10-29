*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modified by: Kamil Szczesniak
...                contact: kamil.szczesniak@nokia.com
...                Test suite for basic UUF OAM Tests in loop:

Force Tags         QCD_MN_RAN    QCP_RAN_VRF    QC_43318    CA_VRF_WRO3    PY39

Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource           ../../../resources/common/uuf_keywords.robot
Variables        ../../../resources/common/mail_list.py

Suite Setup        Set Initial And Candidate

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${EMPTY}
${CANDIDATE}                      ${EMPTY}
${UPGRADE_ITERATION}              3
@{CUSTOM_ALLOWED_ALARMS}
@{TEMPORARY_ALLOWED_ALARMS}
${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     43318
${QC_PROJECT}                     RAN_VRF
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 BUCKET_2_4_UPGRADE_UUFWRO3_RFRL2

&{NODE_MRAT}                node_alias=2xASIK            testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL}         target_sw=${CANDIDATE}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                         temporary_allowed_alarms=${TEMPORARY_ALLOWED_ALARMS}

@{NODES}                    ${NODE_MRAT}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_Bucket_2_4
    [Timeout]   100h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE_MRAT}
    ...    ${UPGRADE_ITERATION}
    ...    report=${True}
    ...    report_comment=${REPORT_COMMENT}
    ...    restore_to_target_sw=${False}
    ...    customers_list=${CUSTOMERS}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
#    ...    use_testpackage=${True}

*** Keywords ***

Set Initial And Candidate
    ${initial_sw}        Get Source SW
    ${candidate_sw}      Get Target SW
    Set to dictionary    ${NODE_MRAT}    source_sw=${initial_sw}    target_sw=${candidate_sw}
