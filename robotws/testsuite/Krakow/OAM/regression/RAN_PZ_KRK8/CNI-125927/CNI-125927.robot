*** Settings ***
Documentation
...    author: Jacek Dziedzicki
...    contact: jacek.dziedzicki@nokia.com
...    Description: Test cases for CDD feature CNI-125927


Resource    resources/CNI-125927_Keywords.robot

Test Timeout  11 hours 55 minutes

Force Tags    RF50

Suite Setup       Test Suite Setup
Suite Teardown    keywords.Test Suite Teardown
Test Setup        keywords.Test Setup
Test Teardown     keywords.Test Teardown


*** Test Cases ***
CNI-125927_L3_call_with_Nokia_CDD1_using_n5_10MHz
    Restart SMAWave    ${SMAWave_address_IP}    ue_index=1
    Start DLUL Data Transfer And Verify Throughput
    ...    ue_index=1
    ...    duration=120
    ...    dl_throughput=110M
    ...    ul_throughput=65M
    ...    max_deviation_dl=10%
    ...    max_deviation_ul=10%

OAM_KPI_Random_OAM_Operations_Exploratory
    [Timeout]    96h
    [Setup]    Common Preconditions     collect_syslog=${False}
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}
    ...                             l3_call=${L3_CALL}
    ...                             l3_call_keywords=${L3_CALL_KEYWORDS}
    [Teardown]    Common Postconditions    collect_syslog=${False}
