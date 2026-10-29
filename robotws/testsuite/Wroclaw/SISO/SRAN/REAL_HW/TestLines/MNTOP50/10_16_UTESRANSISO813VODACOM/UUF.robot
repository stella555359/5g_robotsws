*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Marek Ledwon                                              # set your Name
...                 Contact: marek.ledwon@nokia.com                                    # set your email

Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             taf/rfrl/csv4all/resources/utilities/utilities.py

*** Variables ***
${UPDATE_TEST_ITERATION}        2
${ACTIVATION_RESET_TEST_ITERATION}    10
${RU_RESET_ITERATION}	20
${CAPACITY_MODULE_RESET_ITERATION}    10
${DELTA_COMMISSIONING_ITERATION}    10
${SITE_RESET_TEST_ITERATION}    15

${RP_CA}                    VRF_SiSo
${RP_LOCATION}              VRF_WRO3
${RP_ORGANIZATION}          VRF_WRO3_T01
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF
${EMAIL_RECIPIENTS}         marek.ledwon@nokia.com
@{CUSTOMERS}                Vodacom South Africa
${REPORT}                   ${True}

${INITIAL_SW}               ${EMPTY}     # Set initial build if you are running test from VM e.g. ${INITIAL_SW}  SBTS25R1_ENB_0000_000405_000000
${TARGET_SW}                ${EMPTY}     # Set target build if you are running test from VM. e.g. ${TARGET_SW}  SBTS00_ENB_9999_241216_000009

@{CUSTOM_ALARMS}            @{EMPTY}     # If expected alarms have occurred, type FID number here e.g. @{CUSTOM_ALARMS}  7307  6203

${ONLINE_PARAMETER_DELTA}=  /home/ute/testline_configuration/10_16_UTESRANSISO813VODACOM/online_parameter.yaml

&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=10_16_UTESRANSISO813VODACOM

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
    ...     qc_id=${228761}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODE1}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${228762}

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${RU_RESET_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${228790}

[1][1.0] E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  ${DELTA_COMMISSIONING_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     delta=${ONLINE_PARAMETER_DELTA}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${273483}

[1][2.0] E2E_TL_Site_Reset_with_OAM_KPI_LTE
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${273484}

[1][1.0] E2E_TL_Power_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL POWER SITE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${273485}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
