*** Settings ***
Documentation    common keywords to collect counters from given time and verify them


Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py   WITH NAME   wro4_pm
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/pagstra_pm_counters.py


*** Keywords ***
Collect Counters from Given Time
    [Arguments]   ${start_time}  ${stop_time}  ${pm_dict_name}  ${additional_dict_keys}=${None}
    Show Text on Console   [Counters collecting in progress... can take a while]
    ${pm_intervals_number}   wro4_pm.calculate_pm_intervals_number   ${start_time}   ${stop_time}

    Log   Get counters IDs from dictionary variable
    ${counters}   Get Dictionary Keys   ${${pm_dict_name}}
    ${counter_ids}   Create List
    FOR   ${ne_abbr}  IN   @{counters}
        Append To List  ${counter_ids}   ${${pm_dict_name}}[${ne_abbr}][PI_ID]
    END

    ${counter_values}   wro4_pm.get_sum_of_n_last_pm_counters_values
    ...                         ${counter_ids}
    ...                         n=${pm_intervals_number}
    ...                         additional_dict_keys=${additional_dict_keys}
    [Return]   ${counter_values}


Verification PM Counters
    [Arguments]   ${counter_values}  ${pm_dict_name}  ${nr_cells}=None
    ${counters}   Get Dictionary Keys   ${${pm_dict_name}}
    IF  ${nr_cells} == None
        ${nr_cells}   cell_utilities.get_cells_identifiers  identifier=globalCellId
    END
    Log To Console   \n PM Counters verified correctly:
    FOR  ${ne_abbr}  IN  @{counters}
        ${pi_id}   Set Variable   ${${pm_dict_name}}[${ne_abbr}][PI_ID]
        ${key}     Set Variable   ${${pm_dict_name}}[${ne_abbr}][key]

        IF  'percent_deviation' in ${${pm_dict_name}}[${ne_abbr}]
            ${percent_deviation}   Set Variable   ${${pm_dict_name}}[${ne_abbr}][percent_deviation]
        ELSE
            ${percent_deviation}   Set Variable   0
        END

        Run Keyword If   '${key}' == '${None}'
        ...     Verification Global Counters
        ...         ${pm_dict_name}
        ...         ${ne_abbr}
        ...         ${pi_id}
        ...         ${percent_deviation}
        ...         ${counter_values}
        Run Keyword If   '${key}' == 'NRCELL'
        ...     Verification Counters per NRCELL
        ...         ${pm_dict_name}
        ...         ${ne_abbr}
        ...         ${pi_id}
        ...         ${percent_deviation}
        ...         ${nr_cells}
        ...         ${counter_values}
    END


Verification Global Counters
    [Arguments]   ${pm_dict_name}  ${ne_abbr}  ${pi_id}  ${percent_deviation}  ${counter_values}

    ${expected_value}   Set Variable   ${${pm_dict_name}}[${ne_abbr}][value]
    ${measured_value}   Set Variable   ${counter_values}[${pi_id}]

    IF  ${percent_deviation} == 0
        Run Keyword And Continue On Failure   Run Keywords   Should Be Equal As Integers   ${expected_value}  ${measured_value}
        ...    \n ${ne_abbr} counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}   values=False
        ...   AND   Log To Console   ${SPACE} ${ne_abbr} counter value: ${measured_value}
    ELSE
        ${diff}   Calculate Difference   ${expected_value}  ${measured_value}
        Run Keyword And Continue On Failure   Run Keywords   Should Be True   ${diff} <= ${percent_deviation}
        ...    \n ${ne_abbr} counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}
        ...   AND   Log To Console   ${SPACE} ${ne_abbr} counter value: ${measured_value}, difference: ${diff}%
    END


Verification Counters per NRCELL
    [Arguments]   ${pm_dict_name}  ${ne_abbr}  ${pi_id}  ${percent_deviation}  ${nr_cells}  ${counter_values}

    FOR  ${cell}  IN  @{nr_cells}
        ${expected_value}   Set Variable   ${${pm_dict_name}}[${ne_abbr}][value][NRCELL-${cell}]
        ${measured_value}   Set Variable   ${counter_values}[${pi_id}][NRCELL-${cell}]
        ${msg_on_console}   Set Variable If   '${measured_value}' == '0'   False   True

        IF  ${percent_deviation} == 0
            Run Keyword And Continue On Failure   Run Keywords   Should Be Equal As Integers   ${expected_value}  ${measured_value}
            ...   \n ${ne_abbr} (NRCELL-${cell}) counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}  values=False
            ...   AND   Log   ${SPACE} ${ne_abbr} (NRCELL-${cell}) counter value: ${measured_value}   console=${msg_on_console}
        ELSE
            ${diff}   Calculate Difference   ${expected_value}  ${measured_value}
            Run Keyword And Continue On Failure   Run Keywords   Should Be True   ${diff} <= ${percent_deviation}
            ...   \n ${ne_abbr} (NRCELL-${cell}) counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}
            ...   AND
            ...   Log   ${SPACE} ${ne_abbr} (NRCELL-${cell}) counter value: ${measured_value}, difference: ${diff}%   console=${msg_on_console}
        END
    END


Calculate Difference
    [Arguments]   ${expected_value}  ${measured_value}
    IF  ${expected_value} == 0
        ${percent_diff}   Set Variable   0
    ELSE
        ${percent_diff}   Evaluate   abs((${expected_value} - ${measured_value}) / ${expected_value} * 100)
        ${percent_diff}   Evaluate   "%.2f" % ${percent_diff}
    END
    [Return]   ${percent_diff}
