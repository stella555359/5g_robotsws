*** Settings ***
Documentation
...            Keywords for collecting and analyzing PM counters
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library    OperatingSystem
Library    ta5g_pm_counters
Library    testsuite.Ulm.Handover.Krakow.RRM.RAN_L3_SW2.KRK3.resources.krk3_common.Python.CounterAnalyzer.CounterAnalyzer  WITH NAME  CounterAnalyzer


*** Keywords ***
Get PM Counter Values from XML File
    [Documentation]    Returns a list PM counter values from XML file specified by counter ID and object ID.
    ...                - ``filepath``: Path to XML file with counters
    ...                - ``counter_id``: Counter ID
    ...                - ``mo_id``: Object ID
    ...                Example:
    ...                | Get PM Counter Values from XML File | filepath=counters.xml | counter_id=M55335C03001 |
    ...                |    | mo_id=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 |
    [Arguments]    ${filepath}    ${counter_id}    ${mo_id}
    File Should Exist    ${filepath}
    ${values}    ta5g_pm_counters.get_pm_counter_value
    ...    counter=${counter_id}    localmoid=${mo_id}    filepath=${filepath}
    Should Not Be Empty    ${values}
    ...    msg=PM Counter ${counter_id} does not exist in ${filepath}
    RETURN    ${values}

Verify PM Counters Are Nonzero
    [Documentation]    Verifies if PM counters are larger than zero.
    ...                KW expects counters as dictionaries with ``id``, ``name`` and ``mo_id`` fields.
    ...                Additional fields will be ignored. Continues execution even if verification fails.
    ...                - ``filepath``: Path to XML file with counters
    ...                - ``counters``: List of counter dictionaries with ``id``, ``name`` and ``mo_id`` fields
    ...                Example:
    ...                | ***** Variables ***** |
    ...                | $\{MO_ID\} | PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 |
    ...                | &\{CNT_1\} | id=M55335C03001 | name=UL_GRANT_AL1_CBWP1 | mo_id=$\{MO_ID\} |
    ...                | &\{CNT_2\} | id=M55335C03002 | name=UL_GRANT_AL2_CBWP1 | mo_id=$\{MO_ID\} |
    ...                | @\{COUNTERS\} | &\{CNT_1\} | &\{CNT_2\} |
    ...                | ***** Test Cases ***** |
    ...                | Example_test |
    ...                |  | Verify PM Counters Are Nonzero | filepath=counters.xml | counters=$\{COUNTERS\} |
    [Arguments]    ${filepath}    ${counters}
    File Should Exist    ${filepath}
    Log to Console    Verifying that PM Counters are nonzero
    FOR    ${counter}    IN     @{counters}
      ${out_values}    ta5g_pm_counters.get_pm_counter_value
      ...    counter=${counter.id}    localmoid=${counter.mo_id}    filepath=${filepath}
      Run Keyword And Continue On Failure    Should Not Be Empty    ${out_values}
      ...    msg=PM Counter ${counter.name} (${counter.id}) does not exist in ${filepath} under ${counter.mo_id}
      IF    not ${out_values} == []
      ...    Run Keyword And Continue On Failure
      ...    Should Be True    ${out_values}.count(0) == 0
      ...    msg=PM Counter ${counter.name} (${counter.id}) value is zero
    END

Verify PM Counters Have Exact Values
    [Documentation]    Verifies if PM counters have exactly specified values.
    ...                KW expects counters as dictionaries with ``id``, ``name``, ``mo_id`` and ``value`` fields.
    ...                Additional fields will be ignored. Continues execution even if verification fails.
    ...                - ``filepath``: Path to XML file with counters
    ...                - ``counters``: List of counter dictionaries with ``id``, ``name``, ``mo_id`` and ``value`` fields
    ...                Example:
    ...                | ***** Variables ***** |
    ...                | $\{MO_ID\} | PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 |
    ...                | &\{CNT_1\} | id=M55335C03001 | name=UL_GRANT_AL1_CBWP1 | mo_id=$\{MO_ID\} | value=2500 |
    ...                | &\{CNT_2\} | id=M55335C03002 | name=UL_GRANT_AL2_CBWP1 | mo_id=$\{MO_ID\} | value=3000 |
    ...                | @\{COUNTERS\} | &\{CNT_1\} | &\{CNT_2\} |
    ...                | ***** Test Cases ***** |
    ...                | Example_test |
    ...                |  | Verify PM Counters Have Exact Values | filepath=counters.xml | counters=$\{COUNTERS\} |
    [Arguments]    ${filepath}    ${counters}
    File Should Exist    ${filepath}
    Log to Console    Verifying that PM Counters have exact values
    FOR    ${counter}    IN     @{counters}
      ${out_values}    ta5g_pm_counters.get_pm_counter_value
      ...    counter=${counter.id}    localmoid=${counter.mo_id}    filepath=${filepath}
      Run Keyword And Continue On Failure    Should Not Be Empty    ${out_values}
      ...    msg=PM Counter ${counter.name} (${counter.id}) does not exist in ${filepath} under ${counter.mo_id}
      IF    not ${out_values} == []
      ...    Run Keyword And Continue On Failure
      ...    Should Be True    ${out_values}[0] == int(${counter.value})
      ...    msg=PM Counter ${counter.name} (${counter.id}) value: ${out_values}[0] is not expected ${counter.value}
    END

Verify PM Counters Are In Range
    [Documentation]    Verifies if PM counters are within specified range including edge values.
    ...                KW expects counters as dictionaries with ``id``, ``name``, ``mo_id``, ``low`` and ``high`` fields.
    ...                ``low`` and ``high`` fields determine the lower and upper bound of range.
    ...                Additional fields will be ignored. Continues execution even if verification fails.
    ...                - ``filepath``: Path to XML file with counters
    ...                - ``counters``: List of counter dictionaries with ``id``, ``name``, ``mo_id``,\
    ...                 ``low`` and ``high`` fields
    ...                Example:
    ...                | ***** Variables ***** |
    ...                | $\{MO_ID\} | PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 |
    ...                | &\{CNT_1\} | id=M55335C03001 | name=UL_GRANT_AL1_CBWP1 | mo_id=$\{MO_ID\} | low=100 | high=300 |
    ...                | &\{CNT_2\} | id=M55335C03002 | name=UL_GRANT_AL2_CBWP1 | mo_id=$\{MO_ID\} | low=200 | high=500 |
    ...                | @\{COUNTERS\} | &\{CNT_1\} | &\{CNT_2\} |
    ...                | ***** Test Cases ***** |
    ...                | Example_test |
    ...                |  | Verify PM Counters Are In Range | filepath=counters.xml | counters=$\{COUNTERS\} |
    [Arguments]    ${filepath}    ${counters}
    File Should Exist    ${filepath}
    Log to Console    Verifying that PM Counters are in range
    FOR    ${counter}    IN     @{counters}
      ${msgp}    Set Variable    PM Counter ${counter.name} (${counter.id})
      ${out_values}    ta5g_pm_counters.get_pm_counter_value
      ...    counter=${counter.id}    localmoid=${counter.mo_id}    filepath=${filepath}
      Run Keyword And Continue On Failure    Should Not Be Empty    ${out_values}
      ...    msg=${msgp} does not exist in ${filepath} under ${counter.mo_id}
      IF    not ${out_values} == []
      ...    Run Keyword And Continue On Failure
      ...    Should Be True    int(${counter.low}) <= ${out_values}[0] <= int(${counter.high})
      ...    msg=${msgp} value: ${out_values}[0] is not within expected range ${counter.low}-${counter.high}
    END

Perform Pm Counters Verification With Expected Values
    [Documentation]    Keyword used to perform counters verification
    ...                - ``expected_yaml``: Yaml file with the structure of pm counters to be checked
    ...                - ``pm_file``:  Pm counters xml filepath
    [Arguments]    ${expected_yaml}    ${pm_file}    &{kwargs}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${expected_yaml}    msg=Invalid KW parameter: expected_yaml
    #---------------------------------------------------------------------------------------------------------------
    CounterAnalyzer.perform_pm_counters_verification
    ...    ${expected_yaml}    ${pm_file}    &{kwargs}
