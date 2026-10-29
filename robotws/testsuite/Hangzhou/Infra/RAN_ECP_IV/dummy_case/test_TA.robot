*** Settings ***
Suite Setup       sample suite setup
Suite Teardown    sample suite teardown
Test Setup        sample test setup
Test Teardown     sample test teardown
Resource          ../resources/infra_common_resources.robot

*** Test Cases ***
TestTAcase
    # Single_session
    ${conn1}    sshi.connect_to    ${NEATHOST SSH ACCESS}[ip]    ${NEATHOST SSH ACCESS}[username]    ${NEATHOST SSH ACCESS}[password]
    sshi.execute    free -h
    sshi.execute    su    check_result=${False}
    sshi.execute    ${NEATHOST SSH ACCESS}[password]
    # Multi_sessions
    ${conn2}    sshi.connect_to    ${NEATHOST SSH ACCESS}[ip]    ${NEATHOST SSH ACCESS}[username]    ${NEATHOST SSH ACCESS}[password]    alias=conn2
    sshi.execute    free -h    alias=${conn2}
    sshi.execute    free -h
    call_sshlib    write    free -h
    call_sshlib    Read    delay=1s
    call_sshlib    write    free -h    _alias=${conn2}
    call_sshlib    Read    delay=1s    _alias=${conn2}

*** Keywords ***
sample suite setup
    common_suite_setup_for_infra

sample suite teardown
    common_suite_teardown_for_infra

sample test setup
    common_test_setup_for_infra

sample test teardown
    common_test_teardown_for_infra
