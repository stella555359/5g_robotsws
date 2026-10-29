*** Settings ***
Documentation
...    Author: artur.lebek@nokia.com
...    Description: Suite prepared for STRESS TESTING tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2077 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN2077
...    testsuite/Wroclaw/OAM/VRF_WRO3_T02/STRESS_TESTING/Testsuites/Stress/CB005891.robot

Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Resource        taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource        ../../Testcases/SM.17_Cell_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.17_Cell_Reset/test.robot
Resource        ../../Testcases/SM.18_ALD_Hard_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.19_ALD_Soft_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.20_GNSSE_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.21_FHS_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.22_RMOD_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.23_BBMOD_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.24_RAT_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.25_BBPOOL_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.26_Power_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.27_Site_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.41_Site_Reset_without_RU_Reset_via_NA/test.robot
Resource        ../../Testcases/SM.50_Cell_Lock_Unlock_via_NA/test.robot

Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           CA_VRF_WRO3
...           PY39  ## force python3 UTE package
...           RF50
...           CLOUD_SRAN_NL_1ASIB_2ABIA_1ABIO_1ASIB_1ABIO_1ABIN_2FRGP_4FXDB_3FXED_2FHKA_1AEQM_1AHDB_UTECA
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

*** Variables ***
${INTEGRATE_NETACT}               True

@{CUSTOMERS}                      Generic
${INITIAL_SW}                     ${None}
${CANDIDATE_SW}                   ${None}
${ITERATION}                      1

${REPORT}                         ${False}
${QC_REPORT}                      ${False}
${REPORT_COMMENT}                 ${None}

${QC_DOMAIN}                      MN_RAN
${QC_PROJECT}                     RAN_VRF
${TEST_QC_ID}                     ${None}

${TEMPORARY_ALLOWED_FAULTS}       ${None}
${CUSTOM_ALLOWED_ALARMS}          6823
${HW_TO_ONAIR_TIME}               ${None}

&{NODE_1}                         testline_object=${tl.enbs[0]}
...                               source_sw=${INITIAL_SW}
...                               target_sw=${CANDIDATE_SW}
...                               custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                               temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS}

@{NODES}                          ${NODE_1}

#CUSTOM ALLOWED ALARMS:
#fault_id: 6823 fault_name: SAS Grant Termination Revocation Failure

*** Test Cases ***
# RGT_EFF_Nov_2025_removal
# [1][1.0] Automated__UUF__Software_Upgrade_from_N-x
#     [Timeout]    2h
#     Set Initial And Candidate
#     e2e_tl_upgrade_test
#     ...    nodes_details=${NODES}
#     ...    test_nodes_details=${NODE_1}
#     ...    iterations_per_node=${ITERATION}
#     ...    report=${REPORT}
#     ...    report_comment=${REPORT_COMMENT}
#     ...    customers_list=${CUSTOMERS}
#     ...    qc_domain=${QC_DOMAIN}
#     ...    qc_id=${TEST_QC_ID}
#     ...    qc_project=${QC_PROJECT}

[1][1.0] CB005891_Automated_cell_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.17_Cell_Reset_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact

[1][1.0] CB005891_Automated_cell_reset_via_WebEM_GUI
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    SM.17_Cell_Reset
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact

[1][1.0] CB005891_Automated_hard_ALD_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    ...  AND     common.Ensure NORMAL value on all RMODs
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.18_ALD_Hard_Reset_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact
    ...      AND      Restore parameters value on all RMODs

[1][2.0] CB005891_Automated_soft_ALD_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    ...  AND     common.Ensure NORMAL value on all RMODs
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.19_ALD_Soft_Reset_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact
    ...      AND      Restore parameters value on all RMODs

[1][1.0] CB005891_Automated_GNSSE_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.20_GNSSE_Reset_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact

[1][1.0] CB005891_Automated_FHS_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.21_FHS_Reset_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact

[1][1.0] CB005891_Automated_RMOD_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    ...  AND     common.Ensure NORMAL value on all RMODs
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.22_RMOD_Reset_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact
    ...      AND      Restore parameters value on all RMODs

[1][2.0] CB005891_Automated_BBMOD_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.23_BBMOD_Reset_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact

[1][1.0] CB005891_Automated_RAT_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.24_RAT_Reset_via_NA
    [Teardown]  Run Keywords  SM.24_RAT_Reset_via_NA.Test Case Teardown
    ...  AND  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact

[1][1.0] CB005891_Automated_BBPOOL_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.25_BBPOOL_Reset_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact

[1][1.0] CB005891_Automated_power_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    ...  AND     common.Ensure NORMAL value on all RMODs
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.26_Power_Reset_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact
    ...      AND      Restore parameters value on all RMODs

[1][1.0] CB005891_Automated_site_reset_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.27_Site_Reset_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact

# RGT_EFF_Nov_2025_removal
# [1][1.0] Automated__SM__Site_Reset_without_RU_Reset_via_ACTIONS
#     [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
#     ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
#     ...  AND  common.Ensure NORMAL value on all RMODs
#     Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
#     SM.41_Site_Reset_without_RU_Reset_via_NA
#     [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact
#     ...                  AND  Restore parameters value on all RMODs

[1][1.0] Automated_cell_lock_unlock_via_NetAct
    [Setup]  Run Keywords  common.Common Test Setup  AND  Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                                             ELSE  Skip  msg=Test skipped due to NetAct integration disabled
    ...  AND  common.Ensure NORMAL value on all RMODs
    Run Keyword If  not ${INTEGRATED_TO_NETACT}  Fail  msg=Precondition not met: BTS is not integrated to NetAct.
    SM.50_Cell_Lock_Unlock_via_NA
    [Teardown]  Run Keywords  common.Common Test Teardown  AND  Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact
    ...                  AND  Restore parameters value on all RMODs
    ...                  AND  SM.50_Cell_Lock_Unlock_via_NA.Test Case Teardown

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}        Get Source SW
    ${candidate_sw}      Get Target SW
    Set to dictionary    ${NODE_1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
