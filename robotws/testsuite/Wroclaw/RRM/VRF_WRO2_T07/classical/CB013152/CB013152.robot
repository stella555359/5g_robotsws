*** Settings ***
Documentation
...   author:        Marcin Wolczynski
...   contact:       marcin.wolczynski@nokia.com
...   maintainer:    marcin.wolczynski@nokia.com
...   Description:   Feature CB012439


Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB013152/resources/keywords_CB013152.robot
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB013152/resources/test_specific_keywords_CB013152.py


Suite Setup     Run keywords
...             Prepare Attenuator                                    AND
...             Require Ue  ${UE_ALIAS_13152}  capabilities=${UE_CAPA_13152}


Test Setup      Run Keywords
...             Wait for next counter interval 8409                   AND
...             Start syslog capture

Test Teardown   Run Keywords
...             Stop All Data Transfers 8409                          AND
...             Stop syslog capture   alias=${SYSLOG_ALIAS}           AND
...             Stop syslog capture                                   AND
...             AdminUtils.collect_snapshot

Suite Teardown  Run Keywords
...             Stop Using Ue               ${UE_ALIAS_13152}              AND
...             AdminUtils.unlock_all_cells                          AND
...             Set Scout Configuration ID


*** Test Cases ***
[1]CB013152_PRB_blanking_check
    [Tags]  CRT  26R2  PRB BLANKING TMO
    [1]CB013152 PRB Blanking
     [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS_13152}                  AND
    ...             AdminUtils.unlock_all_cells                             AND
    ...             deactivating_for_prb_blanking_13152                     AND
    ...             Stop syslog capture


[1]CB013152_BWP_profile_checking
    [Tags]  CRT  26R2  PRB BLANKING TMO
    [1]CB013152 BWP profile IWK
     [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS_13152}                  AND
    ...             AdminUtils.unlock_all_cells                             AND
    ...             Rollback SCF afer test                                  AND
    ...             Stop syslog capture

