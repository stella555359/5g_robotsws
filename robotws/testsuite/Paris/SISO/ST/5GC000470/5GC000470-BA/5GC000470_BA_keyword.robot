*** Settings ***
Documentation
...         Description : Testcases for Feature 5GC000470
...
...         5GC000470 aims to support of 5G classical gNB and cloud gNB-DU on ASIB A102/M02 and ABIL/ABIL2
...         with same feature set as with ASIK and ABIL/ABIL2 units, this feature requires testing:
...         - software management via OAM
...         - Multi-UE at I&V (e.g. with Qualcomm)
...         - other MCSs up to max cell capactiy
...         - ET PM counter validation
...         - Higher stability than -A (startup: >90%; Call setup and release > 90%;
...                                         throughput: 8-12h with 90% of MSC data rate)
...
...         AUTHOR (I&V):   Merwane CHEMSSI         merwane.chemssi@nokia.com
...                         Joseph SOQUES           joseph.soques@nokia.com
...                         Philippe GABORIEAU      philippe.gaborieau@nokia.com


Library     OperatingSystem
Library     String
Library     Process
Library     DateTime

Library             ute_reporting_portal

Resource    ../../resources/kw_coam_UTECM.robot
Resource    ../../resources/kw_classical.robot


*** Keywords ***
kw_5GC000470_BA_25_Classical_NSA_TDD_cmWave_5gNB_RU_reset
    [Documentation]  Loop of 5 resets of Radio Module with check of status of all HW modules until Cell on Air

    FOR    ${TEST_LOOP}   IN RANGE   0  ${MAX_LOOP}
       ${date}=                                         Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
       Log                                   RU Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Reset RU Selenium
        Wait until Keyword Succeeds     300s        30s         Check FSM Status From WEBUI
        Wait until Keyword Succeeds     300s        30s         Check FBBs Status From WEBUI
        Wait until Keyword Succeeds     900s        30s         Check RUs Status
        Wait until Keyword Succeeds     300s        30s         Check Cell Status
       Sleep                                            120s
    END


kw_5GC000470_BA_27_Classical_NSA_TDD_cmWave_5gNB_Cell_setup_stability
    [Documentation]  Loop of 5 resets with check of status of all HW modules
    ...              a sleep of 15min is necessary between two resets to avoid fallback

    FOR    ${TEST_LOOP}   IN RANGE   0  ${MAX_LOOP}
       ${date}=                                         Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
       Log                                   GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform gNB Site Reset
        Wait until Keyword Succeeds     300s        30s         Check FSM Status From WEBUI
        Wait until Keyword Succeeds     300s        30s         Check FBBs Status From WEBUI
        Wait until Keyword Succeeds     600s        30s         Check RUs Status
        Wait until Keyword Succeeds     300s        30s         Check Cell Status
       Sleep                                            300s
    END
