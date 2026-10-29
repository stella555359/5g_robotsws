*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Przemyslaw Sas                                               # Set your Name
...                 Contact: przemyslaw.sas@nokia.com                                    # Set your email

Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             taf/rfrl/csv4all/resources/utilities/utilities.py

*** Variables ***
${UPDATE_TEST_ITERATION}        10                                  # Set iteration count for SW_Upgrade_Rollback test
${ACTIVATION_RESET_TEST_ITERATION}    10                                  # Set iteration count for Site_Reset_without_HWF test

${RP_CA}                    VRF_SiSo                                # Set Competence Area
${RP_LOCATION}              VRF_WRO3                                # Set Location
${RP_ORGANIZATION}          VRF_WRO3_T01                            # Set Organization (RP_LOCATION + Team prefix)
${QC_DOMAIN}=               MN_RAN                                  # Set QC DOMAIN. Parameter to define under which QC Domain should be reported
${QC_PROJECT}=              RAN_VRF                              # Set QC PROJECT. Parameter to define under which QC project to report, e.g. RAN_VRF
${EMAIL_RECIPIENTS}         przemyslaw.sas@nokia.com         # Set your email if You want to be notified when test start/end and failures
@{CUSTOMERS}                TMO US                       # List of customers for a given TL e.g. TMO US, if no specific customer then set to Generic
${REPORT}                   ${True}                              # Flag to enable reporting to Reporting Portal, UUF reports, set to True by default.
                                                                    # If you don't want automatic reporting, set this parameter to ${False}

${INITIAL_SW}               ${EMPTY}          # Set initial build if you are running test from VM e.g. ${INITIAL_SW}  SBTS25R1_ENB_0000_000405_000000
${TARGET_SW}                ${EMPTY}          # Set target build if you are running test from VM. e.g. ${TARGET_SW}  SBTS00_ENB_9999_241216_000009

@{CUSTOM_ALARMS}            @{EMPTY}                                 # Each node can have its own set of allowed faults during test operation
                                                             # If expected alarms have occurred, type FID(s) number e.g. @{CUSTOM_ALARMS}  7307  6203
                                                                     # Custom: Will be ignored throughout the entire test execution

# UTE testline initialization (VM definition in init must have a Connection object linking VM to BTS)
# Single BTS or fullrack (dualcore, including Airscale + FSM3) configurations require one node
&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=10_16_UTESRANSISO132         # Set TL hostname like name of BTS in Scout e.g. 10_16_UTESRANSISO083_1


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
    ...     qc_id=${63661}                                     # Set QC ID. Parameter to define under which QC ID should be reported e.g. ${53536}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${180946}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
