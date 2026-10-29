*** Settings ***
Documentation    This is common keywords for oam_KPI
...              Please do not modify the file without notification to author
...              Contact: kaihui.fan@nokia-sbell.com
...              Squard: HZ SG4
Library     taf/rfrl/common_resources/python/SWConfig.py
Library     taf.rfrl.uuf4all.resources.python.uuf_rfrl_oam_kpi
Library     ./e2e_report.py
Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_log.robot



*** Keywords ***
Make Call With All UE for Sleepingcell
    [Arguments]  ${cell_used_in_test}=${None}  ${connection}=GNB_OAM  ${gnb_index}=${0}
    ...   ${duration}=${60}    ${with_peak}=${False}   ${dl_tp}=300M  ${ul_tp}=20M
    Log To Console   \nUUF4ALL/CSV4ALL used cell list: ${cell_used_in_test}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${ru_index_list}    Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}    connection=${connection}
        Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${with_peak}    duration=${duration}
        ...    connection=${connection}   dl_tp=${dl_tp}  ul_tp=${ul_tp}
    END
    [Teardown]   COAM Teardown gnb connections    connection=${connection}

Make Call With All UE
    [Arguments]  ${cell_used_in_test}=${None}  ${connection}=GNB_OAM  ${gnb_index}=${0}
    ...   ${duration}=${300}    ${with_peak}=${True}   ${dl_tp}=300M  ${ul_tp}=20M
    Log To Console   \nUUF4ALL/CSV4ALL used cell list: ${cell_used_in_test}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${ru_index_list}    Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}    connection=${connection}
        Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${with_peak}    duration=${duration}
        ...    connection=${connection}   dl_tp=${dl_tp}  ul_tp=${ul_tp}
    END
    [Teardown]   COAM Teardown gnb connections    connection=${connection}

Download SW package to TAF VM
    [Arguments]   ${package_version}
    ${package_release}   ${package_version}   Get Build Release And Version   package_version=${package_version}
    run keyword and ignore error  Run   rm -rf /home/ute/${package_version}*
    ${package_path}  Set Variable   /home/ute/${package_version}_release_BTSSM_downloadable_A54.zip
    ${file_exist}   run keyword and return status   OperatingSystem.File Should Exist   ${package_path}
    Run Keyword If  ${file_exist}  log to console   \nfile exist
#    ${if_common}   Run Keyword And Return Status   Should Contain   ${package_version}   _ENB_9999_
#    ${common_release}  Split String   ${package_version}   _   1
#    ${package_prefix}   Set Variable if  ${if_common}   SBTS00   ${common_release}[0]
#    ${package_version}   Set Variable If  '${common_release}  SBTS00_${common_verision_separator}[1]   ${package_version}
#    ${package_download_dir}   Set Variable if  ${if_common}   ${common_web_service}/${common_release}[0]   ${package_web_service}/${package_version}
    ${package_download_dir_hz}   Set Variable
    ...   ${common_web_service_hz}/${package_release}_packages/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
    Log    \nPackage Do Not Exist, Start to Download Package From WFT!    WARN
    Run   rm -f wget-log*
    ${wget_command}    set variable
    ...    wget -b ${package_download_dir_hz} -P /home/ute
    run keyword if  not ${file_exist}   Run   ${wget_command}
    log to console   \nstart to check
    run keyword if  not ${file_exist}   Wait Until Keyword Succeeds   30m   1m   Wait Until wget process done
    ...   ${package_version}
    log to console   \ncheck done
    ${file_download}   run keyword and return status  OperatingSystem.File Should Exist   ${package_path}
    Run Keyword If  ${file_download}  Log To Console    Download Package Finished!
    [Return]   ${package_path}

UUF4ALL Suite Setup
    [Arguments]    ${gnb_index}=0
    robot_common_operations.Common Suite Setup
    log to console    \n*** UUF4ALL Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Run Keyword And Ignore Error   Get Mapping Info With ScoutName And TestLine

UUF4ALL Suite Teardown
    [Arguments]    ${gnb_index}=0
    robot_common_operations.Common Suite Teardown
    log to console    \n***UUF4ALL Suite Teardown***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

UUF4ALL NR Test Setup
    [Arguments]    ${gnb_index}=0
    log to console    \n*** UUF4ALL Test Setup***
    ${TEST_START_TIME}=    DateTime.Get Current Date    result_format=%Y%m%d %H:%M:%S.%f
    Set Test Variable    ${TEST_START_TIME}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    Set suite Variable    ${Case_SCF_Path}    ${SCF_Path}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
#    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Set Test Variable   ${SAVE LOG DIRECTORY}  ${LOG_PATH}/${TEST_NAME}
    log to console   ${SAVE LOG DIRECTORY}
#    Set Suite Variable   ${SCOUT_TL_NAME}   ${testline_name}_5G
    robot_common_operations.Common Case Setup    allowed_faults_ids=61074,8150
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}


E2E COAM TEST SETUP
    ${TEST_START_TIME}=    DateTime.Get Current Date    result_format=%Y%m%d %H:%M:%S.%f
    Set Test Variable    ${TEST_START_TIME}
    SISO Coam Test Setup

E2E COAM TEST TEARDOWN
    Report execution results
    SISO Coam Test Teardown

UUF4ALL LTE Test Setup
    [Arguments]    ${gnb_index}=0
    log to console    \n*** UUF4ALL LTE Test Setup***
    ${TEST_START_TIME}=    DateTime.Get Current Date    result_format=%Y%m%d %H:%M:%S.%f
    Set Test Variable    ${TEST_START_TIME}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Set Test Variable   ${SAVE LOG DIRECTORY}  ${LOG_PATH}/${TEST_NAME}
    log to console   ${SAVE LOG DIRECTORY}
#    Set Suite Variable   ${SCOUT_TL_NAME}   ${testline_name}_5G
    robot_common_operations.Common Case Setup    allowed_faults_ids=61074

UUF4ALL NR Test Teardown
    [Arguments]    ${gnb_index}=0
    log to console    \n*** UUF4ALL NR Test Teardown***
    run keyword and ignore error    robot_common_operations.Common Case Teardown
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    # Run Keyword If    '${TEST STATUS}' == 'FAIL'   run keywords
    # ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}     gnb_index=${gnb_index}    AND
    # ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}    AND
    # ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    # ...    ELSE
    # ...    log to console    case pass don't collect snapshot in test teardown!!!
    Report execution results
    CI_interface.Common Case Teardown    connection=${connection}    gnb_index=${gnb_index}

UUF4ALL LTE Test Teardown
    log to console    \n*** UUF4ALL LTE Test Teardown***
    Report execution results
    run keyword and ignore error    robot_common_operations.Common Case Teardown


Wait Until Wget Process Done
    [Arguments]   ${package_name}
    ${output}   Run   cat wget-log | grep -i "saved"
    Should Contain   ${output}   ${package_name}

Download SW package to VM
    [Arguments]   ${package_version}    ${download_dir}=/home/ute
    log to console   Download SW package to VM
    ${package_release}   ${package_version}   Get Build Release And Version   package_version=${package_version}
    ${package_path}  Set Variable   ${download_dir}/${package_version}_release_BTSSM_downloadable_A54.zip
    ${file_exist}   run keyword and return status   OperatingSystem.File Should Exist   ${package_path}
    Run Keyword If  ${file_exist}  log to console   \nfile exist
    Run Keyword If  not ${file_exist}  Start to Download Package From WFT   ${package_release}   ${package_version}
    [Return]   ${package_path}


Start to Download Package From WFT
    [Arguments]    ${package_release}    ${package_version}    ${download_dir}=/home/ute
    ${common_hz_site}   Set Variable   ${GNB_SW_DOWNLOAD_INFO['common_web_service_hz']}
    ${package_download_dir_hz}   Set Variable
    ...  ${common_hz_site}/${package_release}/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
    Log    \nPackage Do Not Exist, Start to Download Package From WFT!    WARN
    ${wget_log_dir}=    Run   pwd
    Run   rm -rf ${wget_log_dir}/wget-log*
    ${wget_log}=    Run   ls -l ${wget_log_dir}/wget-log*
    log to console   ${wget_log}
    ${wget_command}    set variable
    ...    wget -b --header="Authorization: Bearer ${artifactory}" ${package_download_dir_hz} -P ${download_dir}
    Run Keywords   Run   ${wget_command}  AND  Sleep  5s
    Wait Until Keyword Succeeds   30m   1m   Wait Until wget process done
    ...   ${package_version}
    ${check_wget}   Check Package Not Download
    ${check_wget}   Run Keyword If   ${check_wget}    Download Package From More Site   ${package_version}   ${package_release}
    log to console   \nstart to check
    run keyword if  not ${check_wget}    Wait Until Keyword Succeeds   30m   1m   Wait Until wget process done
    ...   ${package_version}
    log to console   \ncheck done
    ${file_download}   run keyword and return status  OperatingSystem.File Should Exist   ${package_path}
    Run Keyword If  ${file_download}  Log To Console    Download Package Finished!


Check Package Not Download
    log to console   Check Package Not Download
    ${output}   Run   cat wget-log
    ${status1}   Run Keyword And Return Status  Should Contain   ${output}   404 Not Found
    ${status2}   Run Keyword And Return Status  Should Contain   ${output}   Failed
    ${status3}   Run Keyword And Return Status  Should Not Contain   ${output}   saved
    ${status}   Set Variable If  ${status1} or ${status2} or ${status3}  ${True}  ${False}
    [Return]   ${status}

Download Package From More Site
    [Arguments]   ${package_version}   ${common_release}    ${download_dir}=/home/ute
    log to console   Download Package From More Site
    ${wget_log_dir}=    Run   pwd
    ${messages}=    Run   rm -rf ${wget_log_dir}/wget-log*
    ${wget_log}=    Run   ls -l ${wget_log_dir}/wget-log*
    log to console   ${wget_log}
    FOR   ${item}   IN   @{GNB_SW_DOWNLOAD_INFO['common_web_service']}
        ${package_download_link}   Set Variable
        ...   ${item}/${common_release}/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
        Log    \nPackage Do Not Exist, Start to Download Package From WFT!    WARN
        ${messages}=    Run   rm -rf ${wget_log_dir}/wget-log*
        ${wget_log}=    Run   ls -l ${wget_log_dir}/wget-log*
        log to console   ${wget_log}
        Sleep  2s
        ${wget_command}    set variable
        ...    wget -b ${package_download_link} -P ${download_dir} --no-check-certificate
        Run   ${wget_command}
        Sleep  5s
        ${check_wget}   Check Package Not Download
        exit for loop if   not ${check_wget}
    END
    [Return]   ${check_wget}

Get Mapping Info With ScoutName And TestLine
    ${is_scout_mapping}  Run Keyword And Return Status  Dictionary Should Contain Key   ${TL_SCOUT_MAPPING_INFO}  ${testline_name}
    ${scoutname}=   Run Keyword If   ${is_scout_mapping}   Get From Dictionary   ${TL_SCOUT_MAPPING_INFO}   ${testline_name}
    ...   ELSE   Set Variable   ${testline_name}_5G
    Set Suite Variable   ${SCOUT_TL_NAME}   ${scoutname}
    log to console   SCOUT_TL_NAME is ${SCOUT_TL_NAME}

Get_DeltaFile_With_Modify_Parameter
    [Arguments]   ${connection}=GNB_OAM   ${dist_name}=MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1     ${filter_parameter}=Activate support for distributed site
    ...   ${pattern}=actDistributedSite
    ${modify_params}    create list
    ${value_list}    create list    true    false
     Selenium Login And Disable Screen Lock
     ${get_value}    Get Parameter Via Webem    dist_name=${dist_name}    filter_param=${filter_parameter}
    Remove Values From List    ${value_list}    ${get_value.lower()}
    ${change_value}  evaluate  random.choice(${value_list})    modules=random
    ${new_item}    create dictionary    dist_name=${dist_name}
    ...    parameter=${pattern}   value=${change_value}
    append to list    ${modify_params}    ${new_item}
    ${delta_file_update}     coam_parameter.create_update_parameters_delta    parameters=${modify_params}    connection=${connection}
    ${delta_file_json}  Set Variable    ${delta_file_update['updated']}
    [Return]  ${delta_file_json}
    [Teardown]       Run Keyword And Ignore Error    selenium_coam.close_browser

Get Build Release And Version
    [Arguments]   ${package_version}
    ${if_common}   Run Keyword And Return Status   Should Contain   ${package_version}   _ENB_9999_
    @{common_verision_separator}  Split String   ${package_version}   _   1
    ${package_release}   Set Variable if  ${if_common}   SBTS00   ${common_verision_separator}[0]
    ${package_version}   Set Variable If  ${if_common}  SBTS00_${common_verision_separator}[1]   ${package_version}
    [Return]  ${package_release}   ${package_version}



Monitor_BTS_Status_For_2_Hours
    [Arguments]   ${connection}=GNB_OAM    ${gnb_index}=${0}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    FOR  ${i}  IN RANGE  12
        log to console   sleep 10 min
        sleep  10min
        ${ru_status}   run keyword and ignore error   COAM Check GNB RU status    connection=${connection}
        log to console  RU status: ${ru_status}
        ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
        should be true    ${cell_status}
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        ...    connection=${connection}
        should be true    ${alarm_status}
    END

Report execution results
    [Documentation]    Report test execution results to management system. This keyword will not fail the test even if reporting fails.
    Run Keyword And Ignore Error    Report execution results internal

Report execution results internal
    ${start_time}=    Get Variable Value    ${TEST_START_TIME}    ${EMPTY}
    ${end_time}=    DateTime.Get Current Date    result_format=%Y%m%d %H:%M:%S.%f
    Log To Console    \n*** Start to report execution results to test management system ***
    ${failure_reason}=    Set Variable If    '${TEST_STATUS}' == 'PASS'    ${EMPTY}    ${TEST_MESSAGE}
    ${customers_value}=    Get Variable Value    ${customers}    ['']
    ${testline_value}=    Get Variable Value    ${testline_name}    ${EMPTY}
    ${Active_SW_version_value}=    Get Variable Value    ${Active_SW_version}    ${EMPTY}
    ${result_dict}=    Create Dictionary
    ...    test_name=${TEST_NAME}
    ...    test_status=${TEST_STATUS}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    customer=${customers_value}[0]
    ...    sw_version=${Active_SW_version_value}
    ...    failure_reason=${failure_reason}
    ...    testline=${testline_value}

    e2e_report.report_result    ${result_dict}
    Log To Console    \n*** Report execution results finished ***
