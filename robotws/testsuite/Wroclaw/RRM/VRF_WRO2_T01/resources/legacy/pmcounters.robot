*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com

Library  taf.collectors.pmcounters  WITH NAME   pm
Library  taf.analyzer.pmcounter
Library  testsuite/Wroclaw/RRM/resources/rrm_fixture.py
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pmcounters.py
Library  OperatingSystem


*** Keywords ***
Collect counters
    &{webservice}=   Create dictionary
    ...                 host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                 user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                 password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                 port=443
    pm.Create PM collector   name=collector   webservice=&{webservice}   oam_type=sbts
    pm.setup collectors      names=collector
    pm.collect collectors    names=collector
    pm.teardown collectors    names=collector

Get last counter values
    [Documentation]  This keyword returns dictionary with the structure given below:
    ...              { counter_id : { cell_id : counter_value }}
    ...              counter_id ->  in example   M55316C05001
    ...              cell_id    ->  global cell id, typically  1 or 2 and so on
    ...              counter_value -> in example  0
    [Arguments]   @{counter_ids}
    ${counters_count}=  Get Length  ${counter_ids}
    ${pi_dict}=  get_pi_value
    ...  pi_list=@{counter_ids}
    ...  pi_dir=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/collector
    ...  pi_file_pattern=PM*
    ${value_dict}=  Get latest counters values   ${pi_dict}
    Log   Returned counter values dict: ${value_dict}
    [Return]  ${value_dict}

Cleanup all downloaded counter files
    ${dir_name}=  set variable   ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/collector
    Remove Directory   ${dir_name}   ${TRUE}


Get Counter Path For Release
    [Documentation]
    ...    ${release} - soft version given in format `SBTS24R1`
    ...    ${path_if_higher} - counter path returned if installed soft version is higher than ${release}
    ...    ${path_if_lower} - counter path returned if installed soft version is lower than ${release}
    ...
    ...    Keyword returns counter path proper to the installed soft

    [Arguments]
    ...    ${release}
    ...    ${path_if_higher}
    ...    ${path_if_lower}

    ${is_higher}    Check Release Is Higher Than    ${release}

    Run Keyword If  ${is_higher}
    ...  Set Test Variable  ${counter_path}  ${path_if_higher}
    ...  ELSE
    ...  Set Test Variable  ${counter_path}  ${path_if_lower}

    [Return]  ${counter_path}


Get Counters Value
    [Documentation]
    ...    Keyword adapted from 2673 - created by Mati.
    ...    Keyword gets given counters values and returnes summed value from all cells

    [Arguments]
    ...    ${counters}

    @{counters_value}  Create List
    Log to console  Featching counters values from WebEm
    Collect counters
    FOR  ${counter}  IN  @{counters}
        ${var_name}  Catenate  SEPARATOR=_  ${counter}  value
        ${value}  Get counter value summation from all cells  ${counter}
        Set Test Variable  ${${var_name}}  ${value}
        Append To List  ${counters_value}  ${${var_name}}
    END

    [Return]  ${counters_value}


Get Counter Value Summation From All Cells
    [Documentation]
    ...    Keyword adapted from 2673 - created by Mati.
    ...    Keyword gets sum of given counter from all cells

    [Arguments]
    ...    ${counter}

    ${counter_value}        Get last counter values  ${counter}
    ${val_on_cells}         Get from dictionary      ${counter_value}  ${counter}
    ${sum_from _all_cells}  Evaluate  int(0)
    FOR  ${id}  IN  @{val_on_cells}
        ${sum_from _all_cells}  Evaluate  ${sum_from _all_cells}+int(${val_on_cells['${id}']})
    END

    [Return]  ${sum_from _all_cells}


Check If Counters Values Equal Zero
    [Documentation]
    ...    Keyword adapted from 2673 - created by Mati.
    ...    Keyword checks if given counters values equal to zero

    [Arguments]
    ...    ${vals}
    ...    ${names}

    ${length}  Get length  ${names}
    FOR  ${counter}  IN RANGE  ${length}
        Should be true  ${vals[${counter}]} == int(0)  msg=${names[${counter}]} != 0
        Log to console  ${names[${counter}]} = 0
    END
    Log to console  Initial counters values OK
