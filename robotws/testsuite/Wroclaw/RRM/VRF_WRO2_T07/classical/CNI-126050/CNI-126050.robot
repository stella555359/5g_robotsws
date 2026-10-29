*** Settings ***
Documentation
...   author:        Marcin Wolczynski
...   contact:       marcin.wolczynski@nokia.com
...   maintainer:    marcin.wolczynski@nokia.com
...   Description:   Feature CNI-126050


Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI-126050/resources/CNI-126050_keywords.robot
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py


Suite Setup     Run keywords
...             Prepare Attenuator                                    AND
...             Require Ue   ${UE_1_alias}   capabilities=${UE_1}     AND
...             Require Ue   ${UE_2_alias}   capabilities=${UE_2}


Test Setup      Run Keywords
...             Start syslog capture

Test Teardown   Run Keywords
...             Stop syslog capture   alias=${SYSLOG_ALIAS}           AND
...             Stop syslog capture                                   AND
...             AdminUtils.collect_snapshot

Suite Teardown  Run Keywords
...             Stop Using Ue               ${UE_1_alias}              AND
...             Stop Using Ue               ${UE_2_alias}              AND
...             AdminUtils.unlock_all_cells



*** Test Cases ***

CNI-126050_Verification_of_different_interference_low_enabledWithPrach_pucch_SA
    [Tags]  CRT  24R2  A1
    [1]CNI-126050_Verification_of_different_interference_low_enabledWithPrach_pucch_SA
     [Teardown]  Run keywords
    ...             Detach Ue   ${UE_1_alias}                               AND
    ...             Detach Ue   ${UE_2_alias}                               AND
    ...             Dectivate CNI126050                                     AND
    ...             Stop syslog capture

