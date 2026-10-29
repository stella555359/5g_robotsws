*** Settings ***
Documentation    Unpacking Lib

*** Keywords ***
Get File Extension
    [Documentation]
    ...  Returns the extension of the given file.
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${file}
    ${extension}    Fetch From Right  ${file}    .
    [Return]    ${extension}

Unpack Archive Content To Directory
    [Documentation]
    ...  Unpacks the given file to the specified destination directory, based on its file extension.
    ...  example of simple use:  Unpack Archive Content To Directory   ${file}  ${destination_directory}
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${file}    ${destination}
    ${extension}=    Get File Extension    ${file}
    Run Keyword If    '${extension}' == 'zip'    _Unzip To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'tar'    _Untar To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'tgz'    _Untgz To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'gz'    _Ungz To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'xz'    _Unxz To Directory    ${file}    ${destination}

_Unzip To Directory
    [Documentation]
    ...  Unpacks the given .zip file to the specified destination directory.
    ...  If directory does not exist it will be created
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${zip_file}    ${destination_dir}
    OperatingSystem.File Should Exist   ${zip_file}    msg=File ${zip_file} doesn't exist!
    ${state}    Run Keyword and return status    OperatingSystem.Directory Should Exist    ${destination_dir}
    Run Keyword if    ${state}==False    Run Keyword    Run    mkdir -p ${destination_dir}
    Run    unzip -o ${zip_file} -d ${destination_dir}
    ${state2}    Run Keyword and return status    OperatingSystem.Directory Should Not Be Empty    ${destination_dir}
    Run Keyword if    ${state2}==False    Log    Extract directory is empty    WARN
    #TAT-26884:
    Append To List    ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}    ${destination_dir}

_Untar To Directory
    [Documentation]
    ...  Unpacks the given .tar file to the specified destination directory.
    ...  If directory does not exist it will be created
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${tar_file}    ${destination_dir}
    OperatingSystem.File Should Exist   ${tar_file}    msg=File ${tar_file} doesn't exist!
    ${state}    Run Keyword and return status    OperatingSystem.Directory Should Exist    ${destination_dir}
    Run Keyword if    ${state}==False    Run Keyword    Run    mkdir -p ${destination_dir}
    Run    tar -oxf ${tar_file} -C ${destination_dir}
    ${state2}    Run Keyword and return status    OperatingSystem.Directory Should Not Be Empty    ${destination_dir}
    Run Keyword if    ${state2}==False    Log    Extract directory is empty    WARN
    #TAT-26884:
    Append To List    ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}    ${destination_dir}

_Untgz To Directory
    [Documentation]
    ...  Unpacks the given .tgz file to the specified destination directory.
    ...  If directory does not exist it will be created
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${tgz_file}    ${destination_dir}
    OperatingSystem.File Should Exist   ${tgz_file}    msg=File ${tgz_file} doesn't exist!
    ${state}    Run Keyword and return status    OperatingSystem.Directory Should Exist    ${destination_dir}
    Run Keyword if    ${state}==False    Run Keyword    Run    mkdir -p ${destination_dir}
    Run    tar -oxzf ${tgz_file} -C ${destination_dir}
    ${state2}    Run Keyword and return status    OperatingSystem.Directory Should Not Be Empty    ${destination_dir}
    Run Keyword if    ${state2}==False    Log    Extract directory is empty    WARN
    #TAT-26884:
    Append To List    ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}    ${destination_dir}

_Ungz To Directory
    [Documentation]
    ...  Unpacks the given .gz file to the specified destination directory.
    ...  If directory does not exist it will be created
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${gz_file}    ${destination_dir}
    OperatingSystem.File Should Exist   ${gz_file}    msg=File ${gz_file} doesn't exist!
    ${state}    Run Keyword and return status    OperatingSystem.Directory Should Exist    ${destination_dir}
    Run Keyword if    ${state}==False    Run Keyword    Run    mkdir -p ${destination_dir}
    Run    gunzip -f ${gz_file} -c > ${destination_dir}/`basename ${gz_file} .gz`
    ${state2}    Run Keyword and return status    OperatingSystem.Directory Should Not Be Empty    ${destination_dir}
    Run Keyword if    ${state2}==False    Log    Extract directory is empty    WARN
    #TAT-26884:
    Append To List    ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}    ${destination_dir}

_Unxz To Directory
    [Documentation]
    ...  Unpacks the given .xz file to the specified destination directory.
    ...  If directory does not exist it will be created
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${xz_file}    ${destination_dir}
    OperatingSystem.File Should Exist  ${xz_file}    msg=File ${xz_file} doesn't exist!
    ${state}    Run Keyword and return status    OperatingSystem.Directory Should Exist    ${destination_dir}
    Run Keyword if    ${state}==False    Run Keyword    Run    mkdir -p ${destination_dir}
    Run    xz -d ${xz_file} -c > ${destination_dir}/`basename ${xz_file} .xz`
    ${state2}    Run Keyword and return status    OperatingSystem.Directory Should Not Be Empty    ${destination_dir}
    Run Keyword if    ${state2}==False    Log    Extract directory is empty    WARN
    #TAT-26884:
    Append To List    ${LIST_OF_DIRECTORY_TO_DEL_AFTER_UNPACK}    ${destination_dir}
