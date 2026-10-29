*** Settings ***
Documentation
...   author:        Marcin Wolczynski
...   contact:       marcin.wolczynski@nokia.com
...   maintainer:    marcin.wolczynski@nokia.com
...   Description:   Feature CB015316


Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB015316/resources/CB015316_keywords.robot
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py


Suite Setup     Run keywords
...             Prepare Attenuator                                    AND
...             Require Ue   ${UE_1_alias}   capabilities=${UE_1}     AND
...             test_specific_keywords_15316.Setup Test Variables


Test Setup      Run Keywords
...             Start syslog capture

Test Teardown   Run Keywords
...             Stop syslog capture   alias=${SYSLOG_ALIAS}           AND
...             Stop syslog capture                                   AND
...             AdminUtils.collect_snapshot

Suite Teardown  Run Keywords
...             Stop Using Ue               ${UE_1_alias}               AND
...             AdminUtils.unlock_all_cells


*** Test Cases ***

CB015316_Features
    [Tags]  CRT  26R1  A1
    CB013316_featureOn_featureOff_withCounters
     [Teardown]  Run keywords
    ...             Detach Ue   ${UE_1_alias}                               AND
    ...             Stop syslog capture

