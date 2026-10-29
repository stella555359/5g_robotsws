*** Settings ***
Documentation
...    author: Jacek Dziedzicki
...    contact: jacek.dziedzicki@nokia.com
...    Description: Test cases for CDD feature CNI-141366


Resource    resources/CNI-141366_Keywords.robot

Test Timeout  11 hours 55 minutes

Force Tags    RF50

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown


*** Test Cases ***
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

    Perform CDD and BTS Commissioning    file_name=${cdd_file_path}/${cdd_configs_list}[1]    cdd_url=${CDD_url}
    ...                                  prefix_tag=${scf_prefix_tags}[1]

    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}
    ...                             l3_call=${L3_CALL}
    ...                             l3_call_keywords=${L3_CALL_KEYWORDS}

    [Teardown]    Common Postconditions    collect_syslog=${False}
