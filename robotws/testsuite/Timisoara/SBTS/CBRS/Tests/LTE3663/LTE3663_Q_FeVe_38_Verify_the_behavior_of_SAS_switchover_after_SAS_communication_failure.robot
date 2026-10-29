*** Settings ***
Documentation
...    = Author = Albert Sakowicz
...    _albert.sakowicz@nokia.com_
...    = Maintainer = Albert Sakowicz
...    _albert.sakowicz@nokia.com_
...    = Reviewers = Bartosz Rutkowski, Lukasz Lechowicz, Michal Moskala
...    _bartosz.rutkowski@nokia.com_
...    _lukasz.lechowicz@nokia.com_
...    _michal.moskala@nokia.com_
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_

*** Keywords ***
LTE3663_Q_FeVe_38_Verify_the_behavior_of_SAS_switchover_after_SAS_communication_failure
    [Documentation]    Feature LTE3663 introduces the capability for Macro eNBs(Airscale) to operate in the shared 3.5GHz (Band48) spectrum
    ...                to leverage the control and manage of 3.5GHz (Band48) LTE spectrum usage.
    ...                The purpose of this test case is to check if eNB performs SAS Switchover in case primarySasServer connection failure

    ${enb_id}                    Set Variable    ${testlines.${testline_id}.enb_id}
    ${vm_ip}                     Set Variable    ${testlines.${testline_id}.vm_ip}
    ${primary_sas_port}          Set Variable    4433
    ${secondary_sas_port}        Set Variable    4444
    ${connect_to_sas_mode}       Set Variable    direct connect to SAS server
    &{expected_alarm_1}          Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Minor
    &{expected_alarm_2}          Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    ${expected_alarms_list}      Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    ${primary_sas_pid}    ${primary_sas_log}   Start SAS Process    alias=primary    port=${primary_sas_port}    version=1.2
    ${secondary_sas_pid}    ${secondary_sas_log}   Start SAS Process    alias=secondary    port=${secondary_sas_port}    version=1.2
    Log To Console    Sum of CBSDs ${SUM_OF_CBSDS}
    Log To Console    Setting primary and secondary SAS IP addresses
    Replace Variables In File    file_path=${CURDIR}/Data/set_primary_and_secondary_SAS.json
    ...                          file_destination=${OUTPUT_DIR}/setting_primary_and_secondary_SAS.json
    ...                          enb_id=${enb_id}
    ...                          primary_sas=${vm_ip}:${primary_sas_port}
    ...                          secondary_sas=${vm_ip}:${secondary_sas_port}
    ...                          connect_to_sas_mode=${connect_to_sas_mode}
    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning    ${OUTPUT_DIR}/setting_primary_and_secondary_SAS.json    connection=RAT_1ST
    Enable CBRS Feature On eNB
    Log To Console    Waiting for eNB to get OnAir
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    ${cbsdId}   Get CBSD Id From Infomodel
    Log To Console    Killing primary SAS and waiting for alarms
    Run    kill -9 ${primary_sas_pid}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                   severity=${expected_alarm_1}[severity]    timeout=90
    ${start_time}   Get Time
    Log To Console    Waiting for SAS Switchover
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=300
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]

    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                   severity=${expected_alarm_2}[severity]    timeout=300
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                     severity=${expected_alarm_2}[severity]    timeout=600
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                        severity=${expected_alarm_2}[severity]

    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Log To Console    Checking SAS log
    ${stop_time}   Get Time
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${secondary_sas_log}
    ...                                          date_start=${start_time}
    ...                                          date_stop=${stop_time}
    ${registration_response}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                         parameter=responseMessage
    ...                                                         data_type=registrationResponse
    Should Contain    ${registration_response}    CBSD request is approved by SAS
    ${registration_code}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                     parameter=responseCode
    ...                                                     data_type=registrationResponse
    ${required_code}   Convert To Integer    0
    Should Contain    ${registration_code}    ${required_code}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=primary    AND
    ...                           Get SAS Logs To Logs Dir    alias=secondary    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Replace Variables In File    file_path=${CURDIR}/Data/remove_secondary_SAS.json
    ...                           file_destination=${OUTPUT_DIR}/remove_secondary_SAS.json
    ...                           enb_id=${enb_id}    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Perform Delta Recommissioning    ${OUTPUT_DIR}/remove_secondary_SAS.json
    ...                           connection=RAT_1ST
