*** Settings ***
Documentation
...     Keywords Purpose:
...         Interface with PMParser
...
...     VERSION:
...         v1.1a       2018-12-20
...
...     AUTHOR (I&V-1):
...         Philippe Deroche     philippe.deroche@nokia.come

Library     BuiltIn
Library     String
Library     OperatingSystem
Library     ../python/discriminate_directory_file.py


*** Variables ***
${json_raw_data_filename}=    output_dict.json


*** Keywords ***
eCLATPMParser extract counters
    [Documentation]
    ...    Integrated invocation of PMParser
    ...    Takes 2 parameters: file, list of requested counters
    ...    Invokes PMParser on the file, creates 'output_dict.json' file
    ...    Need to read 'output_dict.json' file' and load it as json
    [Arguments]     ${file_or_directory}        ${list_of_counters}         ${tooldir}      ${add_options}=""

    #bypass robocop
    ${add_options}    set variable    ${add_options}

    ${result}=                      Run keyword     eCLATPMParser file or directory listofcounters      ${file_or_directory}    ${list_of_counters}
    ...                                                                                                 ${tooldir}
    Should Be Equal As Integers     ${result}       0
    # Detect whether a file or a directory and return proper path/filename
    ${path}=                        disc dir file   ${file_or_directory}
    # read the raw data
    ${json_raw_data}=               Join Path       ${path}                                             ${json_raw_data_filename}
    ${json_content}=                Get file        ${json_raw_data}
    # convert the data to a python object
    ${object}=                      Evaluate        json.loads('''${json_content}''')                   json
    [return]                        ${object}


eCLATPMParser extract counters2
    [Documentation]
    ...    Integrated invocation of PMParser
    ...    Takes 1 parameter: file
    ...    Invokes PMParser on the file, creates 'output_dict.json' file
    ...    Need to read 'output_dict.json' file' and load it as json
    [Arguments]     ${file_or_directory}        ${tooldir}          ${add_options}=""

    #bypass robocop
    ${add_options}    set variable    ${add_options}
    ${result}=                      Run keyword     eCLATPMParser file or directory2    ${file_or_directory}        ${tooldir}
    Should Be Equal As Integers     ${result}       0
    # Detect whether a file or a directory and return proper path/filename
    ${path}=                        disc dir file   ${file_or_directory}
    # read the raw data
    ${json_raw_data}=               Join Path       ${path}                             ${json_raw_data_filename}
    ${json_content}=                Get file        ${json_raw_data}
    # convert the data to a python object
    ${object}=                      Evaluate        json.loads('''${json_content}''')   json
    [return]                        ${object}


eCLATPMParser file or directory
    [Documentation]
    ...    Invocation of the tool with an explicit directory (option -p)
    ...    The output of the command is a CSV file (Result.csv) located in the -p directory
    [Arguments]        ${file_or_directory}         ${tooldir}
    ${result}=                      Run And Return Rc       python ${tooldir}/parsePMFiles.py -p ${file_or_directory}
    Log                             ${result}
    Run Keyword if                  ${result}==0            Express passed
    Run Keyword if                  ${result}!=0            Express failed
    Should Be Equal As Integers     ${result}               0
    [return]                        ${result}


eCLATPMParser file or directory2
    [Documentation]
    ...    Invocation of the tool with an explicit directory (option -p)
    ...    The output of the command is a CSV file (Result.csv) located in the -p directory
    [Arguments]        ${file_or_directory}         ${tooldir}
    ${result}=                      Run And Return Rc       python ${tooldir}/parsePMFiles.py -p ${file_or_directory}
    Log                             ${result}
    Run Keyword if                  ${result}==0            Express passed
    Run Keyword if                  ${result}!=0            Express failed
    Should Be Equal As Integers     ${result}               0
    [return]                        ${result}


eCLATPMParser file or directory listofcounters
    [Documentation]
    ...    Invocation of the tool with an explicit directory (option -p) and a limited list of counters
    ...    The output of the command is two CSV files (Result.csv, Result_partial.csv) located in the -p directory
    [Arguments]     ${filename}         ${list_of_counters}         ${tooldir}
    Log                             ${list_of_counters}
    Log                             ${filename}
    ${result}=                      Run And Return Rc       python ${tooldir}/parsePMFiles.py -p ${filename} -e ${list_of_counters}
    Should Be Equal As Integers     ${result}               0
    Run Keyword if                  ${result}==0            Express passed
    Run Keyword if                  ${result}!=0            Express failed
    [return]                        ${result}


Express passed
    Log         The log file is parse_logging.log and there is a CSV output file


Express failed
    Log         The log file is parse_logging.log and  there is no output CSV file


Directory Existing
    [Arguments]     ${somepath}
    return          ${somepath}


File Existing
    [Arguments]     ${somepath}
    # Extract dirname from filename
    ${ppath}        ${file} =           Split Path      ${somepath}
    [return]        ${file}
