*** Settings ***
Documentation    Auther:jun.8.chen@nokia-sbell.com
...            This Common Keyword is for Feature 5GC000980 of 5G19A.
Library    BuiltIn
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Variables ***
${BTS_ID}    ${tl.gnbs[0].instance_id}


*** Keywords ***
#-----------------------Common Suite Setup-------------------------------------#
980 Suite SetUp
    [Arguments]    ${scf_file_name}=${None}    ${ru_num}=1    ${ru_type}=AZQH    ${scf_path}=/home/ute/SCF    ${is_pdl_checking_needed}=${True}
    COAM Create log directory    is_set_to_test_case_level=${False}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...                                                               file_path=${SUITE_LOG_PATH}
    ${scf_file}   run keyword if  not '${scf_file_name}'=='${None}'    Join Path    ${scf_path}    ${scf_file_name}
    run keyword if  not '${scf_file_name}'=='${None}'    COAM Commission with scf file    scf_file_path=${scf_file}
    ...                                                                                     timeout=900
    ...                                                                                     is_pdl_checking_needed=${is_pdl_checking_needed}
    ${status}    ${result}    Run Keyword And Ignore Error     COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    run keyword if  not '${status}'=='PASS'    Run Keywords    Perform Site Power Off    AND
    ...                                                sleep  10 sec    AND
    ...                                                Perform Site Power On    AND
    ...    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    ${ru_info}      COAM get ru detial info by ru index
    Should Be Equal    ${ru_type}   ${ru_info['productName']}
    run keyword and ignore error    COAM Teardown gnb connections

Recommission With Backup SCF File And Wait Gnb On Air
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}    ${is_pdl_checking_needed}=${True}    ${asik_alais}=ASIK Master
    ${scf_path}    Get SCF File Path
    ${scf_file}    Join Path    ${scf_path}    ${scf_file_name}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    Recommission With Backup SCF File    backup_scf_file=${scf_file}
    ...                                                   is_pdl_checking_needed=${is_pdl_checking_needed}
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Set Suite Variable    ${old_scf_file_name}    ${scf_file_name}
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

Recommission With Backup SCF File
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${backup_scf_file}    ${is_pdl_checking_needed}=${True}    ${timeout}=900    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status     COAM Commission with scf file
    ...                                            scf_file_path=${backup_scf_file}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If  ${status}==${False}    Fail    recovery with backup scf file failed.

Get SCF File Path
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    ${SCF_Path}    ${result}    Split String From Right  ${CURDIR}    testsuite     1
    ${testline_name}  Get Variable Value    ${testline_name}
    ${TL_NAME}   set variable if    '${testline_name}' == 'None' or '${testline_name}' == 'null' or '${testline_name}' == ''
    ...                              ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    ${scf_full_path}   Set Variable    ${SCF_PATH}commissionings/HGZ/${testlinename}
    [Return]   ${scf_full_path}

980 Suite TearDown
    robot_common_operations.Common Suite Teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections


#-----------------------Common Testing Setup-------------------------------------#
Case SetUp
    robot_common_operations.Common Case Setup
    COAM Create log directory
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min

Case TearDown
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    file_path=${TS_CASE_LOG_PATH}
    Run Keyword If Test Failed    COAM Save snapshot via rest api
    run keyword and ignore error    COAM Teardown gnb connections

#-----------------------Some actions for ALD of GNB-------------------------------------#
Get BTS Information via rest api
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Info: ready to Get BTS Information
    ${bts_info} =    coam.get_bts_info    connection=${connection}
    [Return]    ${bts_info}

Enable DC Voltgae For RET Port
    [Arguments]    ${mrbts_id}=${BTS_ID}    ${rmod_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Enable DC Voltgae
    &{dcVoltage_param}    Create Dictionary    abbr=dcVoltageEnabled
    ...    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_index}/RSL-1
    ...    filter_param=DC voltage enabled
    ...    new_value=true
    @{dcVoltage_param}    Create List    ${dcVoltage_param}
    COAM Update several parameters via webUI   parameters_to_update_via_webui=${dcVoltage_param}
    ...    download_dir=${download_dir}

Disable DC Voltgae For RET Port
    [Arguments]    ${mrbts_id}=${BTS_ID}    ${rmod_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Disable DC Voltgae
    &{dcVoltage_param}    Create Dictionary    abbr=dcVoltageEnabled
    ...    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_index}/RSL-1
    ...    filter_param=DC voltage enabled
    ...    new_value=false
    @{dcVoltage_param}    Create List    ${dcVoltage_param}
    COAM Update several parameters via webUI   parameters_to_update_via_webui=${dcVoltage_param}
    ...    download_dir=${download_dir}

Get ALD Information via webUI
    [Arguments]    ${ald_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Get ALD Information
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${ald_info} =    selenium_coam.get_ald_info    ald_index=${ald_index}
    [Return]    ${ald_info}
    [Teardown]    selenium_coam.logout

Get RETU Information via webUI
    [Arguments]    ${retu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Get RETU Information
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${retu_info} =    selenium_coam.get_retu_info    retu_index=${retu_index}
    [Return]    ${retu_info}
    [Teardown]    selenium_coam.logout

Get RAEU Information via webUI
    [Documentation]    Author: Wang Yixiang
    ...    This keyword will get RAE information from web UI
    [Arguments]    ${raeu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${retu_info} =    selenium_coam.get_raeu_info    raeu_index=${raeu_index}
    [Return]    ${retu_info}
    [Teardown]    selenium_coam.logout

Reset ALD via webUI
    [Documentation]    Description: Resrt ALD from webui
    ...    ${reset_type}: value can be software, hardware, defult to use hardware
    ...    ${ald_index}: index of ALD
    [Arguments]    ${reset_type}=hardware    ${ald_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Reset ALD
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    selenium_coam.reset_ald    reset_type=${reset_type}    ald_index=${ald_index}
    [Teardown]    selenium_coam.logout

Calibrate RETU via webUI
    [Arguments]    ${retu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Calibrate RETU
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    selenium_coam.calibrate_retu    retu_index=${retu_index}
    [Teardown]    selenium_coam.logout

Set RETU Angless via webUI
    [Arguments]    ${angle_value}    ${retu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Info: ready to Set RETU Angless
    &{angle_configuration}    Create Dictionary    angle=${angle_value}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    selenium_coam.set_retu_angles    configuration=${angle_configuration}    retu_index=${retu_index}
    [Teardown]    selenium_coam.logout

ALD Should Be Online
    [Arguments]    ${ald_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: ready to verify ALD should be online...
    ${ald_info} =    Get ALD Information via webUI    ald_index=${ald_index}    download_dir=${download_dir}
    ${sw_version}     coam.get_sw_version    connection=GNB_OAM
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    run keyword if    ${result}    Should Be Equal As Strings    ${ald_info["Status"]["Availability status"]}    Online
    ...    msg=Current ALD availability_status is not online    ignore_case=${True}

RETU Should Be Online
    [Arguments]    ${retu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: ready to verify RETU should be online...
    ${sw_version}     coam.get_sw_version    connection=GNB_OAM
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${retu_info} =    Get RETU Information via webUI    retu_index=${retu_index}    download_dir=${download_dir}
    run keyword if    ${result}    Should Be Equal As Strings    ${retu_info["Status"]["Availability status"]}    Online
    ...    msg=Current RETU availability_status is not online    ignore_case=${True}

ALD Should Be Ready
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${ald_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: verify ALD should be ready...
    ${sw_version}    coam.Get Sw Version     connection=GNB_OAM
    @{result}    string.split string    string=${sw_version}    separator=_
    ${procedural_status}    Set Variable     -
    Check ALD Status
    ...    administrative_state=Unlocked    availability_status=Online
    ...    operational_state=Enabled    procedural_status=${procedural_status}
    ...    ald_index=${ald_index}    download_dir=${download_dir}

RAEU Should Be Ready
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${raeu_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: verify RAEU should be ready...
    ${sw_version}    coam.Get Sw Version     connection=GNB_OAM
    @{result}    string.split string    string=${sw_version}    separator=_
    ${procedural_status}    Set Variable     -
    Check RAEU Status
    ...    administrative_state=Unlocked    availability_status=Online
    ...    operational_state=Enabled    procedural_status=${procedural_status}
    ...    raeu_index=${raeu_index}    download_dir=${download_dir}


Check ALD Status
    [Arguments]    ${administrative_state}
    ...    ${availability_status}
    ...    ${operational_state}
    ...    ${procedural_status}
    ...    ${ald_index}=1
    ...    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: ready to check ALD status...
    ${sw_version}     coam.get_sw_version    connection=GNB_OAM
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${ald_info} =    Get ALD Information via webUI    ald_index=${ald_index}    download_dir=${download_dir}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${ald_info["Status"]["Administrative state"]}    ${administrative_state}
    ...    msg=Current ALD administrative_state is not in ${administrative_state} status    ignore_case=${True}
    run keyword if    ${result}    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${ald_info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current ALD availability_status is not in ${availability_status} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${ald_info["Status"]["Operational state"]}    ${operational_state}
    ...    msg=Current ALD operational_state is not in ${operational_state} status    ignore_case=${True}
    Run keyword and continue on failure    should contain
    ...    ${ald_info["Status"]["Procedural status"]}    ${procedural_status}
    ...    msg=Current ALD procedural_status is not in ${procedural_status} status    ignore_case=${True}

Check RETU Status
    [Arguments]    ${administrative_state}
    ...    ${availability_status}
    ...    ${operational_state}
    ...    ${procedural_status}
    ...    ${retu_index}=1
    ...    ${download_dir}=${TS_CASE_LOG_PATH}
    Log To Console    Info: ready to check RETU status...
        ${sw_version}     coam.get_sw_version    connection=GNB_OAM
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${retu_info} =    Get RETU Information via webUI    retu_index=${retu_index}    download_dir=${download_dir}
    Should Be Equal As Strings    ${retu_info["Status"]["Administrative state"]}    ${administrative_state}
    ...    msg=Current RETU administrative_state is not in ${administrative_state} status    ignore_case=${True}
    run keyword if    ${result}    Should Be Equal As Strings    ${retu_info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current RETU availability_status is not in ${availability_status} status    ignore_case=${True}
    Should Be Equal As Strings    ${retu_info["Status"]["Operational state"]}    ${operational_state}
    ...    msg=Current RETU operational_state is not in ${operational_state} status    ignore_case=${True}
    should contain    ${retu_info["Status"]["Procedural status"]}    ${procedural_status}
    ...    msg=Current RETU procedural_status is not in ${procedural_status} status    ignore_case=${True}

Check RAEU Status
    [Documentation]    Author: Wang Yixiang
    ...    Check RAE status(administrative_state, availability_status, operational_state, procedural_status) by web UI
    [Arguments]    ${administrative_state}
    ...    ${availability_status}
    ...    ${operational_state}
    ...    ${procedural_status}
    ...    ${raeu_index}=1
    ...    ${download_dir}=${TS_CASE_LOG_PATH}
    ${raeu_info} =    Get RAEU Information via webUI    raeu_index=${raeu_index}    download_dir=${download_dir}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${raeu_info["Status"]["Administrative state"]}    ${administrative_state}
    ...    msg=Current RAEU administrative_state is not in ${administrative_state} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${raeu_info["Status"]["Availability status"]}    ${availability_status}
    ...    msg=Current RAEU availability_status is not in ${availability_status} status    ignore_case=${True}
    Run keyword and continue on failure    Should Be Equal As Strings
    ...    ${raeu_info["Status"]["Operational state"]}    ${operational_state}
    ...    msg=Current RAEU operational_state is not in ${operational_state} status    ignore_case=${True}
    Run keyword and continue on failure    should contain
    ...    ${raeu_info["Status"]["Procedural status"]}    ${procedural_status}
    ...    msg=Current RAEU procedural_status is not in ${procedural_status} status    ignore_case=${True}

#-----------------------Some actions for GNB-------------------------------------#
Get Parameter via webUI
    [Arguments]    ${dist_name}    ${abbr}    ${filter_param}    ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${para_value} =    selenium_coam.get_parameter_value
    ...    dist_name=${dist_name}
    ...    abbr=${abbr}
    ...    filter_param=${filter_param}
    [Return]    ${para_value}
    [Teardown]    selenium_coam.logout

Update parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}
    ...    ${is_need_to_check_validation_errors}=${False}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    @{diff_para} =    create list
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
        ${cur_para_value}    selenium_coam.get_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
        ...    Log to console    current value is ${cur_para_value}, no need to update
        ...    ELSE    run keywords
        ...    selenium_coam.set_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}    AND
        ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Teardown]    selenium_coam.logout
