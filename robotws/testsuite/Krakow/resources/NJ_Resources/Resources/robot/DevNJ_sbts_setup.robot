
*** Setting ***
Documentation
...    author: Cuicui Wang
...    contact: cuicui.wang@nokia-sbell.com
...    Purpose: This file inculde commom suite setup/teardown, test setup/teardowm, suggestion feature team use them
...
...    Clarification: In common setup and teardown keyword, it include catch syslog function, so please confirm:
...    1. In KVM, manually catch syslog should be successfully with btslog tool
...    2. Catch syslog depend on __init__.py, so please confirm config __init__.py as template:
...       https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1264886687
...    3. If there is gnbs=[_cbts] and enbs=[_lteenb] in __init__.py, both gNB and eNB syslog will be catched, so please
...    confirm 1 in both gNB and eNB KVM.

Library           Collections
Library           OperatingSystem
Library           String
Library           Process
Library           taf.ul.sc.tl_config.TestLineConfiguration
#Library           ${CURDIR}/../python/DevNJ_CM_lib
Library           ../python/DevNJ_get_tl_configuration.py    WITH NAME    Get_TL_Configuration
Library           ../python/DevNJ_download_build_from_LS.py  WITH NAME    Download_Obj
Library           ../python/DevNJ_sbts_keywords.py
Library           ../python/DevNJ_btslog.py
Library           ../python/DevNJ_ResourceUsage.py
Resource          ./DevNJ_asicli.robot
Resource          ./DevNJ_epcsim_setup.robot
#Resource          ./DevNJ_upgrade.robot
#Resource          ./DevNJ_testline.robot
Resource          taf/rfrl/common_resources/common_step/interface.robot
Library           ${CURDIR}/../python/DevNJ_SuiteSetup
Library           ${CURDIR}/../python/DevNJ_TruckRoll

*** Variables ***
#${SCF_TEMPLATE_PATH}    ${CURDIR}${/}configuration_file
#${config_dir}  ${OUTPUT DIR}/config/gnb1/
#${WTS_DIR}        /opt/iphy/latest    # can not change because it is hardcode in TA lib
#${BTS_STARTUP_RETRY}    1
#@{PARAMS_IN_SCF}    @{EMPTY}
#@{PARAMS_IN_SWCONFIG}    @{EMPTY}
${FLAG}    ${True}
${tl_type}  ${tl.tl_cloud_topology}
${ENB_BUILD}    null
${Test_Setup_Status}  ${False}
${StopFix}  ${True}


*** Keywords ***
Common Suite Setup For Sbts
    [Arguments]    ${subtype}=${None}    ${bts_type}=all

    Log To Console    \n=====Start: Common Suite Setup For Sbts=====
    Common Env Setup
    Run Keyword If  ${FLAG}==${True}  Prepare Sbts To Onair Status    ${subtype}
    Setup Sbts Btslog Collector    bts_type=${bts_type}
    Log To Console    \n=====End: Common Suite Setup For Sbts=====

Common Suite Teardown For Sbts
    [Arguments]    ${bts_type}=all
    Log To Console    \n=====Start: Common Suite Teardown For Sbts=====
    Run Keyword And Ignore Error  DevNJ_SuiteSetup.Loadpkg Delete  loadname=${ENB_BUILD}
    Teardown Sbts Btslog Collector    bts_type=${bts_type}
    Run Keyword And Ignore Error  BackUp SCF
    Log To Console    \n=====End: Common Suite Teardown For Sbts=====

Common Test Setup For Sbts
    [Arguments]    ${forbidden_fault_id_list}=${None}
    ...  ${allowed_fault_id_list}=${None}
    ...  ${required_fault_id_list}=${None}
    ...  ${cell_status_check_number}=${1}
    ...  ${bts_type}=all
    [Documentation]  Cuicui Wang: Common Test Setup For Sbts
    ...    This Keyword is common for 5G and 4G, but have a limitation

    Set Test Variable  ${Test_Setup_Status}  ${False}
    Log To Console    \n=====Start: Common Test Setup For Sbts=====
    Create Test Log Directory For Sbts
    Start Collecting Sbts Btslog    bts_type=${bts_type}
    ${expected_status}  Create Dictionary  availabilityStatus=Online
    Wait Until Keyword Succeeds  ${cell_status_check_number}x  10  Check Sbts Cell Status  expected_status_dict=${expected_status}
    Check Sbts Active Alarm
    ...  forbidden_fault_id_list=${forbidden_fault_id_list}
    ...  allowed_fault_id_list=${allowed_fault_id_list}
    ...  required_fault_id_list=${required_fault_id_list}
#    Start Get Resources Usage  check_hanging_resouce_flag=${hanging_resource_flag}
    Set Test Variable  ${Test_Setup_Status}  ${True}
    Log To Console    \n=====Common Test Setup For Sbts successfully, set Test_Setup_Status=${Test_Setup_Status}=====
    Log To Console    \n=====End: Common Test Setup For Sbts=====

Common Test Teardown For Sbts
    [Arguments]    ${bts_type}=all
    [Documentation]  Cuicui Wang: Common Test Teardown For Sbts
    ...    This Keyword is common for 5G and 4G, but have a limitation

    Stop Collecting Sbts Btslog  log_dir=${TEST_LOG_DIR}    bts_type=${bts_type}
    ${expected_status}  Create Dictionary  availabilityStatus=Online
    Check Sbts Cell Status  expected_status_dict=${expected_status}
#    Run Keyword And Ignore Error  End Get Resources Usage  check_hanging_resouce_flag=${hanging_resource_flag}
    Log To Console    \n=====Start: Common step trigger=====
    interface.Common Step Trigger
    Log To Console    \n=====End: Common step trigger=====
    Run Keyword And Ignore Error  BackUp SCF  case_dir_flag=${True}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error  Run Keyword If  ${Test_Setup_Status}==${True}
#    ...  Run Keyword If Test Failed  Collect Sbts Snapshot  target_file_name=${TEST_LOG_DIR}/${TEST NAME}.zip  timeout=900  AND
    ...  Run Keyword If Test Failed  Save Snapshot  target_log_dir=${TEST_LOG_DIR}  sub_file_name=${TEST NAME}  timeout=900  AND
    ...  Run Keyword If Test Failed  Run Keyword If  ${StopFix}==${True}  Stop And Fix

Common Env Setup
    ${time}    Get Time
    Log To Console    \n=====Current Time is ${time}=====
    Log To Console    \n=====CURDIR=${CURDIR}=====
    Log Variables
    Run Keyword And Ignore Error    OperatingSystem.Run  sed -i "s/mode:.*/mode: off/" /home/ute/.xscreensaver
    Run Keyword And Ignore Error    OperatingSystem.Run  df -h ${OUTPUT_DIR}
    Create Suite Log Directory For Sbts
    Log To Console    \n=====Setup EPCsim=====
    Run Keyword If  ${FLAG}==${True}  Setup EPCSim
    Run Keyword If  'DAS' not in '${tl_type}' and 'CDD' not in '${tl_type}'  Run Keywords
    ...  Log To Console    \nPerpare CLI  AND
    ...  Install ASI CLI For UTE Cloud

Prepare Sbts To Onair Status
    [Arguments]    ${subtype}
    Waiting For Sbts Connection
    ${the_same_build}  Compare Build Info
    ${cell_status}  Create Dictionary  administrativeState=Unlocked  operationalState=Enabled
    ${cell_status_res}  Run Keyword and Return Status  Check Sbts Cell Status  expected_status_dict=${cell_status}
    Run Keyword If  '${the_same_build}'=='True' and '${cell_status_res}'=='True'
    ...  Change Siso Configuration  ${subtype}
    ...  ELSE  Run Keywords  Log To Console  \n=====Need upgrade=====\n
    ...  AND  Sw Upgrade  loadname=${ENB_BUILD}  comm_subtype=${subtype}

Compare Build Info
    ${sw_version}  Get Sbts Sw Version
    Log To Console  \n=====Current Build is ${sw_version}=====
    Log To Console  \n=====Target Build is ${ENB_BUILD}=====
    @{source_build_list}  Split String  ${sw_version}  _  1
    @{target_build_list}  Split String  ${ENB_BUILD}  _  1
    ${the_same_build}  Set Variable If  '${source_build_list[1]}' == '${target_build_list[1]}'  True  False
    Run Keyword If  '${the_same_build}'=='True'  Log To Console  =====Source load and target load is the same====
    [Return]    ${the_same_build}

Change Siso Configuration
    [Arguments]    ${subtype}
    Log To Console  \n=====Source load and target load is the same and cells are online. Wont upgrade=====\n
    Run Keyword If  '${subtype}'=='${None}'
    ...    Log To Console  \n=====Change Siso configuration will be bypass due to subtype=${subtype}=====\n
    ...    ELSE  Run Keywords  Log To Console  \n=====Change Siso configuration according to subtype: ${subtype}=====\n
    ...    AND  Change Siso  loadname=${ENB_BUILD}  comm_subtype=${subtype}

Create Suite Log Directory For Sbts
    ${SUITE_LOG_DIRECTORY} =    Catenate    SEPARATOR=${/}    ${OUTPUT_DIR}    ${SUITE NAME}
    ${SUITE_LOG_DIRECTORY}    Replace String    ${SUITE_LOG_DIRECTORY}/    ${SPACE}    _
    Remove Directory    ${SUITE_LOG_DIRECTORY}    True
    Create Directory    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_DIRECTORY}
    Log To Console    \n=====LOG_DIR=${SAVE LOG DIRECTORY}=====

Create Test Log Directory For Sbts
    ${TEST_LOG_DIR}  Catenate    SEPARATOR=${/}  ${OUTPUT_DIR}  ${SUITE NAME}  ${TEST NAME}
    ${TEST_LOG_DIR}  Replace String    ${TEST_LOG_DIR}/    ${SPACE}    _
    Remove Directory    ${TEST_LOG_DIR}    True
    Create Directory    ${TEST_LOG_DIR}
    Set Suite Variable    ${TEST_LOG_DIR}
    Log To Console    \n=====LOG_DIR=${TEST_LOG_DIR}=====

Create Directory To Save Backup Scf
    [Arguments]    ${case_dir_flag}=${False}
    ${real_suite_name}  Replace String    ${SUITE NAME}    ${SPACE}    _
    ${sw_version_scf}  Get Sbts Sw Version
    Set Suite Variable  ${sw_version_scf}
    ${Backup_scf_dirctory}  Run Keyword If  ${case_dir_flag}==${True}
    ...  Set Variable  /home/ute/.backup_scf/${sw_version_scf}/${real_suite_name}/cases
    ...  ELSE  Set Variable  /home/ute/.backup_scf/${sw_version_scf}/${real_suite_name}
    ${dirctory_status}  Run Keyword and Return Status  Directory Should Exist  ${Backup_scf_dirctory}
    Run Keyword If  '${dirctory_status}' == 'False'  Create Directory  ${Backup_scf_dirctory}
    Set Suite Variable  ${Backup_scf_dirctory}
    Log To Console    \n=====BK_SCF_DIR=${Backup_scf_dirctory}=====

BackUp SCF
    [Arguments]    ${case_dir_flag}=${False}
    Log To Console    \n=====Start: Backup scf file in teardown=====
    Create Directory To Save Backup Scf  case_dir_flag=${case_dir_flag}
    ${scf_name}  Run Keyword If  ${case_dir_flag}==${True}  Replace String    ${TEST NAME}    ${SPACE}    _
    ...  ELSE  Replace String    ${SUITE NAME}    ${SPACE}    _
    Run Keyword And Ignore Error  Save Bts Scf  local_dir_path=${Backup_scf_dirctory}
    ...  sub_file_name=${scf_name}  export_type=configurationAndRuntimeObjects  timeout=${30}
    Run Keyword And Ignore Error  Save Asir Scf  local_path=${Backup_scf_dirctory}  sub_file_name=${scf_name}
    Run Keyword If  ${case_dir_flag}==${False}  Send Msg To Dataspark  ute_ip=${tl.test_pc.default_ssh_connection_details.addr}
    ...  sw_build=${sw_version_scf}  scf_path=${Backup_scf_dirctory}
    Log To Console    \n=====End: Backup scf file in suite teardown=====
