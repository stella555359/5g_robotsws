*** Settings ***
Documentation
...   author:
...    - Joanna Zajdel (joanna.zajdel@nokia.com)

Resource    resources/keywords.robot

Library     String
Library     taf.rfrl.csv4all.CSV4AllTestCases
Library     taf.rfrl.utilities.cloud_manager.artifacts
Library     testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource    ./resources/common_keywords.robot

Suite Setup    Custom Suite Setup
Suite Teardown    Common Suite Teardown

Test Teardown    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs

*** Variables ***
${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
@{CUSTOM_ALARMS}                    61648    4420    4123    4125    8150    4459    8000    61623    4710    4080
${TESTLINE_SCOUT_NAME}              7_7_T01PY135

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 testline_scout_name=${TESTLINE_SCOUT_NAME}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}            1



*** Test Cases ***
CB010788_A_1 Alarm suppression for fan speed monitoring fault
   [Tags]      T01_trunk      4080    trunk
    Load Config0 For BTS
    Sleep    120s
    TC1 p6 Disabled fault 4080
    Sleep    120
    duoperations.wait_for_site_to_be_onair
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding
    TC1 p4 Suppress fault 4080    #trunk
    Trigger fault 4080
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    Sleep    120
    TC1 p6 Disabled fault 4080    #trunk
    Sleep    120
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding


CB010788_A_8 Robustness
    [Tags]      T08_trunk      61623    trunk

    Load Config0 For BTS    #trunk
    Sleep    120s
    duoperations.wait_for_site_to_be_onair
    TC8 p1 moc productCode    #trunk
    Sleep    120
    TC8 p1 mocDN    #trunk
    Sleep    120
    Trigger fault 4710
    Sleep    120
    gnbalarm.verify_alarm_is_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1

    Sleep    120
    TC8 p5 Suppress fault 4710    #trunk
    Sleep    10s
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1

    Sleep    120
    TC8 p7 alarmList ANY    #trunk
    Sleep    10s
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1

    Sleep    120
    TC8 p9 Allow alarm 7115    #trunk
    Sleep    10s
    gnbalarm.verify_alarm_is_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1



CB010788_A_7 Exploratory
    [Tags]      T07_trunk      4710      4080    trunk

    Load Config0 For BTS
    Sleep    120s
    TC1 p6 Disabled fault 4080
    Sleep    120
    duoperations.wait_for_site_to_be_onair
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1
    Trigger fault 4710
    duoperations.wait_for_site_to_be_onair
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding
    Log To Console    FID:4080 verified
    gnbalarm.verify_alarm_is_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1
    Log To Console    FID:4710 verified
    TC7 p5 Suppress fault 4080 4710    #trunk
    Log To Console    FID:4080, 4710 suppressed
    Sleep      10s
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1
    Log To Console    FID:4080, 4710 not present

    Sleep    300s
    duoperations.wait_for_site_to_be_onair
    #E2E TL UPGRADE TEST
    #...                                     nodes_details=${NODES}
    #...                                     test_nodes_details=${NODE1}
    #...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    #...                                     report=${False}
    #...                                     sw_build=${TARGET_SW}

    Sleep    300s
    duoperations.wait_for_site_to_be_onair
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1
    Log To Console    pkt8 finished

    ruoperations.reset_radio_unit
    duoperations.wait_for_site_to_be_onair
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1

    duoperations.reset_bts
    duoperations.wait_for_site_to_be_onair
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1
    Log To Console    pkt12 finished

    TC7 p13 23 Disabled fault 4080 4710    #trunk
    Sleep    300s
    duoperations.wait_for_site_to_be_onair
    TC7 p14 Suppress fault 4080 4710    #trunk
    Sleep      10s
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1
    Log To Console    pkt15 finished

    sg7keywords.Block cells    [1]
    gnbcell.Verify Cell Is Blocked    cell_id=${1}
    sg7keywords.Unblock cells        [1]
    gnbcell.Verify Cell Is Unblocked    cell_id=${1}
    gnbcell.Wait For All Cells To Be OnAir    timeout=600
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1
    Log To Console    pkt18 finished

    Sleep    120s
    duoperations.wait_for_site_to_be_onair
    ${SW}=    Get gNB Sw Version
    ${SW}=    Convert Sw Version    ${SW}
    Log To Console      ${SW}
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_T01PY135/${SW}/TL013_CB010788_trunk_TC7_pkt19.xml
#    Load Config11 For BTS    #trunk
    Sleep    60s
    TC7 p5 Suppress fault 4080 4710
    Sleep      10s
    gnbalarm.verify_alarm_is_not_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1
    Log To Console    pkt20 finished

    Sleep    120s
    duoperations.wait_for_site_to_be_onair
    TC7 p21 Allow fault 4080 4710    #trunk
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1
    Log To Console    pkt22 finished

    Sleep    120s
    duoperations.wait_for_site_to_be_onair
    TC7 p13 23 Disabled fault 4080 4710    #trunk
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1
    Log To Console    pkt24 finished

    Sleep    120s
    duoperations.wait_for_site_to_be_onair
    TC7 p25 Suppress fault 4080 4710    #trunk
    Trigger fault 4080
    Wait Until Keyword Succeeds    6 min    50 sec    gnbalarm.verify_alarm_is_active    fault_name=Cooling fan is over speeding
    gnbalarm.verify_alarm_is_not_active    fault_name=SyncE SSM Timed Out on SMOD-1, EIF1







