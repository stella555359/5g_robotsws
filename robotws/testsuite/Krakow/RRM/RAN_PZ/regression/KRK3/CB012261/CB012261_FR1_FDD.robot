*** Settings ***
Documentation    Test suite for FR1 FDD CB012261
...              authors: Aleksandra Faliszek
...              contact: aleksandra.faliszek@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ./resources/CB012261_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
...            prefix_tag=CB012261
Suite Teardown  Common Suite Teardown

*** Test Cases ***
CB012261_SR_B_01_B1-Controlling_number_of_PRBs_available_for_PUSCH_when_FDAGC_PRACH_algorithm_is_enabled_and_disabled_with_long_PUCCH_formats_Loki_FDD
    [Setup]      Common Preconditions With Watching Alarms
    Disable feature CB012261    1
    Require Ue    ue_alias=Smawave    capabilities=Smawave
    Perform 5G Attach and collect TTI Trace for FDD TC
    Get PRB Values   feature_off.csv
    Enable feature CB012261    1
    Perform 5G Attach and collect TTI Trace for FDD TC
    Get PRB Values   feature_on.csv
    Compare PRB Between Two Runs for FDD TC
    [Teardown]   Common Postconditions With Watching Alarms

CB012261_SR_A_03_B1-Enable_and_disable_FDAGC_PRACH_algorithm_FR1_FDD_Loki
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS
