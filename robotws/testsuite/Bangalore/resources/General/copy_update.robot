*** Settings ***
Documentation    Test to copy robot files from 5GET_BLR to T09 and update imports
Library          OperatingSystem
Library          Process
Library          Collections

*** Variables ***
${BLR_ROOT}    ${CURDIR}/../../RRM/5GET_BLR
@{ROBOT_FOLDERS}    CB007113

*** Test Cases ***
Copy Multiple Folders Example
    [Documentation]    Example: Copy N folders from 5GET_BLR to T09 with updated imports
    [Tags]    example    multi_folder_copy
    ${dest_dir}=    Set Variable    ${CURDIR}/../../RRM/T09
    @{SOURCES}=    Create List
    FOR    ${folder}    IN    @{ROBOT_FOLDERS}
        ${path}=    Set Variable    ${BLR_ROOT}/${folder}
        Append To List    ${SOURCES}    ${path}
    END
    Copy From 5GET To T09    ${dest_dir}    @{SOURCES}

*** Keywords ***
Copy From 5GET To T09
    [Documentation]    Copy one or more sources from 5GET_BLR to T09 and update imports
    [Arguments]    ${dest_dir}    @{sources}
    ${script_path}=    Set Variable    ${CURDIR}/copy_update.py
    File Should Exist    ${script_path}
    Create Directory    ${dest_dir}
    ${result}=    Run Process    python    ${script_path}    ${dest_dir}    @{sources}
    ...    shell=True    cwd=${CURDIR}/..
    Should Be Equal As Integers    ${result.rc}    0    Copy script failed: ${result.stderr}
    Log    Successfully copied sources to ${dest_dir}
