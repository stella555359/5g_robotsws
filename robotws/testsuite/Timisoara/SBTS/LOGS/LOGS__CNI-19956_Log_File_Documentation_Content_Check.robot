*** Settings ***
Documentation  Test for CNI-19956
Library    OperatingSystem
Library    String
Library    Collections
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/unpacking.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_general.robot



*** Keywords ***
TC__LOGS__CNI-19956_Log_File_Documentation_Content_Check.robot
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-11193
    ...  ******************
    ...  Author: Lukasz Targonski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2018-08-06 - https://jira3.int.net.nokia.com/browse/TAT-11193 - Initial creation
    ...  - 2020-04-11 - https://jira3.ext.net.nokia.com/browse/TAT-19935 - add: Download <SW>_snapshot_documentation.tgz file
    ...  - 2021-08-12 - https://jira3.ext.net.nokia.com/browse/TAT-21731 - remove obsolete tag [[]@9. Customer Sensitive Data[]]
    ...  - 2021-12-17 - https://jira3.ext.net.nokia.com/browse/TAT-22366 - cosmetic changes to improve execution in TA/CRT
    ...  - 2023-03-24 - https://jiradc.ext.net.nokia.com/browse/TAT-25033 - update new link for download the <SW>_snapshot_documentation.tgz file
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax, changed 'in range' operator to all caps to prevent warn
    ...  - 05.03.2023 - TAT-27038 - remove option "encoding_errors=ignore" due to the req. OAM_REQ_TEST_300
    ...
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if all log documentation files have all mandatory sections (tags).
    ...  All tags are specified in {tag_list} variable. Template documentation file is located here:
    ...  https://bts.inside.nokiasiemensnetworks.com/twiki/pub/Main/TechLogFileDescriptionTemplate/template.txt
    ...  *******************
    ...  Test case flowchart:
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__CNI-19956_Log_Files_Documentation_Content_Check.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com    PHASE-CR2    SW-SBTS18

    Step 1: Extract Documentation
    Step 2: Check Logs Documentation Files


Step 1: Extract Documentation
     [Documentation]
    ...  In this test step snapshot documentation tgz archive from DOCUMENTATION_PATH, containing trbl.csv and log files documentation, is extracted

    Log    \n Get Active Sw Version  console=${true}
    Set Test Variable  ${DOCUMENTATION_PATH}  ${BTS Files}/snapshot_documentation
    ${SW}  coam.Get Sw Version
    Log    Active Sw Version: ${SW}  console=${true}
    @{SW_splited}    Split String    ${SW}    _
    ${BRANCH}=    Remove String Using Regexp  ${SW_splited[0]}  SBTS
    ${SW_00}=    Replace String Using Regexp  ${SW}  ${BRANCH}  00
    OperatingSystem.Run  mkdir -p ${DOCUMENTATION_PATH}
    Log  Download <SW>_snapshot_documentation.tgz file  console=${true}
    ${file_ute_path}  Set Variable  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
    Run Keyword If  ${SW_splited[2]}==9999
    ...        OperatingSystem.Run  cd ${DOCUMENTATION_PATH} ; wget ${file_ute_path}/SBTS00/${SW_00}/${SW_00}_snapshot_documentation.tgz
    ...  ELSE  OperatingSystem.Run  cd ${DOCUMENTATION_PATH} ; wget ${file_ute_path}/SBTS${BRANCH}/${SW}/${SW}_snapshot_documentation.tgz
    Sleep  30

    Log  Step 1: Extract snapshot documentation  console=yes
    ${files_in_directory}  OperatingSystem.List Files In Directory  ${DOCUMENTATION_PATH}
    ${files_in_directory_length}  Get Length  ${files_in_directory}
    FOR  ${i}  IN RANGE  0  ${files_in_directory_length}
        ${documentation_file_name}  Run Keyword And Ignore Error  Should Match Regexp  ${files_in_directory[${i}]}  .*snapshot_documentation.tgz
        Run Keyword If  '${documentation_file_name[0]}'=='PASS'  Exit For Loop
    END
    Run Keyword If  '${documentation_file_name[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Documentation file .*snapshot_documentation.tgz is not present under ${DOCUMENTATION_PATH} directory.

    unpacking.Unpack Archive Content To Directory  ${DOCUMENTATION_PATH}/${documentation_file_name[1]}  ${DOCUMENTATION_PATH}/extracted

    ${files_in_directory}  OperatingSystem.List Files In Directory  ${DOCUMENTATION_PATH}/extracted
    ${files_in_directory_length}  Get Length  ${files_in_directory}

    FOR  ${i}  IN RANGE  0  ${files_in_directory_length}
        ${trbl_file_name}  Run Keyword And Ignore Error  Should Match Regexp  ${files_in_directory[${i}]}  .*trbl_log_list.csv
        Run Keyword If  '${trbl_file_name[0]}'=='PASS'  Exit For Loop
    END
    Run Keyword If  '${trbl_file_name[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Documentation file .*trbl_log_list.csv is not present under ${DOCUMENTATION_PATH}/extracted directory.

    #TAT-27038 remove option "encoding_errors=ignore" due to the req. OAM_REQ_TEST_300
    ${trbl}  OperatingSystem.Get File  ${DOCUMENTATION_PATH}/extracted/${trbl_file_name[1]}
    Set Test Variable  ${trbl}


Step 2: Check Logs Documentation Files
    [Documentation]
    ...  In this test step each line from trbl.csv is analyzed.
    ...  It is checked firstly if analyzed line is correct (there should be 15 separators ';')
    ...  if analyzed line is correct, it is checked if the documentation file exists
    ...  after that, the content of documentation file is checked. All mandatory tags from {tag_list} varaible must be present
    Log  Step 2: Check if documentation files are present  console=yes
    @{lines_from_trbl}  Split To Lines  ${trbl}
    Remove From List  ${lines_from_trbl}  0
    FOR  ${line}  IN  @{lines_from_trbl}
        @{values}  Split String  ${line}  ;
        ${trbl_dictionary}  Create Trbl Dictionary  @{values}
        ${trbl_dictionary_length}  Get Length  ${trbl_dictionary}
        Run Keyword If  ${trbl_dictionary_length}>0  Check Documentation File Availability  ${trbl_dictionary}
    END

Create Trbl Dictionary
    [arguments]  @{values}
    ${values_length}  Get Length  ${values}
    ${trbl_dictionary}  Create Dictionary
    Run Keyword If  ${values_length}==15  Run Keywords
    ...  Set To Dictionary  ${trbl_dictionary}  SCM assembly info  ${values[0]}
    ...  AND  Set To Dictionary  ${trbl_dictionary}  comment  ${values[10]}
    ...  ELSE  Log  Incorrect line in trbl: ${values}  WARN  console=yes

    [return]  ${trbl_dictionary}

Check Documentation File Availability
    [arguments]  ${trbl_dictionary}
    ${log_documentation_path}  Get From Dictionary  ${trbl_dictionary}  SCM assembly info
    ${log_documentation_name}  Get From Dictionary  ${trbl_dictionary}  comment
    ${file_exist}  Run Keyword And Ignore Error  OperatingSystem.File Should Exist
    ...  ${DOCUMENTATION_PATH}/extracted/${log_documentation_path}/${log_documentation_name}
    Run Keyword If  '${file_exist[0]}'=='FAIL'
    ...  verdicts.Set Test Failed  Documentation file ${log_documentation_name} is not present under ${log_documentation_path} directory.
    ...  ELSE  Check Documentation File Content  ${log_documentation_path}  ${log_documentation_name}

Check Documentation File Content
    [arguments]  ${log_documentation_path}  ${log_documentation_name}
    ${tag_list}  Create List  [[]@1. Key information in the file[]]  [[]@2. Format of the data[]]
    ...  [[]@3. Log file properties[]]  [[]@4. Creation prerequisites[]]  [[]@5. RAD param/config tag content dependency[]]
    ...  [[]@6. Existing external links describing the file[]]  [[]@7. Primarily used for investigating cases/incidents[]]
    ...  [[]@8. May contain information helpful in cases/incidents[]]

    FOR  ${tag}  IN  @{tag_list}
        ${documentation_content}  OperatingSystem.Get File
        ...  ${DOCUMENTATION_PATH}/extracted/${log_documentation_path}/${log_documentation_name}  encoding_errors=ignore
        ${grep}  OperatingSystem.Grep File
        ...  ${DOCUMENTATION_PATH}/extracted/${log_documentation_path}/${log_documentation_name}  ${tag}  encoding_errors=ignore
        Run Keyword If  '${grep}'==''
        ...  verdicts.Set Test Failed  No ${tag} tag in documentation file ${log_documentation_path}/${log_documentation_name}.
    END

TC Setup
    Common Test Setup  modules_check=${False}   syslog_launch=${False}    cells_check=${False}    alarms_check=${False}  scf_check=${False}

TC Teardown
    Run Keywords
    ...    OperatingSystem.Run  rm -rf ${DOCUMENTATION_PATH}/extracted
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown    collect_snapshot=never


