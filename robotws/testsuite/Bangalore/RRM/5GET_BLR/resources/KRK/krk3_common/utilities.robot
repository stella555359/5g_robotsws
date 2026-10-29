*** Settings ***
Library    OperatingSystem
Library    Process
Library    String
Library    json

*** Keywords ***
Remove Non-printable Characters And Tab From File
    [Arguments]       ${file_path}
    Run Process     sed  -i  \'s/[^[:print:]\\t]//g\'  ${file_path}    shell=True

Unzip File
    [Documentation]    Unzips a file with ``unzip`` program and returns result object.
    ...                - ``file_path``: Path to ZIP file
    ...                - ``dest_dir``: Destination directory, Default: Same as ZIP file
    ...                - ``remove_zip``: Removes zip file after extraction, Default: no
    ...                - ``params``: Extra unzip parameters
    [Arguments]    @{params}    ${file_path}    ${dest_dir}=.    ${remove_zip}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${file_path}
    Should Be True    '${remove_zip}' in ('yes','no')    msg=Invalid KW parameter: remove_zip
    #---------------------------------------------------------------------------------------------------------------
    Log to Console    Unzipping file: ${file_path}
    ${result}    Run Process And Expect Success     unzip    -d    ${dest_dir}    @{params}    ${file_path}
    ...    msg=Error unziping file: ${file_path}
    Run Keyword If    '${remove_zip}' == 'yes'    Remove File    ${file_path}
    [Return]    ${result}

Find Files
    [Documentation]    Searches for files in directory hierarchy via ``find`` command and returns a list of files.
    ...                WARNING: Do not pass unquoted wildcards into search patterns (Use: ``-name '*.json'``, not: ``-name *.json``).
    ...                Use single-quotes only.
    ...                - ``dir``: Directory to search in
    ...                - ``params``: List of search parameters for ``find`` command, See: https://manpages.org/find
    ...                - ``fail_on_empty``: If keyword should fail when no files are found, Default: no
    ...                - ``return``: Type of return data: list or dict, Default: list
    [Arguments]    ${dir}    @{params}    ${fail_on_empty}=no    ${return}=list
    #--------- Param check -----------------------------------------------------------------------------------------
    Directory Should Exist    ${dir}
    Should Be True    '${fail_on_empty}' in ('yes','no')    msg=Invalid KW parameter: fail_on_empty
    Should Be True    '${return}' in ('list','dict')    msg=Invalid KW parameter: return
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Create List    find    ${dir}    -type    f    @{params}
    ${result}    Run Process And Expect Success    @{cmd}
    ${list}    Split To Lines    ${result.stdout}
    Run Keyword If    '${fail_on_empty}' == 'yes'    Should Not Be Empty    ${list}
    ...    msg=No files were found using command: @{cmd}
    ${dict}    Create Dictionary
    FOR    ${path}    IN    @{list}
      ${dir}    ${filename}    Split Path    ${path}
      ${name}    ${ext}    Split Extension    ${filename}
      Set To Dictionary    ${dict}    ${name}=${path}
    END
    ${files}    Set Variable If    '${return}' == 'dict'    ${dict}    ${list}
    [Return]    ${files}

Run Process And Expect Success
    [Documentation]    Runs a process and fails if return status is not 0. Returns result object.
    ...                - ``process``: Process name
    ...                - ``params``: Process parameters as list
    ...                - ``shell``: Specifies whether to run the command in shell, Default: True
    ...                - ``msg``: Custom fail message, Default: Standard message
    ...                - ``config``: Additonal process configuration,\
    ...                See: https://robotframework.org/robotframework/3.1.2/libraries/Process.html#Process%20configuration
    [Arguments]    ${process}    @{params}    ${shell}=${True}    ${msg}=${Empty}    &{config}
    ${result}    Run Process    ${process}    @{params}    shell=${shell}    &{config}
    Log    stdout: ${result.stdout}${\n}stderr: ${result.stderr}${\n}rc: ${result.rc}    level=DEBUG
    ${mlen}    Get Length    ${msg}
    ${msg}    Set Variable If    ${mlen} == 0    Error running ${process} @{params}    ${msg}
    ${msg}    Set Variable    ${msg}${\n}stdout: ${result.stdout}${\n}stderr: ${result.stderr}
    Should Be Equal As Integers    ${result.rc}    0    values=${False}    msg=${msg}
    [Return]    ${result}

Wait Until Process Succeeds
    [Documentation]    Runs a process in a loop and and waits for status 0. Returns result object.
    ...                - ``process``: Process name
    ...                - ``params``: Process parameters as list
    ...                - ``msg``: Custom fail message, Default: Standard message
    ...                - ``timeout``: Timeout for success, Default: 10s
    ...                - ``config``: Additonal process configuration,\
    ...                See: https://robotframework.org/robotframework/3.1.2/libraries/Process.html#Process%20configuration
    [Arguments]    ${process}    @{params}    ${timeout}=10s    ${msg}=${Empty}    &{config}
    ${handle}    Start Process    until    ${process}    @{params}    ;    do    sleep    1    ;    done
    ...    shell=${True}    &{config}
    ${result}    Wait For Process    handle=${handle}    timeout=${timeout}    on_timeout=terminate
    ${mlen}    Get Length    ${msg}
    ${msg}    Set Variable If    ${mlen} == 0    Timeout (${timeout}) running ${process} @{params}    ${msg}
    ${msg}    Set Variable    ${msg}${\n}stdout: ${result.stdout}${\n}stderr: ${result.stderr}
    Should Be Equal As Integers    ${result.rc}    0    values=${False}    msg=${msg}
    [Return]    ${result}

Check Available Memory on VM
   [Documentation]    Checks and logs available memory in Mebibytes on VM.
   ...                - ``warn_t``: Threshold for warning message, Default: 0 (No warning)
   [Arguments]    ${warn_t}=0
   ${result}    Run Process And Expect Success    free    -m    |    grep    Mem
   ${values}    Split String    ${result.stdout}
   ${total}    ${aval}    Set Variable    ${values}[1]    ${values}[-1]
   Log to Console    Available memory on VM: ${aval} MiB of out ${total} MiB
   Run Keyword If    ${warn_t} > 0 and ${aval} < ${warn_t}
   ...    Log    Available memory on VM below required threshold: ${aval} MiB < ${warn_t} MiB    level=WARN

Get JSON File Content
    [Documentation]    Reads a JSON file and returns its content as structured data.
    ...                - ``filepath``: Path to input file
    [Arguments]    ${filepath}
    ${string}    Get File    ${filepath}
    ${data}    json.loads    ${string}
    [Return]    ${data}

Save Data as JSON File
    [Documentation]    Saves structured data as JSON file.
    ...                - ``data``: Structured input data
    ...                - ``filepath``: Path to output file
    ...                - ``indent``: Number of spaces to use to indent file as INT, Default: 2
    [Arguments]    ${data}    ${filepath}    ${indent}=${2}
    ${string}    json.dumps    ${data}    indent=${indent}
    Create File    ${filepath}    ${string}

Convert Traffic Strings to Unit
    [Documentation]    Converts a list of strings with traffic values into numbers in specified unit.
    ...                - ``strings``: Unpacked list of strings
    ...                - ``output_unit``: Unit of output numbers: bps / kbps / mbps
    ...                Example:
    ...                | $\{val1\} | $\{val2\} | Convert Traffic Strings to Unit | 10.0 Mbps | 5.0 Mbps | output_unit=kbps |
    [Arguments]    @{strings}    ${output_unit}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${output_unit}' in ('bps','kbps','mbps')    msg=Invalid KW parameter: output_unit
    #---------------------------------------------------------------------------------------------------------------
    ${converted}    Create List
    ${input_mp}    Create Dictionary    bps=1    Kbps=1000    Mbps=1000000
    ${output_mp}    Create Dictionary    bps=1    kbps=0.001    mbps=0.000001
    FOR    ${string}    IN    @{strings}
      ${match}    ${value}    ${unit}    Run Keyword If    '${string}' == '0'    Create List    zero    0    bps
      ...    ELSE    Should Match Regexp    ${string}    (\\d+.\\d)\\s+([MK]?bps)
      ${output}    Evaluate    ${value} * ${input_mp}[${unit}] * ${output_mp}[${output_unit}]
      Append To List    ${converted}    ${output}
    END
    [Return]    ${converted}
