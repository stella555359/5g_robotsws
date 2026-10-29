*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Anna Plecha
...                 Contact: anna.plecha@nokia.com
...                 Description of particular variables You can find on Confluence:
...  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1926949248#UUFCSV4ALLHowtouseinVRF_WRO4-Testsuite(onenode)forTLwithinit.py

Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             taf/rfrl/csv4all/resources/utilities/utilities.py

*** Variables ***
${UPDATE_TEST_ITERATION}              5
${ACTIVATION_RESET_TEST_ITERATION}    10

${RP_CA}                    VRF_SiSo
${RP_LOCATION}              VRF_WRO3
${RP_ORGANIZATION}          VRF_WRO3_T07
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF
${EMAIL_RECIPIENTS}         katarzyna.herlender@nokia.com
@{CUSTOMERS}                Generic
${REPORT}                   ${True}

${INITIAL_SW}               @{EMPTY}     # Set initial build if you are running test from VM e.g. ${INITIAL_SW}  SBTS25R1_ENB_0000_000405_000000
${TARGET_SW}                @{EMPTY}    # Set target build if you are running test from VM. e.g. ${TARGET_SW}  SBTS00_ENB_9999_241216_000009
@{CUSTOM_ALARMS}            @{EMPTY}     # If expected alarms have occurred, type FID number here e.g. @{CUSTOM_ALARMS}  7307  6203

&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=10_16_UTESRANSISO129_1

@{NODES}                    ${NODE1}

*** Test Cases ***
[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   24h
    Set Initial And Candidate
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     restore_to_target_sw=${True}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${121580}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${182876}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}