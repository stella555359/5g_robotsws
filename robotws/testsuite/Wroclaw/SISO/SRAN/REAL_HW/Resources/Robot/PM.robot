*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  ../Python/counters_helpers.py
Library  Collections

*** Keywords ***
Verify Counter And Return Length
    [Arguments]  ${counters_name}  ${min_range}  ${max_range}  ${bts_id}  ${return_timestamp}=True
    [Documentation]
    ...  This keyword will verify if all the values of the counters are in the range ${min_range}-${max_range}
    ...  and if all the timestamps are valid. It will return the total number of entries for all counters.
    ...  If ${return_timestamp} is set to True, it will also return the last timestamp of the last entry.
    ...
    ...  Author: mateusz.kawka@nokia.com
    ...  Maintainer: mateusz.kawka@nokia.com

    ${counters_name_for_api}  Evaluate  ','.join(${counters_name})
    Logging With Timestamp
    ...  message=Getting PM Counter ${counters_name_for_api} and checking values ...
    ...  style=ONGOING
    ${pm_counter}  admin.Get Pm Counters  ${counters_name_for_api}  alias=${bts_id}
    ${last_timestamps_list}  Create List
    ${total_pm_counter_length}  Set Variable  ${0}
    FOR  ${counter_name}  IN  @{counters_name}
        ${counters_values_list}  Find Key In Nested Dictionary  ${pm_counter}  ${counter_name}
        ${total_pm_counter_length}  Evaluate  sum(len(d) for d in ${counters_values_list})+${total_pm_counter_length}
        ${counters_values_len}  Evaluate  sum(len(d) for d in ${counters_values_list})
        ${counters_values_list_len}  Evaluate  len(${counters_values_list})
        Logging With Timestamp
        ...  message=Found ${counters_values_list_len} occurrences of counter ${counter_name}!
        Logging With Timestamp
        ...  message=Found total of ${counters_values_len} entries for counter ${counter_name}!
        Logging With Timestamp
        ...  message=Checking entries for each counter will now proceed ...
        ...  style=ONGOING
        ${incremental_var}  Set Variable  ${1}
        FOR  ${dict}  IN  @{counters_values_list}
            Logging With Timestamp
            ...  message=Checking dictionary values for ${incremental_var}. occurence of counter ${counter_name} ...
            ...  style=ONGOING
            ${range_status}  Check Dictionary Values In Range  ${dict}  ${min_range}  ${max_range}
            IF  ${range_status}
                Logging With Timestamp
                ...  message=All counter values are in range ${min_range}-${max_range} !
                ...  style=DONE
            ELSE
                Logging With Timestamp
                ...  message=Some counters are out of range ${min_range}-${max_range} !
                ...  style=ERROR
                Run Keyword And Continue On Failure  Fail  Some counter values are out of range ${min_range}-${max_range} !
            END
            ${last_timestamp}  Get Last Timestamp From Counters Dictionary  ${dict}
            Append To List  ${last_timestamps_list}  ${last_timestamp}
            ${time_status}  Validate Epoch Timestamp  ${last_timestamp}
            IF  ${time_status}
                Logging With Timestamp
                ...  message=All entries of counter ${counter_name} have valid timestamps.
                ...  style=DONE
            ELSE
                Logging With Timestamp
                ...  message=Some of the entries of counter ${counter_name} have invalid timestamps!
                ...  style=ERROR
                Run Keyword And Continue On Failure  Fail
                ...  Some of the entries of counter ${counter_name} have invalid timestamps!
            END
            ${incremental_var}  Evaluate  ${incremental_var}+1
        END
    END

    ${all_timetamps_equal_status}  Check If All Elements In List Equal  ${last_timestamps_list}

    IF  ${all_timetamps_equal_status}
        Logging With Timestamp
        ...  message=All last timestamps are the same !
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Not all last timestamps are the same !
        ...  style=ERROR
        Run Keyword And Continue On Failure  Fail  Not all last timestamps are the same !
    END

    IF  ${return_timestamp}
        ${last_timestamp}  Get Last Timestamp From Counters Dictionary  ${dict}  time_format=human  utc=True
        RETURN  ${total_pm_counter_length}  ${last_timestamp}
    ELSE
        RETURN  ${total_pm_counter_length}
    END

PM Rmod Get Measurement
    [Arguments]  ${measurements}  ${rmod_number}
    [Documentation]
    ...  Description:
    ...  Keyword retrieves the power measurement for a specific radio module from a list of measurement dictionaries.
    ...  It iterates through the provided measurements, identifies the RMod by matching the number extracted from the key,
    ...  and returns the corresponding power value.
    ...
    ...  Arguments:
    ...  +------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument         | Man.  | Description                                                                                   |
    ...  +==================+=======+===============================================================================================+
    ...  | measurements     | Yes   | List of dictionaries containing RMod measurement data.                                        |
    ...  +------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | rmod_number      | Yes   | The RMod number                                                                               |
    ...  +------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...  Returns:
    ...  +--------+--------+--------------------------------------------------+
    ...  | Name   | Type   | Description                                      |
    ...  |--------|--------|--------------------------------------------------|
    ...  | power  | float  | The power value associated with the given RMod.  |
    ...  +--------+--------+--------------------------------------------------+
    ...
    ...  Usage:
    ...  ${power}  PM Rmod Get Measurement  ${measurements}  ${rmod_number}
    ...
    ...  Author: lukasz.wystup@nokia.com
    ...  Maintainer: lukasz.wystup@nokia.com

    FOR  ${measurement}  IN  @{measurements}
      ${rmod}  Get Dictionary Keys  ${measurement}
      ${rmod}  Get From List    ${rmod}    0
      ${rmod_r}  Fetch From Right  ${rmod}  /
      ${rmod_power}  IF  '${rmod_r}'=='${rmod_number}'  Get From Dictionary  ${measurement}  ${rmod}
      ${power}  IF  '${rmod_r}'=='${rmod_number}'  Get From Dictionary  ${rmod_power}  power
      Exit For Loop If  '${rmod_r}'=='${rmod_number}'
     END
    [Return]  ${power}
