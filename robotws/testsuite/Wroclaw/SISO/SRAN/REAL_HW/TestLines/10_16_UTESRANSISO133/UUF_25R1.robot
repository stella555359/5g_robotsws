*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Krzysztof Pekala (rafał zawsze w sercu xD)
...                 Contact: krzysztof.pekala@nokia.com
...                 Description of particular variables You can find on Confluence:
...  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1926949248#UUFCSV4ALLHowtouseinVRF_WRO4-Testsuite(onenode)forTLwithinit.py

Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             taf/rfrl/csv4all/resources/utilities/utilities.py

*** Variables ***
${UPDATE_TEST_ITERATION}        10
${SITE_RESET_TEST_ITERATION}    10

${RP_CA}                    VRF_SiSo
${RP_LOCATION}              VRF_WRO4
${RP_ORGANIZATION}          VRF_WRO4_T05
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF
${EMAIL_RECIPIENTS}         kzysztof.pekala@nokia.com
@{CUSTOMERS}                TMO US
${REPORT}                   ${True}

${INITIAL_SW}               SBTS00_ENB_9999_250127_000010
${TARGET_SW}                SBTS00_ENB_9999_250128_000007
@{CUSTOM_ALARMS}            @{EMPTY}

&{NODE1}                    node_vm=10.44.240.24
...                         secondary_vm=10.44.240.25
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=10_16_UTESRANSISO133_1

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
    ...     restore_to_target_sw=${False}    # blokuje drugi update
    ...     qc_id=${97681}

[1][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}  ${NODE1}  ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${97682}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
