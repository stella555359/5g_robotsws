*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modified by: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM Tests in loop:

Force Tags         QCD_MN_RAN    QCP_RAN_VRF    QC_43320    CA_VRF_WRO3    PY39

Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Variables        ../../../resources/common/mail_list.py

Suite Setup        Set Initial And Candidate

*** Variables ***
@{CUSTOMERS}                    Generic
${INITIAL}                      ${EMPTY}
${CANDIDATE}                    ${EMPTY}
${RESET_ITERATION}              20
${QC_DOMAIN}                    MN_RAN
${TEST_QC_ID}                   43320
${QC_PROJECT}                   RAN_VRF
${QC_REPORT}                    ${True}
${REPORT_COMMENT}               BUCKET_2_1_RESET_UUFWRO3_RFRL2

&{NODE_4G}                  node_alias=ASIB_4G           testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL}         target_sw=${CANDIDATE}

&{NODE_5G}                  node_alias=ASIL_5G           testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL}         target_sw=${CANDIDATE}

@{NODES}                    ${NODE_4G}    ${NODE_5G}


*** Test Cases ***
E2E_Tl_Site_Reset_Without_Hwf_With_Oam_Kpi_Bucket_2_1
    [Timeout]   100h
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    ${NODES}
    ...    ${NODE_5G}
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
    Set to dictionary    ${NODE_4G}    source_sw=${candidate_sw}    target_sw=${candidate_sw}
    Set to dictionary    ${NODE_5G}    source_sw=${candidate_sw}    target_sw=${candidate_sw}
