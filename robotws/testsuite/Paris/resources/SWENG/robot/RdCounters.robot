*** Settings ***
Documentation
...            == Purpose ==
...            Keywords used for retrieving and for managing RD counters
...
...            == Description ==
...            *Concepts:*.
...
...            RD counters are basic measures on a network object produced by OAM and regularly pushed in PM files.
...            For each branch (TRUNK or other), a counter file is set in SWENG/config/KPI/<Branch> directory.
...
...            *Services:*.
...
...            Main services are :
...            | Collect And Check RD Counters   | To collect RD counters and check if theirs values are equal to the ones provided as parameters |
...            | Collect RD Counters             | To collect RD counters from a GNB and store them in a local directory                          |
...            | Verify RD Counters              | To check the counters provided as parameter against the extracted counters                     |
...            | Check RD Counter Value          | To check that the value of a counter in the last reporting period is equal to a given value    |
...            | Get RD Counter Value            | To get the value of a counter in the last reporting period                                     |
...
...            *Usage:*.
...
...            Typical sequence to use these services is as follows:
...              Collect And Check RD Counters    cell_id=${CELL_ID}
...              ...                               expected_counters=${EXPECTED_COUNTERS}
...              ...                               gnb=${GNB}
...
...            *Example:*.
...
...            | Collect And Check RD Counters |  cell_id=1 | expected_counters=${EXPECTED_COUNTERS} | gnb=${GNB} |
...


Library           BuiltIn
Library           String

Library           taf.analyzer.pmcounter       WITH NAME    check_pm

Resource          Tools.robot
Resource          Connect.robot


*** Keywords ***

Collect And Check RD Counters
    [Documentation]
    ...                              Get RD counters and check if theirs values are equal to the ones provided as parameters
    ...
    ...                              *Argument details:*
    ...                              - *cell_id*: the cell to be used for checking
    ...                              - *expected_counters*: the dictionary containing expected counter IDs and associated values
    ...                              - *gnb*: the GNB where to search for RD counters data (by default = GNB_DU)

    [Arguments]                       ${cell_id}
    ...                               ${expected_counters}
    ...                               ${gnb}=${GNB_DU}

    ${rd_counters_dir}                Collect RD Counters    gnb=${gnb}

    Verify RD Counters                counters_dir=${rd_counters_dir}
    ...                               expected_counters=${expected_counters}
    ...                               cell_id=${cell_id}


Collect RD Counters
    [Documentation]                   INTERNAL USAGE
    ...                               Get the XML file containing the counters data from GNB
    ...                               Return the path of the local dir where the XML file is stored
    ...
    ...                              *Argument details:*
    ...                              - *gnb*: the GNB where to search for RD counters data (by default = GNB_DU)

    [Arguments]                       ${gnb}=${GNB_DU}

    ${gnb_host}                       Set Variable    ${gnb.entryCard[0]}
    ${local_counters_dir}             Set Variable    ${LOG_PATH}/gnb_rd_counters
    ${counters_xml_filename}          Set Variable    RD.BTS_counters.xml
    ${local_counters_xml_file}        Set Variable    ${local_counters_dir}/${counters_xml_filename}
    Create directory                  ${local_counters_dir}
    ${connection}                     SSH Wait For Connect    ${gnb_host}

    # get the zip file containing the counters from the GNB
    # (in case there are several zip files found, take the most recent)
    ${output}                         SSH Cmd    ls -1t /tmp/RD.BTS-1*.gz | head -1    alias=${connection}
    ${remote_counters_zip_file}       getStringFromCmdReturn    ${output}
    Dated Log                         remote_counters_zip_file=${remote_counters_zip_file}

    # uncompres the zip file into the XML file
    ${remote_counters_xml_file}       Set Variable    /tmp/${counters_xml_filename}
    ${cmd}                            Set Variable    gunzip -c ${remote_counters_zip_file} > ${remote_counters_xml_file}
    ${output}                         SSH Cmd    ${cmd}    alias=${connection}

    # copy the XML file to the local dir
    ${output}                         SSH Download File    host=${gnb_host}
    ...                                                    remotePath=${remote_counters_xml_file}
    ...                                                    localPath=${local_counters_xml_file}

    BuiltIn.Log                       The RD counters file collected from GNB is : ${local_counters_xml_file}

    [Return]                          ${local_counters_dir}


Verify RD Counters
    [Documentation]                   Check the counters provided as parameter against the counters extracted from
    ...                               files stored under a given directory
    ...
    ...                               *Argument details:*
    ...                               - *counters_dir*: directory where to find XML files containing counters data
    ...                               - *expected_counters*: dictionary providing the expected list of counters names
    ...                                 and associated values
    ...                               - *cell_id*: the cell ID to be used for verification

    [Arguments]                       ${counters_dir}
    ...                               ${expected_counters}
    ...                               ${cell_id}

    FOR    ${counter_name}    IN    @{expected_counters.keys()}
        ${counter_value}    Set Variable    ${expected_counters["${counter_name}"]}
        Dated Log           Checking RD counter [${counter_name}]
        Check RD Counter Value    ${counters_dir}    ${counter_name}    ${counter_value}    NRBTS-1/NRCELL-${cell_id}
    END


Verify RD Counters With Criteria
    [Documentation]                   Check the counters provided as parameter against the counters extracted from
    ...                               files stored under a given directory
    ...
    ...                               *Argument details:*
    ...                               - *counters_dir*: directory where to find XML files containing counters data
    ...                               - *expected_counters*: dictionary providing the expected list of counters names
    ...                                 and associated values
    ...                               - *cell_id*: the cell ID to be used for verification
    ...                               - *comparison*: could be '>=' '>' '<=' '<' '=='

    [Arguments]                       ${counters_dir}
    ...                               ${expected_counters}
    ...                               ${cell_id}
    ...                               ${comparison}
    ${FailFound}=    Set Variable    0
    FOR    ${counter_name}    IN    @{expected_counters.keys()}
        ${counter_value}    Set Variable    ${expected_counters["${counter_name}"]}
        Dated Log           Checking RD counter [${counter_name}]
        ${cell_dn_id}    Set Variable    NRBTS-1/NRCELL-${cell_id}
        ${ret}   Check RD Counter Value With Criteria    ${counters_dir}    ${counter_name}    ${counter_value}   ${cell_dn_id}   ${comparison}
        ${FailFound}=      Run Keyword if      ${ret}==${False}        Evaluate     ${FailFound} + 1
        ...                 ELSE             Evaluate       ${FailFound} + 0
    END
    ${retKW}=       Run Keyword if      ${FailFound}>0        Set Variable   ${False}
    ...             ELSE        Set Variable   ${True}
    Run Keyword if      ${retKW}==${False}       FAIL    All values do not match the criteria
    [Return]    ${retKW}


Check RD Counter Value With Criteria
    [Documentation]
    ...                               Checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...                               *Argument details:*
    ...                               - *counters_dir*: directory where to find XML files containing counters data
    ...                               - *counters_name*: name of the counter to be checked
    ...                               - *expected_value*: the exepected value  of the counter
    ...                               - *moc*: the Managed Object Class containing the counter e.g. NRCELL-1
    ...                                 It is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    ...                               - *comparison*: could be '>=' '>' '<=' '<' '=='

    [Arguments]                       ${counters_dir}
    ...                               ${counter_name}
    ...                               ${expected_value}
    ...                               ${moc}
    ...                               ${comparison}
    ${counter_value}                  Get RD Counter Value    ${counters_dir}    ${counter_name}    ${moc}

    ${ret}    Set Variable    ${False}
    ${ret}  Compare with Value  		${comparison}    ${expected_value}     ${counter_value}
    Dated Log           Check RD counter ${counter_name} value=${counter_value} expected=${expected_value}
    Dated Log        \t ===> Check RD counter ${counter_name} value=${counter_value} expected=${expected_value} comp=${comparison} result=${ret}
    [Return]    ${ret}


Compare with Value
    [Documentation]   INTERNAL USAGE
    [Arguments]    ${comparison}    ${expected_val}     ${val}
    ${compare_result}=    Set Variable    ${False}
    ${iVal}=    evaluate      ${val}
    ${iExpected}=    evaluate      ${expected_val}
    ${compare_result1}=   Evaluate     ${iVal} >= ${iExpected}
    ${compare_result2}=   Evaluate     ${iVal} > ${iExpected}
    ${compare_result3}=   Evaluate     ${iVal} <= ${iExpected}
    ${compare_result4}=   Evaluate     ${iVal} < ${iExpected}
    ${compare_result5}=   Evaluate     ${iVal} == ${iExpected}
    ${compare_result}=      Run Keyword if      ${comparison}=='>='
    ...                         Set Variable    ${compare_result1}
    ...                     ELSE IF        ${comparison}=='>'
    ...                         Set Variable    ${compare_result2}
    ...                     ELSE IF        ${comparison}=='<='
    ...                         Set Variable    ${compare_result3}
    ...                     ELSE IF        ${comparison}=='<'
    ...                         Set Variable    ${compare_result4}
    ...                     ELSE IF        ${comparison}=='=='
    ...                         Set Variable    ${compare_result5}
    ...                     ELSE
    ...                         Set Variable    ${False}
    [Return]    ${compare_result}


Check RD Counter Value
    [Documentation]
    ...                               Checks that the value of a counter in the last reporting period is equal to a given value
    ...
    ...                               *Argument details:*
    ...                               - *counters_dir*: directory where to find XML files containing counters data
    ...                               - *counters_name*: name of the counter to be checked
    ...                               - *expected_value*: the exepected value  of the counter
    ...                               - *moc*: the Managed Object Class containing the counter e.g. NRCELL-1
    ...                                 It is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1

    [Arguments]                       ${counters_dir}
    ...                               ${counter_name}
    ...                               ${expected_value}
    ...                               ${moc}

    ${counter_value}                  Get RD Counter Value    ${counters_dir}    ${counter_name}    ${moc}
    ${counter_value}                  Convert To Integer    ${counter_value}
    ${expected_value}                 Convert to Integer    ${expected_value}
    Run Keyword if   '${counter_value}'>'${expected_value}'
    ...        Dated Log    RD counter ${counter_name} is OK (${counter_value} > ${expected_value})
    ...    ELSE
    ...        Dated Log    RD counter ${counter_name} is NOK (${counter_value} <= ${expected_value})


Get RD Counter Value
    [Documentation]
    ...                               Use XML files stored under a given directory to get the value of a counter in the
    ...                               last reporting period
    ...
    ...                               *Argument details:*
    ...                               - *counters_dir*: directory where to find XML files containing counters data
    ...                               - *counters_name*: name of the counter to be checked
    ...                               - *moc*: the Managed Object Class containing the counter e.g. NRCELL-1
    ...                                 It is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1

    [Arguments]    ${counters_dir}   ${counter_name}    ${moc}

    ${counter_list}                   Create List    ${counter_name}
    ${PM_report_dict_list}            check_pm.get_pi_value
    ...                                   pi_list=${counter_list}
    ...                                   pi_dir=${counters_dir}
    ...                                   pi_file_pattern=RD.BTS*
    ${last_report}                    Get From List    ${PM_report_dict_list}    -1
    ${counter_dict}                   Get Dictionary Values    ${last_report}
    ${first_counter}                  Get From List    ${counter_dict}    0
    ${cell_dict_list}                 Get Dictionary Values    ${first_counter}
    ${cell_dict}                      Get From List    ${cell_dict_list}    0
    ${moc_list}                       Get Dictionary Keys    ${cell_dict}
    ${full_moc}                       Set Variable    ${EMPTY}
    FOR  ${key}  IN   @{moc_list}
        ${key_is_moc}    Run Keyword And Return Status    Should Contain    ${key}    ${moc}
        ${full_moc}      Set Variable If    ${key_is_moc}    ${key}    ${full_moc}
    END
    ${counter_value}                  Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log                       Value of counter ${counter_name} = ${counter_value}
    [Return]                          ${counter_value}

