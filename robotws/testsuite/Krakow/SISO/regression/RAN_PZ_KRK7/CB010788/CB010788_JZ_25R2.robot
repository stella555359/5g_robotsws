*** Settings ***
Documentation
...   author:
...    - Joanna Zajdel (joanna.zajdel@nokia.com)

Resource    resources/keywords.robot

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource    ./resources/common_keywords.robot

Suite Setup    Custom Suite Setup
Suite Teardown    Common Suite Teardown

Test Teardown    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs

*** Variables ***
${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
@{CUSTOM_ALARMS}                    61648    4420    4123    4125    8150    4459    8000    61623    4710    4080
${TESTLINE_SCOUT_NAME}              7_7_TSPY013

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 testline_scout_name=${TESTLINE_SCOUT_NAME}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}            1



*** Test Cases ***

CB010788_A_1_Alarm_suppression_for_fan_speed_monitoring_fault
   [Tags]      T01_25R2      4080    25R2
    Load Config0 For BTS
    duoperations.wait_for_site_to_be_onair
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding
    Load Config1 For BTS    #25R2
    Trigger fault 4080
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    Sleep    120
    Load Config0 For BTS    #25R2
    Sleep    120
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding


CB010788_A_8_Robustness
    [Tags]      T08_25R2      4710    25R2

    Load Config6 For BTS    #25R2
    Sleep    120s
    duoperations.wait_for_site_to_be_onair
    Sleep    120
    Load Config7 For BTS    #25R2
    Sleep    120
    Trigger fault 4710
    Sleep    120
    gnbalarm.verify_alarm_is_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period

    Sleep    120
    Load Config8 For BTS    #25R2
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period

    Sleep    120
    Load Config9 For BTS    #25R2
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period

    Sleep    120
    Load Config10 For BTS    #25R2
    gnbalarm.verify_alarm_is_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period



CB010788_A_7_Exploratory
    [Tags]      T07_25R2      4710      4080    25R2

    duoperations.wait_for_site_to_be_onair
    Load Config0 For BTS
    duoperations.wait_for_site_to_be_onair
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
    Trigger fault 4710
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding
    Log To Console    FID:4080 verified
    gnbalarm.verify_alarm_is_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
    Log To Console    FID:4710 verified
    Load Config2 For BTS    #25R2
    Log To Console    FID:4080, 4710 suppressed
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
    Log To Console    FID:4080, 4710 not present

    Sleep    300s
    duoperations.wait_for_site_to_be_onair
    E2E TL UPGRADE TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${False}
    ...                                     sw_build=${TARGET_SW}

    Sleep    300s
    duoperations.wait_for_site_to_be_onair
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
    Log To Console    pkt8 finished

    ruoperations.reset_radio_unit
    duoperations.wait_for_site_to_be_onair
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period

    duoperations.reset_bts
    duoperations.wait_for_site_to_be_onair
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
    Log To Console    pkt12 finished

    Load Config3 For BTS    #25R2
    Sleep    300s
    duoperations.wait_for_site_to_be_onair
    Load Config2 For BTS    #25R2
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
    Log To Console    pkt15 finished

    sg7keywords.Block cells    [1]
    gnbcell.Verify Cell Is Blocked    cell_id=${1}
    sg7keywords.Unblock cells        [1]
    gnbcell.Verify Cell Is Unblocked    cell_id=${1}
    gnbcell.Wait For All Cells To Be OnAir    timeout=600
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
    Log To Console    pkt18 finished

    Sleep    120s
    duoperations.wait_for_site_to_be_onair
    Load Config2 For BTS    #25R2
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
    Log To Console    pkt20 finished

    Sleep    120s
    duoperations.wait_for_site_to_be_onair
    Load Config4 For BTS    #25R2
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
    Log To Console    pkt22 finished

    Sleep    120s
    duoperations.wait_for_site_to_be_onair
    Load Config3 For BTS    #25R2
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
    Log To Console    pkt24 finished

    Sleep    120s
    duoperations.wait_for_site_to_be_onair
    Load Config5 For BTS    #25R2
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period





