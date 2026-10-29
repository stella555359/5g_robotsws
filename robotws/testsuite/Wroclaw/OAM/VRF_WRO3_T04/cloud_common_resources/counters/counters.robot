*** Settings ***
Documentation    Description:      Resources used during sending some traffic from TestPC to TL.
...              Author:           jagoda.kubacka@nokia.com
...              Modification:     14-05-2024 made by jagoda.kubacka@nokia.com

Library     taf.transport.ssh       WITH NAME    ssh
Resource    ../../../cloud_common_resources/parameters/parameters.robot
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Library     Collections

*** Variables ***

${IP_TEST_PC}=     10.42.63.239
${LOGIN_TEST_PC}=  trs
${PASS_TEST_PC}=   YT_xk39b

*** Keywords ***
Wait For Next Counter Interval and Get Counter Timestamp with Value
    [Documentation]    Description:      Keyword to choose the proper time to send the packets. It check the available counter
    ...                                  and wait for the next one. After that - the packet must be sent and then the same KW
    ...                                  could be used to get the value for the counter. Example:
    ...                - available_counter=10:15:00 - KW wait until counter 10:20:00 will be available.
    ...                - available_counter=10:20:00 - KW end because new counter is available
    ...                - packets are sent - it must be used KW from test_pc.robot file
    ...                - available_counter=10:20:00 - KW wait until next counter will be available
    ...                                               because the next one will have the packets
    ...                - available_counter=10:25:00 - KW end because new counter with packets is available
    ...                Return:           Dictionary with counter's timestamp and value.
    ...                Author:           jagoda.kubacka@nokia.com
    [Arguments]        ${counter_id}                    #the ID for the counter, example: M51328C18
    ...                ${address_or_objects}=address    #get path by IP Address or by providing counter
    ...                ${choosen_object}=0              #number od choosen object from @{objects}
    ...                ${ip_address}=${None}            #provide IP Address in case of ${address_or_objects}=address
    ...                ${hw_type}=${None}               #vCU/vDU
    ${temp_conn}=      Connect to ADMIN    hw_type=${hw_type}
    # Getting the path for the defined counter - two ways are available. To get all paths for the defined counter
    # or provide the IP address and get one path where this address are set in SCF file.
    @{objects}=        Run Keyword If    "${address_or_objects}"=="objects"
    ...                counters._Get Counter Objects From WebEM    counter_id=${counter_id}    timeout=30    hw_type=${hw_type}
    ${ip_address}=     Run Keyword If    "${address_or_objects}"=="address"
    ...                counters._Get Counter Object From WebEM Via Address    ${ip_address}    hw_type=${hw_type}
    ${object_or_address}     Set Variable If    "${address_or_objects}"=="address"    ${ip_address}    ${objects[${choosen_object}]}
    # Getting all values available for the defined counter
    ${all_events}            counters._Get Counter Values    counter_id=${counter_id}    dist_name=${object_or_address}
    ...                      temp_conn=${temp_conn}    hw_type=${hw_type}
    # Getting the last available value for defined counter (timestamp)
    ${current_timestamp}=    Set Variable If   '${hw_type}' == 'vDU'   ${all_events[-1]['start_time']}
    ...                      ${all_events['values'][-1]['start_time']}
    Log    The current available counter is ${current_timestamp}. Waiting for next counter...    console=true
    ${is_event_created}=     Set Variable    ${False}
    WHILE                    not ${is_event_created}
        # Getting again the value for defined counter to wait until the new timestamp will be available
        ${all_events}            counters._Get Counter Values    counter_id=${counter_id}    dist_name=${object_or_address}
        ...                      temp_conn=${temp_conn}    hw_type=${hw_type}
        ${timestamp}     Set Variable If   '${hw_type}' == 'vDU'   ${all_events[-1]['start_time']}
        ...              ${all_events['values'][-1]['start_time']}
        # Comparing the current available values for the counter with the value taken before while loop.
        # If this condition pass, so the current available value will be more actual - the loop ends.
        ${is_event_created}=    Evaluate    '${timestamp}' > '${current_timestamp}'
        IF    not ${is_event_created}
            Log To Console    Waiting for counter event...
            Sleep    10sec
        END
    END
    # Again the values are taken to return the value and time for defined counter.
    ${all_events}            counters._Get Counter Values    counter_id=${counter_id}    dist_name=${object_or_address}
    ...                      temp_conn=${temp_conn}    hw_type=${hw_type}
    ${current_timestamp}=    Set Variable If   '${hw_type}' == 'vDU'   ${all_events[-1]['start_time']}
    ...                      ${all_events['values'][-1]['start_time']}
    ${current_value}         Set Variable If   '${hw_type}' == 'vDU'   ${all_events[-1]['value']}
    ...                      ${all_events['values'][-1]['value']}
    &{counter_values}        Create Dictionary
    Set To Dictionary        ${counter_values}    ${current_timestamp}=${current_value}
    [Return]                 &{counter_values}
    [Teardown]               Disconnect from ADMIN    hw_type=${hw_type}    connection=${temp_conn}

Get Counter Value without Period Checking
    [Documentation]    Description:      Keyword to choose the proper time to send the packets. It check the available counter
    ...                                  and wait for the next one. After that - the packet must be sent and then the same KW
    ...                                  could be used to get the value for the counter. Example:
    ...                - available_counter=10:15:00 - KW wait until counter 10:20:00 will be available.
    ...                - available_counter=10:20:00 - KW end because new counter is available
    ...                - packets are sent - it must be used KW from test_pc.robot file
    ...                - available_counter=10:20:00 - KW wait until next counter will be available
    ...                                               because the next one will have the packets
    ...                - available_counter=10:25:00 - KW end because new counter with packets is available
    ...                Return:           Dictionary with counter's timestamp and value.
    ...                Author:           jagoda.kubacka@nokia.com
    [Arguments]        ${counter_id}                    #the ID for the counter, example: M51328C18
    ...                ${address_or_objects}=address    #get path by IP Address or by providing counter
    ...                ${ip_address}=${None}            #provide IP Address in case of ${address_or_objects}=address
    ...                ${hw_type}=${None}               #vCU/vDU
    ${temp_conn}=      Connect to ADMIN    hw_type=${hw_type}
    # Getting the path for the defined counter - two ways are available. To get all paths for the defined counter
    # or provide the IP address and get one path where this address are set in SCF file.
    @{objects}=        Run Keyword If    "${address_or_objects}"=="objects"
    ...                counters._Get Counter Objects From WebEM    counter_id=${counter_id}    timeout=30    hw_type=${hw_type}
    ${ip_address}=     Run Keyword If    "${address_or_objects}"=="address"
    ...                counters._Get Counter Object From WebEM Via Address    ${ip_address}    hw_type=${hw_type}
    ${object_or_address}     Set Variable If    "${address_or_objects}"=="address"    ${ip_address}    ${objects[0]}
    # Getting all values available for the defined counter
    ${all_events}            counters._Get Counter Values    counter_id=${counter_id}    dist_name=${object_or_address}
    ...                      temp_conn=${temp_conn}    hw_type=${hw_type}
    ${current_timestamp}=    Set Variable If   '${hw_type}' == 'vDU'   ${all_events[-1]['start_time']}
    ...                      ${all_events['values'][-1]['start_time']}
    ${current_value}         Set Variable If   '${hw_type}' == 'vDU'   ${all_events[-1]['value']}
    ...                      ${all_events['values'][-1]['value']}
    &{counter_values}        Create Dictionary
    Set To Dictionary        ${counter_values}    ${current_timestamp}=${current_value}
    [Return]                 &{counter_values}
    [Teardown]               Disconnect from ADMIN    hw_type=${hw_type}    connection=${temp_conn}

################################################################################################################################

counters._Get Counter Objects From WebEM
    [Arguments]            ${counter_id}    ${timeout}    ${my_temp_conn}=${NONE}    ${hw_type}=${None}
    ${temp_conn}=    Run Keyword If    '${my_temp_conn}' == '${NONE}'
    ...              Connect to ADMIN    hw_type=${hw_type}
    ...              ELSE    Set Variable    ${my_temp_conn}
    @{counter_objects}=    Run Keyword If    '${hw_type}' == 'vDU'    vdu_admin.get_counter_objects
    ...                    counter_id=${counter_id}
    ...                    timeout=${timeout}
    ...                    vdu_connection=${temp_conn}
    ...                    ELSE    vcu_admin.get_counter_objects
    ...                    counter_id=${counter_id}
    ...                    timeout=${timeout}
    ...                    connection=${temp_conn}
    [Return]               @{counter_objects}
    [Teardown]             Run Keyword If    '${my_temp_conn}' == '${NONE}'
    ...                    Disconnect from ADMIN    connection=${temp_conn}    hw_type=${hw_type}

counters._Get Counter Object From WebEM Via Address
    [Arguments]       ${ip_address}    ${hw_type}=${NONE}    ${lenght}=4
    ${dist_name}=     Check Parameter Object Via Value on BTS    param_value=${ip_address}    hw_type=${hw_type}
    ${specific_dist_name}=     counters._Get Defined DistName Path    ${dist_name}[0]    ${lenght}
    [Return]    ${specific_dist_name}

_Get Defined DistName Path
    [Documentation]    Description:      Returning a path to an object of a defined length (defined number of objects in the path).
    ...                                  Example of usage:
    ...                                  dist_name=MRBTS-8446/TNLSVC-1/TNL-6/IPNO-1/IPIF-1/IPADDRESSV4-1/IPADDRESSV4_R-1
    ...                                  lenght=4
    ...                                  Output:
    ...                                  specific_dist_path=MRBTS-8446/TNLSVC-1/TNL-6/IPNO-1
    ...                Return:           The path to object that was changed to specific length.
    ...                Author:           jagoda.kubacka@nokia.com
    ...                Modification:     14-05-2024 made by jagoda.kubacka@nokia.com
    [Arguments]        ${dist_name}      # The full path for specific parameter
    ...                ${length}         # Length that should have path (how many elements should have)
    ${path}=           Split String    ${dist_name}    /
    ${desired_path}=   Create List
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${desired_path}    ${path}[${index}]
        ${specific_dist_path}=    Evaluate    '/'.join(${desired_path})
    END
    [Return]    ${specific_dist_path}

_Get Counter Values
    [Arguments]      ${counter_id}    ${dist_name}    ${temp_conn}=${NONE}    ${hw_type}=${NONE}
    ${conn}=         Run Keyword If    '${temp_conn}' == '${NONE}'
    ...              Connect to ADMIN    hw_type=${hw_type}
    ...              ELSE    Set Variable    ${temp_conn}
    ${all_events}=   Run Keyword If    '${hw_type}' == 'vDU'
    ...              vdu_admin.get_counter_values    counter_id=${counter_id}    vdu_connection=${conn}
    ...              dimension_dn=${dist_name}
    ...              ELSE
    ...              vcu_admin.get_counter    measurement_id=${None}    dimension_dist_name=${dist_name}
    ...              counter_id=${counter_id}    connection=${conn}
    [Return]         ${all_events}
    [Teardown]       Run Keyword If    '${temp_conn}' == '${NONE}'
    ...              Disconnect from ADMIN    connection=${conn}    hw_type=vDU
