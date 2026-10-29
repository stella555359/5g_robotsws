*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modified by: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM Tests in loop:


Force Tags         QCD_MN_RAN    QCP_RAN_VRF    QC_43324    CA_VRF_WRO3    PY39

Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Variables        ../../../resources/common/mail_list.py

Suite Setup        Set Initial And Candidate

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${EMPTY}
${CANDIDATE}                      ${EMPTY}
${UPGRADE_ITERATION}              3
@{4G_CUSTOM_ALLOWED_ALARMS}       4078
@{5G_CUSTOM_ALLOWED_ALARMS}       4078
@{4G_TEMPORARY_ALLOWED_ALARMS}    4530    4773
${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     43324
${QC_PROJECT}                     RAN_VRF
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 BUCKET_2_3_UPGRADE_UUFWRO3_RFRL2

&{NODE_4G}                  node_alias=ASIB_4G           testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL}         target_sw=${CANDIDATE}
...                         custom_allowed_alarms=${4G_CUSTOM_ALLOWED_ALARMS}
...                         temporary_allowed_alarms=${4G_TEMPORARY_ALLOWED_ALARMS}

&{NODE_5G}                  node_alias=ASIB_5G           testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL}         target_sw=${CANDIDATE}
...                         custom_allowed_alarms=${5G_CUSTOM_ALLOWED_ALARMS}

@{NODES}                    ${NODE_4G}    ${NODE_5G}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_Bucket_2_3
    [Timeout]   100h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE_5G}
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
    Set to dictionary    ${NODE_4G}    source_sw=${initial_sw}    target_sw=${candidate_sw}
    Set to dictionary    ${NODE_5G}    source_sw=${initial_sw}    target_sw=${candidate_sw}