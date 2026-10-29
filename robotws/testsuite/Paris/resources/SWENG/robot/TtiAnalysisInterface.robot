*** Settings ***
Documentation
...                  == Purpose ==
...                  This file contains the keywords to interfacte to the TTI analysis library written in python.
...
...                  == Description ==
...                  This library is used to analyze a TTI trace content from a JSON format file.
...                  It is an interface to a python lib available in python/TtiTrace SWENG folder.
...
...                  *Main keywords:*
...                      -    Create Tti Analyzer: This keyword is used to create the Tti Analyzer object
...                      -    Verify Distribution Table Of: This keyword is used to verify the distribution table of the data
...                      -    Check Target BLER Is Less Than Percentage With DF: This keyword is used to check if the target BLER is
...                                                                              less than the percentage
...                      -    Check Min Max Doesnt Exceed: This keyword is used to check if the min and max values of the data don't
...                                                        exceed the limits
...                      -    Check Min For Column: This keyword is used to check the min value of the column
...                      -    Check Max For Column: This keyword is used to check the max value of the column
...                      -    Get Columns With Same Values: This keyword is used to get the columns with the same values
...                      -    Get Columns With Long Names: This keyword is used to get the columns with long names
...                      -    Check Unique Value For Column: This keyword is used to check the unique value for a given column
...                      -    Get Column Values: This keyword is used to get the values of the given column
...                      -    Get First Column Value: This keyword is used to get the first value of the given column
...                      -    Get Columns Names Containing Substring: This keyword is used to get the list of columns names containing
...                                                                   the given substring
...                      -    Check Multi Columns Values: This keyword is used to check the multi columns values given as a dictionary
...                      -    Check Value Inrange For Column: This keyword is used to check all the values are in the range for the given
...                                                           column
...                      -    Check Value Inrange For Column Dict: This keyword is used to check all the values are in the range for the
...                                                                given columns
...                      -    Get Dict From Dataframe Column: This keyword is used to get the dictionary from a given dataframe column
...                      -    Get List From Dataframe Column: This keyword is used to get the list from a given dataframe column
...                      -    Get List Of Dict From Dataframe Column: This keyword is used to get the list of dictionaries
...                                                                   from a given dataframe column
...                      -    Get First Dict Value From Dataframe Column: This keyword is used to get the first dictionary
...                                                                       value from a given dataframe column
...                      -    Get First List Value From Dataframe Column: This keyword is used to get the first list value
...                                                                       from a given dataframe column
...                      -    Get First List Of Dict Value From Dataframe Column: This keyword is used to get the first list of
...                                                                               dictionary values from a given dataframe
...                                                                               column
...                      -    Export Current Dataframe To CSV: This keyword is used to export the current dataframe to a CSV file
...                      -    Export Specific Parameters To CSV and Dataframe: This keyword is used to export a set of specific parameters
...                                                                            and generic parameters to a dataframe and a CSV file. Filters
...                                                                            are used to select the rows to export.
...
...
...                  == Usage ==
...                  The Tti Analyzer object is created using the Create Tti Analyzer keyword
...                  the KW getting information are usuful to analyze the data content and quality
...                  The data content is checked by the KWs like:
...                     -    Check Min Max Doesnt Exceed,
...                     -    Check Min For Column,
...                     -    Check Max For Column,
...                     and others
...
...
...                  == Example ==
...                  | Create Tti Analyzer | ${path_to_json} | ${list_events}=None |
...                  | Verify Distribution Table Of | ${column_name} | ${plot}=None | ${validate}=None | ${need_return}=False |
...                  | Check Target BLER Is Less Than Percentage With DF | ${filtered_df} | ${txNumber_event} | ${laMode_event_value} | ${tolerance}
...                  | ${threshold}=1 |
...                  | Check Min Max Doesnt Exceed | ${column_name} |
...                  | Check Min For Column | ${column} |
...                  | Check Max For Column | ${column} |
...                  | Get Columns With Same Values |
...                  | Get Columns With Long Names |
...                  | Check Unique Value For Column | ${column} |
...                  | Get Column Values | ${column} |
...                  | Export Current Dataframe To CSV | ${path_to_csv} |
...                  | Export Specific Parameters To CSV and Dataframe | ${path_to_csv} | ${parameters} | ${common_parameters_filter}
...                                                                    | ${specific_parameters_filter} |
...
...
...                  Some files robotframework and in python are given as examples in
...                        examples folder
...                        and python/Examples folder
...

Library            ../python/TtiTrace/TtiAnalysis.py


*** Keywords ***

Create Tti Analyzer
    [Documentation]    This keyword used to create the Tti Analyzer object. A JSON file containing a TTI trace is mandatory for the KW.
    ...                This file can be generated by converting a pcap capture file using the TtiConvert library.
    ...                The Tti Analyzer object is used to analyze the TTI data.
    [Arguments]    ${path_to_json}    ${list_events}
    ${my_instance} =    Make myClass    ${path_to_json}    ${list_events}
    [Return]    ${my_instance}

Verify Distribution Table Of
    [Documentation]    This keyword is used to verify the distribution table of the TTI data.
    ...                The distribution table is used to check the distribution of the data. A graph included in an HTML page is generated.
    [Arguments]    ${column_name}    ${plot}=None    ${validate}=None    ${need_return}=False
    ${result_df} =    TtiAnalysis.Verify Distribution Table Of    ${column_name}    ${plot}    ${validate}    ${need_return}
    [Return]    ${result_df}

Check Target BLER Is Less Than Percentage With DF
    [Documentation]    This keyword is used to check if the target BLER is less than a given percentage.
    ...                The target BLER is used to check the BLER of the data.
    [Arguments]    ${filtered_df}    ${txNumber_event}    ${laMode_event_value}    ${tolerance}    ${threshold}=1
    ${result} =    TtiAnalysis.Check Target BLER Is Less Than Percentage With DF    ${filtered_df}    ${txNumber_event}    ${laMode_event_value}
    ...            ${tolerance}    ${threshold}
    [Return]    ${result}

Check Min Max Doesnt Exceed
    [Documentation]    This keyword is used to check if the min and max values of the data don't exceed the limits.
    [Arguments]    ${column_name}
    ${result} =    TtiAnalysis.Check Min Max Doesnt Exceed    ${column_name}
    [Return]    ${result}

Check Min For Column
    [Documentation]    This keyword is used to check the min value of the column.
    [Arguments]    ${column}
    ${result} =    TtiAnalysis.Check Min For Column    ${column}
    [Return]    ${result}

Check Max For Column
    [Documentation]    This keyword is used to check the max value of the column.
    [Arguments]    ${column}
    ${result} =    TtiAnalysis.Check Max For Column    ${column}
    [Return]    ${result}

Get Columns With Same Values
    [Documentation]    This keyword is used to get the columns with the same values for every row.
    [Arguments]
    ${result_list} =    TtiAnalysis.Get Columns With Same Values
    [Return]    ${result_list}

Get Columns With Long Names
    [Documentation]    This keyword is used to get the columns with long names. This means containing two points or more as separators.
    [Arguments]
    ${result_list} =    TtiAnalysis.Get Columns With Long Names
    [Return]    ${result_list}

Check Unique Value For Column
    [Documentation]    This keyword is used to check the unique value for a given column.
    ...                Get Columns With Same Values keyword can be used to list all the columns having a unique value.
    ...                This can be a complement to this KW.
    [Arguments]    ${column}
    ${has_unique_value}    ${value} =    TtiAnalysis.Check Unique Value For Column    ${column}
    [Return]    ${has_unique_value}    ${value}

Get Column Values
    [Documentation]    This keyword is used to get the values of the given column.
    [Arguments]    ${column}
    ${values_list} =    TtiAnalysis.Get Column Values    ${column}
    [Return]    ${values_list}

Get First Column Value
    [Documentation]    This keyword is used to get the first value of the given column.
    [Arguments]    ${column}
    ${result} =    TtiAnalysis.Get First Column Value    ${column}
    [Return]    ${result}

Get Columns Names Containing Substring
    [Documentation]    This keyword is used to get the list of columns names containing the given substring.
    [Arguments]    ${col_substring}
    ${column_list} =    TtiAnalysis.Get Columns Names Containing Substring    ${col_substring}
    [Return]    ${column_list}

Check Substrings In Columns
    [Documentation]    This keyword is used to check the substrings in the columns.
    ...                The substrings are given as a list.
    ...                The keyword returns a dictionary with substrings as keys and lists of columns containing the substring as values.
    [Arguments]    ${substrings}
    ${substr_dict} =    TtiAnalysis.Check Substrings In Columns   ${substrings}
    [Return]    ${substr_dict}

Check Multi Columns Values
    [Documentation]    This keyword is used to check the multi columns values given as a dictionary.
    ...                The dictionary contains the column name as the key and the value as the value.
    ...                The keyword checks if the given values are present in the columns.
    [Arguments]    ${column_value_dict}
    ${result} =    TtiAnalysis.Check Multi Columns Values    ${column_value_dict}
    [Return]    ${result}

Check Value Inrange For Column
    [Documentation]    This keyword is used to check all the values are in the range for the given column.
    [Arguments]    ${column}    ${range}
    ${result} =    TtiAnalysis.Check Value Inrange For Column    ${column}    ${range}
    [Return]    ${result}

Check Value Inrange For Column Dict
    [Documentation]    This keyword is used to check all the values are in the range for the given columns.
    ...                The columns and the ranges are given as a dictionary.
    [Arguments]    ${column_range_dict}
    ${result} =    TtiAnalysis.Check Value Inrange For Column Dict   ${column_range_dict}
    [Return]    ${result}

Get Dict From Dataframe Column
    [Documentation]    This keyword is used to get the dictionary from a given dataframe column.
    ...                The column should contain data in the form of a dictionary.
    [Arguments]   ${column}
    ${dict_values}    ${size} =    TtiAnalysis.Get Dict From Dataframe Column    ${column}
    [Return]    ${dict_values}    ${size}

Get List From Dataframe Column
    [Documentation]    This keyword is used to get the list from a given dataframe column.
    ...                The column should contain data in the form of a list.
    [Arguments]    ${column}
    ${value_list}     ${size} =    TtiAnalysis.Get List From Dataframe Column    ${column}
    [Return]    ${value_list}    ${size}

Get List Of Dict From Dataframe Column
    [Documentation]    This keyword is used to get the list of dictionaries from a given dataframe column.
    ...                The column should contain data in the form of a list of dictionaries.
    [Arguments]    ${column}
    ${dict_list}     ${size} =    TtiAnalysis.Get List Of Dict From Dataframe Column    ${column}
    [Return]    ${dict_list}    ${size}

Get First Dict Value From Dataframe Column
    [Documentation]     This keyword is used to get the first dictionary value from a given dataframe column.
    ...                 The column should contain data in the form of a dictionary or None.
    ...                 None is transformed to an empty string when assigned to result.
    [Arguments]    ${column}
    ${result} =    TtiAnalysis.Get First Dict Value From Dataframe Column    ${column}
    [Return]    ${result}

Get First List Value From Dataframe Column
    [Documentation]     This keyword is used to get the first list value from a given dataframe column.
    ...                 The column should contain data in the form of a list or None.
    ...                 None is transformed to an empty string when assigned to result.
    [Arguments]    ${column}
    ${result} =    TtiAnalysis.Get First List Value From Dataframe Column    ${column}
    [Return]    ${result}

Get First List Of Dict Value From Dataframe Column
    [Documentation]     This keyword is used to get the first list of dictionary value from a given dataframe column.
    ...                 The column should contain data in the form of a list of dictionaries.
    ...                 The keyword returns a dataframe with the first list of dictionary values or None.
    ...                 None is transformed to an empty string when assigned to resulting_dataframe.
    [Arguments]    ${column}
    ${resulting_dataframe} =    TtiAnalysis.Get First List Of Dict Value From Dataframe Column    ${column}
    [Return]    ${resulting_dataframe}

Export Current Dataframe To CSV
    [Documentation]    This keyword is used to export the current dataframe
    ...                to a CSV file. The CSV file is saved in the same
    ...                folder as the JSON file.
    ...                use_floats is a boolean to indicate if the floats
    ...                values instead of integers should be used or not
    ...                in resulting dataframe and csv.
    [Arguments]        ${path_to_csv}    ${use_floats}=False    ${path_to_json}=None
    TtiAnalysis.Export Dataframe To Csv    ${path_to_csv}    ${use_floats}
    ...    ${path_to_json}

Export Specific Parameters To CSV and Dataframe
    [Documentation]    This keyword is used to export the specific parameters
    ...                to a dataframe. The CSV file is saved in the same
    ...                folder as the origin JSON file. Export specific
    ...                parameters of one or more events:
    ...                manage a dynamic list of the concerned parameters
    ...                [event_name_1.param_1, event_name_2.param_x, etc.]
    ...                into a dataframe and related CSV file, but in such a
    ...                way that the parameters are when possible correlated
    ...                with each other based on common parameters values.
    ...                use_floats is a boolean to indicate if the floats
    ...                values instead of integers should be used or not
    ...                in resulting dataframe and csv.
    ...
    ...        Example:
    ...            | *** Variables ***
    ...            | ${path_to_json} \ \ \ \ \ \ \ \ /tmp/TTI_A05_3_Traffic.json
    ...            | ${path_to_csv2} \ \ \ \ \ \ \ \ /tmp/TTI_export.csv
    ...            | @{parameters2} \ \ \ \ \ \ \ \ \ timeStamp    sfn    slot    rnti    physCellId     dlFdSchedData.numOfPrb
    ...            | &{common_parameters_filter} \ \ \ \ slot=[1, 2, 3, 4, 5, 6]        rnti=[65521, 21187]
    ...            | &{specific_parameters_filter} \ \ ulPuschReceiveRespPsData.rxPower=[0, -73.4786, -73.4931, -73.4836]
    ...            | &{specific_parameters_filter3} \ \ ulPuschReceiveRespPsData.rxPower={'rnti': [27126]}
    ...            | &{specific_parameters_filter3} \  \ None
    ...            |
    ...            | *** Test Cases ***
    ...            | Test Export Specific Parameters To CSV and Dataframe 2
    ...            | [Tags]\ \ \ \ DEBUG
    ...            | Set Global Variable\ \ \ \ ${path_to_json}
    ...            | Set Global Variable\ \ \ \ ${path_to_csv2}
    ...            | Log \ \ \ \ Exporting specific parameters to CSV and Dataframe
    ...            | TtiAnalysisInterface.Export Specific Parameters To CSV and Dataframe \ \ \ \ ${path_to_csv2} \ \ \ \ {parameters2}
    ...            | ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ${common_parameters_filter} \ \ \ \ ${specific_parameters_filter2}
    ...            | ${file_exists} \ \ \ \ Run Keyword And Return Status \ \ \ \ File Should Exist \ \ \ \ ${path_to_csv2}
    ...            | Should Be True \ \ \ \ {file_exists} \ \ \ \ msg=File does not exist
    ...
    [Arguments]        ${path_to_csv}    ${parameters}
    ...    ${common_parameters_filter}    ${specific_parameters_filter}
    ...    ${use_floats}=False    ${path_to_json}=None
    TtiAnalysis.Export Specific Parameters    ${path_to_csv}    ${parameters}
    ...    ${common_parameters_filter}    ${specific_parameters_filter}
    ...    ${use_floats}    ${path_to_json}
