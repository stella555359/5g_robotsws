*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

Library       testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI-122209/lib/CNI-122209.py
Library       ArchiveLibrary

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CNI-122209 in SBTS25R3 program (LL)

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Variables ***

${search_term}               base-pstore
@{check_terms}               var/log/pstore/console-ramoops-0.1.gz
...                          var/log/pstore/dmesg-ramoops-0.1.gz
...                          var/log/pstore/dmesg.txt.1.gz
${snapshot_filelist_name}    snapshot_file_list.txt

*** Test Cases ***
[1]CNI-122209_03_Collect RFSW kernel log from RU into BTS Snapshot on AQQL
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${connection}    Set Variable    GNB_OAM
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
#    coam.reset_site    connection=${connection}    reset_without_ru=${False}
#    Sleep    5min
#    Wait Until Keyword Succeeds    5min    30s    Check all cells info should be onair    connection=${connection}
#    Wait Until Keyword Succeeds    2min    30s    Connect to gnb coam via ssl    connection=${connection}

    Selenium Login And Disable Screen Lock
    selenium_coam.reset_ru  ru_index=1
    Wait Until Keyword Succeeds    5min    30s    verify all cells should be onair    connection=${connection}
    #wait for log generated
    Sleep  10min

    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Set Test Variable    ${snapshot_zip_path}    ${SAVE LOG DIRECTORY}/Snapshot_${time_stamp}.zip
    ${log_status}    Run Keyword And Return Status    coam.Get Snapshot    target_file_name=${snapshot_zip_path}
    ...    coverage=Full   force=${True}    connection=${connection}    timeout=1800
    Run Keyword If    ${log_status}    Log To Console    \nCollecting Snapshot to ${snapshot_zip_path} [DONE]
    ${file_status}    Run Keyword And Return Status    ArchiveLibrary.Archive Should Contain File
    ...    zip_file=${snapshot_zip_path}    filename=${snapshot_filelist_name}
    Set Test Variable    ${snapshot_unzip_path}    ${SAVE LOG DIRECTORY}/Snapshot_${time_stamp}
    Run Keyword If    ${file_status}    ArchiveLibrary.Extract Zip File    zip_file=${snapshot_zip_path}
    ...    dest=${snapshot_unzip_path}
    ${pattern}    Get Specific RMOD base-pstore File Pattern    ru_index=1    connection=${connection}
    ${upper_level_path}    Find Upper Level Path    file_list_path=${snapshot_unzip_path}/${snapshot_filelist_name}
    ...    search_term=${pattern}
    #BTS_part4.zip
    ${output}   OperatingSystem.get file    path=${snapshot_unzip_path}/${snapshot_filelist_name}
    ${base-pstore_CompressFile_Path_list}    Get Regexp Matches     ${output}    (${pattern}.*)    1
    ${base-pstore_CompressFile}    Set Variable    ${base-pstore_CompressFile_Path_list}[0]
    #BTS2457_L1214211778_RMOD_L_1_base-pstore.tar.gz

    @{split_upper_level_path}    string.split string    string=${upper_level_path}    separator=.
    ${upper_level_folder}    set variable     ${split_upper_level_path}[0]
    Set Test Variable    ${uncompress_path}    ${SAVE LOG DIRECTORY}/${upper_level_folder}_${time_stamp}
    ArchiveLibrary.Extract Zip File    zip_file=${snapshot_unzip_path}/${upper_level_path}
    ...    dest=${uncompress_path}

    ${fetch_base-pstore_path}    string.Fetch From Left    string=${base-pstore_CompressFile}    marker=.
    Set Test Variable    ${base-pstore_UncompressFile_path}    ${SAVE LOG DIRECTORY}/${fetch_base-pstore_path}_${time_stamp}
    ArchiveLibrary.Extract Tar File    tar_file=${uncompress_path}/${base-pstore_CompressFile}
    ...    dest=${base-pstore_UncompressFile_path}

    #BTS_part8_20250318221548
	Log To Console    \n${uncompress_path}
	#BTS2457_L1214211778_RMOD_L_1_base-pstore_20250318221548
	Log To Console    \n${base-pstore_UncompressFile_path}

    @{items}    List Directory    path=${base-pstore_UncompressFile_path}
    FOR  ${item}  IN  @{items}
        ${file0_exist}    Run Keyword And Return Status    ArchiveLibrary.Archive Should Contain File
        ...    zip_file=${base-pstore_UncompressFile_path}/${item}    filename=${check_terms}[0]
        Run Keyword If   ${file0_exist}    Log To Console    \nfile ${check_terms}[0] exist
        ${file1_exist}    Run Keyword And Return Status    ArchiveLibrary.Archive Should Contain File
        ...    zip_file=${base-pstore_UncompressFile_path}/${item}    filename=${check_terms}[1]
        Run Keyword If   ${file1_exist}    Log To Console    \nfile ${check_terms}[1] exist
        ${file2_exist}    Run Keyword And Return Status    ArchiveLibrary.Archive Should Contain File
        ...    zip_file=${base-pstore_UncompressFile_path}/${item}    filename=${check_terms}[2]
        Run Keyword If   ${file2_exist}    Log To Console    \nfile ${check_terms}[2] exist
        #dmesg.txt is not mandatory
        Should Be True    ${file0_exist} and ${file1_exist} or ${file2_exist}
    END

    [Teardown]    SISO Coam Test Teardown
#    [Teardown]  Run Keywords   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
#    ...    AND  run keyword and ignore error    csn.Disconnect    connection=ASIK Master
#    ...    AND  run keyword and ignore error    Selenium Logout And Close Browser
#    ...    AND  CI_interface.Common Case Teardown    gnb_index=0    connection=${connection}

*** Keywords ***
Get Specific RMOD base-pstore File Pattern
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${pattern}    Set Variable    BTS${MRBTS_ID}_${serial_number}_RMOD_L_${ru_index}_${search_term}
    [Return]    ${pattern}
