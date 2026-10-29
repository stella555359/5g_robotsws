*** Settings ***
Documentation
...   Test Suite for testing CB010505 feature
...   SW activation, commissioning, cell block/unblock, RU reset and tput verification on AHLOB n71 25/30MHz
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com


Resource    ./resources/CB010505_keywords.robot

Suite Setup      Suite Setup
Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms
Suite Teardown   Common Suite Teardown

*** Test Cases ***
[2.0] Manual_SiSo_SWM_Software_download_and_activation
    SWM_Software_download_and_activation
    Sleep    5 minutes
    Perform L3 Call on single UE

[2.0] General_SiSo_Commissioning_BTS_Template_Commissioning
    Commissioning_BTS_Template_Commissioning
    Perform L3 Call on single UE

[1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    Perform L3 Call on single UE    95_percent_tput_required=True

[1][1.0] General_SiSo_Auto_Random_OAM_operations
    [Setup]    Common Preconditions
    [Timeout]    96h
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}
    ...                             l3_call=${L3_CALL}
    ...                             l3_call_keywords=${L3_CALL_KEYWORDS}
    [Teardown]    Common Postconditions
