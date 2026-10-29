*** Settings ***
Documentation
...      31.03.2025 -- RF5.0 issues

Library     String
Library     Process
Library     DateTime
Library	    Collections
Library		OperatingSystem
Library     XML  lxml=True
Library     taf.sbts.oam.coam.admin     WITH NAME   admin_cli

*** Keywords ***
Wait for counter to be gathered after guard peroid
    [Arguments]    ${interval}
    Wait Until Keyword Succeeds    1 min
    ...                            5 sec
    ...                            Wait For Proper Time    interval=${interval}
    PM Wait To Nearest Measurement Period
    ...    interval=${interval}

Wait for counter peroid end
    [Arguments]    ${interval}
    PM Wait For Measurement Period End
    ...    interval=${interval}

PM Wait To Nearest Measurement Period
    [Arguments]    ${interval}
    Log To Console    PM Wait To Nearest Measurement Period ${interval}
    ${interval_plus_one}    Add One To Interval    ${interval}
    Wait Until Keyword Succeeds                    ${interval_plus_one} min
    ...                                            1 min
    ...                                            Wait For Right Period    interval=${interval}
    Wait Until Keyword Succeeds                    1 min
    ...                                            5 sec
    ...                                            Wait For Proper Time    interval=${interval}

PM Wait For Measurement Period End
    [Arguments]    ${interval}
    Log To Console    PM Wait For Measurement Period End ${interval}
    ${interval_plus_one}    Add One To Interval    ${interval}
    Wait Until Keyword Succeeds                    ${interval_plus_one} min
    ...                                            1 min
    ...                                            Wait For Period End    interval=${interval}
    Wait Until Keyword Succeeds                    1 min
    ...                                            5 sec
    ...                                            Wait For Proper Time    interval=${interval}

Create Interval List
    [Arguments]    ${interval}
    ${listLen}     Set Variable    60/${interval}
    ${list}        Create List     00
    FOR    ${index}    IN RANGE    0    ${listLen}-1
        ${index}         Convert to string  ${index}
        ${index_list}=   Split string  ${index}  separator=\.
        ${index}=        Get from list  ${index_list}  0
        ${time}          Add Time To Time    ${list[${index}]} minute    ${interval} minute    result_format=timer    exclude_millis=false
        ${time}          Get Substring    ${time}    3    5
        ${time}          Convert To String    ${time}
        Append To List    ${list}    ${time}
    END
    [Return]    ${list}

Wait For Right Period
    [Arguments]      ${interval}
    SYSTEM Get Time From Various Time Sources    #debug kw to monitor/check time differences from various sources
    ${list}    Create Interval List    interval=${interval}
    ${actualTime}     Get Current Date    result_format=%M
    ...                                   time_zone=UTC
    ...                                   increment=${time_offset} hour
    ${actualHour}     Get Current Date    result_format=%H
    ...                                   time_zone=UTC
    ...                                   increment=${time_offset} hour
    ${date}           Get Current Date    result_format=%Y-%m-%d
    ...                                   time_zone=UTC
    ...                                   increment=${time_offset} hour
    ${date_nodash}    Get Current Date    result_format=%Y%m%d
    ...                                   time_zone=UTC
    ${actualTime_snapshot}    Get Current Date    result_format=%M
    ...                                           time_zone=UTC
    ${actualHour_snapshot}    Get Current Date    result_format=%H
    ...                                           time_zone=UTC
    ${actualEpoch}    Convert Date    ${date} ${actualHour}:${actualTime}:00.000	epoch
    List Should Contain Value	      ${list}  ${actualTime}
    Set Global Variable               ${actualTime}
    Set Global Variable               ${actualHour}
    Set Global Variable               ${actualTime_snapshot}
    Set Global Variable               ${actualHour_snapshot}
    Set Global Variable               ${actualEpoch}
    Set Global Variable               ${date}
    Set Global Variable               ${date_nodash}

Wait For Period End
    [Arguments]      ${interval}
    ${list}    Create Interval List      interval=${interval}
    ${actualTime}    Get Current Date    result_format=%M
    ...                                  time_zone=UTC
    ...                                  increment=${time_offset} hour
    ${actualHour}    Get Current Date    result_format=%H
    ...                                  time_zone=UTC
    ...                                  increment=${time_offset} hour
    ${date}    Get Current Date          result_format=%Y-%m-%d
    ...                                  time_zone=UTC
    ...                                  increment=${time_offset} hour
    List Should Contain Value            ${list}  ${actualTime}

Wait For Proper Time
    [Arguments]      ${interval}
    ${list}    Create Interval List      interval=${interval}
    ${actualTime}    Get Current Date    result_format=%M
    ...                                  time_zone=UTC
    ...                                  increment=${time_offset} hour
    List Should Not Contain Value        ${list}  ${actualTime}

Check if counter is configured
    [Arguments]  ${expected_value}   ${parameter_name}
    admin_cli.collect scf   target_file_name=/home/ute/scf.xml
    ${XML}=   Parse XML   /home/ute/scf.xml
    ${value}=   Get Element Text   ${XML}   //p[@name="${parameter_name}"]
    Should be equal   ${value}   ${expected_value}

Check if counters are collected in proper objects
   [Documentation]  This keyword can be expanded for getting PM counters at the start of test case (after time slot
   ...   is correct) and collect all counters and iterate over dict here to improve performance.
   [Arguments]  ${measurement_id}   ${epoch}
   ${counter_values}=   admin_cli.get pm counters   ${measurement_id}
   ${string_values}=   Convert To String   ${counter_values}
   Should Contain   ${string_values}  ${epoch}

Check if counters are not collected in proper objects
   [Documentation]  This keyword can be expanded for getting PM counters at the start of test case (after time slot
   ...   is correct) and collect all counters and iterate over dict here to improve performance.
   [Arguments]  ${measurement_id}   ${epoch}
   ${counter_values}=   admin_cli.get pm counters   ${measurement_id}
   ${string_values}=   Convert To String   ${counter_values}
   Should Not Contain   ${string_values}  ${epoch}

Check if counter group is fully collected
   [Documentation]    ${counter_id_main} is a counter ID without 2 last digits for loop to iterate over measurements
   [Arguments]  ${counter_id_main}   ${numer_of_measurements}   #${interval}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   FOR   ${measurement}   IN RANGE   1   ${numer_of_measurements}
      Run keyword if   ${measurement} < 10
      ...   Check if counters are collected in proper objects   ${counter_id_main}${0}${measurement}   ${nopoint_epoch}
      ...   ELSE   Check if counters are collected in proper objects   ${counter_id_main}${measurement}   ${nopoint_epoch}
   END

Check if counter group not collected at timestamp
   [Arguments]  ${counter_id_main}   ${numer_of_measurements}   #${interval}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   FOR   ${measurement}   IN RANGE   1   ${numer_of_measurements}
      Run keyword if   ${measurement} < 10
      ...   Check if counters are not collected in proper objects   ${counter_id_main}${0}${measurement}   ${nopoint_epoch}
      ...   ELSE   Check if counters are not collected in proper objects   ${counter_id_main}${measurement}   ${nopoint_epoch}
   END

Collect and unzip snapshot
   [Arguments]  ${path}
   admin_cli.collect_snapshot   target_file_name=${path}/snapshot.zip
   ${result}=   Run   unzip ${path}/snapshot.zip -d ${path}

Assert that snapshot contains counters from last update
   [Documentation]  This keyword only checks if file exists in file list. Can be expanded to checking the XML file
   ...   physically. Complexity is high.
   [Arguments]  ${path}
   ${snapshot_content}=   Get file   ${path}/snapshot_file_list.txt
   Should Match Regexp   ${snapshot_content}   (?m)${date_nodash}.${actualHour_snapshot}${actualTime_snapshot}00
   #TODO: implement checking actual XML files

Clean up snapshot
   [Arguments]  ${path}
   Run   rm -rf ${path}

Modify the SCF for measurement to be gathered in minute intervals
   [Arguments]  ${interval}   ${parameter_name}
   Log   ${interval}
   Log   ${parameter_name}
   admin_cli.Perform Parameter Recommissioning   dist_name=MRBTS-${OUT_MRBTS_ID}/NRBTS-${OUT_MRBTS_ID}/NRPMRNL-1    parameter=${parameter_name}
   ...   value=${interval}   operation=update   skip_parameter_relation_errors=true

Add One To Interval
    [Arguments]    ${interval}
    ${interval_int}    Convert To Integer    ${interval}
    ${interval_plus_one}    Evaluate    ${interval_int}+1
    ${interval_plus_one}    Convert To String    ${interval_plus_one}
    [Return]    ${interval_plus_one}


Change Time Zone
    [Arguments]  ${value}
     taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...                                  dist_name=${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...                                  parameter=timeZone
    ...                                  operation=update
    ...                                  value=${value}
    ...                                  timeout=900
    ...                                  connection=${ADMIN_ALIAS}
    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is OnAir

Modify the SCF for measurement to be gathered in minute intervals1
   [Arguments]  ${interval}   ${tree}   ${parameter_name}
   Log   ${interval}
   Log   ${parameter_name}
   admin_cli.Perform Parameter Recommissioning   dist_name=${tree}   parameter=${parameter_name}
   ...   value=${interval}   operation=update   skip_parameter_relation_errors=true

Wait for counter to be gathered after guard peroid1
   [Arguments]  ${interval}
   Sleep   ${interval} minutes
   PM Wait To Nearest Measurement Period1  ${interval}


PM Wait To Nearest Measurement Period1
   [Arguments]  ${interval}
   Log    PM Wait To Nearest Measurement Period1    console=yes

   Wait Until Keyword Succeeds                     ${interval+1} min
   ...                                             1 min
   ...                                             Wait For Right Period1
   Sleep                                           60

Wait For Right Period1
   ${list}=           Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${actualTime}=     Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ...                                    increment=1 hour
   ${actualHour}=     Get Current Date    result_format=%H
   ...                                    time_zone=UTC
   ...                                    increment=1 hour
   ${date}=     Get Current Date    result_format=%Y-%m-%d
   ...                                    time_zone=UTC
   ...                                    increment=1 hour
   ${date_nodash}=    Get Current Date    result_format=%Y%m%d
   ...                                    time_zone=UTC
   ${actualTime_snapshot}=     Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ${actualHour_snapshot}=     Get Current Date    result_format=%H
   ...                                    time_zone=UTC
#   ${actualEpoch}=    Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
   ${tt}   Run     date "+%D %H:%M"
   ${actualEpoch}    Run    date --date='${tt}' +"%s"
   List Should Contain Value	           ${list}  ${actualTime}
   Log                                    ${actualTime}
   Set Global Variable                    ${actualTime}
   Set Global Variable                    ${actualHour}
   Set Global Variable                    ${actualTime_snapshot}
   Set Global Variable                    ${actualHour_snapshot}
   Set Global Variable                    ${actualEpoch}
   Set Global Variable                    ${date}
   Set Global Variable                    ${date_nodash}

Check if counter group is fully collected1
   [Documentation]    ${counter_id_main} is a counter ID without 2 last digits for loop to iterate over measurements
   [Arguments]  ${counter_id_main}   ${interval}   #${numer_of_measurements}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-${interval}*60
#   Set time difference to epoch if needed
#   ...    epoch_minus_interval=${epoch_minus_interval}
   #TODO: 15 minutes is subject to change if higher granularity is included
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   Check if counters are collected in proper objects   M55110C00001   ${epoch_minus_interval_string}
