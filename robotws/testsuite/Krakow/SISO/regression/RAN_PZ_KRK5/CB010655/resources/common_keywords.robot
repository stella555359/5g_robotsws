*** Settings ***
Documentation
...   Keywords for regression testing of feature CB010655
...   author: Mateusz Bugaj
...   contact: mateusz.bugaj@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/bts/robot/gnb.robot

Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                  WITH NAME    alarm
Library      taf.rfrl.utilities.logger.custom_logger                                     WITH NAME    logger
Library      ./resources.py                                                              WITH NAME    local_resources
Library      ./ru_resources.py                                                           WITH NAME    ru_resources
Library      ./snapshot_resources.py                                                     WITH NAME    snapshot_resources


*** Keywords ***
Await For Next Periodical Trigger
    [Arguments]    ${time}=1      ${unit}=m     ${loops}=3
    FOR     ${loop_num}     IN RANGE    1       ${loops}
        BuiltIn.Sleep       ${time}${unit}
        logger.log_info_to_console      Checking If gNB is still onAir after loop:${loop_num} (${time}${unit}).
        Wait Until Keyword Succeeds     100 sec     10 sec      gnbcell.Verify All Cells Are Onair
    END

Power Reset RU
    ru_resources.actions with ru    action=Turn Off
    Wait Until Keyword Succeeds     150 sec     10 sec       Verify Alarm is Active on gNB
    ...                             fault_name=No connection to unit     fault_id=10
    ru_resources.actions with ru    action=Turn On
    Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair

Reset RU
    ru_resources.actions with ru    action=Reset
    Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair

Trigger Alarm On Ru
    [Arguments]     ${src}      ${dst}      ${replace_val}=${True}
    logger.log_info_to_console      Triggerring alarms on RU.
    ru_resources.trigger alarm on ru        src=${src}        dst=${dst}        replace_val=${replace_val}
    ...                                     commands_to_trigger_alarm_on_ru=${commands_to_trigger_alarm_on_ru}

Verify Fault History
    [Arguments]    ${state}=1
    logger.log_info_to_console      Verifying Fault history in bbox5 file from snapshot.
    snapshot_resources.verify bts alarm history     file_to_check=BTS76007_EB2239R1963_RMOD_L_2_BBOX5_all.zip
    ...                                             event_id=1152       state=${state}      type_of_event=major

Verify BBOX5 file On Ru
    logger.log_info_to_console      Verifying all expected items are available in the file in RU.
    ru_resources.verify all items are avaliable in file on ru    path_to_file=/mnt/runtime/BBOX5
    ...                                                          expected_items=${expected_items_rf_bbox_5}

Verify BBOX5 file On Snapshot
    logger.log_info_to_console      Verifying all expected items are available in the file in RU.
    snapshot_resources.verify all items are avaliable in file    file_to_check=BTS76007_EB2239R1963_RMOD_L_2_BBOX5_all.zip
    ...                                                          expected_items=${expected_items_rf_bbox_5}

Verify NVM Updating in BBOX5 file On Snapshot
    logger.log_info_to_console      Verifying support NVM updating in the file in Snapshot File.
    snapshot_resources.verify support nvm updating in file in snapshot    file_to_check=BTS76007_EB2239R1963_RMOD_L_2_BBOX5_all.zip

Verify Product Code And Serial Number in BBOX5 file On Snapshot
    logger.log_info_to_console      Verifying Product Code And Serial Number in BBOX5 file On Snapshot.
    snapshot_resources.verify product code and serial number in bbox5 file in snapshot    file_to_check=BTS76007_EB2239R1963_RMOD_L_2_BBOX5_all.zip

Verify Radio SW Version And Firmware Version After Enhancement
    logger.log_info_to_console      Verifying Radio SW Version And Firmware Version After Enhancement.
    ${main_sw_version}=     local_resources.get gnb sw version
    ${resets_count} =      Set Variable       5
    ${ru_sw_versions}=	Create List
    FOR         ${loop_num}     IN RANGE    1       ${resets_count}
        local_resources.try to update sw        main_sw_version=${main_sw_version}
        BuiltIn.Sleep       120s
        Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair
        ${sw_version}=      ru_resources.get_ru_sw_version
        Append To List      ${ru_sw_versions}        ${sw_version}
    END
    logger.log_info_to_console      Reseting RU...
    ru_resources.actions with ru    action=Reset
    Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair
    snapshot_resources.verify sw version after enhancement of radio    file_to_check=BTS76007_EB2239R1963_RMOD_L_2_BBOX5_all.zip
    ...                                                                ru_sw_versions=${ru_sw_versions}

Enhancement Of Reset Counter
    logger.log_info_to_console      Verifying Reset Counter After Enhancement.
    ${main_sw_version}=     local_resources.get gnb sw version
    ${resets_count} =      Set Variable       3
    FOR         ${loop_num}     IN RANGE    1       ${resets_count}
        local_resources.try to update sw        main_sw_version=${main_sw_version}
        BuiltIn.Sleep       120s
        Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair
        ru_resources.actions with ru    action=Reset
        Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair
        Reset gNB
        Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair
    END
    snapshot_resources.verify reset counter in bbox5 file in snapshot    file_to_check=BTS76007_EB2239R1963_RMOD_L_2_BBOX5_all.zip
    ...                                                                  reset_count=${resets_count}

Verify Temperature In Snapshot File
    logger.log_info_to_console      Verifying temperature values in snapshot file
    ${temperature_values}=      snapshot_resources.verify temperature in snapshot
    ...                         file_to_check=BTS76007_EB2239R1963_RMOD_L_2_BBOX5_all.zip
    [Return]    ${temperature_values}


Verify Support BTS ID and BTS SW Version
    logger.log_info_to_console      Verifying support BTS ID and BTS SW Version
    snapshot_resources.verify support bts id and bts sw version    file_to_check=BTS76007_EB2239R1963_RMOD_L_2_permanent.xml.gz

Change timeBetweenSaveOnNVM On Ru
    [Arguments]     ${src}      ${dst}      ${replace_val}=${True}
    logger.log_info_to_console      Changing timeBetweenSaveOnNVM
    ru_resources.change timeBetweenSaveOnNVM    src=${src}      dst=${dst}      replace_val=${replace_val}
    ...                                         commands_to_change_time_on_ru=${commands_to_change_time_on_ru}
    BuiltIn.Sleep       1m
    Wait Until Keyword Succeeds     900 sec     30 sec      gnbcell.Verify All Cells Are Onair

Verify BBOX5 Periodical Trigger Occur
    [Arguments]    ${trigger_occur}     ${occurence}
    logger.log_info_to_console      Verifying periodical trigger occur in Snapshot File.
    ${trigger_occur_result}=        snapshot_resources.verify trigger occur     expected_items=${trigger_occur}
    ...                             file_to_check=BTS76007_EB2239R1963_RMOD_L_2_BBOX5_all.zip
    ...                             occurence=${occurence}
    [Return]    ${trigger_occur_result}

Verify If Number Of Occurences Are Updated
    [Arguments]    ${trigger_occur}
    local_resources.verify_if_number_of_occurences_are_updated      ${trigger_occur}

Verify If Temperature Is Changed
    [Arguments]     ${temperature_first_occurence}      ${temperature_second_occurence}
    local_resources.verify if temperature is changed    ${temperature_first_occurence}      ${temperature_second_occurence}


Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions after test
    Common Postconditions With Watching Alarms
    Remove custom allowed alarms if defined
