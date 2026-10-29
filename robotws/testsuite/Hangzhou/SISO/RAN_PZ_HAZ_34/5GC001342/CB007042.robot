*** Settings ***
Documentation     author: Chen Yin
...               contact: Yin.1.chen@nokia-sbell.com
...               squad group: SG_02
...               configuration: 1S_1CC_4DL2UL
Force Tags        5G_SISO    CIT_TRUNK    COAM    CIT_22R4     CIT_22R3
...    PY36
Suite Setup       Setup enviornment with relevant configuration    scf_path=2S_1CC_4DL4UL_peak.xml     ru_list=2
Resource          Resources/5GC001342_common_keywords.robot
Resource          ../5GC002029-A/Resources/5GC002029_A_common_keywords.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Library           taf.selenium.sbts    WITH NAME    selenium_coam_A
Library           ./Resources/get_zip_by_filter.py


*** Variables ***
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
&{fault_61649}             faultId=${61649}    #LMP access via port 443
@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}      &{fault_61649}
${btslog_path}    /opt/btslog/btslog
${btslog_launcher_path}    /opt/btslog/btslog_launcher
${btslog_folder}    /tmp/btslog2

*** Test Cases ***
[1]CB007042-B_05_L1low_dump_capture
    [Setup]    Test Case Setup
    Troubleshooting Scripts for Radio module    script_name=RU_Common_capture_L1low_data
    [Teardown]    Test Case Teardown

[1]CB007042-B_04_Register_dump_capture
    [Setup]    Test Case Setup
    Troubleshooting Scripts for Radio module    script_name=RU_Common_capture_register_dump
    [Teardown]    Test Case Teardown

[1]CB007042-B_03_RF_IQ_data_capture
    [Setup]    Test Case Setup
    Troubleshooting Scripts for Radio module    script_name=RU_Common_capture_IQ_data
    [Teardown]    Test Case Teardown

*** Keywords ***
Troubleshooting Scripts for Radio module
    [Arguments]  ${script_name}
	set test variable    ${mrbtsid}    ${tl.gnbs[0].instance_id}
	set test variable    ${nrbtsid}    ${tl.gnbs[0].global_bts_id}
    ${cells_name}    create list    MRBTS-${mrbtsid}/NRBTS-${nrbtsid}/NRCELL-1    MRBTS-${mrbtsid}/NRBTS-${nrbtsid}/NRCELL-2
    ${mods_name}    create list    MRBTS-${mrbtsid}/EQM-1/APEQM-1/RMOD-1      MRBTS-${mrbtsid}/EQM-1/APEQM-1/RMOD-2
    Run  rm -rf /tmp/*SCRIPT_RESULT*
    Connect to gnb coam via ssl
    ${status}    coam.launch_troubleshooting_script    script_name=${script_name}
    ...    output_file_name=${TS_CASE_LOG_PATH}/script_result_011_${script_name}.zip
    ...    cell_list=${cells_name}    rmod_list=${mods_name}
    ...    free_parameters=${EMPTY}    timeout=900    connection=GNB_OAM
    Should Be Equal    ${status}    Launching succeeded. Snapshot has been successfully created.
    ${script_zip_file_path}      Set Variable       ${TS_CASE_LOG_PATH}/script_result_011_${script_name}.zip
    File Should Exist    ${TS_CASE_LOG_PATH}/script_result_011_${script_name}.zip
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${script_unzip_file_path}    Join Path    ${TS_CASE_LOG_PATH}    script_${timestamp}
    extract zip file    ${script_zip_file_path}    ${script_unzip_file_path}
    ${output}   OperatingSystem.get file    ${script_unzip_file_path}/snapshot_file_list.txt
    ${script_log_names}   Get Regexp Matches   ${output}   .*SCRIPT_RESULT.*
    ${script_zip_names}   get_zip_names_by_filter    ${script_unzip_file_path}/snapshot_file_list.txt    SCRIPT_RESULT
    FOR  ${item}  IN  @{script_zip_names}
       extract zip file    ${script_unzip_file_path}/${item}    ${script_unzip_file_path}
    END
    FOR  ${item}  IN  @{script_log_names}
        File Should Exist    ${script_unzip_file_path}/${item.strip()}
        File Should not be empty    ${script_unzip_file_path}/${item.strip()}
    END


