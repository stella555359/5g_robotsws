# *** Settings ***
# Resource    ../Resources/5GC001541_Keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# Documentation
# ...   author: Liu Zheng
# ...   contact: zheng.4.liu@nokia-sbell.com
# ...   feature_owner: liya.wang@nokia-sbell.com
# ...   squad group: SG_04
# ...   Feature 5GC001541 in 5G19A program, RU type: AWHHD
# 
# Force Tags      5G_SISO         6.8352  1541
# ...    PY36
# 
# Suite Setup      Run Keywords   robot_common_operations.Common Suite Setup   Suite preparation
# 
# Suite Teardown  Run Keywords   robot_common_operations.Common Suite Teardown   AND   Run Keyword And Ignore Error    Suite env recovery
# 
# *** Test Cases ***
# [1]General_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
#     [Tags]    master_classicalbts_all      CRT_TRUNK
#     [Setup]      Run Keywords   robot_common_operations.Common Case Setup    Case preparation for ALD case
#     ${ald_info} =    Get ALD Information via webUI    ald_index=1
#     Run keyword and continue on failure    Should Not Be Empty    ${ald_info["Product code"]}    msg=There is no Product code for ALD
#     Run keyword and continue on failure    Should Not Be Empty    ${ald_info["Serial number"]}    msg=There is no Serial number for ALD
#     Run keyword and continue on failure    Should Not Be Empty    ${ald_info["HW version"]}    msg=There is no HW version for ALD
#     Run keyword and continue on failure    Should Not Be Empty    ${ald_info["SW version"]}    msg=There is no SW version for ALD
#     [Teardown]    Run Keywords   robot_common_operations.Common Case Teardown   AND
#     ...    Run Keyword And Ignore Error   Collect logs in teardown    is_called_in_test_case_level=${True}    AND
#     ...    Run Keyword And Ignore Error   Case env recovery common
# 
# [1]General_SiSo_ALD_State_Management_ALD_state_management_handling_and_visibility
#     [Documentation]    author: Liu Zheng
#     [Setup]      Case preparation for ALD case
#     Check ALD Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=--
#     Check RETU Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=--
#     Disable DC Voltgae For RET Port    mrbts_id=${tl.gnbs[0].instance_id}
#     Wait Until Keyword Succeeds   5 min  5 sec    Check ALD Status    administrative_state=Unlocked
#     ...    availability_status=PowerOff    operational_state=Disabled    procedural_status=not initialized
#     Wait Until Keyword Succeeds   5 min  5 sec    Check RETU Status    administrative_state=Unlocked
#     ...     availability_status=PowerOff    operational_state=Disabled    procedural_status=not initialized
#     Enable DC Voltgae For RET Port    mrbts_id=${tl.gnbs[0].instance_id}
#     ${status}    run keyword and return status    Wait until ALD AND RETU status normal
#     run keyword if    '${status}' == 'False'    WA for ALD cases due to dip adjustment lever hw miss
#     run keyword if    '${status}' == 'False'    Wait until ALD AND RETU status normal
#     [Teardown]    Run Keyword And Ignore Error    Run keywords    Collect logs in teardown    is_called_in_test_case_level=${True}    AND
#     ...    DC Voltage Case recovery
# 
# [1]General_SiSo_ALD_Configuration_Management_RET_calibration_via_command
#     [Tags]    CRT_TRUNK
#     [Documentation]    author: Liu Zheng
#     [Setup]      Run Keywords   robot_common_operations.Common Case Setup    Case preparation for ALD case
#     ${sw_version}    coam.Get Sw Version     connection=GNB_OAM
#     @{result}    string.split string    string=${sw_version}    separator=_
#     ${procedural_status}=    run keyword if    '@{result}[0]' == 'SBTS21B'   set variable     -
#     ...    ELSE    set variable     -
#     Check RETU Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=${procedural_status}
#     Calibrate RETU via webUI
#     ${status}    run keyword and return status  RETU status should be normal
#     run keyword if    '${status}' == 'False'    WA for ALD cases due to dip adjustment lever hw miss
#     run keyword if    '${status}' == 'False'    Wait Until Keyword Succeeds   1 min  5 sec    Check RETU Status    administrative_state=Unlocked
#     ...    availability_status=Online    operational_state=Enabled    procedural_status=${procedural_status}
#     [Teardown]    Run Keywords   robot_common_operations.Common Case Teardown   AND
#     ...    Run Keyword And Ignore Error    Collect logs in teardown    is_called_in_test_case_level=${True}    AND
#     ...    Run Keyword And Ignore Error    Case env recovery common
# 
# *** Keywords ***
# Suite preparation
#     [Documentation]    author: Liu Zheng
#     Run Keyword And Ignore Error    run process    pkill -9 firefox    shell=True
#     COAM Create log directory    is_set_to_test_case_level=${False}
#     ${scf_file_path}    Add ALD information to scf
#     ${scf_params_update}    Combine lists    ${PARAMS_TO_MODIFY_SCF}    ${SCF_MODIFY_VALUE_ALD}
#     Preparation with swconfig modification and comissioning    scf_modify=${scf_params_update}        is_pdl_checking_needed=${PDL_CHECKING}
#     ...    scf_template_path=${scf_file_path}
#     #Run Keyword And Ignore Error    run process    taskkill /f /im chromedriver.exe    shell=True
#     #Run Keyword And Ignore Error    run process    ps -ef|grep chrome | awk '{print $2}' |xargs kill -9    shell=True
#     Run Keyword And Ignore Error    run process    taskkill /f /im firefoxdriver.exe    shell=True
#     Run Keyword And Ignore Error    run process    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9    shell=True
#     Run Keyword And Ignore Error    run process    pkill -9 firefox    shell=True
#     ${status}    run keyword and return status    Wait until ALD AND RETU status normal    timeout=3 min    download_dir=${SUITE_LOG_PATH}
#     run keyword if    '${status}' == 'False'    WA for ALD cases due to dip adjustment lever hw miss    download_dir=${SUITE_LOG_PATH}
#     Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}
#     [Teardown]    Run keyword and ignore error    Tear down all SISO connections
# 
# Suite env recovery
#     [Documentation]    author: Liu Zheng
#     Suite teardown common
# 
# Case preparation for ALD case
#     [Documentation]    author: Liu Zheng
#     COAM Create log directory
#     ${status}    run keyword and return status    Wait until ALD AND RETU status normal    timeout=2 min    download_dir=${TS_CASE_LOG_PATH}
#     run keyword if    '${status}' == 'False'    run keywords
#     ...    WA for ALD cases due to dip adjustment lever hw miss    download_dir=${TS_CASE_LOG_PATH}    AND
#     ...    COAM Wait For Gnb Ready And Cell Setup    timeout=${RECOVERY_TIMEOUT}
#     Connect to gnb coam via ssl
# 
# DC Voltage Case recovery
#     [Documentation]    author: Liu Zheng
#     Run Keyword If Test Failed    Enable DC Voltgae For RET Port
#     Case env recovery common
# 
# WA for ALD cases due to dip adjustment lever hw miss
#     [Documentation]    author: Liu Zheng
#     [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
#     To Reset ALD via webUI    reset_type=software    ald_index=1    download_dir=${download_dir}
#     sleep    30s
#     ${retu_status}    run keyword and return status    Check RETU Status    administrative_state=Unlocked
#     ...    availability_status=Online    operational_state=Enabled    procedural_status=-    download_dir=${download_dir}
#     Run keyword if    '${retu_status}'=='False'    To Reset ALD via webUI    reset_type=software
#     ...    ald_index=1    download_dir=${download_dir}
# 
# 
# To Reset ALD via webUI
#     [Documentation]    Description: To Reset ALD from webui
#     ...    ${reset_type}: value can be software, hardware, defult to use hardware
#     ...    ${ald_index}: index of ALD
#     [Arguments]    ${reset_type}=hardware    ${ald_index}=1    ${download_dir}=${TS_CASE_LOG_PATH}
#     Log to console    Info: ready to Reset ALD
#     COAM Navigate to login page via webUI    download_dir=${download_dir}
# 	${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
#     Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
#     selenium_coam.reset_ald    reset_type=${reset_type}    ald_index=${ald_index}
#     [Teardown]    selenium_coam.logout
# 
# RETU status should be normal
#     [Documentation]    author: Liu Zheng
#     Wait Until Keyword Succeeds   2 min  5 sec    Check RETU Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=initializing
#     Wait Until Keyword Succeeds   3 min  5 sec    Check RETU Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=-
# 
# Wait until ALD AND RETU status normal
#     [Documentation]    author: Liu Zheng
#     [Arguments]    ${timeout}=${5} min   ${download_dir}=${TS_CASE_LOG_PATH}
#     Wait Until Keyword Succeeds   ${timeout}  20 sec    Check ALD Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=-    download_dir=${download_dir}
#     Wait Until Keyword Succeeds   ${timeout}  5 sec    Check RETU Status    administrative_state=Unlocked    availability_status=Online
#     ...    operational_state=Enabled    procedural_status=-    download_dir=${download_dir}
# 
# Add ALD information to scf
#     [Documentation]    author: Liu Zheng
#     ...                this keyword is mainly for add ALD related objects and elements.
#     ...                return the updated scf file path.
#     [Arguments]    ${scf_file_path}=${SCF_DEFAULT_FILE_PATH}
#     ${local_log_file_folder}    set variable    ${SUITE_LOG_PATH}
#     ${default_scf_file_path}    Copy file    source=${scf_file_path}    destination=${local_log_file_folder}
#     ${scf_file_name}    Fetch from right    ${scf_file_path}    /
#     ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
#     ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
#     ...    _ALD_add.xml
#     ${scf_file_update_path}    set variable    ${local_log_file_folder}/${scf_name_for_update}
#     scf.Load scf    ${default_scf_file_path}
#     :For    ${item}    IN    @{ALD_MOS_PARAMS_TO_ADD}
#     \    scf.add object to scf  class_name=&{item}[class_name]    dist_name=&{item}[dist_name]   version=&{item}[version]
#     :For    ${item}    IN    @{ALD_LIST_NAME_PARAMS_TO_ADD}
#     \    scf.add list to scf  dist_name=&{item}[dist_name]   list_name=&{item}[list_name]
#     :For    ${item}    IN    @{ALD_LIST_ITEMS_PARAMS_TO_ADD}
#     \    scf.add item to list  dist_name=&{item}[dist_name]    list_name=&{item}[list_name]    elements=&{item}[elements]
#     :For    ${item}    IN    @{ALD_LIST_ELEMENTS_PARAMS_TO_ADD}
#     \    scf.add elements to list  dist_name=&{item}[dist_name]    list_name=&{item}[list_name]    elements=&{item}[elements]
#     :For    ${item}    IN    @{ALD_ELEMENTS_PARAMS_TO_ADD}
#     \    scf.add element to scf  dist_name=&{item}[dist_name]    p_name=&{item}[p_name]    value=&{item}[value]
#     scf.Save scf    ${scf_file_update_path}
# 
#     ${program}    gnb_classical_hangzhou.Get program version based on stream version
#     ${ret_serial_number}    set variable if    '${program}'=='master'    00000020111200363    00000020111200363
#     ${ret_product_code}     set variable if    '${program}'=='master'    TY-RCUB20    TY-RCUB20
#     Run    sed -i 's/replace_productCode/${ret_product_code}/g' ${scf_file_update_path}
#     Run    sed -i 's/replace_serialNumber/${ret_serial_number}/g' ${scf_file_update_path}
# 
#     [Return]    ${scf_file_update_path}
