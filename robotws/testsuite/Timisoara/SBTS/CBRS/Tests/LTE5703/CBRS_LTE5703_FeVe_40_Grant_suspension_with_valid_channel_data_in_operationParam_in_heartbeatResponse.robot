*** Settings ***
Documentation
...    = Author = Albert Sakowicz
...    _albert.sakowicz@nokia.com_
...    = Maintainer = Albert Sakowicz
...    _albert.sakowicz@nokia.com_
...    = Reviewer = Artur Czainski
...    _artur.czainski@nokia.com_
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_

*** Keywords ***
CBRS_LTE5703_FeVe_40_Grant_suspension_with_valid_channel_data_in_operationParam_in_heartbeatResponse
    [Documentation]    The purpose of this test is to verify whether eNB behaves correctly eNB received valid channel
    ...                data in the operationParam list in heartbeat response. It is realized by SAS Sim configuration.
    ...                Tested Requirement: OM_GEN_SFS_CBRS.381

    &{expected_alarm}   Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    ...                                        reason=responseCode : 501 transmitExpireTime expires.
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarm}
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Log To Console    Setting SAS to respond 501 for 3rd heartbeat and provide valid channel in operationParam
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/SAS_conf_40.conf
    ${start_time}   Get Time
    Enable CBRS Feature On eNB
    Log To Console    CBRS enabled, waiting to get onair

    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Log To Console    Waiting for suspend
    Sleep And Display Progress    120    s
    ${meantime}   Get Time
    Log To Console    Checking SAS log
    ${sum_of_grant_request}                Run    grep 'grantRequest' ${sas_log} | wc -l
    ${sum_of_heartbeats_with_suspension}   Run    grep 'The grant is suspended' ${sas_log} | wc -l
    ${sum_of_relinquishment_requests}      Run    grep 'relinquishmentRequest' ${sas_log} | wc -l
    Log To Console    Sum of RMODs: ${SUM_OF_CBSDS}
    Log To Console    Sum of grants: ${sum_of_grant_request}
    Log To Console    Sum of suspensions: ${sum_of_heartbeats_with_suspension}
    Log To Console    Sum of relinquishments: ${sum_of_relinquishment_requests}
    ${grant_status}   Evaluate    ((${SUM_OF_CBSDS}-1) < ${sum_of_grant_request} < 16)
    Should Be True    ${grant_status}
    ${suspensions_for_all_cbsds}       Evaluate    ${SUM_OF_CBSDS}*2
    ${relinquishments_for_all_cbsds}   Evaluate    ${SUM_OF_CBSDS}*4
    Should Be Equal As Numbers    ${sum_of_heartbeats_with_suspension}    ${suspensions_for_all_cbsds}
    Should Be Equal As Numbers    ${sum_of_relinquishment_requests}    ${relinquishments_for_all_cbsds}
    Log To Console    Checking if eNB is still onair
    Watchdog Check For Failures

    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Log To Console    Wait to make sure another HB appeared
    Sleep And Display Progress    30    s
    ${stop_time}   Get Time
    ${initial_parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                                  date_start=${start_time}
    ...                                                  date_stop=${meantime}
    ${initial_grantId_list}   Extract Values From Sas Log    log_name=${initial_parsed_log_file}
    ...                                                        parameter=grantId
    ...                                                        data_type=heartbeatResponse
    ...                                                        start_from=spectrumInquiryResponse
    ...                                                        packet_amount=1
    ${final_parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                                date_start=${meantime}
    ...                                                date_stop=${stop_time}
    ${final_grantId_list}   Extract Values From Sas Log    log_name=${final_parsed_log_file}
    ...                                                      parameter=grantId
    ...                                                      data_type=heartbeatResponse
    ...                                                      packet_amount=1
    Log To Console    Initial grant IDs ${initial_grantId_list}
    Log To Console    Final grant IDs ${final_grantId_list}
    Should Not Contain    ${final_grantId_list}    ${initial_grantId_list[0]}
    Should Not Contain    ${final_grantId_list}    ${initial_grantId_list[1]}
    Should Not Contain    ${final_grantId_list}    ${initial_grantId_list[2]}
    Should Not Contain    ${final_grantId_list}    ${initial_grantId_list[3]}
    Log To Console    Grants are ok, checking if eNB onair again
    Watchdog Check For Failures

    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Log To Console    eNB is onair, checking historical alarms

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures
