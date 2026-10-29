*** Settings ***
Documentation
...   Test Suite for testing CB007935 feature
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com


Resource    ./resources/CB007935_keywords.robot

Suite Setup      Suite Setup
Test Setup       Common Preconditions
Suite Teardown   Common Suite Teardown

*** Variables ***
${ru_type}    asirmod

*** Test Cases ***
[1][1.0] CB007935 1. Regression feature testing with Intelligent Holdover
    # Step 1: Enabling feature CB007935
    gnbcounter.Wait for Next PM Period    interval=5min
    Read Measurement File
    Perform Delta Commissioning On gNB      ${CB007935_enable_delta["${ru_type}"]}
    Read Measurement File
    Verify Parameter Value    synceStatus    OK
    Verify Parameter Value    ssmValue    ssmPRC
    # Step 2: Waiting for next step.
    gnbcounter.Wait for Next PM Period    interval=5min
    Verify Pm Counter Last Value    counter_id=${ruSynceRearrangement}     verification=is    expected_value=0
    Verify Parameter Value    syncStatus    Locked
    Verify Parameter Value    ruAssistedHoPeriod    0
    Verify Measurement File Length    expected_lines=8
    # Step 3: Perform major impairment - drop of SyncE
    Execute Commands On Switch    commands=${synce_drop_commands}
    Verify Parameter Value    synceStatus    NOK
    Verify Measurement File Doesnt Exist
    Run Keyword If    '${ru_type}' == 'rmod'    Alarms.Wait For Alarm Activation    fault_id=4781    awaiting_time=300
    # Step 4: Restore SyncE.
    Execute Commands On Switch    commands=${synce_restore_commands}
    Run Keyword If    '${ru_type}' == 'rmod'    Alarms.Wait For Alarm Deactivation    fault_id=4781    awaiting_time=300
    Verify Measurement File Length    expected_lines=1
    Verify Parameter Value    synceStatus    OK
    Verify Parameter Value    ssmValue    ssmPRC
    gnbcounter.Wait for Next PM Period    interval=5min
    Verify Pm Counter Last Value    counter_id=${ruSynceRearrangement}    verification=is not    expected_value=0
    # Step 5: Perform minor SyncE impairment
    keywords.Reset Radio Unit
    ru_operations.Wait For Radio Unit Statuses    operational_state=disabled        radio_type=${ru_type}
    ru_operations.Wait For Radio Unit To Be Online    radio_type=${ru_type}
    Sleep    180s
    Verify Existance Of Nan Values In Measurement File    should_exist=${True}    minutes=12
    # Step 6: Holdover estimation
    Sleep    63 minutes
    keywords.Verify Radio Unit Is Online
    Verify Parameter Value    synceStatus    OK
    Verify Parameter Value    ssmValue    ssmPRC
    Verify Parameter Value    syncStatus    Locked
    Verify Parameter Value    ruAssistedHoPeriod    1
    Verify Existance Of Nan Values In Measurement File    should_exist=${False}    minutes=63
    Verify Pm Counter Last Value    counter_id=${ruSynceEstHoldoverTime}    verification=is    expected_value=1
    # Step 7: Holdover estimation 2 hours
    Sleep    64 minutes
    keywords.Verify Radio Unit Is Online
    Verify Parameter Value    synceStatus    OK
    Verify Parameter Value    ssmValue    ssmPRC
    Verify Pm Counter Last Value    counter_id=${ruSynceEstHoldoverTime}    verification=is    expected_value=2
    Verify Parameter Value    syncStatus    Locked
    Verify Parameter Value    ruAssistedHoPeriod    2
    Verify Existance Of Nan Values In Measurement File    should_exist=${False}    minutes=64
    # Step 8: Enter into Holdover mode, PTP drop
    Execute Commands On Switch    commands=${ptp_drop_commands}
    Alarms.Wait For Alarm Activation
    ...    fault_id=4298
    ...    awaiting_time=600
    ru_operations.Wait For Radio Unit To Be Online    radio_type=${ru_type}
    Verify Cells Statuses    availability_status=degraded
    Verify Parameter Value    synceStatus    Parent
    Verify Parameter Value    syncStatus    Holdover
    Verify Parameter Value    ruAssistedHoPeriod    2
    Verify Existance Of Nan Values In Measurement File    should_exist=${False}    minutes=127
    Verify Pm Counter Last Value    counter_id=${ruSynceEstHoldoverTime}    verification=is    expected_value=2
    # Step 9: RU in Holdover mode
    Sleep    60 minutes
    Alarms.Wait For Alarm Activation
    ...    fault_id=4298
    ...    awaiting_time=600
    Verify Cells Statuses    availability_status=degraded
    Verify Pm Counter Last Value    counter_id=${ruSynceEstHoldoverTime}    verification=is    expected_value=2
    Verify Parameter Value    synceStatus    Parent
    Verify Parameter Value    syncStatus    Holdover
    Verify Parameter Value    ruAssistedHoPeriod    1
    # Step 10: RU going out from Holdover mode
    Sleep    60 minutes
    Alarms.Wait For Alarm Activation
    ...    fault_id=4298
    ...    awaiting_time=600
    Alarms.Wait For Alarm Activation
    ...    fault_id=16
    ...    awaiting_time=600
    Verify Parameter Value    syncStatus    Freerun
    Verify Parameter Value    synceStatus    OK
    Verify Radio Unit Availability Status    availability_status=offline
    Verify Measurement File Doesnt Exist
    Verify Counter Doesnt Exist    counter_id=${ruSynceEstHoldoverTime}
    Verify Parameter Value    ruAssistedHoPeriod    65535
    # Step 11: Step 11: Restore PTP sync
    Execute Commands On Switch    commands=${restore_ptp_sync_commands}
    ru_operations.Wait For Radio Unit To Be Online    radio_type=${ru_type}
    Verify Parameter Value    synceStatus    OK
    Verify Parameter Value    syncStatus    Locked
    Verify Parameter Value    ruAssistedHoPeriod    0
    Verify Measurement File Length    expected_lines=10
    Verify Pm Counter Last Value    counter_id=${ruSynceEstHoldoverTime}    verification=is    expected_value=0
    Verify Alarms Not Active    alarms_to_be_verified=${alarms_4298_16}
    # Step 12: Disable feature CB007935
    Perform Delta Commissioning On gNB      ${CB007935_disable_delta["${ru_type}"]}
    Verify Counter Doesnt Exist    counter_id=${ruSynceEstHoldoverTime}
    Verify Syncestatus Not Exist
    [Teardown]    Run Keywords
    ...    Test Teardown
    ...    AND    Perform Full Commissioning On Classical gnb    update_timeout=1200
    ...    AND    Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair

[1][1.0] CB007935 2. Regression feature testing with Manual Holdover
    # Step 1: Enabling feature CB007935 with Manual Holdover
    gnbcounter.Wait for Next PM Period    interval=5min
    Perform Delta Commissioning On gNB    ${CB007935_enable_delta_manual["${ru_type}"]}
    Verify Parameter Value    synceStatus    OK
    Verify Parameter Value    ssmValue    ssmPRC
    # Step 2: Waiting for next step.
    gnbcounter.Wait for Next PM Period    interval=5min
    Verify Pm Counter Last Value    counter_id=${ruSynceRearrangement}    verification=is    expected_value=0
    Verify Parameter Value    syncStatus    Locked
    Verify Parameter Value    ruAssistedHoPeriod    1
    Verify Measurement File Length    expected_lines=7

    # new step 1: Perform major impairment - change SyncE ssm value below acceptance level.
    Execute Commands On Switch    commands=${ssm_too_low_commands}
    Verify Parameter Value    synceStatus    NOK
    Verify Parameter Value    ssmValue    ssmQualityUnknown
    Verify Parameter Value    syncStatus    Locked
    Verify Parameter Value    ruAssistedHoPeriod    65535
    Run Keyword If    '${ru_type}' == 'rmod'    Alarms.Wait For Alarm Activation    fault_id=4781    awaiting_time=300     #check_with_new_config
    # new step 2: Restore SyncE ssm value.
    Execute Commands On Switch    commands=${restore_ssm_commands}
    Run Keyword If    '${ru_type}' == 'rmod'    Alarms.Wait For Alarm Deactivation    fault_id=4781    awaiting_time=300     #check_with_new_config
    Verify Parameter Value    synceStatus    OK
    Verify Existance Of Nan Values In Measurement File    should_exist=${False}    minutes=10
    Verify Pm Counter Last Value    counter_id=${ruSynceRearrangement}    verification=is    expected_value=0
    Verify Pm Counter Last Value    counter_id=${ruSynceEstHoldoverTime}    verification=is    expected_value=0
    Verify Parameter Value    ruAssistedHoPeriod    1

    # Step 3: Perform minor impairment - drop PTP.
    Execute Commands On Switch    commands=${ptp_drop_commands}
    Alarms.Wait For Alarm Activation
    ...    fault_id=4298
    ...    awaiting_time=300
    ru_operations.Wait For Radio Unit To Be Online    radio_type=${ru_type}
    Verify Cells Statuses    availability_status=degraded
    Verify Parameter Value    synceStatus    Parent
    Verify Parameter Value    syncStatus    Holdover
    Verify Parameter Value    ruAssistedHoPeriod    0
    Verify Existance Of Nan Values In Measurement File    should_exist=${False}    minutes=5
    Verify Pm Counter Last Value    counter_id=${ruSynceRearrangement}   verification=is    expected_value=0
    Verify Pm Counter Last Value    counter_id=${ruSynceEstHoldoverTime}    verification=is    expected_value=0
    # Step 4: Perform major impairment  change SyncE ssm value below acceptance level.
    Execute Commands On Switch    commands=${ssm_too_low_commands}
    Verify Cells Statuses    availability_status=degraded
    Verify Radio Unit Availability Status    availability_status=offline
    Verify Parameter Value    synceStatus    NOK
    Verify Parameter Value    ssmValue    ssmQualityUnknown
    Verify Parameter Value    syncStatus    Freerun
    Verify Parameter Value    ruAssistedHoPeriod    65535
    Verify Measurement File Doesnt Exist
    Run Keyword If    '${ru_type}' == 'rmod'    Alarms.Wait For Alarm Activation    fault_id=4781    awaiting_time=300
    Alarms.Wait For Alarm Activation
    ...    fault_id=16
    ...    awaiting_time=300
    Alarms.Wait For Alarm Activation
    ...    fault_id=4298
    ...    awaiting_time=300
    Verify Pm Counter Last Value    counter_id=${ruSynceRearrangement}    verification=is    expected_value=2
    # Step 5: Restore PTP sync
    Execute Commands On Switch    commands=${restore_ptp_sync_commands}
    Verify Parameter Value    ruAssistedHoPeriod    65535
    ru_operations.Wait For Radio Unit To Be Online    radio_type=${ru_type}
    Verify Parameter Value    synceStatus    NOK
    Verify Measurement File Doesnt Exist
    Verify Counter Doesnt Exist    counter_id=${ruSynceEstHoldoverTime}
    Verify Pm Counter Last Value    counter_id=${ruSynceRearrangement}    verification=is    expected_value=0
    Verify Parameter Value    syncStatus    Locked
    Verify Alarms Not Active    alarms_to_be_verified=${alarms_4298_16}
    Run Keyword If    '${ru_type}' == 'rmod'    Alarms.Wait For Alarm Activation    fault_id=4781    awaiting_time=300
    # Step 6: Restore SyncE ssm value.
    Execute Commands On Switch    commands=${restore_ssm_commands}
    Run Keyword If    '${ru_type}' == 'rmod'    Alarms.Wait For Alarm Deactivation    fault_id=4781    awaiting_time=300
    Verify Parameter Value    synceStatus    OK
    Verify Existance Of Nan Values In Measurement File    should_exist=${False}    minutes=10
    Verify Pm Counter Last Value    counter_id=${ruSynceRearrangement}    verification=is    expected_value=0
    Verify Pm Counter Last Value    counter_id=${ruSynceEstHoldoverTime}    verification=is    expected_value=0
    # Step 7: Enter to manual holdover  drop PTP.
    Execute Commands On Switch    commands=${ptp_drop_commands}
    Alarms.Wait For Alarm Activation
    ...    fault_id=4298
    ...    awaiting_time=300
    ru_operations.Wait For Radio Unit To Be Online    radio_type=${ru_type}
    Verify Cells Statuses    availability_status=degraded
    Verify Parameter Value    synceStatus    Parent
    Verify Parameter Value    syncStatus    Holdover
    Verify Parameter Value    ruAssistedHoPeriod    0
    Verify Existance Of Nan Values In Measurement File    should_exist=${False}    minutes=20
    Verify Pm Counter Last Value    counter_id=${ruSynceRearrangement}    verification=is    expected_value=0
    Verify Pm Counter Last Value    counter_id=${ruSynceEstHoldoverTime}    verification=is    expected_value=0
    # Step 8
    Sleep    60 minutes
    Alarms.Wait For Alarm Activation
    ...    fault_id=4298
    ...    awaiting_time=300
    Alarms.Wait For Alarm Activation
    ...    fault_id=16
    ...    awaiting_time=300
    Verify Parameter Value    syncStatus    Freerun
    Verify Parameter Value    synceStatus    OK
    Verify Radio Unit Availability Status    availability_status=offline
    Verify Measurement File Doesnt Exist
    Verify Parameter Value    ruAssistedHoPeriod    65535
    # Step 9: Restore PTP sync
    Execute Commands On Switch    commands=${restore_ptp_sync_commands}
    ru_operations.Wait For Radio Unit To Be Online    radio_type=${ru_type}
    Verify Parameter Value    synceStatus    OK
    Verify Parameter Value    syncStatus    Locked
    Verify Parameter Value    ruAssistedHoPeriod    1
    Verify Measurement File Length    expected_lines=10    #placeholder
    Verify Pm Counter Last Value    counter_id=${ruSynceEstHoldoverTime}    verification=is    expected_value=0
    Verify Alarms Not Active    alarms_to_be_verified=${alarms_4298_16}
    # Step 10
    Perform Delta Commissioning On gNB      ${CB007935_disable_delta_manual["${ru_type}"]}
    Verify Counter Doesnt Exist    counter_id=${ruSynceEstHoldoverTime}
    Verify Syncestatus Not Exist
    [Teardown]    Test Teardown

