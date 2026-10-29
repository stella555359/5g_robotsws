*** Settings ***
Documentation
...   author: Sylwia Swiatkiewicz
...   contact: sylwia.swiatkiewicz@nokia.com
...   Feature 5GC001546-AA in 5G19A program

Library     String
Library     Process
Library     DateTime
Library     Collections
Library     XML  lxml=True

Library     taf.sbts.oam.coam.admin     WITH NAME   admin_cli

Resource    ../../../resources/admin_infomodel.robot
Resource    ../../../resources/admin.robot

*** Variables ***
${delta_ETHIF_2_delete}=     ${CURDIR}/Delta_ETHIF_2_delete.json
${delta_temporary}=          ${CURDIR}/Delta_Temporary.json


*** Keywords ***
Set mrbtsId and nrbtsId variables
    admin_cli.collect scf   target_file_name=/home/ute/scf.xml
    ${XML}=   Parse XML   /home/ute/scf.xml
    ${mrbtsId_element}=   Get Element   ${XML}   //managedObject[@class="com.nokia.srbts:MRBTS"]
    ${nrbtsId_element}=   Get Element   ${XML}   //managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]

    set global variable   ${mrbtsId}   ${mrbtsId_element.attrib['distName']}
    set global variable   ${nrbtsId}   ${nrbtsId_element.attrib['distName']}

Modify the SCF for measurement to be gathered in minute intervals
   [Arguments]  ${interval}   ${tree}   ${parameter_name}
   Log   ${interval}
   Log   ${parameter_name}
   admin_cli.Perform Parameter Recommissioning   dist_name=${tree}   parameter=${parameter_name}
   ...   value=${interval}   operation=update   skip_parameter_relation_errors=true

Wait for counter to be gathered after guard peroid
   [Arguments]  ${interval}
   Sleep   ${interval} minutes
   PM Wait To Nearest Measurement Period  ${interval}

PM Wait To Nearest Measurement Period
   [Arguments]  ${interval}
   Log    PM Wait To Nearest Measurement Period    console=yes

   Wait Until Keyword Succeeds                     ${interval+1} min
   ...                                            1 min
   ...                                             Wait For Right Period
   Sleep                                           60

Wait For Right Period
   ${list}=           Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${actualTime}=     Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ...                                    increment=2 hours
   ${actualHour}=     Get Current Date    result_format=%H
   ...                                    time_zone=UTC
   ...                                    increment=2 hours
   ${date}=     Get Current Date    result_format=%Y-%m-%d
   ...                                    time_zone=UTC
   ...                                    increment=2 hours
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


Check if counters are not collected in proper objects
   [Documentation]  This keyword can be expanded for getting PM counters at the start of test case (after time slot
   ...   is correct) and collect all counters and iterate over dict here to improve performance.
   [Arguments]  ${measurement_id}   ${epoch}
   ${counter_values}=   admin_cli.get pm counters   ${measurement_id}
   ${string_values}=   Convert To String   ${counter_values}
   Should Not Contain   ${string_values}  ${epoch}

Check if counters are collected in proper objects
   [Documentation]  This keyword can be expanded for getting PM counters at the start of test case (after time slot
   ...   is correct) and collect all counters and iterate over dict here to improve performance.
   [Arguments]  ${measurement_id}   ${epoch}
   ${counter_values}=   admin_cli.get pm counters   ${measurement_id}
   ${string_values}=   Convert To String   ${counter_values}
   Should Contain   ${string_values}  ${epoch}

Check if counter group is fully collected
   [Documentation]    ${counter_id_main} is a counter ID without 2 last digits for loop to iterate over measurements
   [Arguments]  ${counter_id_main}   ${numer_of_measurements}   ${interval}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-${interval}*60
#   Set time difference to epoch if needed
#   ...    epoch_minus_interval=${epoch_minus_interval}
   #TODO: 15 minutes is subject to change if higher granularity is included
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   Check if counters are collected in proper objects   M55110C00001   ${epoch_minus_interval_string}

Check if counter group is fully collected M51301C1
   [Documentation]    ${counter_id_main} is a counter ID without 2 last digits for loop to iterate over measurements
   [Arguments]  ${counter_id_main}   ${numer_of_measurements}   ${interval}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-${interval}*60
#   Set time difference to epoch if needed
#   ...    epoch_minus_interval=${epoch_minus_interval}
   #TODO: 15 minutes is subject to change if higher granularity is included
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   Check if counters are collected in proper objects   M51301C1   ${epoch_minus_interval_string}


Check if counter group not collected at timestamp
   [Arguments]  ${counter_id_main}   ${numer_of_measurements}   ${interval}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-${interval}*60
#   Set time difference to epoch if needed
#   ...    epoch_minus_interval=${epoch_minus_interval}
   #TODO: 15 minutes is subject to change if higher granularity is included
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   Check if counters are not collected in proper objects   M55110C00001   ${epoch_minus_interval_string}

Check if counter group not collected at timestamp M51301C1
   [Arguments]  ${counter_id_main}   ${numer_of_measurements}   ${interval}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-${interval}*60
#   Set time difference to epoch if needed
#   ...    epoch_minus_interval=${epoch_minus_interval}
   #TODO: 15 minutes is subject to change if higher granularity is included
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   Check if counters are not collected in proper objects   M51301C1   ${epoch_minus_interval_string}

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

Wait For OnAir
    [Documentation]
    ...    to check if cOAM BTS is in OnAir
    [Arguments]    ${timeout}=15 min
    wait until keyword succeeds    ${timeout}
    ...                            30s
    ...                            ADMIN INFOMODEL Check If BTS Is OnAir

Set time difference to epoch if needed
    [Arguments]    ${epoch_minus_interval}
    ${api_responseTime}    Run
    ...    command=tail --lines=4 ${admin_api_log_dir}/admin_api_default.log | awk '{print $1}' | egrep -m 1 '[0-9]+:[0-9]+:[0-9]+'
    ${api_responseHour}    Fetch From Left    ${api_responseTime}    :
    ${integer_api_responseHour}    Convert To Integer    ${api_responseHour}
    ${time_difference}    Subtract Time From Time    ${integer_api_responseHour}    ${actualHour}
    ${integer_time_difference}    Convert To Integer    ${time_difference}
    Run Keyword If    ${integer_time_difference}!=0
    ...    Set time difference to epoch
    ...    epoch_minus_interval=${epoch_minus_interval}
    ...    integer_time_difference=${integer_time_difference}


Set time difference to epoch
    [Arguments]    ${epoch_minus_interval}    ${integer_time_difference}
    ${new_epoch_minus_interval}    Evaluate    ${epoch_minus_interval}+${integer_time_difference}*3600
    Set Test Variable    ${epoch_minus_interval}    ${new_epoch_minus_interval}

Change Time Zone
    [Arguments]  ${value}
     taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...                                  dist_name=${mrbtsId}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...                                  parameter=timeZone
    ...                                  operation=update
    ...                                  value=${value}
    ...                                  timeout=900
    ...                                  connection=${ADMIN_ALIAS}
    ...                                  skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is Configured


Temporary SCF Validation
    ADMIN Perform Delta Recommissioning         ${delta_ETHIF_2_delete}
    ...                                         skip_parameter_relation_errors=True

Temporary SCF Validation 2
    ADMIN Perform Delta Recommissioning         ${delta_temporary}
    ...                                         skip_parameter_relation_errors=True

Branch or Trunk
    ${split_build}=  Split String  ${OUT_ACTIVE_SW}  separator=\_
    ${trunk_flag}=   Get from list  ${split_build}   2
    Set Suite Variable  ${trunk_flag}
    ${sw_version}=   Get from list  ${split_build}   0
    Set Suite Variable  ${sw_version}

