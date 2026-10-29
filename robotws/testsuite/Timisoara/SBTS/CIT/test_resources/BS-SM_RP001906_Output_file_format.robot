*** Settings ***
Documentation
    ...  Feature RP001906 SFP data availability via BTS CLI
    ...  ${\n}Purpose of this test is to verify that SFP data files created via CLI has right format.
    ...  ${\n}Available Output file formats ('compact' or 'human')

Resource  ../../common_resources/ca_CIT_general.robot


*** Keywords ***
TC__BS-SM RP001906 SFP Data Availability Via BTS CLI
    [Documentation]
    ...  [CASE LINK] https://jira3.int.net.nokia.com/browse/TAT-15957
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 31.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-15957 - Initial creation
    ...  - 26.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19486 - doubled json in one file correction, compact format
    ...  - 25.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19774 - deleting cli script before test
    ...  - 07.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20722 - increase number of retries for CLI setup
    ...  - 11.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21025 - btsauto directory creation
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  ${\n}image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-15957.png
    ...  *******************

    Set Tags  CA-BS-SM  OWNER-grzegorz.gulaj@nokia.com  AUTHOR-grzegorz.gulaj@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CRT  SW-SBTS19  FEATURE-RP001906

    Precondition
    Step 1: Check Human Output Format
    Step 2: Check Compact Output Format


Precondition
    [Documentation]  Check if CLI feature is enabled if not enable it

    Check If Admin CLI Feature Check Is Enabled  True


Step 1: Check Human Output Format
    [Documentation]  Check if output file from CLI is human readable

    ${sw_path_split}  Split String  ${ACTIVE_SW_VERSION}  _
    Run  mkdir /home/ute/btsauto
    ${admin_cli_directory}  OperatingSystem.List Directories In Directory  /home/ute/btsauto  *${sw_path_split}[-2]_${sw_path_split}[-1]_ADMIN_CLI
    Run Keyword If  ${admin_cli_directory}
    ...  Run  sudo rm -r /home/ute/btsauto/${admin_cli_directory}[0]
    Wait Until Keyword Succeeds  5x  15s
    ...  Setup Admin CLI For "human" Format
    ${cli_output}  Get SFP Data From CLI
    ${cli_output}  Last Root JSON Part  ${cli_output}
    Verify Human Format  ${cli_output}


Step 2: Check Compact Output Format
    [Documentation]  Check if output file from CLI is compact

    ${sw_path_split}  Split String  ${ACTIVE_SW_VERSION}  _
    ${admin_cli_directory}  OperatingSystem.List Directories In Directory  /home/ute/btsauto  *${sw_path_split}[-2]_${sw_path_split}[-1]_ADMIN_CLI
    Run Keyword If  ${admin_cli_directory}
    ...  Run  sudo rm -r /home/ute/btsauto/${admin_cli_directory}[0]
    Wait Until Keyword Succeeds  5x  15s
    ...  Setup Admin CLI For "compact" Format
    ${cli_output}  Get SFP Data From CLI
    ${cli_output}  Last Root JSON Part  ${cli_output}
    Verify Compact Format  ${cli_output}


Setup Admin CLI For "${fmt}" Format
    [Documentation]
    ...  Setup Admin CLI
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+--------+--------------------------------------------------+
    ...  | Input Parameters | Man.   | Description                                      |
    ...  +====================+========+================================================+
    ...  | fmt              | Yes    | format  supported values: human, compact         |
    ...  +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...  Setup Admin CLI For "human" Format

    Log  Setup ${fmt} format  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  output_format=${fmt}


Get SFP Data From CLI
    [Documentation]
    ...  Prepare SFP Data via CLI and return content of output file
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+--------+--------------------------------------------------+
    ...  | Input Parameters | Man.   | Description                                      |
    ...  +====================+========+================================================+
    ...  | cli_file_content | Yes    |  string content of CLI file response             |
    ...  +------------------+--------+--------------------------------------------------+
    ...  +------------------+--------+--------------------------------------------------+
    ...  | Output           | Description                                               |
    ...  +====================+========+================================================+
    ...  | cli_file_content | string content of CLI file response                       |
    ...  +------------------+--------+--------------------------------------------------+
    ...   **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...  ${cli_file_content}  Get SFP Data From CLI

    ${cli_message}  Set Variable  { "requestId": 1, "parameters": {"name": "sfpData"}}
    Send Admin CLI Request  ${cli_message}  output_json=${TEST_FILES}/cli_test.txt
    ${cli_file_content}  OperatingSystem.Get File  ${TEST_FILES}/cli_test.txt
    Verify Cli Response Error  ${cli_file_content}

    [Return]  ${cli_file_content}


Verify Compact Format
    [Documentation]
    ...  Check if output file is right compact format which not contain unnecessary spaces/end line characters, and is easier for the parsing
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+--------+--------------------------------------------------+
    ...  | Input Parameters | Man.   | Description                                      |
    ...  +====================+========+================================================+
    ...  | cli_file_content | Yes    |  string content of CLI file response             |
    ...  +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...  Verify Compact Format  ${cli_file_content}
    [Arguments]  ${string}

    Log  ${\n}Admin CLI output file content in compact format:  console=true
    Log  =================Start of human compact content===================  console=true
    Log  ${string}  console=true
    Log  =================End of compact format content===================  console=true
    ${num_of_lines}  Get Line Count  ${string}
    Should Be True  ${num_of_lines}=1  CLI file result in compact format must be one line
    ${num_of_spaces}  Evaluate  str.count("""${string}""", ' ')  string
    Should Be True  ${num_of_spaces}<${NUMBER_OF_SPACES_IN_HUMAN_FORMAT}  Too many spaces in compact format


Verify Human Format
    [Documentation]
    ...  Check if output file is right human readable format
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+--------+--------------------------------------------------+
    ...  | Input Parameters | Man.   | Description                                      |
    ...  +====================+========+================================================+
    ...  | cli_file_content | Yes    |  string content of CLI file response             |
    ...  +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...  Verify Human Format  ${cli_file_content}
    [Arguments]  ${string}

    Log  ${\n}Admin CLI output file content in human format:  console=true
    Log  =================Start of human format content===================  console=true
    Log  ${string}  console=true
    Log  =================End of human format content===================  console=true
    ${num_of_lines}  Get Line Count  ${string}
    Should Be True  ${num_of_lines}>1  CLI file result in human format must be multiline
    ${num_of_spaces}  Evaluate  str.count("""${string}""", ' ')  string
    Set Test Variable  ${NUMBER_OF_SPACES_IN_HUMAN_FORMAT}  ${num_of_spaces}
    @{lines}  Split To Lines  ${string}
    FOR  ${index}  ${line}  IN ENUMERATE  @{lines[:-1]}
        Check Indents  ${line}  ${lines}[${index+1}]  ${index+1}
    END


Calculate Indent Length Of Line ${line}
    [Documentation]
    ...  Calculate indent length of line
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------+--------+--------------------------------------------------+
    ...  | Input Parameters | Man.   | Description                                      |
    ...  +====================+========+================================================+
    ...  | line             | Yes    |   line                                           |
    ...  +------------------+--------+--------------------------------------------------+
    ...  +------------------+--------+--------------------------------------------------+
    ...  | Output             | Description                                             |
    ...  +====================+========+================================================+
    ...  | line_indent_length | amount leading spaces in line                           |
    ...  +------------------+--------+--------------------------------------------------+
    ...   **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...  ${num_of_leading_spaces_in_line}  calculate indent length of line ${line}

    ${line_length}  Get Length  ${line}
    ${cropped_line}  Strip String  ${line}  mode=left
    ${cropped_line_length}  Get Length  ${cropped_line}
    ${line_indent_length}  Evaluate  ${line_length}-${cropped_line_length}

    [Return]  ${line_indent_length}


Check Indents
    [Documentation]
    ...  Check indent after line with character at end of line
    ...  Rules if last character is:
    ...   - opening curly bracket - next line has indent longer than first line
    ...   - closing curly bracket - next line has indent shorter than first line
    ...   - opening square bracket - next line has indent longer than first line
    ...   - closing square bracket - next line has indent shorter than first line
    ...   - comma - next line has indent equal first line
    ...   - none of the above - next line has indent shorter than first line
    ...  **Input Parameters:**
    ...
    ...  +------------------+--------+--------------------------------------------------+
    ...  | Input Parameters | Man.   | Description                                      |
    ...  +====================+========+================================================+
    ...  | line1            | Yes    |  line from analized text                         |
    ...  +------------------+--------+--------------------------------------------------+
    ...  | line2            | Yes    |  next line from analized text                    |
    ...  +------------------+--------+--------------------------------------------------+
    ...  | line_number      | Yes    |  index of line1 (position in text)               |
    ...  +------------------+--------+--------------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...  check indents  ${line1}  ${line2}  ${line1_number}
    [Arguments]  ${line1}  ${line2}  ${line_number}

    # calculate indent lengths
    ${first_line_indent_length}  Calculate Indent Length Of Line ${line1}
    ${second_line_indent_length}  Calculate Indent Length Of Line ${line2}
    # check indents
    ${is_opening_curly_bracket}  Run Keyword And Return Status
    ...  Should End With  ${line1}  {
    Run Keyword If  ${is_opening_curly_bracket}
    ...  Should Be True  ${first_line_indent_length}<${second_line_indent_length}
    ...  Wrong indent after opening curly bracket, line number:${line_number}

    ${is_closing_curly_bracket}  Run Keyword And Return Status
    ...  Should End With  ${line1}  }
    Run Keyword If  ${is_closing_curly_bracket}
    ...  Should Be True  ${first_line_indent_length}>${second_line_indent_length}
    ...  Wrong indent after closing curly bracket, line number:${line_number}

    ${is_opening_square_bracket}  Run Keyword And Return Status
    ...  Should End With  ${line1}  [
    Run Keyword If  ${is_opening_square_bracket}
    ...  Should Be True  ${first_line_indent_length}<${second_line_indent_length}
    ...  Wrong indent after opening square bracket, line number:${line_number}

    ${is_closing_square_bracket}  Run Keyword And Return Status
    ...  Should End With  ${line1}  ]
    Run Keyword If  ${is_closing_square_bracket}
    ...  Should Be True  ${first_line_indent_length}>${second_line_indent_length}
    ...  Wrong indent after closing square bracket, line number:${line_number}

    ${is_comma}  Run Keyword And Return Status
    ...  Should End With  ${line1}  ,
    Run Keyword If  ${is_comma}
    ...  Should Be True  ${first_line_indent_length}=${second_line_indent_length}
    ...  Wrong indent after comma, line number:${line_number}

#  ${pattern}  Regexp Escape  {},[]
#  ${is_other_char}  Run Keyword And Return Status  Should Match Regexp  ${line1}  [^${pattern}]$
#  Run Keyword If  ${is_other_char}  Should Be True  ${first_line_indent_length}>${second_line_indent_length}
#  ...  Wrong indent, line number:${line_number} ${first_line_indent_length}>${second_line_indent_length}line1:${line1} line2:${line2}


TC Setup
    Common Test Setup  alarms_check=${FALSE}  cells_check=${FALSE}  modules_check=${FALSE}


TC Teardown
    Common Test Teardown
