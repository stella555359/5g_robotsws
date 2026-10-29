*** Settings ***
Documentation    Cloud KPIs keywords.
...              Authors:    Karol Sadowski
...              Contact:    karol.sadowski@nokia.com

Resource    taf/rfrl/cbts/robot/kpi.robot

Library     DateTime
Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin


*** Keywords ***

#################################################### Main  Keywords ####################################################

Check Operation Duration At MR Operations History
    [Documentation]    Description:    Calculates the duration of MR operation by finding start and end events
    ...                                in feedback log from MR operations history and saves it as txt file.
    ...                Input:          id = The MR Operation Group ID for which to fetch feedback.
    ...                                start_event_text = The text identifying the start event of the operation.
    ...                                end_event_text = The text identifying the end event of the operation.
    ...                                nms_lab_ip = The IP address of the NMS lab.
    ...                                output_file_path = path to save feedback from MR operation history
    ...                Output:         The duration between the start and end events as a Robot Framework time string.
    ...                Author:         damian.kotula@nokia.com
    [Arguments]    ${id}    ${start_event_text}    ${end_event_text}    ${nms_lab_ip}
    ...            ${output_file_path}=${TEST_RESULTS_DIR}/MR_feedback_operation_${id}.txt

    _Connect To NMS    nms_lab_ip=${nms_lab_ip}
    ${feedback}=    nms.Fetch Feedback    group_id=${id}
    Create File     ${output_file_path}    content=${feedback}
    ${start_timestamp}=    _Get Timestamp For Event   feedback_text=${feedback}
    ...                                               searched_text=${start_event_text}
    ${end_timestamp}=      _Get Timestamp For Event   feedback_text=${feedback}
    ...                                               searched_text=${end_event_text}
    Log    ${start_event_text} at: ${start_timestamp}
    Log    ${end_event_text} at: ${end_timestamp}
    ${start_timestamp}=    Convert Date    ${start_timestamp}    date_format=%m/%d/%y %I:%M:%S %p    result_format=datetime
    ${end_timestamp}=      Convert Date    ${end_timestamp}      date_format=%m/%d/%y %I:%M:%S %p    result_format=datetime
    ${operation_duration}=    DateTime.Subtract Date From Date    ${end_timestamp}    ${start_timestamp}
    [Return]    ${operation_duration}
    [Teardown]    nms.Delete Node    service_name=cmwas

Convert Operation Duration To Seconds
    [Documentation]    Description:    Converts operation duration from mixed format to seconds
    ...                Input:          operation_duration = operation duration in mixed format (e.g., 1h 2m 3s 4ms)
    ...                Output:         Operation duration in seconds represented as a number
    ...                Author:         karol.sadowski@nokia.com
    [Arguments]        ${operation_duration}
    ${time_in_seconds}=    Convert Time    ${operation_duration}
    [Return]    ${time_in_seconds}

################################################ Supplementary Keywords ################################################

_Get Timestamp For Event
    [Documentation]    Description:    Finds and returns the timestamp for a specific event within MR operation feedback.
    ...                Input:          feedback_text = The raw feedback string from an MR operation.
    ...                                searched_text = The text of the event description to search for.
    ...                Output:         The timestamp string associated with the found event
    ...                Author:         damian.kotula@nokia.com
    [Arguments]    ${feedback_text}    ${searched_text}

    ${parsed_events}=    _Parse Feedback Events To Dictionaries    ${feedback_text}
    FOR    ${event_dict}    IN    @{parsed_events}
        ${description}=    Get From Dictionary    ${event_dict}    description
        ${status}=    Run Keyword And Return Status    Should Contain    ${description}    ${searched_text}
        IF    ${status}
            ${timestamp}=    Get From Dictionary    ${event_dict}    timestamp
            RETURN    ${timestamp}
        END
    END
    Fail    Could not find timestamp for event: '${searched_text}'

_Parse Feedback Events To Dictionaries
    [Documentation]    Description:    Parses the 'Feedbacks' section of MR operation text into a list of dictionaries.
    ...                Input:          feedback_text = The raw feedback string from an MR operation.
    ...                Output:         A list of dictionaries, where each dictionary has `description` and `timestamp`
    ...                                keys for an event.
    ...                Author:         damian.kotula@nokia.com
    [Arguments]    ${feedback_text}

    @{feedback_section_matches}=    Get Regexp Matches    ${feedback_text}    (?s)Feedbacks\n(.*)    1
    ${num_matches}=    Get Length    @{feedback_section_matches}
    ${feedback_content}=    Set Variable    ${feedback_section_matches[0]}
    @{event_blocks}=    Split String    ${feedback_content}    \n\n
    ${parsed_events}=    Create List

    FOR    ${block}    IN    @{event_blocks}
        ${block}=    Strip String    ${block}
        ${length}=    Get Length    ${block}
        IF    ${length} == 0    CONTINUE
        @{lines}=    Split To Lines    ${block}
        ${num_lines}=    Get Length    ${lines}
        ${timestamp_info_line}=    Get From List    ${lines}    ${num_lines - 1}
        ${timestamp_parts}=    Split String    ${timestamp_info_line}    : Information    max_split=1
        ${timestamp}=    Set Variable    ${timestamp_parts[0].strip()}
        ${description_lines}=    Get Slice From List    ${lines}    0    ${num_lines - 1}
        ${description}=    Catenate    SEPARATOR=\n    @{description_lines}
        ${description}=    Strip String    ${description}
        ${event_dict}=    Create Dictionary    description=${description}    timestamp=${timestamp}
        Append To List    ${parsed_events}    ${event_dict}
    END
    [Return]    ${parsed_events}
