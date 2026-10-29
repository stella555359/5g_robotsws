*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010969
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      taf.rfrl.utilities.test_config
Resource     ./local_resources/common_keywords.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/call_procedure/call_procedure_keywords.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/snapshot_validation/snapshot_validation_keywords.robot

Library      taf.ue     WITH NAME   ue

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./local_resources/common_variables.py

Force Tags    CA_VRF_KRK

Suite Setup        Prepare test line
Suite Teardown     Test line teardown

*** Variables ***
@{CellIDs}      NRCELL-11    NRCELL-12    NRCELL-31    NRCELL-32
${capabilities}      REAL_UE

*** Test Cases ***
CB010969_gNB CBSD Cell Activation_-_TS version 2.0_1NR_concurrency_SBTS
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Upgrade]
    Start SASsim
    [Teardown]    Actions after test

CB010969_General_SiSo_RU_lock_unlock
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Upgrade]
    Perform RU lock unlock
    ${traffic_matrix1}    Convert To Dictionary    ${TPUT_MATRIX1}
    Call To Selected Cells      cells_list=@{CellIDs}     duration=60s     traffic_matrix=${traffic_matrix1}     ue_capabilities=${capabilities}
    [Teardown]    Actions after test

CB010969_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    Actions before test     alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Snapshot]
    ${expected_missing_files}    Convert To Dictionary    ${ACCEPTED_MISSING_FILES}
    Verify snapshot    expected_missing_files=${expected_missing_files}
    [Teardown]      Actions after test

CB010969_desiredPmax_is_decreased_by_an_operator_while_providing_service
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Upgrade]
    Load basic Commissioning change parameters and verify if CBRS cells are on Air
    ...     delta_file=${DELTAS['desiredPmax']}
    [Teardown]      Actions after test

CB010969_maxGrantPwrRed_is_decreased_by_an_operator_while_providing_service
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Upgrade]
    Load basic Commissioning change parameters and verify if CBRS cells are on Air
    ...     delta_file=${DELTAS['maxGrantPwrRed']}
    [Teardown]      Actions after test

CB010969_CBRS_CA_continue_channels_space_configuration_change
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Upgrade]
    Load basic Commissioning change parameters and verify if CBRS cells are on Air
    ...     delta_file=${DELTAS['channelspacing']}
    [Teardown]      Actions after test
