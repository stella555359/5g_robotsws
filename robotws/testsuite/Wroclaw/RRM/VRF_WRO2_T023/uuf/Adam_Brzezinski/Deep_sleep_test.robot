*** Settings ***
Documentation
...  Author:        Marcin Wolczynski
...  Contact:       marcin.wolczynski@nokia.com


Library        ute_ue
Library        taf/rfrl/csv4all/CSV4AllTestCases.py



Library        taf/rfrl/csv4all/resources/utilities/utilities.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Adam_Brzezinski/resources/test_specific_keywords_deep_sleep.py
Resource       ../../feature_resources/RJIO/resources/RJIO_Data_Transfer.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Adam_Brzezinski/resources/test_specyfic_keywords_deep_sleep.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/tools/daily_activities/resources/daily_activities_keywords.robot


Resource       ../../resources/attenuator.robot
Resource       ../../resources/ca_IWK.robot

Test Setup    Start syslog capture
Test Teardown    Run Keywords       ute_syslog.Stop Syslog         AND
    ...            Collect Snapshot     ${OUTPUT_DIR}/snapshots/snapshot    AND
    ...            Check_snapshot_prints    ${OUTPUT_DIR}/Deep sleep test/Deep Sleep Test case


*** Test Cases ***
Deep Sleep Test case
    [Documentation]       Test Deep Sleep for RJIO
    Deep Sleep Test case for RJIO