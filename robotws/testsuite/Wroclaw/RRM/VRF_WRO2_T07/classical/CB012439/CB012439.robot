*** Settings ***
Documentation
...   author:        Marcin Wolczynski
...   contact:       marcin.wolczynski@nokia.com
...   maintainer:    marcin.wolczynski@nokia.com
...   Description:   Feature CB012439


Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB012439/resources/keywords_CB012439.robot
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py


Suite Setup     Run keywords
...             Prepare Attenuator                                    AND
...             Require Ue  ${UE_ALIAS_12439}  capabilities=${UE_CAPA_12439}


Test Setup      Run Keywords
...             Wait for next counter interval 8409                   AND
...             Start syslog capture

Test Teardown   Run Keywords
...             Stop All Data Transfers 8409                          AND
...             Stop syslog capture   alias=${SYSLOG_ALIAS}           AND
...             Stop syslog capture                                   AND
...             AdminUtils.collect_snapshot

Suite Teardown  Run Keywords
...             Stop Using Ue               ${UE_ALIAS_12439}              AND
...             AdminUtils.unlock_all_cells                          AND
...             Set Scout Configuration ID


*** Test Cases ***
[1]CB012439_handover_with_5QI9
    [Tags]  CRT  24R2  A1
    [1]CB012439 Handover With 5QI9 5QI1 Test
     [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS_12439}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             deactivating_handover_CB012439                          AND
    ...             AdminUtils.unlock_all_cells                             AND
    ...             Stop syslog capture


[1]CB012439_VoNR_CA_checking_counters
    [Tags]  CRT  26R2  A1
    [1]CB012439_VoNR_CA_checking_counters
     [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS_12439}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             deactivating_handover_CB012439                          AND
    ...             AdminUtils.unlock_all_cells                             AND
    ...             Stop syslog capture
