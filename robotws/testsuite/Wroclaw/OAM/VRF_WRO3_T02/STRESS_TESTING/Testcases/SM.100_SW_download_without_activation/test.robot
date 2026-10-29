*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot

Documentation
...  TEST NAME:     SM.100_SW_download_without_activation
...  AUTHORS:       artur.lebek@nokia.com, tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform software download without activation for random software build
...  and then check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  06.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Legacy test
...  03.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-464 - robotws migration and small hotfixes
...  15.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-587 - change the SW download path for one lower release than SW that is on BTS
...  29.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-615 - Delay time between iterations during the SW Download
...  02.04.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-16896 - fix logic for proper SW package selection
...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-25565 - Solution for non-existing SW download folder
...  ******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${software_type}
${newSnumber1}
${newRnumber1}
${MAIN_SBTS_SW_PATH}    /media/Global_veryfication/[1] SW/SBTS

*** Keywords ***
SM.100_SW_download_without_activation

    SM.100_SW_download_without_activation.Test_Step:0 Test Preparation
    SM.100_SW_download_without_activation.Test_Step:1 Perfom SW Download
    SM.100_SW_download_without_activation.Test_Step:2 Check BTS

SM.100_SW_download_without_activation.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    SCF Backup

SM.100_SW_download_without_activation.Test_Step:1 Perfom SW Download
    Log to console    \n========================================
    Log  Step: 1 Perfom SW Download  console=${True}
    Log to console    ========================================
    ${sw_type_base}  Set Variable If  '${SMOD_COMPOSITION}'=='FSMF' or '${SMOD_COMPOSITION}'=='FSMF+FSMF'  ${sw_type_base}_FSM3  ${sw_type_base}
    Log to console  Performing software download without activation on release: ${sw_type_base}
    ${SW_DOWNLOAD_ITERATIONS}  Convert to integer  ${SW_DOWNLOAD_ITERATIONS}
    @{files}  OperatingSystem.List Files In Directory  ${sw_path}
    @{filtred_files}  Run Keyword If  '${SMOD_COMPOSITION}'=='FSMF' or '${SMOD_COMPOSITION}'=='FSMF+FSMF'
    ...             Evaluate  [pkg for pkg in ${files} if 'FSM3' in pkg]
    ...    ELSE     Evaluate  [pkg for pkg in ${files} if 'ENB' in pkg]
    ${already_used}  Set Variable  ${EMPTY}
    FOR  ${i}  IN RANGE  1  ${SW_DOWNLOAD_ITERATIONS+1}
        ${to_be_used}  Evaluate  random.choice([pkg for pkg in ${filtred_files} if pkg not in '${already_used}'])  modules=random
        ${sw_package}  Set Variable  ${sw_path}/${to_be_used}
        Log To Console    Starting SW download for package ${sw_package}
        Wait Until Keyword Succeeds  1min  5s    admin.update software
        ...    sw_package=${sw_package}    should_activate=false  timeout=3600
        ${already_used}  Set Variable  ${to_be_used}
    END

SM.100_SW_download_without_activation.Test_Step:2 Check BTS
    Log to console    \n========================================
    Log  Step: 2 Check BTS  console=${True}
    Log to console    ========================================
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN

SM.100_SW_download_without_activation.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY

SM.100_SW_download_without_activation.Test Case Setup
    ${sw_type_base}  Set SW for Download
    Set Test Variable  ${sw_type_base}
    ${sw_path}  Prepare Directory For SW Download  ${sw_type_base}
    Set Test Variable  ${sw_path}

Prepare Directory For SW Download
    [Arguments]  ${sw_type_base}
    ${is_fsmf}  Set Variable If  '${SMOD_COMPOSITION}'=='FSMF' or '${SMOD_COMPOSITION}'=='FSMF+FSMF'  True  False
    ${software_type}  Set Variable If  ${is_fsmf}  ${sw_type_base}_FSM3  ${sw_type_base}_ENB
    ${sw_dir_path}  Set Variable If  ${is_fsmf}  ${MAIN_SBTS_SW_PATH}/${software_type}  ${MAIN_SBTS_SW_PATH}/${sw_type_base}
    # check if directory for ${software_type} exists
    ${dir_pattern}  Set Variable If  ${is_fsmf}  ${sw_type_base}_FSM[F3]  ${sw_type_base}
    @{valid_directories}  OperatingSystem.List Directories In Directory  path=${MAIN_SBTS_SW_PATH}/
    ...                                                                  pattern=${dir_pattern}  # matches exact string, but utilises glob patterns
    ...                                                                  absolute=True
    ${sw_dir_path}  Set Variable If  ${valid_directories}==[]  ${sw_dir_path}  ${valid_directories[0]}
    OperatingSystem.Create Directory  ${sw_dir_path}    # passes if the directory already exists
    OperatingSystem.Wait Until Created  ${sw_dir_path}
    @{sw_path_files}  Operatingsystem.List Files In Directory  path=${sw_dir_path}/
    ...                                                        pattern=${software_type}*_A54.zip
    ${sw_path_files_count}  Get Length  ${sw_path_files}
    IF  ${sw_path_files_count}>1  RETURN  ${sw_dir_path}
    Run Keywords  Log To Console  Creating directory for${SPACE}  no_newline=true
    ...  AND  Run Keyword If  ${is_fsmf}  Log To Console  ${software_type}
    ...                             ELSE  Log To Console  ${sw_type_base}
    # check if directory for ${sw_type_base} exists
    ${base_dir_exists}  Run Keyword And Return Status      OperatingSystem.Directory Should Exist   path=${MAIN_SBTS_SW_PATH}/${sw_type_base}/
    @{base_dir_files}  Run Keyword If  ${base_dir_exists}  Operatingsystem.List Files In Directory  path=${MAIN_SBTS_SW_PATH}/${sw_type_base}/
    ...                                                                                             pattern=${software_type}*_A54.zip
    ...                          ELSE  Create List
    ${base_dir_files_count}  Get Length  ${base_dir_files}
    @{files_to_copy}  Run Keyword If  ${base_dir_files_count}>1
    ...                        Evaluate  random.sample([file for file in ${base_dir_files} if file not in ${sw_path_files}], 2-${sw_path_files_count})
    ...                                  modules=random
    ...                  ELSE  Evaluate  [file for file in ${base_dir_files} if file not in ${sw_path_files}]
    FOR  ${file}  IN  @{files_to_copy}
        Log To Console  Copying file: ${file}
        OperatingSystem.Copy File  ${MAIN_SBTS_SW_PATH}/${sw_type_base}/${file}  ${sw_dir_path}
    END
    ${sw_path_files_count}  OperatingSystem.Count Files In Directory  path=${sw_dir_path}/
    ...                                                               pattern=${software_type}*_A54.zip
    IF  ${sw_path_files_count}>1  RETURN  ${sw_dir_path}
    ${artifactory_command}  Set Variable If  ${is_fsmf}  curl -s -q ${artifactory}/${software_type}/ | grep -oP '(?<=href=")${software_type}.*(?=/")'
    ...                                                  curl -s -q ${artifactory}/${sw_type_base}/ | grep -oP '(?<=href=")${software_type}.*(?=/")'
    ${command_output}  Run  ${artifactory_command}
    ${command_output_split}  Split String  ${command_output}
    ${packages_count}  Get Length  ${command_output_split}
    ${random_packages}  Evaluate   random.sample(${command_output_split}, 2)  modules=random
    ${file_postfix}  Set Variable  _release_BTSSM_downloadable_A54.zip
    ${build_type}  Set Variable If  ${is_fsmf}  ${software_type}  ${sw_type_base}
    FOR  ${package}  IN  @{random_packages}
      Log To Console  Downloading from Artifactory: ${package}${file_postfix}
      Run  curl -s -q ${artifactory}/${build_type}/${package}/${package}${file_postfix} -o '${sw_dir_path}/${package}${file_postfix}'
    END
    [Return]  ${sw_dir_path}

Set SW for Download
    Log to console  Active Software on BTS: ${ACTIVE_SW_VERSION}
    ${sw_splited}  Split String  ${ACTIVE_SW_VERSION}  _
    ${sw} = 	Get From List  ${sw_splited}  0
    ${prefix}=    Get Substring    ${sw}    0    4
    ${sbtsNum}=    Get Substring    ${sw}    4    6
    ${rPart}=    Get Substring    ${sw}    6
    ${rNumber}=    Get Substring    ${rPart}    1
    ${newRnumber}=    Evaluate   int(${rNumber})
    ${newSnumber}=    Evaluate    int(${sbtsNum})
    ${newSnumber1}=    Run Keyword If    '${rPart}' == 'R1'    Evaluate    int(${newSnumber}) - 1
    ...    ELSE    Set Variable    ${newSnumber}
    ${newRnumber1}=    Run Keyword If    '${rPart}' == 'R1'    Set Variable    3
    ...    ELSE    Evaluate    int(${newRnumber}) - 1
    ${newSnumber}=    Evaluate    str(${newSnumber1})
    ${newSW}=    Catenate    ${prefix}${newSnumber1}R${newRnumber1}
    [Return]    ${newSW}
