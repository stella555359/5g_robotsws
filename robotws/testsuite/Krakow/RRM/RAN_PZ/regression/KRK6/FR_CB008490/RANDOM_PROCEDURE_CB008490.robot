*** Settings ***
Documentation
...   Test suite for executing random OAM operation in loop
...   author: Piotr Brzezicki, piotr.brzezicki@nokia.com
...   maintainer: Piotr Brzezicki, piotr.brzezicki@nokia.com

Library    testsuite.Krakow.resources.random_oam_procedure_runner
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.setups.Setups          WITH NAME    st
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.teardowns.Teardowns    WITH NAME    td

Variables   ./resources/variables/random_operations.py

Suite Setup        st.cb008490_suite_setup     ue_in_use=${False}
Suite Teardown     td.cb008490_suite_teardown

Test Setup         st.run_common_preconditions
Test Teardown      td.run_common_postconditions

*** Test Cases ***
General_SiSo_Auto_Random_OAM_operations
    [Timeout]    96h
    Set Test Variable    ${COLLECT_LOGS_DURING_DATA_TRANSFER}   ${False}
    Set Test Variable    ${ENABLE_RACH_OBSERVER}                ${False}
    Run Random OAM Operations
        ...    operations=${OPERATIONS}
        ...    timeout=${TOTAL_TIMEOUT}
        ...    email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
        ...    operation_kwargs=${OPERATION_KWARGS}
        ...    random_seed=${RANDOM_SEED}
        ...    l3_call=${L3_CALL}
        ...    l3_call_keywords=${L3_CALL_KEYWORDS}
