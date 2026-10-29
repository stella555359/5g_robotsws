*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
#Test Setup
#Test Teardown
Test Timeout      120 minutes

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008990_SG05/resource/CB008990_resource.robot

#CNI-122209
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Library       testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI-122209/lib/CNI-122209.py
Library       ArchiveLibrary

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    Squad group:SG_05
...    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL in TRUNK program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Variables ***
#CNI-122209
${search_term}               base-pstore
@{check_terms}               var/log/pstore/console-ramoops-0.1.gz
...                          var/log/pstore/dmesg-ramoops-0.1.gz
...                          var/log/pstore/dmesg.txt.1.gz
${snapshot_filelist_name}    snapshot_file_list.txt

*** Test Cases ***
#### part-1: CB008325-5G-A non-peak cases - 1*Made2 - 1 TCs ###
#[1]CB008325-5G-A_30_General_SiSo_BB_sub-unit_reset_with_L3_call
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    Baseband_module_reset_via_WEBUI    with_call=${True}
#    [Teardown]    SISO Coam Test Teardown

#### part-2: CB008990 'Improve detection and recovery for internal RU problems' (limit to 1CC for simplify scenario) - 2 TCs ###
[1]CB008990-SR-01_Ecpri_RU_DFE_no_TX_Data_fault_activation
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK    CRT_25R1
    [Setup]    SISO Coam Test Setup
    ${fault_list}    Create List    1904
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Ecpri_RU_DFE_no_TX_Data_fault_activation_Fault1904_AQQL
    [Teardown]    SISO Coam Test Teardown

[1]CB008990-SR-01_Ecpri_RU_DFE_Fronthaul_switch_link_fault_activation
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIPB1_AQQL    CRT_UTE    CRT_TRUNK    CRT_25R1
    [Setup]    SISO Coam Test Setup
    ${fault_list}    Create List    1981
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Ecpri_RU_DFE_Fronthaul_switch_link_fault_activation_Fault1981_AQQL
    [Teardown]    SISO Coam Test Teardown

#### part-3: CNI-122209 - 1 TCs ###
[1]CNI-122209_03_Collect RFSW kernel log from RU into BTS Snapshot on AQQL
    [Tags]    CRT_UTE    CRT_TRUNK    CRT_25R3    CRT_26R1
    [Setup]    SISO Coam Test Setup
    ${connection}    Set Variable    GNB_OAM
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}

    Selenium Login And Disable Screen Lock
    selenium_coam.reset_ru  ru_index=1
    Wait Until Keyword Succeeds    5min    30s    verify all cells should be onair    connection=${connection}
    #wait for log generated
    Sleep  15min

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
    #BTS2457_L1214211778_RMOD_L_(\d+)_base-pstore

    ${output}   OperatingSystem.get file    path=${snapshot_unzip_path}/${snapshot_filelist_name}
    ${base-pstore_CompressFile_Path_list}    Get Regexp Matches     ${output}    (${pattern}.*)    1
    ${base-pstore_CompressFile}    Set Variable    ${base-pstore_CompressFile_Path_list}[0]
    #BTS2457_L1214211778_RMOD_L_1_base-pstore.tar.gz

    ${upper_level_path}    Find Upper Level Path    file_list_path=${snapshot_unzip_path}/${snapshot_filelist_name}
    ...    search_term=${base-pstore_CompressFile}
    #BTS_part4.zip

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

*** Keywords ***
Get Specific RMOD base-pstore File Pattern
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
#    ${pattern}    Set Variable    BTS${MRBTS_ID}_${serial_number}_RMOD_L_${ru_index}_${search_term}
    ${pattern}    Set Variable    BTS${MRBTS_ID}_${serial_number}_RMOD_L_(\\d+)_${search_term}
    [Return]    ${pattern}
