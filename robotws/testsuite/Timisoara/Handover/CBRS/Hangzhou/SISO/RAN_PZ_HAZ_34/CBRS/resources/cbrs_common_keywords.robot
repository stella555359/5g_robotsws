*** Settings ***
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_log.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot

Library    SASsimInterface.py
Library    ProxyInterface.py
Library    common.py
Library    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library    robot.libraries.DateTime
Library    Process
Variables    ../TestData/variables.py
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    cbrs_4g_keywords.robot

Documentation    This is for SG8 common keywords
...              Author: linjiangjing & cailanwen & wangqingqing
...              Squard: HZ SG8

*** Variables ***
@{cell_id1}    ${1}
${if_commissioning}   True
${GIT_ACCESS_TOKEN}    glpat-BSYueCsBruKYmUvrCJ7z
${sas_log_path}    ${CURDIR}/SASSim_HZ/SAS_Sim.log
${sas_2_0}    /testsuite/Timisoara/Handover/CBRS/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/SASSim_TS2
${sas_3}    /testsuite/Timisoara/Handover/CBRS/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/SASSim3
${Certificate_set}    ${CURDIR}/certificates
${CBRSAdditionalCa_set}   ${Certificate_set}/5GC001321_TA_1125.pem
${UTEhostip}    ${tl.test_pc.default_ssh_connection_details.addr}


*** Keywords ***
LTE TL CBRS Suite Setup
    [Arguments]    ${feature_scf_flag}=${False}     ${UTECloud}=${False}
    Download Sas Server
    log to console    \n***LTE TL CBRS Suite Setup***
    set suite variable    ${test_teardown_fail}    ${True}
    run keyword if     ${UTECloud}==${True}     cbrs_common_keywords.CBRS UTE Common Suite Setup
    robot_common_operations.CommonSuiteSetup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    run keyword if    ${ute_env}    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${OUTPUT DIR}
    run keyword if    '${feature_scf_flag}'=='False' and '${if_commissioning}'=='True'
    ...    Commissioning SCF And Check RU On Air    scf_file_path=${Golden_SCF_Path}
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${Golden_SCF_Path}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID_enb}
    set suite variable  ${lnbtsID}
    &{fault_7312}     Create Dictionary     faultId=${7312}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    &{fault_6826}     Create Dictionary     faultId=${6826}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7312}    ${fault_7313}    ${fault_6826}
    set suite variable  ${ALLOWED_FAULT}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    delete_icmp_policy
    Run Keyword And Ignore Error    kill SAS server started by manual

LTE TL CBRS Test Setup
    log to console    \n***CBRS Test Setup***
    robot_common_operations.CommonCaseSetup     allowed_faults_ids=6832
    log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${False}
    Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    Run Keyword If    ${ru_status}==${False} or ${SCF_Status}==${True}    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_Path}
    ${scf_path_lte}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    set test variable    ${scf_path_lte}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser
    ${cbsdIds}     Create Dictionary
    set test variable    ${cbsdIds}
    coam.perform_delta_recommissioning    delta_file=${enable_actcbrs}    connection=GNB_OAM

LTE TL CBRS Test Teardown
    log to console    \n***CBRS Test Teardown***
    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim.log
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    robot_common_operations.CommonCaseTeardown
    set suite variable    ${test_teardown_fail}    ${False}
    coam.perform_delta_recommissioning    delta_file=${disable_actcbrs}    connection=GNB_OAM
    kill process for SAS server
    Connect to gnb coam via ssl
#    Wait Until Keyword Succeeds    5 min    5 sec    Verify all cells should be disabled
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    run keyword if test failed     run keywords
    ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

CBRS Suite Setup
    [Arguments]    ${feature_scf_flag}=${False}     ${UTECloud}=${False}
    Download Sas Server
    Unblock SAS In Iptables
    ${cmd}    Set Variable    pip install -i https://artifactory-hz1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple -U pyOpenSSL
    ${rc}    ${output}    Run and Return RC and Output    ${cmd}
    Should Be Equal As Integers    ${rc}    0    msg=${output}
    log to console    \n***CBRS Suite Setup***
    set suite variable    ${test_teardown_fail}    ${True}
    run keyword if     ${UTECloud}==${True}     cbrs_common_keywords.CBRS UTE Common Suite Setup
    robot_common_operations.CommonSuiteSetup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    run keyword if    ${ute_env}    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${OUTPUT DIR}
    run keyword if    '${feature_scf_flag}'=='False' and '${if_commissioning}'=='True'
    ...    Commissioning SCF And Check RU On Air    scf_file_path=${Golden_SCF_Path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${Golden_SCF_Path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${UTEhostip}:4433
    &{fault_61628}     Create Dictionary     faultId=${61628}
    &{fault_7312}     Create Dictionary     faultId=${7312}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7312}    ${fault_7313}    ${fault_61628}
    set suite variable  ${ALLOWED_FAULT}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    add allowed cbrs history fault to the allowed history fault list
    delete_icmp_policy
    Run Keyword And Ignore Error    kill SAS server started by manual
    #kws below added from CBRS 4G resources
    Get SAS Gerrit Repository
    Setup OpenSSL Certifier
    Prepare And Install CBRS Certificates on BTS    alias=GNB_OAM

Unblock SAS In Iptables
    Run  sudo iptables -F
    Run  sudo iptables -X
    Run  sudo iptables-save

CBRS UTE Upgrade Suite Setup
    [Arguments]    ${UTECloud}=${False}
    Download Sas Server
    ${cmd}    Set Variable    pip install -i https://artifactory-hz1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple -U pyOpenSSL
    ${rc}    ${output}    Run and Return RC and Output    ${cmd}
    Should Be Equal As Integers    ${rc}    0    msg=${output}
    log to console    \n***CBRS Suite Setup***
    set suite variable    ${test_teardown_fail}    ${True}
    run keyword if     ${UTECloud}==${True}     cbrs_common_keywords.CBRS UTE Common Suite Setup
    robot_common_operations.CommonSuiteSetup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    run keyword if    ${ute_env}    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${OUTPUT DIR}
    Run Keyword And Ignore Error    Install CBRS Certificate    cert_file=${CBRSAdditionalCa_set}
    ...    cert_type=CBRSAdditionalCa    cert_format=PEM
    Sleep    30s
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${Golden_SCF_Path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    Run Keyword And Ignore Error    Set primarySasServer value    value=${UTEhostip}:4433
    &{fault_61628}     Create Dictionary     faultId=${61628}
    &{fault_7312}     Create Dictionary     faultId=${7312}
    &{fault_7313}     Create Dictionary     faultId=${7313}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_7312}    ${fault_7313}    ${fault_61628}
    set suite variable  ${ALLOWED_FAULT}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    add allowed cbrs history fault to the allowed history fault list
    delete_icmp_policy
    Run Keyword And Ignore Error    kill SAS server started by manual

CBRS Suite Teardown
    log to console    \n***CBRS Suite Teardown***
    robot_common_operations.CommonSuiteTeardown
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    run keyword if    ${test_teardown_fail}    run keywords
    ...    Capture RU logs    target_dir=${SUITE_LOG_PATH}    connection=GNB_OAM    AND
    ...    Save Coam Snapshot    target_dir=${SUITE_LOG_PATH}    connection=GNB_OAM    AND
    ...    Save Coam im snapshot    target_dir=${SUITE_LOG_PATH}    connection=GNB_OAM
    ...    ELSE
    ...    log to console    don't collect snapshot in suite teardown!!!
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

CBRS Test Setup
    [Arguments]    ${actCbrsEnhMeas}=${False}
    log to console    \n***CBRS Test Setup***
    robot_common_operations.CommonCaseSetup     allowed_faults_ids=6832
    AlarmWatchdog.add_allow_alarms    fault_id=6828
    AlarmWatchdog.add_allow_alarms    fault_id=6825
    AlarmWatchdog.add_allow_alarms    fault_id=6829
    AlarmWatchdog.add_allow_alarms    fault_id=6824
    AlarmWatchdog.add_allow_alarms    fault_id=6823
    AlarmWatchdog.add_allow_alarms    fault_id=6826
    AlarmWatchdog.add_allow_alarms    fault_id=4532
    AlarmWatchdog.add_allow_alarms    fault_id=61628
    AlarmWatchdog.add_allow_alarms    fault_id=61625
    AlarmWatchdog.add_allow_alarms    fault_id=6832
    AlarmWatchdog.add_allow_alarms    fault_id=6827
    AlarmWatchdog.add_allow_alarms    fault_id=6830
    AlarmWatchdog.add_allow_alarms    fault_id=6831
    log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path_NR}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${False}
    Set Test Variable    ${Case_SCF_Path}    ${SCF_Path_NR}
#    Run Keyword If    ${ru_status}==${False} or ${SCF_Status}==${True}    Commissioning SCF And Check RU On Air    scf_file_path=${SCF_Path}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    set test variable    ${scf_path}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser
    ${cbsdIds}     Create Dictionary
    set test variable    ${cbsdIds}
    Activate feature CBRS By Coam    actCbrsEnhMeas=${actCbrsEnhMeas}

CBRS Get BTS Info
    [Arguments]   ${connection}=GNB_OAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=${300}
    Set Test Variable   ${bts_name}    ${bts_info["name"]}

Commission SCF and enable actnrcbrs
    [Arguments]    ${scf_file_path}
    Commissioning SCF And Check RU On Air   scf_file_path=${scf_file_path}
    Activate feature CBRS By Coam
    sleep    30s

Grep Message In The Saslog
    [Arguments]    ${msg}    ${path}
    ${rc}    ${output}    Run and Return RC and Output
	...    cat ${path} | grep '${msg}'
    Should not Be Empty    ${output}

verify cell status not degrade or disable by cellid
    [Arguments]    ${cellid}    ${administrative}    ${operationalState}    ${cell_type}=nr    ${connection}=GNB_OAM
    Log to console    verify cell status not degrade or disable by cellid
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run Keyword If     ${cell['physicalCellId']} == ${cellid}
        ...    Run keywords    Should Be Equal As Strings    ${cell['status']['administrativeState']}    ${administrative}    AND
        ...    Should Be Equal As Strings    ${cell['status']['operationalState']}    ${operationalState}    AND
        ...    Dictionary Should Not Contain Key    ${cell['status']}     availabilityStatus    msg=cell is disable or degraded, please check.
        exit for loop if   ${cell['physicalCellId']} == ${cellid}
    END

verify cell status degrade or disable by cellid
    [Arguments]    ${cellid}    ${administrative}    ${operationalState}    ${availabilityStatus}    ${cell_type}=nr    ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run Keyword If     ${cell["physicalCellId"]} == ${cellid}
        ...    Run keywords    Should Be Equal As Strings    ${cell["status"]["administrativeState"]}    ${administrative}    AND
        ...    Should Be Equal As Strings    ${cell["status"]["operationalState"]}    ${operationalState}    AND
        ...    Should Be Equal As Strings    ${cell["status"]["availabilityStatus"]}    ${availabilityStatus}
        exit for loop if   ${cell["physicalCellId"]} == ${cellid}
    END

check RU Availability
    [Arguments]  ${rmod_index}=${1}    ${connection}=GNB_OAM
    ${ru}    COAM get ru detial info by ru index     ru_index=${rmod_index}   connection=${connection}
    Dictionary Should Not Contain Key    ${ru['status']}     availabilityStatus    msg=RU is disable or degraded

Verify all cells should be disabled
    [Arguments]    ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${cells_info}   coam.get_cells_info   timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run keyword and continue on failure    Should be equal as strings    ${cell['status']['operationalState']}    ${disabled}
    END

Verify lte cell should be onair
    [Arguments]    ${cell_index}=${0}    ${cell_type}=lte  ${connection}=enblte
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    Should be equal as Strings    ${cells_info[${cell_index}]['status']['operationalState']}    enabled
    Should Be Equal As Strings    ${cells_info[${cell_index}]['status']['administrativeState']}     unlocked
    Should Be Equal As Strings    ${cells_info[${cell_index}]['status']['blockingState']}    Unblocked

Verify lte cell should be disabled
    [Arguments]    ${cell_index}=${0}    ${cell_type}=lte  ${connection}=enblte
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    Should be equal as Strings    ${cells_info[${cell_index}]['status']['operationalState']}    disabled
    Should Be Equal As Strings    ${cells_info[${cell_index}]['status']['administrativeState']}     unlocked
    Should Be Equal As Strings    ${cells_info[${cell_index}]['status']['blockingState']}    Unblocked

Get mrbtsID and lnbtsID via SCF for eNB
    [Arguments]    ${scf_path}
    ${lncell_info}    Run    cat ${scf_path} | grep -oE "MRBTS-[0-9]+/LNBTS-[0-9]+" | head -n 1
    ${mrbtsID}    Run    echo ${lncell_info}|grep -oE "MRBTS-[0-9]+"| awk -F '-' '{print $2}'
    ${lnbtsID}    Run    echo ${lncell_info}|grep -oE "LNBTS-[0-9]+"| awk -F '-' '{print $2}'
    [Return]    ${mrbtsID}    ${lnbtsID}

CBRS 4G Test Setup
    [Arguments]    ${enable_delta_file}=${enable_actcbrs}
    Connect to eNB via ssl
    coam.perform_delta_recommissioning    delta_file=${enable_delta_file}    connection=enblte
    Sleep    60s

CBRS 4G Test Teardown
    [Arguments]    ${disable_delta_file}=${modify_actcbrs}
    coam.perform_delta_recommissioning    delta_file=${disable_delta_file}    connection=enblte
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be disabled    connection=enblte
    Enblte close down

CBRS Test Teardown
    [Arguments]    ${actCbrsEnhMeas}=${False}
    log to console    \n***CBRS Test Teardown***
    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim.log
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    robot_common_operations.CommonCaseTeardown
    set suite variable    ${test_teardown_fail}    ${False}
    Deactivate feature CBRS By Coam    actCbrsEnhMeas=${actCbrsEnhMeas}
    kill process for SAS server
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    run keyword if test failed     run keywords
    ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

add allowed cbrs history fault to the allowed history fault list
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault6832}    Create Dictionary    faultId=${6832}
    ${fault4532}    Create Dictionary    faultId=${4532}
    ${fault6828}    Create Dictionary    faultId=${6828}
    ${fault6823}    Create Dictionary    faultId=${6823}
    ${fault6824}    Create Dictionary    faultId=${6824}
    ${fault6825}    Create Dictionary    faultId=${6825}
    ${fault6826}    Create Dictionary    faultId=${6826}
    ${fault6827}    Create Dictionary    faultId=${6827}
    ${fault6829}    Create Dictionary    faultId=${6829}
    ${fault6830}    Create Dictionary    faultId=${6830}
    ${fault6831}    Create Dictionary    faultId=${6831}
    ${fault7312}    Create Dictionary    faultId=${7312}
    ${fault7313}    Create Dictionary    faultId=${7313}
    ${fault16}    Create Dictionary    faultId=${16}
    ${fault49}    Create Dictionary    faultId=${49}
    ${fault4614}    Create Dictionary    faultId=${4614}
    ${fault1815}    Create Dictionary    faultId=${1815}
    ${fault10}    Create Dictionary    faultId=${10}
    ${fault4003}    Create Dictionary    faultId=${4003}
    ${fault4589}    Create Dictionary    faultId=${4589}
    ${fault61628}    Create Dictionary    faultId=${61628}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${fault6832}    ${fault6828}    ${fault4532}    ${fault6823}    ${fault6824}
    ...    ${fault6825}    ${fault6826}    ${fault6827}    ${fault6829}    ${fault6830}    ${fault6831}     ${fault7312}   ${fault7313}
    ...    ${fault16}    ${fault49}    ${fault4614}    ${fault1815}    ${fault10}    ${fault4003}    ${fault4589}    ${fault61628}
    Set suite Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}

Set diff json based on release branch
    [Arguments]  ${json1}    ${json2}    ${connection}=GNB_OAM
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"=="SBTS23R2"    coam.perform_delta_recommissioning    delta_file=${json2}    connection=${connection}
    ...    ELSE    coam.perform_delta_recommissioning    delta_file=${json1}    connection=${connection}

kill SAS server started by manual
    ${pid}    run    ps -ef | grep "SAS_Sim" | grep -v grep | awk '{print $2}'
    run keyword if    '${pid}' != '${EMPTY}'    run    kill -9 ${pid.strip()}    ELSE
    ...    log to console    SAS Server is not running, no need to kill

Get CBSDCEL_R value via COAM
    [Arguments]   ${cellID}=1    ${CBSDCELLID}=0     ${pattern}=grantChannelType    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=CBSDCEL_R    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${distname}    generate_correct_cbsdcell_distname    distname_before=${distname_tmp}    cellid=${cellID}    cbsdcelid=${CBSDCELLID}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=${connection}
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Get Parameter value via COAM
    [Arguments]     ${class_name}    ${pattern}    ${connection}=enblte
    ${MO_A}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}
    ${distname}    Set variable    ${MO_A[0]['distName']}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=${connection}
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Get cell carrier freq
    [Arguments]  ${cell_idx}=${1}    ${technology}=NR
    ${info_cell}    selenium_coam.get_cell_info    cell_idx=${cell_idx}    technology=${technology}
    ${carrier_freq_cell}     set variable    ${info_cell['Carrier frequency']}
    ${carrier_freq_cell}    get_carrier_freq    carrier_freq_str=${carrier_freq_cell}
    [Return]    ${carrier_freq_cell}

check cell status by cellid
    [Arguments]    ${cellid}    ${status}    ${cell_type}=lte  ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run Keyword If     ${cell['physicalCellId']} == ${cellid}
        ...    Should be equal as Strings    ${cell['status']['operationalState']}    ${status}
        exit for loop if   ${cell['physicalCellId']} == ${cellid}
    END

check cell availability status by cellid
    [Arguments]    ${cellid}    ${status}    ${cell_type}=lte  ${connection}=GNB_OAM
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run Keyword If     ${cell['physicalCellId']} == ${cellid}
        ...    Should be equal as Strings    ${cell['status']['availabilityStatus']}    ${status}
        exit for loop if   ${cell['physicalCellId']} == ${cellid}
    END

Get LNCEL_TDD_A value via COAM
    [Arguments]   ${cellID}=1    ${LNCEL_TDDID}=0     ${pattern}=chBw    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=LNCEL_TDD_A    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${distname}    generate_correct_LNCEL_TDD_distname    distname_before=${distname_tmp}    cellid=${cellID}    LNCEL_TDDid=${LNCEL_TDDID}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=${connection}
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Check NO Deregister Message by cbsdid
    [Arguments]     ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is not found in saslog    tag={\"deregistrationRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    [Teardown]    end_to_check

Check Deregister Success Message by cbsdid
    [Arguments]     ${cbsdid}
    ${deregister_info}    Set variable    {\"deregistrationRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag=${deregister_info}
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Modify the parameter on NR
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    coam.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=GNB_OAM

Get arfcnSsbPbch By Coam
    [Arguments]    ${cellID}=1    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=NRCELL_R    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${distname}    generate_correct_nrcell_distname    distname_before=${distname_tmp}    cellid=${cellID}
    ${powred}     coam.get_parameters   dist_name=${distname}    pattern=arfcnSsbPbch   connection=${connection}
    [Return]    ${powred}[arfcnSsbPbch]

Get carrierFreqNrCell From 4G By Coam
    [Arguments]    ${connection}=GNB_OAM
    ${MO_A}    coam.get_managed_objects    class_name=NRDCPR_A    connection=${connection}
    ${distname}    Set variable    ${MO_A[0]['distName']}
    ${powred}     coam.get_parameters   dist_name=${distname}/ENDCMEASCONF_A-0    pattern=carrierFreqNrCell   connection=${connection}
    [Return]    ${powred}[carrierFreqNrCell]

Install CBRS Certificate
    [Arguments]    ${cert_file}    ${cert_type}    ${cert_format}    ${connection}=GNB_OAM
    coam.install_certificate    cert_file=${cert_file}    cert_type=${cert_type}
    ...    cert_format=${cert_format}    connection=${connection}

Delete CBRS Certificate
    [Arguments]    ${fingerprint}    ${connection}=GNB_OAM
    coam.delete_certificate    fingerprint=${fingerprint}        domain_type=CBRS    connection=${connection}

Get CBRS Certificate file
    [Arguments]    ${fingerprint}    ${target_file_name}    ${connection}=GNB_OAM
    coam.get_certificate_file    fingerprint=${fingerprint}    target_file_name=${target_file_name}    connection=${connection}

Perform SW rollback
    [Arguments]  ${connection}=GNB_OAM
    coam.rollback_software    connection=${connection}
    Sleep    60s

Activate feature CBRS
    log to console    activate feature CBRS
    Selenium Login And Disable Screen Lock
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR CBRS    p_name=actNrCbrs    value=true
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate graceful cell shutdown    p_name=actGrflShdn    value=true
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}
    [Teardown]    Selenium Logout And Close Browser

Activate feature CBRS By Coam
    [Arguments]    ${connection}=GNB_OAM    ${actCbrsEnhMeas}=${False}
    log to console    activate feature CBRS
    ${parameters}  create list
    ${item}  create dictionary  parameterName=actNrCbrs    operation=update    value=true
    append to list  ${parameters}  ${item}
    ${item}  create dictionary  parameterName=actCbrsEnhMeas    operation=update    value=true
    run keyword if    '${actCbrsEnhMeas}'=='True'    append to list  ${parameters}  ${item}
    coam.perform_object_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...                                        parameter=${parameters}
    ...                                        operation=update
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        connection=${connection}
    Sleep    20s

Online Cell deletion
    [Arguments]  ${deletion_cell}=1  ${deletion_cellgrp}=0    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    selenium login and disable screen lock
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        Exit For Loop If    '${value}'=='${deletion_cellgrp}'
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
#    COAM Check GNB cell on air
    [Teardown]  selenium logout and close browser

Online Cell addition
    [Documentation]  Online last Cell addition deletion via webem
    [Arguments]    ${file_path}    ${addition_cell}=2  ${addition_cellgrp}=1    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    ${cell_grp_len}    get length    ${cell_grp}
    ${cell_grp_len}=   Evaluate    ${cell_grp_len}+1
    selenium login and disable screen lock
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${file_path}    timeout=${300}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    ${new_conf_name}    SG8_common.get_file_name    file_path=${file_path}
    ${new_conf_1}    Replace String    ${new_conf_name}    SCF_    CONF-1_SCF_
    log to console  add object
    Wait Until Keyword Succeeds    2min    10s
    ...    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
#    sleep    3s
    Wait Until Keyword Succeeds    2min    10s
    ...    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
#    sleep    3s
    Wait Until Keyword Succeeds    2min    10s
    ...    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=${new_conf_1}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_cellgrp}
    ...    id_value=${addition_cellgrp}    timeout=15
    ${lcrId}   Convert To Integer   ${addition_cell}
#    sleep    3s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrId}
    # recover NRDU-1 as prev
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN RANGE    0    ${cell_grp_len}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    [Teardown]  selenium logout and close browser

Lock all RUs and check all status in AZQC
    [Arguments]  ${ru_index_list}
    log to console  \n**Lock all RUs and check all status***
    ${led_status_list_lock}    create list    YELLOW YELLOW
    FOR  ${ru_index}  IN  @{ru_index_list}
        Create file in RU    ru_index=${ru_index}
        Collect RF Logs To TestPC    log_name=before_ru_lock    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=before_ru_lock
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  15
        Check LED Status In RU Log    led_status_list=${led_status_list_lock}    log_name=after_ru_lock
        ...    ru_index=${ru_index}    timestamp=${new_timestamp}    exclude_led_status=GREEN GREEN
        Download Soap and Check Ru Lock Unlock Message    type=lock    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
    END

UnLock all RUs and check all status in AZQC
    [Arguments]    ${ru_index_list}
    log to console  \n**UnLock all RUs and check all status***
    ${led_status_list}    create list   GREEN GREEN
    FOR  ${ru_index}  IN  @{ru_index_list}
        Collect RF Logs To TestPC    log_name=before_ru_unlock    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=before_ru_unlock
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        Run Keyword If  ${status}==${False}    Check LED Status In RU Log    led_status_list=${led_status_list}    log_name=after_ru_unlock
        ...    ru_index=${ru_index}    timestamp=${new_timestamp}    exclude_led_status=YELLOW YELLOW
        Download Soap and Check Ru Lock Unlock Message    type=unlock    ru_index=${ru_index}
        Run Keyword If  ${status}==${False}    Check file Exist in RU    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
    END

Check cell status
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${cellflag}=${True}    ${connection}=GNB_OAM
    ${subcell_status}=  coam_siso_common.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Run Keyword If    '${cellflag}'=='True'    Should Be Equal As Strings   ${subcell_status["operationalState"]}   enabled
    ...    ELSE    Should Be Equal As Strings   ${subcell_status["operationalState"]}   disabled
    Should Be Equal As Strings   ${subcell_status["administrativeState"]}  Unlocked
    Should Be Equal As Strings    ${subcell_status["blockingState"]}    Unblocked

Set qRxLevMin value
    [Arguments]    ${value}    ${cellid}=1    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
    ...                                            parameter=qRxLevMin
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=${connection}

Set cbrsFreqPriority value
    [Arguments]    ${value}    ${cellid}=1    ${nrcbsdcell}=0   ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}/NRCBSDCELL-${nrcbsdcell}
    ...                                            parameter=cbrsFreqPriority
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=${connection}

Set actIpThpt value
    [Arguments]    ${value}    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...                                            parameter=actIpThpt
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=${connection}

Set primarySasServer value
    [Arguments]    ${value}    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBRSPR-1
    ...                                            parameter=primarySasServer
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=${connection}

Set actIpThpt value by webem
    [Arguments]    ${actIpThpt}
    ${release}    Get program version based on gNB active version
    ${flitervalue_actIpThpt}=   Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS24R2"
    ...    Set Variable    Activate reporting of DL PDCP cell level and DL/UL RLC cell level PM counters
	...    ELSE    Set Variable    Activate reporting of DL PDCP cell level and DL/UL RLC cell level throughput PM counters
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=${flitervalue_actIpThpt}
	...    target_value=${actIpThpt}
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x    20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${300}

Set primarySasServer value by webem
    [Arguments]    ${primarySasServer}
    ${flitervalue_primarySasServer}=    Set Variable    Primary SAS server
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=${flitervalue_primarySasServer}
    ...    target_value=${primarySasServer}
    selenium_coam.validate_plan
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5x    20s    selenium_coam.activate_plan
    ...    activate_plan_despite_errors=${True}    timeout=${300}

Set channelSpace2020 By webem
    [Arguments]  ${channelSpace2020}    ${flitervalue_channelSpace2020}    ${NRCBSDID}=1
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBRSPR-${NRCBSDID}
    ...    filter_param=${flitervalue_channelSpace2020}
    ...    target_value=${channelSpace2020}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Set channelSpace2020 By Coam
    [Arguments]  ${channelSpace2020}    ${NRCBSDID}=1    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBRSPR-${NRCBSDID}
    ...                                            parameter=channelSpace2020
    ...                                            value=${channelSpace2020}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Get cbrsFreqPriority By Coam
    [Arguments]    ${cellID}=1    ${CBSDCELLID}=0    ${connection}=GNB_OAM
    ${MO_A}    coam.get_managed_objects    class_name=NRCBSDCELL_A    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_A[0]['distName']}
    ${distname}    generate_correct_nrcbsdcell_distname    distname_before=${distname_tmp}    cellid=${cellID}    cbsdcelid=${CBSDCELLID}
    ${powred}     coam.get_parameters   dist_name=${distname}    pattern=cbrsFreqPriority   connection=${connection}
    [Return]    ${powred}[cbrsFreqPriority]

Set CBRS Frequency Type
    [Arguments]    ${type}=PAL    ${NRCBSDID}=1
    log to console    begain to set cbrsFreqType to ${type}...
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}    filter_param=CBRS frequency type
    ...    abbr=cbrsFreqType    new_value=${type}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Set CBRS Frequency Type By Coam
    [Arguments]    ${type}=PAL    ${NRCBSDID}=1    ${connection}=GNB_OAM
    log to console    begain to set cbrsFreqType to ${type}...
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...                                            parameter=cbrsFreqType
    ...                                            value=${type}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}
    Sleep    20s

Get CBRS User Identity By Coam
    [Arguments]    ${connection}=GNB_OAM
    ${MO_A}    coam.get_managed_objects    class_name=NRCBSD_A    connection=${connection}
    ${distname}    Set variable    ${MO_A[0]['distName']}
    ${powred}     coam.get_parameters   dist_name=${distname}    pattern=userId   connection=${connection}
    [Return]    ${powred}[userId]

Set CBRS User Identity
    [Arguments]    ${userId}    ${NRCBSDID}=1
    log to console    begain to set userId to ${userId}...
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}    filter_param=User identity
    ...    abbr=userId    new_value=${userId}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Set CBRS User Identity By Coam
    [Arguments]    ${userId}    ${NRCBSDID}=1    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...                                            parameter=userId
    ...                                            value=${userId}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Get CBRS FCC identity By Coam
    [Arguments]    ${connection}=GNB_OAM
    ${MO_A}    coam.get_managed_objects    class_name=NRCBSD_A    connection=${connection}
    ${distname}    Set variable    ${MO_A[0]['distName']}
    ${powred}     coam.get_parameters   dist_name=${distname}    pattern=fccId   connection=${connection}
    [Return]    ${powred}[fccId]

Set CBRS FCC identity
    [Arguments]    ${fccId}    ${NRCBSDID}=1
    log to console    begain to set fccId to ${fccId}...
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}    filter_param=FCC identity
    ...    abbr=fccId    new_value=${fccId}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Set CBRS FCC identity By Coam
    [Arguments]    ${fccId}    ${NRCBSDID}=1    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...                                            parameter=fccId
    ...                                            value=${fccId}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Set Frequency Channel Value
    [Arguments]    ${frequency_channel}    ${NRCBSDID}=1
    log to console    begain to set supportedSpectrumV2
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}    filter_param=Supported spectrum V2
    ...    abbr=supportedSpectrumV2    new_value=${frequency_channel}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Set Frequency Channel Value By Coam
    [Arguments]    ${frequency_channel}    ${NRCBSDID}=1    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...                                            parameter=supportedSpectrumV2
    ...                                            value=${frequency_channel}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}
    Sleep    20s

Online Change NR CBRS Flag
    [Arguments]  ${actNrCbrs}
    log to console    online change NR CBRS
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}    filter_param=Activate NR CBRS
    ...    abbr=actNrCbrs    new_value=${actNrCbrs}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Change NR CBRS Flag By Coam
    [Arguments]  ${actNrCbrs}  ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...                                            parameter=actNrCbrs
    ...                                            value=${actNrCbrs}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}
    Sleep    20s

Connect to SAS server mode
    [Arguments]  ${connectToSasMode}    ${NRCBSDID}=1
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBRSPR-${NRCBSDID}
    ...    filter_param=Connect to SAS server mode    abbr=connectToSasMode    new_value=${connectToSasMode}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Connect to SAS server mode By Coam
    [Arguments]  ${connectToSasMode}    ${NRCBSDID}=1    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBRSPR-${NRCBSDID}
    ...                                            parameter=connectToSasMode
    ...                                            value=${connectToSasMode}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Deactivate feature CBRS
    log to console    deactivate feature CBRS
    Selenium Login And Disable Screen Lock
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR CBRS    p_name=actNrCbrs    value=false
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate graceful cell shutdown    p_name=actGrflShdn    value=false
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}
    [Teardown]    Selenium Logout And Close Browser

Deactivate feature CBRS By Coam
    [Arguments]    ${actCbrsEnhMeas}=${False}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM
    log to console    deactivate feature CBRS
    ${parameters}  create list
    ${item}  create dictionary  parameterName=actNrCbrs    operation=update    value=false
    append to list  ${parameters}  ${item}
    ${item}  create dictionary  parameterName=actCbrsEnhMeas    operation=update    value=false
    run keyword if    '${actCbrsEnhMeas}'=='True'    append to list  ${parameters}  ${item}
    coam.perform_object_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...                                        parameter=${parameters}
    ...                                        operation=update
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        connection=GNB_OAM
    Sleep    20s
    [Teardown]    COAM Teardown gnb connections

Config SAS Server
    [Arguments]    ${server_ip}=${tl.test_pc.default_ssh_connection_details.addr}   ${server_port}=4433
    Selenium Login And Disable Screen Lock
    log to console    began to config sas server
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBRSPR-1
    ...    filter_param=Primary SAS server    p_name=primarySasServer    value=${server_ip}:${server_port}
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}
    [Teardown]    Selenium Logout And Close Browser

Set SAS UserGroup
    [Arguments]    ${groupType}    ${groupIdString}
    log to console    begin to set nrsasusergroup
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRSASUSERGROUP-1
    ...    filter_param=Group type    p_name=groupType    value=${groupType}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRSASUSERGROUP-1
    ...    filter_param=Group Id string    p_name=groupIdString    value=${groupIdString}
    append to list  ${modify_params}  ${item}
    Selenium Login And Disable Screen Lock
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}

Set SAS UserGroup By Coam
    [Arguments]    ${groupType}    ${groupIdString}    ${connection}=GNB_OAM
    log to console    begin to set nrsasusergroup
    ${parameters}  create list
    ${item}  create dictionary  parameterName=groupType    operation=update    value=${groupType}
    append to list  ${parameters}  ${item}
    ${item}  create dictionary  parameterName=groupIdString    operation=update    value=${groupIdString}
    append to list  ${parameters}  ${item}
    coam.perform_object_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRSASUSERGROUP-1
    ...                                        parameter=${parameters}
    ...                                        operation=update
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        connection=${connection}
    Sleep    20s

Check Register Status
    [Arguments]    ${expect_register_status}=Registered    ${NRCBSDID}=1
    ${cbrs_register_status}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...    filter_param=CBSD registration state
    log to console    cbsd registration state is ${cbrs_register_status}
    Should Be Equal As Strings  ${cbrs_register_status}  ${expect_register_status}

Check Register Status By Coam
    [Arguments]    ${expect_register_status}=Registered    ${NRCBSDID}=1    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=NRCBSD_R    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${path}    ${node_name}=    String.Split String From Right    ${distname_tmp}    /    1
    ${cbrs_register_status}    coam.get_parameters   dist_name=${path}/NRCBSD_R-${NRCBSDID}    pattern=cbsdRegistrationState
    ...    connection=${connection}
    Should Be Equal As Strings  ${cbrs_register_status}[cbsdRegistrationState]  ${expect_register_status}

Check TS Version
    [Arguments]    ${expect_version}=version 1.2
    ${version}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBRSPR-1
    ...    filter_param=WINNF technical specification version
    log to console    ts version is ${version}
    Should Be Equal As Strings  ${version}  ${expect_version}

Check TS Version By Coam
    [Arguments]    ${expect_version}=version 1.2    ${class_name}=NRCBRSPR_R    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}
    ${distname}    Set variable    ${MO_R[0]['distName']}
    ${version}    coam.get_parameters   dist_name=${dist_name}    pattern=wINNFTSVersion   connection=${connection}
    Should Be Equal As Strings  ${version}[wINNFTSVersion]  ${expect_version}

Check if message is found in saslog
     [Arguments]    ${tag}
     ${output}=    find_message    ${tag}
     Should Be True    '${output}' != '${None}'

Check if message is not found in saslog
     [Arguments]    ${tag}
     ${output}=    find_message    ${tag}
     Should Be True    '${output}' == '${None}'

Check if total times of the message in log is matched
    [Arguments]    ${sasMessage}    ${totalTimes}
    ${output}=    verify_sas_messages_total_times    ${sasMessage}    ${totalTimes}
    Should Be True    '${output}' == 'True'

Get Correct Register Parameters Value
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    ${userId}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...    filter_param=User identity
    ${fccId}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...    filter_param=FCC identity
    ${cbsdSerialNumber}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...    filter_param=CBSD serial number
    ${cbsdcategory}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...    filter_param=CBSD device category
    ${groupIdString}     selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRSASUSERGROUP-1
    ...    filter_param=Group Id string
    ${groupType}     selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRSASUSERGROUP-1
    ...    filter_param=Group type
    ${ru_info}    COAM get all ru detail info
    &{ru_info_index}    Set variable    ${ru_info['${ru_index}']}
    ${ru_name}    Set variable    ${ru_info_index}[productName]
    ${register_info}    Set variable    {\"registrationRequest\":.*\"airInterface\":{\"radioTechnology\":\"NR\".*
    ${register_info}    Set variable    ${register_info}\"cbsdCategory\":\"${cbsdcategory}\".*
    ${register_info}    Set variable    ${register_info}\"cbsdInfo\":{\"model\":\"${ru_name}\",\"softwareVersion\":\"${Active_SW_version}\",
    ${register_info}    Set variable
    ...    ${register_info}\"vendor\":\"Nokia\".*"cbsdSerialNumber\":\"${cbsdSerialNumber}(.NR)?\".*\"fccId\":\"${fccId}\".*
    ${register_info}    Run keyword if    '${groupId_need}'=='True'    Set Variable    ${register_info}\"groupId\":\"${groupIdString}\".*
    ...    ELSE    Set Variable     ${register_info}
    ${register_info}    Run keyword if    '${groupType_need}'=='True'    Set Variable    ${register_info}\"groupType\":\"${groupType}\".*
    ...    ELSE    Set Variable     ${register_info}
    ${register_info}    Set variable    ${register_info}\"measCapability\":.*\"RECEIVED_POWER_WITHOUT_GRANT\".*\"userId\":\"${userId}\".*
    set test variable    ${register_info}
    Set To Dictionary    ${cbsdIds}    ${NRCBSDID}    ${userId}_${fccId}_${cbsdSerialNumber}

Get Correct Register Parameters Value By Coam
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=NRCBSD_R    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${path}    ${node_name}=    String.Split String From Right    ${distname_tmp}    /    1
    ${cbsdSerialNumber}    coam.get_parameters   dist_name=${path}/NRCBSD_R-${NRCBSDID}    pattern=cbsdSerialNumber   connection=${connection}
    ${cbsdSerialNumber}    Set variable    ${cbsdSerialNumber}[cbsdSerialNumber]
    ${cbsdcategory}    coam.get_parameters   dist_name=${path}/NRCBSD_R-${NRCBSDID}    pattern=cbsdCategory   connection=${connection}
    ${cbsdcategory}    Set variable    ${cbsdcategory}[cbsdCategory]
    ${MO_A}    coam.get_managed_objects    class_name=NRCBSD_A    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_A[0]['distName']}
    ${path}    ${node_name}=    String.Split String From Right    ${distname_tmp}    /    1
    ${userId}    coam.get_parameters   dist_name=${path}/NRCBSD_A-${NRCBSDID}    pattern=userId   connection=${connection}
    ${userId}    Set variable    ${userId}[userId]
    ${fccId}    coam.get_parameters   dist_name=${path}/NRCBSD_A-${NRCBSDID}    pattern=fccId   connection=${connection}
    ${fccId}    Set variable    ${fccId}[fccId]
    ${MO_A}    coam.get_managed_objects    class_name=NRSASUSERGROUP_A    connection=${connection}
    ${distname}    Set variable    ${MO_A[0]['distName']}
    ${groupIdString}    coam.get_parameters    dist_name=${distname}    pattern=groupIdString   connection=${connection}
    ${groupIdString}    Set variable    ${groupIdString}[groupIdString]
    ${groupType}    coam.get_parameters    dist_name=${distname}    pattern=groupType   connection=${connection}
    ${groupType}    Set variable    ${groupType}[groupType]
    ${ru_info}    COAM get all ru detail info
    &{ru_info_index}    Set variable    ${ru_info['${ru_index}']}
    ${ru_name}    Set variable    ${ru_info_index}[productName]
    ${register_info}    Set variable    {\"registrationRequest\":.*\"airInterface\":{\"radioTechnology\":\"NR\".*
    ${register_info}    Set variable    ${register_info}\"cbsdCategory\":\"${cbsdcategory}\".*
    ${register_info}    Set variable    ${register_info}\"cbsdInfo\":{\"model\":\"${ru_name}\",\"softwareVersion\":\"${Active_SW_version}\",
    ${register_info}    Set variable
    ...    ${register_info}\"vendor\":\"Nokia\".*"cbsdSerialNumber\":\"${cbsdSerialNumber}(.NR)?\".*\"fccId\":\"${fccId}\".*
    ${register_info}    Run keyword if    '${groupId_need}'=='True'    Set Variable    ${register_info}\"groupId\":\"${groupIdString}\".*
    ...    ELSE    Set Variable     ${register_info}
    ${register_info}    Run keyword if    '${groupType_need}'=='True'    Set Variable    ${register_info}\"groupType\":\"${groupType}\".*
    ...    ELSE    Set Variable     ${register_info}
    ${register_info}    Set variable    ${register_info}\"measCapability\":.*\"RECEIVED_POWER_WITHOUT_GRANT\".*\"userId\":\"${userId}\".*
    set test variable    ${register_info}
    Set To Dictionary    ${cbsdIds}    ${NRCBSDID}    ${userId}_${fccId}_${cbsdSerialNumber}

Get Grant Parameters From WEBUI
    [Arguments]    ${cellID}=1    ${CBSDCELLID}=0    ${NRCBSDID}=1
    ${grant_info_on_web}     Create Dictionary
    set test variable    ${grant_info_on_web}
    ${grantId_webui}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}/NRCBSDCELL-${CBSDCELLID}
    ...    filter_param=SAS grant ID
    ${grantMaxEirp_webui}    selenium_coam.Get Parameter Value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}/NRCBSDCELL-${CBSDCELLID}    filter_param=SAS grant max EIRP
    ${grantOperationState_webui}    selenium_coam.Get Parameter Value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}/NRCBSDCELL-${CBSDCELLID}    filter_param=SAS grant operation state
    ${grantSpectrumFreqHigh_webui}    selenium_coam.Get Parameter Value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}/NRCBSDCELL-${CBSDCELLID}    filter_param=Grant spectrum high frequency
    ${grantSpectrumFreqLow_webui}    selenium_coam.Get Parameter Value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}/NRCBSDCELL-${CBSDCELLID}    filter_param=Grant spectrum low frequency
    ${cbrsFreqType_webui}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...    filter_param=CBRS frequency type
    Set To Dictionary    ${grant_info_on_web}    grantId    ${grantId_webui}
    Set To Dictionary    ${grant_info_on_web}    maxEirp    ${grantMaxEirp_webui}
    Set To Dictionary    ${grant_info_on_web}    OperationState    ${grantOperationState_webui}
    Set To Dictionary    ${grant_info_on_web}    SpectrumFreqHigh    ${grantSpectrumFreqHigh_webui}
    Set To Dictionary    ${grant_info_on_web}    SpectrumFreqLow    ${grantSpectrumFreqLow_webui}
    Set To Dictionary    ${grant_info_on_web}    cbrsFreqTyp    ${cbrsFreqType_webui}
    [Return]    ${grant_info_on_web}

Get Op State From WEBUI
    [Arguments]    ${cellID}=1    ${CBSDCELLID}=0
    ${op_state}    selenium_coam.Get Parameter Value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}/NRCBSDCELL-${CBSDCELLID}    filter_param=SAS grant operation state
    [Return]    ${op_state}

Get Pmax From WEBUI
    [Arguments]    ${cellID}=1
    ${pMax}    selenium_coam.Get Parameter Value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}    filter_param=Maximum output power
    [Return]    ${pMax}

Get pMax By Coam
    [Arguments]    ${cellID}=1    ${connection}=GNB_OAM
    ${MO_A}    coam.get_managed_objects    class_name=NRCELL_A    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_A[0]['distName']}
    ${distname}    generate_correct_nrcell_distname    distname_before=${distname_tmp}    cellid=${cellID}
    ${powred}     coam.get_parameters   dist_name=${distname}    pattern=pMax   connection=${connection}
    [Return]    ${powred}[pMax]

Set desiredPmax By WEBEM
    [Arguments]    ${value}    ${cellID}=1    ${CBSDCELLID}=0
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}/NRCBSDCELL-${CBSDCELLID}
    ...    filter_param=Desired maximum output power
    ...    abbr=desiredPmax    new_value=${value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Get desiredPmax From WEBUI
    [Arguments]    ${cellID}=1    ${CBSDCELLID}=0
    ${desiredPmax}    selenium_coam.Get Parameter Value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}/NRCBSDCELL-${CBSDCELLID}    filter_param=Desired maximum output power
    [Return]    ${desiredPmax}

Get desiredPmax By Coam
    [Arguments]    ${cellID}=1    ${CBSDCELLID}=0    ${connection}=GNB_OAM
    ${MO_A}    coam.get_managed_objects    class_name=NRCBSDCELL_A    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_A[0]['distName']}
    ${distname}    generate_correct_nrcbsdcell_distname    distname_before=${distname_tmp}    cellid=${cellID}    cbsdcelid=${CBSDCELLID}
    ${release}    Get program version based on gNB active version
    ${powred}    Run Keyword If   "${release}"=="SBTS22R2"
    ...    coam.get_parameters   dist_name=${distname}    pattern=desiredPmax   connection=${connection}
    ...    ELSE    coam.get_parameters   dist_name=${distname}    pattern=configSetForVariChBw   connection=${connection}
    ${desiredPmax}    Run Keyword If   "${release}"=="SBTS22R2"    Set variable    ${powred}[desiredPmax]
    ...    ELSE    Set variable    ${powred}[configSetForVariChBw][0][desiredPmax]
    [Return]    ${desiredPmax}

Get antennaGain From WEBUI
    [Arguments]    ${NRCBSDID}=1
    ${antennaGain}    selenium_coam.Get Parameter Value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}    filter_param=Antenna gain
    [Return]    ${antennaGain}

Get antennaGain By Coam
    [Arguments]   ${connection}=GNB_OAM
    ${MO_A}    coam.get_managed_objects    class_name=NRCBSD_A    connection=${connection}
    ${distname}    Set variable    ${MO_A[0]['distName']}
    ${powred}     coam.get_parameters   dist_name=${distname}    pattern=antennaGain   connection=${connection}
    [Return]    ${powred}[antennaGain]

Get subGrantInfo Item by Coam
    [Arguments]    ${pattern}=grantIdSub    ${cellID}=1    ${index}=0    ${CBSDCELLID}=0    ${connection}=GNB_OAM
    ${subGrantInfo}    Get subGrantInfo by Coam    cellID=${cellID}    CBSDCELLID=${CBSDCELLID}    connection=${connection}
    ${subGrantInfo}    sorted_subGrantInfo_list    subGrantInfo_list=${subGrantInfo}[subGrantInfo]
    [Return]    ${subGrantInfo}[${index}][${pattern}]

Get subGrantInfo by Coam
    [Arguments]    ${cellID}=1    ${CBSDCELLID}=0    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=NRCBSDCELL_R    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${distname}    generate_correct_nrcbsdcell_distname    distname_before=${distname_tmp}    cellid=${cellID}    cbsdcelid=${CBSDCELLID}
    ${subGrantInfo}    coam.get_parameters   dist_name=${distname}    pattern=subGrantInfo   connection=${connection}
    [Return]    ${subGrantInfo}

Get Grant Parameters By Coam
    [Arguments]    ${cellID}=1    ${CBSDCELLID}=0    ${NRCBSDID}=1    ${connection}=GNB_OAM
    ${grant_info_coam}     Create Dictionary
    ${MO_R}    coam.get_managed_objects    class_name=NRCBSDCELL_R    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${distname}    generate_correct_nrcbsdcell_distname    distname_before=${distname_tmp}    cellid=${cellID}    cbsdcelid=${CBSDCELLID}
    ${release}    Get program version based on gNB active version
    FOR    ${i}    IN RANGE    0    30
        ${grantId_coam}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
        ...    coam.get_parameters   dist_name=${distname}    pattern=grantId    connection=${connection}
        ...    ELSE    Get subGrantInfo by Coam    cellID=${cellID}    CBSDCELLID=${CBSDCELLID}
        ${grantId_coam}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
        ...    Set Variable     ${grantId_coam}[grantId]
        ...    ELSE    Set Variable     ${grantId_coam}[subGrantInfo][0][grantIdSub]
        Exit For Loop If    '${grantId_coam}'!='None'
        Sleep    2s
    END
    ${grantChannelType_coam}    coam.get_parameters   dist_name=${distname}    pattern=grantChannelType   connection=${connection}
    ${grantMaxEirp_coam}    coam.get_parameters   dist_name=${distname}    pattern=grantMaxEirp   connection=${connection}
    ${grantOperationState_coam}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    coam.get_parameters   dist_name=${distname}    pattern=grantOperationState    connection=${connection}
	...    ELSE    Get subGrantInfo by Coam    cellID=${cellID}    CBSDCELLID=${CBSDCELLID}
    ${grantOperationState_coam}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Set Variable     ${grantOperationState_coam}[grantOperationState]
	...    ELSE    Set Variable     ${grantOperationState_coam}[subGrantInfo][0][grantOperationStateSub]
    ${grantSpectrumFreqHigh_coam}    coam.get_parameters   dist_name=${distname}    pattern=grantSpectrumFreqHigh    connection=${connection}
    ${grantSpectrumFreqLow_coam}    coam.get_parameters   dist_name=${distname}    pattern=grantSpectrumFreqLow    connection=${connection}
    ${MO_A}    coam.get_managed_objects    class_name=NRCBSD_A    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_A[0]['distName']}
    ${path}    ${node_name}=    String.Split String From Right    ${distname_tmp}    /    1
    ${cbrsFreqType_coam}    coam.get_parameters   dist_name=${path}/NRCBSD_A-${NRCBSDID}    pattern=cbrsFreqType   connection=${connection}
    Set To Dictionary    ${grant_info_coam}    grantId    ${grantId_coam}
    Set To Dictionary    ${grant_info_coam}    grantChannelType    ${grantChannelType_coam}[grantChannelType]
    Set To Dictionary    ${grant_info_coam}    maxEirp    ${grantMaxEirp_coam}[grantMaxEirp]
    Set To Dictionary    ${grant_info_coam}    OperationState    ${grantOperationState_coam}
    Set To Dictionary    ${grant_info_coam}    SpectrumFreqHigh    ${grantSpectrumFreqHigh_coam}[grantSpectrumFreqHigh]
    Set To Dictionary    ${grant_info_coam}    SpectrumFreqLow    ${grantSpectrumFreqLow_coam}[grantSpectrumFreqLow]
    Set To Dictionary    ${grant_info_coam}    cbrsFreqTyp    ${cbrsFreqType_coam}[cbrsFreqType]
    [Return]    ${grant_info_coam}

Get Op State By Coam
    [Arguments]    ${cellID}=1    ${CBSDCELLID}=0    ${connection}=GNB_OAM
    ${MO_R}    coam.get_managed_objects    class_name=NRCBSDCELL_R    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${distname}    generate_correct_nrcbsdcell_distname    distname_before=${distname_tmp}    cellid=${cellID}    cbsdcelid=${CBSDCELLID}
    ${op_state}    coam.get_parameters   dist_name=${distname}    pattern=grantOperationState    connection=${connection}
    [Return]    ${op_state}[grantOperationState]

Get NRCBSDCELL_R value via COAM
    [Arguments]   ${cellID}=1    ${CBSDCELLID}=0     ${pattern}=grantOperationState
    ${MO_R}    coam.get_managed_objects    class_name=NRCBSDCELL_R    connection=GNB_OAM
    ${distname_tmp}    Set variable    ${MO_R[0]['distName']}
    ${distname}    generate_correct_nrcbsdcell_distname    distname_before=${distname_tmp}    cellid=${cellID}    cbsdcelid=${CBSDCELLID}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=GNB_OAM
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Check GrantOperationState Status Success
    [Arguments]   ${cellID}=1    ${Status}=Authorized
    ${release}    Get program version based on gNB active version
    ${GrantOperationState}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"
    ...    Get NRCBSDCELL_R value via COAM    cellID=${cellID}
	...    ELSE    Get subGrantInfo Item by Coam    cellID=${cellID}    pattern=grantOperationStateSub
    Should be True    '${GrantOperationState}' == '${Status}'

Get maxGrantPwrRed On WEBUI
    [Arguments]    ${cellID}=1    ${CBSDCELLID}=0
    ${powred}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}/NRCBSDCELL-${CBSDCELLID}
    ...    filter_param=Maximum allowed grant power reduction
    log to console    maxGrantPwrRed is: ${powred}
    [Return]    ${powred}

Get maxGrantPwrRed By Coam
    [Arguments]    ${cellID}=1    ${CBSDCELLID}=0    ${connection}=GNB_OAM
    ${MO_A}    coam.get_managed_objects    class_name=NRCBSDCELL_A    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_A[0]['distName']}
    ${distname}    generate_correct_nrcbsdcell_distname    distname_before=${distname_tmp}    cellid=${cellID}    cbsdcelid=${CBSDCELLID}
    ${release}    Get program version based on gNB active version
    ${powred}    Run Keyword If   "${release}"=="SBTS22R2"
    ...    coam.get_parameters   dist_name=${distname}    pattern=maxGrantPwrRed   connection=${connection}
    ...    ELSE    coam.get_parameters   dist_name=${distname}    pattern=configSetForVariChBw   connection=${connection}
    ${maxGrantPwrRed}    Run Keyword If   "${release}"=="SBTS22R2"    Set variable    ${powred}[maxGrantPwrRed]
    ...    ELSE    Set variable    ${powred}[configSetForVariChBw][0][maxGrantPwrRed]
    [Return]    ${maxGrantPwrRed}

Check Register Success Message
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdId}(.NR)?\".*\"responseCode\": 0.*
#    Check if message is not found in saslog    tag=${register_info}
    [Teardown]    end_to_check

Check Deregister Success Message
    [Arguments]    ${NRCBSDID}=1
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    ${deregister_info}    Set variable    {\"deregistrationRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${deregister_info}
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"cbsdId\": \"${cbsdId}(.NR)?\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Set CBRS FCC And User identity
    [Arguments]    ${userId}    ${fccId}    ${NRCBSDID}=1
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}    filter_param=User identity
    ...    abbr=userId    new_value=${userId}
    selenium_coam.set_parameter_value  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}    filter_param=FCC identity
    ...    abbr=fccId    new_value=${fccId}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Set CBRS FCC And User identity By COAM
    [Arguments]    ${userId}    ${fccId}    ${NRCBSDID}=1    ${connection}=GNB_OAM
    ${parameters}  create list
    ${item}  create dictionary  parameterName=userId    operation=update    value=${userId}
    append to list  ${parameters}  ${item}
    ${item}  create dictionary  parameterName=fccId    operation=update    value=${fccId}
    append to list  ${parameters}  ${item}
    coam.perform_object_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-${NRCBSDID}
    ...                                        parameter=${parameters}
    ...                                        operation=update
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        connection=${connection}

Online Delta Commission
    [Arguments]    ${dist_name}    ${filter_param}    ${target_value}
    ${current_value}    selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=${filter_param}
    run keyword if  not '${current_value}'=='${target_value}'
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    ...    new_value=${target_value}

Online Change desiredPmax maxGrantPwrRed And antennaGain
    [Arguments]    ${desiredPmax}    ${maxGrantPwrRed}    ${antennaGain}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
    ...    filter_param=Desired maximum output power    target_value=${desiredPmax}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1/NRCBSDCELL-0
    ...    filter_param=Maximum allowed grant power reduction    target_value=${maxGrantPwrRed}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-1
    ...    filter_param=Antenna gain    target_value=${antennaGain}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

create configSetForVariChBw list
    [Arguments]    ${maxGrantPwrRed}    ${desiredPmax}    ${chBw}=20MHz    ${bwpDN1}=0    ${bwpDN2}=40     ${cSRS}=13
    ...   ${csirsTrackingPeriod}=80ms    ${aggregationLevel}=4CCEs    ${msg1FrequencyStart}=5     ${reqMinNumPuschPrb}=19    ${startRB}=0
    ${release}    Get program version based on gNB active version
    ${tmp}    Run Keyword If   "${release}"=="SBTS22R3"    create dictionary
    ...    bwpDN    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-${bwpDN2}
    ...    chBw    20MHz
    ...    desiredPmax    ${desiredPmax}
    ...    maxGrantPwrRed    ${maxGrantPwrRed}
    ...    ELSE    create dictionary
    ...    aggregationLevel    ${aggregationLevel}
    ...    bwpDN1    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-${bwpDN1}
    ...    bwpDN2    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-${bwpDN2}
    ...    chBw    ${chBw}
    ...    csirsTrackingPeriod    ${csirsTrackingPeriod}
    ...    cSRS    ${cSRS}
    ...    desiredPmax    ${desiredPmax}
    ...    maxGrantPwrRed    ${maxGrantPwrRed}
    ...    msg1FrequencyStart    ${msg1FrequencyStart}
    ...    reqMinNumPuschPrb    ${reqMinNumPuschPrb}
    ...    startRB    ${startRB}
    ${tmp}     Create List    ${tmp}
    [Return]    ${tmp}

Change desiredPmax maxGrantPwrRed And antennaGain by Coam
    [Arguments]    ${desiredPmax}    ${maxGrantPwrRed}    ${antennaGain}    ${cellid}=1    ${connection}=GNB_OAM
    ${release}    Get program version based on gNB active version
    ${tmp}    create configSetForVariChBw list    maxGrantPwrRed=${maxGrantPwrRed}    desiredPmax=${desiredPmax}
    ${configSetForVariChBw}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}/NRCBSDCELL-0
    ...    parameter    configSetForVariChBw
    ...    value        ${tmp}
    ${desiredPmax_22r2}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}/NRCBSDCELL-0
    ...    parameter    desiredPmax
    ...    value        ${desiredPmax}
    ${maxGrantPwrRed_22r2}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}/NRCBSDCELL-0
    ...    parameter    maxGrantPwrRed
    ...    value        ${maxGrantPwrRed}
    ${antennaGain}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCBSD-1
    ...    parameter    antennaGain
    ...    value        ${antennaGain}
    ${parameters}    Run Keyword If   "${release}"=="SBTS22R2"    Create List    ${desiredPmax_22r2}    ${maxGrantPwrRed_22r2}    ${antennaGain}
    ...    ELSE    Create List    ${configSetForVariChBw}    ${antennaGain}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}

Check not find channel 3550-3570 in SI procedure
    prepare_to_check_message_from_start
    ${req}    Set variable    {\"spectrumInquiryRequest\":.*\"inquiredSpectrum\":.*\"lowFrequency\":3550000000.*\"highFrequency\":3570000000.*
    ${resp}    Set variable    {\"spectrumInquiryResponse\":.*"availableChannel":.*\"lowFrequency\": 3550000000.*\"highFrequency\": 3570000000.*
    Check if message is not found in saslog    tag=${req}
    Check if message is not found in saslog    tag=${resp}
    [Teardown]    end_to_check

Check online modification registration procedure
    [Arguments]    ${NRCBSDID}=1    ${ru_index}=1
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"cbsdId\": \"${cbsdId}(.NR)?\".*\"responseCode\": 0.*
    Get Correct Register Parameters Value By Coam    groupId_need=${False}    groupType_need=${False}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId_new}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdId_new}(.NR)?\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId_new}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId_new}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId_new}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId_new}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId_new}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId_new}(.NR)?".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Register Fail Message Dueto Code 201
    [Arguments]    ${groupId_need}=${False}    ${groupType_need}=${False}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 201.*
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"responseCode\": 201.*
    Check if total times of the message in log is matched
    ...    sasMessage='\"registrationResponse\":.*\"cbsdId\":.*\"${cbsdId}(.NR)?\"'
    ...    totalTimes=${0}
    [Teardown]    end_to_check

Check SAS Mode Online Change procedure
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check cbrs Freq Type Online Change procedure
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check heartbeat Success According Pointed Times
    [Arguments]    ${times}=1
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*\"maxEirp\":.*\"highFrequency\":.*\"lowFrequency\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    FOR    ${i}    IN RANGE    0    ${times}
        Check if message is found in saslog    tag={\"heartbeatRequest\":.*
        Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    END
    [Teardown]    end_to_check

Check Spectrum Inquiry Success Message
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Grant Success Message
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check CBRS Process Success
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?.*\"responseCode\": 0.*
    log to console    Check CBRS Process Success
    [Teardown]    end_to_check

Check Case 84 CBRS Process
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    ${req}    Set variable    {\"spectrumInquiryRequest\":.*\"inquiredSpectrum\":.*\"lowFrequency\":3550000000.*\"highFrequency\":3570000000.*
    ${resp}    Set variable    {\"spectrumInquiryResponse\":.*"availableChannel":.*\"lowFrequency\": 3550000000.*\"highFrequency\": 3570000000.*
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag=${req}
    Check if message is found in saslog    tag=${resp}
    [Teardown]    end_to_check

Check Case 80 CBRS Process
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*
    [Teardown]    end_to_check

Check Case 81 CBRS Process
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set test variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is not found in saslog    tag={\"relinquishmentRequest\":.*
    Check if message is not found in saslog    tag={\"relinquishmentResponse\":.*
    [Teardown]    end_to_check

Check heartbeat Suspend for first Grant
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    ${grantId_1}    Get grantID value from saslog    filepath=${sas_log_path}
    set test variable    ${grantId_1}
    Check if message is found in saslog    tag=grant ${grantId_1} change op state to Granted from Idle
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*"grantId":\"${grantId_1}"\.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": "${grantId_1}".*"responseCode": 501.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    log to console    Check heartbeat Suspend for first Grant Success
    [Teardown]    end_to_check

Check heartbeat fail procedure with Code 100
    [Arguments]    ${groupId_need}=${True}    ${groupType_need}=${True}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdId}(.NR)?\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 100.*
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"cbsdId\": \"${cbsdId}(.NR)?\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdId}(.NR)?\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check SAS Running Success Message
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=accepted new connection
    log to console    SAS server Running Success
    sleep    1s

Check heartbeat Success Message with GrantId
    [Arguments]    ${grantId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*"grantId":\"${grantId}"\.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": \"${grantId}"\.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check heartbeat Success Message
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check heartbeat 501 with GrantId
    [Arguments]    ${grantId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*"grantId":\"${grantId}"\.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": \"${grantId}"\.*\"responseCode\": 501.*
    [Teardown]    end_to_check

Check relinquishment Success Message
    [Arguments]    ${grantId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*"grantId":"${grantId}".*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*"grantId": "${grantId}".*"responseCode": 0.*
    [Teardown]    end_to_check

Check No relinquishmentRequest procedure
    [Arguments]     ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is not found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    [Teardown]    end_to_check

Check Spectrum Inquiry Fail Message Dueto Code 106
    [Arguments]    ${groupId_need}=${False}    ${groupType_need}=${False}    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${groupId_need}    groupType_need=${groupType_need}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    prepare_to_check_message_from_start
    ${spectrum}    generate_inquire_spectrum_info    inquiredspectrumlist=${inquiredSpectrum}
    ${powermeas}    generate_power_means_report    powermeaslist=${rcvdPowerMeasReports}
    ${inquiry_info}    Set variable    {\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*${spectrum}${powermeas}
    Check if message is found in saslog    tag=${inquiry_info}
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 106.*
    Check if message is found in saslog    tag=${inquiry_info}
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 106.*
    ${means_check}    check_power_means    filepath=${sas_log_path}
    Should Be True    '${means_check}' == 'True'
    [Teardown]    end_to_check

Check GAA Channel Create Success Request
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*\"maxEirp\":.*\"highFrequency\":.*\"lowFrequency\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"grantId\":.*\"channelType\": \"GAA\".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check Grant Request with Code 400
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*\"highFrequency\":.*"lowFrequency":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"maxEirp\":.*\"lowFrequency\":.*\"highFrequency\":.*\"responseCode\": 400.*
    ${maxErip_first_request}    get_maxeirp_in_first_grantrequest    filepath=${sas_log_path}
    ${grant_info_from_log}    get_recommend_value_from_grant_response    filepath=${sas_log_path}
    log to console    grant info from saslog: ${grant_info_from_log}
    ${maxEirp_log}    set variable    ${grant_info_from_log}[maxEirp]
    ${highFreq_log}    set variable    ${grant_info_from_log}[highFrequency]
    ${lowFreq_log}    set variable    ${grant_info_from_log}[lowFrequency]
    ${grantId_log}    set variable    ${grant_info_from_log}[grantId]
    ${maxGrantPwrRed}    Get maxGrantPwrRed By Coam
    ${maxErip_use}    get_valid_maxerip    requesvalue=${maxErip_first_request}    recommandvalue=${maxEirp_log}
    ...    maxgrantpwrred=${maxGrantPwrRed}
    ${request_new}    set variable    {\"grantRequest\":.*\"maxEirp\":${maxErip_use}.*\"highFrequency\":${highFreq_log},"lowFrequency":${lowFreq_log}
    Check if message is found in saslog    tag=${request_new}
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
#    Check if total times of the message in log is matched
#    ...    sasMessage='\"spectrumInquiryRequest\":.*'
#    ...    totalTimes=${1}
    ${maxEirp_log}    set variable    ${maxErip_use}
    set test variable    ${maxEirp_log}
    set test variable    ${highFreq_log}
    set test variable    ${lowFreq_log}
    set test variable    ${grantId_log}
    [Teardown]    end_to_check

Check Grant Msg with Code 401
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 401.*
    ${grant_id_1}    get_grantID_from_grantRequest   filepath=${sas_log_path}    msg_index=1
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*\"responseCode\": 0.*
    ${grant_id_2}    get_grantID_from_grantRequest    filepath=${sas_log_path}    msg_index=2
    Should Be True    '${grant_id_1}'=='${grant_id_2}'
    [Teardown]    end_to_check

Check if bts is pingable
    [Arguments]    ${gnb_index}=0    ${IP}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${output}    Run    sudo ping -c 1 -W 10 ${IP}
    Should contain    ${output}    1 packets transmitted, 1 received

Commissioning SCF And Check RU On Air
    [Arguments]  ${scf_file_path}
    Log to console    +++Commissioning SCF And Check RU On Air+++
    Log to console    SCF Path:${scf_file_path}
    COAM Commission with scf file  scf_file_path=${scf_file_path}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    sleep    300s
    Check RU Onair

Check RU Onair
    [Arguments]   ${connection}=GNB_OAM
    Wait Until Keyword Succeeds  15min  5s  Check if bts is pingable
    FOR    ${i}    IN RANGE    0    30
        ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status    connection=${connection}
        exit for loop if    ${ru_status}
        sleep    30s
    END
    should be true    ${ru_status}

Get CBSD Numbers
    [Arguments]  ${scf_file_path}
    ${cbsd_num}    get_str_appeared_times_in_file    str=class=\"com.nokia.srbts.nrbts:NRCBSD\"    filepath=${scf_file_path}
    log to console    cbsd_num is ${cbsd_num}
    [Return]    ${cbsd_num}

Environment Recovery
    [Arguments]    ${actCbrsEnhMeas}=${False}
    Run Keywords    Deactivate feature CBRS By Coam    actCbrsEnhMeas=${actCbrsEnhMeas}    AND
    ...    save_sas_log    dstFile=${TS_CASE_LOG_PATH}/SAS_Sim.log    AND
    ...    kill process for SAS server

Check CBRS L3 call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]check CBRS L3 call (1CC)
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${tput}    ${target_avg_percent}=0.5    ${min_percent}=0.2    ${duration}=${60}
    UE attach and start traffic    ue_index=${0}    dl_tp=${tput['dl_send']}     ul_tp=${tput['ul_send']}
    log to console    \n***Start Collect Throughput***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id1}    Convert To String    ${cell_mapping[1]['nrCellIdentity']}
    ${cell_id1}    Create List    ${cell_id1}
    log to console    \n***Start Check Throughput***
    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    Run keywords  run keyword and ignore error    csn.disconnect    connection=ASIK Master  AND
    ...    run keyword and ignore error    Stop Single UE L3 Call

Check CBRS Mobility L3 call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]check CBRS Mobility L3 call
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${tput}    ${target_avg_percent}=0.5    ${min_percent}=0.2    ${duration}=${60}
    UE attach and start traffic    ue_index=${0}    dl_tp=${tput['dl_send']}     ul_tp=${tput['ul_send']}
    log to console    \n***adjust PA***
    log to console    \n***Start Collect Throughput***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id2}    Convert To String    ${cell_mapping[2]['nrCellIdentity']}
    ${cell_id2}    Create List    ${cell_id2}
    log to console    \n***Start Check Throughput***
    power_ue.Check Bi Tput    log=${tput_log}    cells=${cell_id2}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    Run keywords  run keyword and ignore error    csn.disconnect    connection=ASIK Master  AND
    ...    run keyword and ignore error    Stop Single UE L3 Call

Check Grant New Success
    [Arguments]   ${grantId_old}=${grantId_1}
    ${release}    Get program version based on gNB active version
    ${grantId_new}    Run Keyword If   "${release}"=="SBTS24R1" or "${release}"=="SBTS23R4"    Get NRCBSDCELL_R value via COAM    pattern=grantId
	...    ELSE    Get subGrantInfo Item by Coam    pattern=grantIdSub
    Should Be True    '${grantId_new}' != '${None}'
    Should be True    '${grantId_new}' != '${grantId_old}'
    Set test variable    ${grantId_new}

Get chBw and nrarfcn By Coam
    ${info_coam}     Create Dictionary
    ${chBw_coam}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=chBw
    ${nrarfcn_coam}    Get NRCELL Value By Coam    class_name=NRCELL_A    pattern=nrarfcn
    Set To Dictionary    ${info_coam}    chBw    ${chBw_coam}
    Set To Dictionary    ${info_coam}    nrarfcn    ${nrarfcn_coam}
    [Return]    ${info_coam}

Check grantRenew set to true
    log to console    Check grantRenew set to true
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"grantRenew\":true.*
    [Teardown]    end_to_check

Check heartbeat Suspend for second Grant
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    ${grantId_1}    Get grantID value from saslog    filepath=${sas_log_path}
    set test variable    ${grantId_1}
    Check if message is found in saslog    tag=grant ${grantId_1} change op state to Granted from Idle
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*"grantId":\"${grantId_1}"\.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 501.*
    log to console   Trigger heartbeat Suspend 501 for the second grant
    ${grantId_list}    get_all_grantID_value_from_saslog    filepath=${sas_log_path}
    Set test variable    ${grantId_2}    ${grantId_list[1]}
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantId_2}"\.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*"grantId":\"${grantId_2}"\.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": \"${grantId_2}"\.*\"responseCode\": 501.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*"grantId":\"${grantId_2}"\.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*"grantId": "${grantId_2}".*\"responseCode\": 0.*
    log to console   Check The Third Grant Success
    ${grantId_list}    get_all_grantID_value_from_saslog    filepath=${sas_log_path}
    Set test variable    ${grantId_3}    ${grantId_list[2]}
    Check if message is found in saslog    tag={\"grantRequest\":.*
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantId_3}"\.*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    10s    2s    Check Grant New Success    grantId_old=${grantId_1}
    Wait Until Keyword Succeeds    10s    2s    Check GrantOperationState Status Success
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*"grantId":\"${grantId_1}"\.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 0.*\
    [Teardown]    end_to_check

Trigger heartbeat terminat for first Grant
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*"grantId":"${grantId_1}".*
    Check if message is found in saslog
    ...    tag={"heartbeatResponse":.*"cbsdId": "${cbsdId}(.NR)?".*"grantId": "${grantId_1}".*"responseCode": 500.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check heartbeat terminat for second Grant
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*
    ${grantId_1}    Get grantID value from saslog    filepath=${sas_log_path}
    set test variable    ${grantId_1}
    Check if message is found in saslog    tag=grant ${grantId_1} change op state to Granted from Idle
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*"grantId":\"${grantId_1}"\.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 501.*
    log to console   Trigger heartbeat terminat 500 for second Grant
    ${grantId_list}    get_all_grantID_value_from_saslog    filepath=${sas_log_path}
    Set test variable    ${grantId_2}    ${grantId_list[1]}
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantId_2}"\.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*"grantId":\"${grantId_2}"\.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": \"${grantId_2}"\.*\"responseCode\": 500.*
    ${grantId_list}    get_all_grantID_value_from_saslog    filepath=${sas_log_path}
    Set test variable    ${grantId_3}    ${grantId_list[2]}
    Check if message is found in saslog    tag={\"grantResponse\":.*"grantId": \"${grantId_3}"\.*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*"grantId":\"${grantId_3}"\.*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"grantId": \"${grantId_3}"\.*\"responseCode\": 0.*
    Wait Until Keyword Succeeds    10s    2s    Check Grant New Success    grantId_old=${grantId_2}
    Should be True    '${grantId_3}'=='${grantId_new}'
    Wait Until Keyword Succeeds    10s    2s    Check GrantOperationState Status Success
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*"grantId":\"${grantId_1}"\.*
    Check if message is found in saslog    tag={\"relinquishmentResponse\":.*"grantId": \"${grantId_1}"\.*\"responseCode\": 0.*
    log to console    Check heartbeat terminat for second Grant success
    [Teardown]    end_to_check

Check No unexpected CBSD-SAS procedure triggered
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdId}(.NR)?".*\"responseCode\": 0.*
    Check if message is not found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdId}(.NR)?\".*
    [Teardown]    end_to_check

Get physcellid on WebEM
    [Arguments]    ${cellID}=1
    ${physcellid_pre}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}
    ...    filter_param=Physical cell identifier
    [Return]    ${physcellid_pre}

Get physcellid By Coam
    [Arguments]    ${class_name}=NRCELL_A    ${pattern}=physCellId     ${cellID}=1
    ${MO}    coam.get_managed_objects    class_name=${class_name}    connection=GNB_OAM
    ${distname_tmp}    Set variable    ${MO[0]['distName']}
    ${distname}    generate_correct_nrcell_distname    distname_before=${distname_tmp}    cellid=${cellID}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=GNB_OAM
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Online modify physcellid on WebEM
    [Arguments]    ${cellID}=1    ${value}=${754}
    log to console   Online modify physcellid on WebEM to ${value}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}
    ...    filter_param=Physical cell identifier    p_name=physCellId    value=${value}
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}

modify physcellid by Coam
    [Arguments]    ${cellID}=1    ${value}=${754}    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellID}
    ...                                            parameter=physCellId
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Check Alarm in Alarm List
    [Arguments]    ${faultId}    ${stamp_case_start}=${None}    ${type}=Active    ${Supplementary}=${None}
    ...    ${expect}=${True}    ${connection}=GNB_OAM
     ${alarms_list}    Run Keyword If    '${type}'=='Active'
     ...    coam.get_active_alarms    connection=${connection}    timeout=100
     ...    ELSE IF   '${type}'=='History'
     ...    coam.get_historic_alarms    connection=${connection}    timeout=100
     ${status}    check_alarm_in_Active_Or_History_Alarmlist    alarmlist=${alarms_list}
     ...    faultId=${faultId}    supplementary=${Supplementary}    stamp_case_start=${stamp_case_start}
    Should be True    '${status}'=='${expect}'

Get Timestamp For Current Time
    ${time}    Get Current Date    result_format=timestamp
    ${time_stamp_second}    Convert Date    ${time}    epoch
    ${time_stamp_millisecond}    evaluate    int(round(${time_stamp_second} * 1000))
    [Return]    ${time_stamp_millisecond}

CBRS make 2cc call
    [Arguments]    ${tput_expect}    ${attach_1}    ${attach_2}    ${duration}=${300}    ${tput_from}=tool    ${target_avg}=0.5
     ...    ${min_percent}=0.2    ${cell_id1}=${1}    ${cell_id2}=${2}
    ${tput_expect}    get_self_define_tput_by_release    tput_info=${tput_expect}
    coam.perform_delta_recommissioning    delta_file=${attach_1}    connection=GNB_OAM
    sleep    20
    ${tput_info_total}    create dictionary
    ${ue_index1}    set variable    ${tput_expect[${cell_id1}]['ue_index']}
    ${tput_cell1}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool    cell_id=${cell_id1}    target_avg_percent=${target_avg}
    ...    min_percent=${min_percent}    ue_index=${ue_index1}    duration=${duration}    connection=GNB_OAM
    ...    ELSE    set variable    ${tput_expect[${cell_id1}]}
    set to dictionary    ${tput_info_total}    ${cell_id1}    ${tput_cell1}
    log to console    tput info for cell ${cell_id1} is: ${tput_cell1}
    ${ue_type1}    translate_power_ue_type_from_testline    ue_index=${ue_index1}
    make_call    tput_info=${tput_cell1}    ue_index=${ue_index1}    process_num_ul=5
    sleep  10
    coam.perform_delta_recommissioning    delta_file=${attach_2}    connection=GNB_OAM
    sleep  10
    ${ue_index2}    set variable    ${tput_expect[${cell_id2}]['ue_index']}
    ${tput_cell2}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool    cell_id=${cell_id2}    target_avg_percent=${target_avg}
    ...    min_percent=${min_percent}    ue_index=${ue_index2}    duration=${duration}    connection=GNB_OAM
    ...    ELSE    set variable    ${tput_expect[${cell_id2}]}
    set to dictionary    ${tput_info_total}    ${cell_id2}    ${tput_cell2}
    log to console    tput info for cell ${cell_id2} is: ${tput_cell2}
    ${ue_type2}    translate_power_ue_type_from_testline    ue_index=${ue_index2}
    make_call    tput_info=${tput_cell2}    ue_index=${ue_index2}    process_num_ul=5
    ${tput_log1}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
#    ${tput_log2}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id1}    ue_index=${ue_index1}    tput_log=${tput_log1}
    ...    target_avg_percent=${target_avg}    min_percent=${min_percent}
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id2}    ue_index=${ue_index2}    tput_log=${tput_log1}
    ...    target_avg_percent=${target_avg}    min_percent=${min_percent}
    [Teardown]    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Verify the First GAA Grant successfully
    [Arguments]    ${NRCBSDID}=1    ${ru_index}=1
    Get Correct Register Parameters Value By Coam    groupId_need=${False}    groupType_need=${False}
    ...    NRCBSDID=${NRCBSDID}    ru_index=${ru_index}
    ${cbsdId}    Get From Dictionary    dictionary=${cbsdIds}    key=${NRCBSDID}
    Set Test Variable    ${cbsdId}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag=${register_info}
    Check if message is found in saslog    tag={"registrationResponse":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog    tag={"spectrumInquiryRequest":.*"cbsdId":"${cbsdId}(.NR)?".*
    Check if message is found in saslog    tag={"spectrumInquiryResponse":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog
    ...    tag={"grantRequest":.*"cbsdId":"${cbsdId}(.NR)?".*"highFrequency":3610000000,"lowFrequency":3590000000.*
    Check if message is found in saslog    tag={"grantResponse":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 400.*
    Check if message is found in saslog
    ...    tag={"grantRequest":.*"cbsdId":"${cbsdId}(.NR)?".*"highFrequency":3570000000,"lowFrequency":3550000000.*
    Check if message is found in saslog
    ...    tag={"grantResponse":.*"cbsdId": "${cbsdId}(.NR)?".*"grantId": "3550000000_3570000000".*"channelType": "GAA".*"responseCode": 0.*
    Check if message is found in saslog
    ...    tag={"heartbeatResponse":.*"cbsdId": "${cbsdId}(.NR)?".*"grantId": "3550000000_3570000000".*"responseCode": 0.*

Verify the Second Grant successfully
    Check if message is found in saslog    tag={"spectrumInquiryRequest":.*"cbsdId":"${cbsdId}(.NR)?".*
    Check if message is found in saslog    tag={"spectrumInquiryResponse":.*"cbsdId": "${cbsdId}(.NR)?".*"responseCode": 0.*
    Check if message is found in saslog
    ...    tag={"grantRequest":.*"cbsdId":"${cbsdId}(.NR)?".*"highFrequency":3610000000,"lowFrequency":3590000000.*
    Check if message is found in saslog
    ...    tag={"grantResponse":.*"cbsdId": "${cbsdId}(.NR)?".*"grantId": "3590000000_3610000000".*"channelType": "PAL".*"responseCode": 0.*
    Wait Until Keyword Succeeds    2min    5s    Check grant new success    grantId_old=3550000000_3570000000
    Should be True    "${grantId_new}"=="3590000000_3610000000"
    log to console    ***Check relinquishment process***
    Check if message is found in saslog    tag={"relinquishmentRequest":.*"cbsdId":"${cbsdId}(.NR)?".*"grantId":"3550000000_3570000000".*
    Check if message is found in saslog
    ...    tag={"relinquishmentResponse":.*"cbsdId": "${cbsdId}(.NR)?".*"grantId": "3550000000_3570000000".*"responseCode": 0.*
    [Teardown]    end_to_check

Check grantExpireTimer expired Message
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={"eventType": "intGrantTimeoutEvent".*"cbsdId": "${cbsdId}(.NR)?"
    [Teardown]    end_to_check

L3Call_And_Check_TPUT_2Cells
    [Arguments]    ${target_avg_percent}=0.95    ${min_percent}=0.85
    Set qRxLevMin value    value=${-40}    cellid=1
	Set qRxLevMin value    value=${-22}    cellid=2
    UE attach and start traffic    ue_index=${0}    dl_tp=${tput['dl_send']}     ul_tp=${tput['ul_send']}
    Sleep    10s
    Set qRxLevMin value    value=${-22}    cellid=1
    Set qRxLevMin value    value=${-40}    cellid=2
    UE attach and start traffic    ue_index=${1}    dl_tp=${tput['dl_send']}     ul_tp=${tput['ul_send']}
    log to console    \n***Start Collect Throughput***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${20}    check_source=Aasyslog
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
    ${cell_id1}    Convert To String    ${cell_mapping[1]['nrCellIdentity']}
    ${cell_id1}    Create List    ${cell_id1}
    ${cell_id2}    Convert To String    ${cell_mapping[2]['nrCellIdentity']}
    ${cell_id2}    Create List    ${cell_id2}
	log to console    \n***Start Check Throughput***
    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cell_id1}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cell_id2}    ultarget_throughput=${tput['ul_exp_tp']}
    ...    dltarget_throughput=${tput['dl_exp_tp']}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    Run keywords  run keyword and ignore error    csn.disconnect    connection=ASIK Master  AND
    ...    run keyword and ignore error    Stop_L3Call_2Cells

Stop_L3Call_2Cells
   Stop Single UE L3 Call    ue_index=${0}
   Stop Single UE L3 Call    ue_index=${1}

Check HO success from BTSlog
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Check HO success from BTSlog
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    Set Test Variable    ${HO LOG DIRECTORY}    ${SAVE LOG DIRECTORY}HO
    Start Btslog With Path Check
    Set qRxLevMin value    value=${-35}    cellid=1
    Set cell1 PA first
    Set cell1 PA second
    sleep    10s
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${HO LOG DIRECTORY}
    Run and Return RC and Output    gzip -d ${HO LOG DIRECTORY}/btslog/syslog_files.tgz
    ${rc}    ${output}    Run and Return RC and Output
	...    cat ${HO LOG DIRECTORY}/btslog/syslog_files.tar | grep -a "status: Completed" | grep -a "ActiveProcedure reset from intraGnbHandover"
    Should not Be Empty    ${output}

Set PA To attach cell2
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Set Scell PA to 127
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${port1}    ${port2}    ${port3}    ${port4}    ${port5}    ${port6}
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    attenuator.set_attenuation    port=${port1}    value=${80}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${port2}    value=${80}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${port3}    value=${80}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${port4}    value=${80}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${port5}    value=${30}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${port6}    value=${30}    attenuator_device=HBTE

Set cell1 PA first
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Set Scell PA to 50
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0]}    value=${50}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1]}    value=${50}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2]}    value=${50}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3]}    value=${50}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0]}    value=${50}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1]}    value=${50}    attenuator_device=HBTE

Set cell1 PA second
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Set Scell PA HO to cell1
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0]}    value=${30}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1]}    value=${30}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2]}    value=${30}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3]}    value=${30}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0]}    value=${80}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1]}    value=${80}    attenuator_device=HBTE

Get SsbFrequency value by coam
    ${MO_A}    coam.get_managed_objects    class_name=NRHOIF_A    connection=GNB_OAM
    ${distname}    Set variable    ${MO_A[0]['distName']}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=ssbFrequency   connection=GNB_OAM
    ${ssbFrequency}    set variable     ${dict_pattern['ssbFrequency']}
    [Return]    ${ssbFrequency}

Get NRCELL value by coam
    [Arguments]    ${class_name}=NRCELL_R    ${pattern}=arfcnSsbPbch     ${cellID}=1
    ${MO}    coam.get_managed_objects    class_name=${class_name}    connection=GNB_OAM
    ${distname_tmp}    Set variable    ${MO[0]['distName']}
    ${distname}    generate_correct_nrcell_distname    distname_before=${distname_tmp}    cellid=${cellID}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=GNB_OAM
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Set TL62 Peak PA
    [Documentation]   [TEST PURPOSE]Set Peak PA   Owner_lanwen.cai@nokia-sbell.com
    ${PA_CBRS}    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    FOR  ${index}    IN RANGE    9    13
        attenuator.set_attenuation    port=${index}    value=${20}    attenuator_device=${PA_CBRS}
    END
    FOR  ${index}    IN RANGE    13    15
        attenuator.set_attenuation    port=${index}    value=${127}    attenuator_device=${PA_CBRS}
    END

Get NRCBSD_A value by coam
    [Arguments]    ${pattern}
    ${MO}    coam.get_managed_objects    class_name=NRCBSD_A   connection=GNB_OAM
    ${distname}    Set variable    ${MO[0]['distName']}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=GNB_OAM
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Verify_the_CBRS_online_de-activation_is_successful
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To check online_de-activation is successful
    ...    *******************
    ...    qingqing.wang.1@nokia-sbell.com
    ${cbsd_nums}    Get CBSD Numbers    scf_file_path=${scf_path}
    Run Keyword If    ${cbsd_nums}!=1    Run Keywords
    ...    Commissioning SCF And Check RU On Air   scf_file_path=${Golden_SCF_Path}
    ...    AND    Activate feature CBRS By Coam
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    5min    30s    Check Register Status By Coam
    Check Register Success Message    groupId_need=${False}    groupType_need=${False}
    Change NR CBRS Flag By Coam    actNrCbrs=false
    Wait Until Keyword Succeeds    5min    30s    Check Deregister Success Message
    Wait until keyword succeeds    5min    30s    Verify all cells should be disabled
    ${register_status}  run keyword and return status  wait until keyword succeeds    2min    30s    Check Register Status By Coam
    Should be True    ${register_status} == False

Verify_CBRS_L3_call_Samsung
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]check CBRS L3 call
    ...    *******************
    ...    Owner_tianyi.ye@nokia-sbell.com
    [Arguments]
    Start SAS server
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    5min    10s    Check Register Status By Coam
    Wait until keyword succeeds    5min    20s    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85

Verify_the_AirScale_CBRS_L3_call_successfully_with_CBSD
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]check CBRS L3 call
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${tput}    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${duration}=${300}
    Start SAS server
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    5min    10s    Check Register Status By Coam
    Wait until keyword succeeds    5min    20s    verify all cells should be onair
    Check CBRS L3 call    tput=${tput}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    duration=${duration}

Verify_CBRS_L3_call_10MHz
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify CBRS L3 call
    ...    *******************
    ...    Owner_tianyi.ye@nokia-sbell.com
    [Arguments]    ${tput_self_define}
    Activate feature CBRS By Coam
    Start SAS server
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    5min    10s    Check Register Status By Coam
    Wait until keyword succeeds    5min    20s    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_self_define}    loop_times=${1}
    ...    duration=${300}    tput_from=self_define

Verify_CBRS_L3_call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify CBRS L3 call
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${tput_self_define}
    Activate feature CBRS By Coam
    Start SAS server
    Wait Until Keyword Succeeds    5min    10s    Check CBRS Process Success    groupId_need=${False}    groupType_need=${False}
    Wait Until Keyword Succeeds    5min    10s    Check Register Status By Coam
    Wait until keyword succeeds    5min    20s    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_self_define}    loop_times=${1}

Download Sas Server
    #[Arguments]    ${url}=https://gitlabe1.ext.net.nokia.com/api/v4/projects/40602/repository/files/Tools%2FSASSim3.tar/raw?ref=master
    [Arguments]    ${url}= https://gitlabe1.ext.net.nokia.com/api/v4/projects/76719/repository/files/CBRS%2FSASSim3.tar/raw?ref=main
     ${SASserver_download_return_code}=  Run And Return Rc
      ...  command= curl --header "PRIVATE-TOKEN: ${GIT_ACCESS_TOKEN}" ${url} -o ${CURDIR}/SASSim3.tar
      Run Keyword If  ${SASserver_download_return_code} != 0
      ...  Fail  Downloading SASserver failed with error code ${SASserver_download_return_code}
      ...  ELSE
      ...  Log  Downloading SASserver successful
    OperatingSystem.Run   tar -xvf ${CURDIR}/SASSim3.tar -C ${CURDIR}
    [Teardown]    OperatingSystem.Run   rm -rf ${CURDIR}/SASSim3.tar

Download File By Wget
    [Arguments]    @{params}    ${link}    ${local_path}    ${exec}=no
    Should Be True    '${exec}' in ('yes','no')    msg=Invalid KW parameter: exec
    Log to Console    Downloading ${link}
    Run Process And Check Result    wget    -O    ${local_path}    @{params}    ${link}
    File Should Exist    ${local_path}
    Run Keyword If    '${exec}' == 'yes'    Run Process And Check Result    chmod    u+x    ${local_path}

Run Process And Check Result
    [Arguments]    ${process}    @{params}    ${shell}=${True}    ${msg}=${Empty}    &{config}
    ${result}    Run Process    ${process}    @{params}    shell=${shell}    &{config}
    ${mlen}    Get Length    ${msg}
    ${msg}    Set Variable If    ${mlen} == 0    Error running ${process} @{params}    ${msg}
    ${msg}    Set Variable    ${msg}${\n}stdout: ${result.stdout}${\n}stderr: ${result.stderr}
    Should Be Equal As Integers    ${result.rc}    0    values=${False}    msg=${msg}
    [Return]    ${result}

CBRS UTE Common Suite Setup
    [Documentation]    This keyword will contain both WA operation for CIT/UTEC in suite setup.
    [Arguments]  ${gnb_index}=${0}    ${du_index}=${0}    ${common_unit_index}=${0}
    CBRS UTE common commissioning    gnb_index=${gnb_index}   du_index=${du_index}
    ...    common_unit_index=${common_unit_index}

CBRS UTE common commissioning
    [Timeout]    90min
    [Documentation]  common commisioning for hz test line.
    ...   Keyword depends on variables from command line, keyword will return directly without them.
    ...   Keyword supports both classical and cloud gnb.
    ...   Keyword supports both hz ci and ute cloud test line.
    ...   For test line on ute cloud, keyword will install package again if fault 23 raises.
    ...   Keyword do normal commissioning for classical bts.
    ...   Keyword do cu and du commissioning for cloud bts.
    ...   Tester needs to put SCF to scf_base_path with particular name.
    [Arguments]   ${gnb_index}=${0}   ${du_index}=${0}    ${common_unit_index}=${0}
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
    run keyword if    '${var_status}'=='FAIL'    run keywords
    ...    Builtin.log    Not ute or ci command, will not do common commission.    level=WARN    AND
    ...    return from keyword
#    run keyword if      '${ci_var_dict}[gnb_type]'=='CloudBts'
#    ...    CI_commssion.Do CU Commission    ${ci_var_dict}
    CBRS UTE Do DU Commission    &{ci_var_dict}

CBRS UTE Do DU Commission
    [Arguments]          ${connection}=du_coam    &{var_dict}
    CI_commssion.Connect To Du With F1 Or LMP    connection=${connection}    du_host=${var_dict}[du_host]
    ...        username=${var_dict}[username]    password=${var_dict}[password]
    CI_commssion.Commisioning Custom DU Scf    connection=${connection}   testline=${var_dict}[testline]
    ...    stream=${var_dict}[stream]    gnb_type=${var_dict}[gnb_type]   ute_env=${var_dict}[ute_env]
    ...    gnb_index=${var_dict}[gnb_index]
    WAIT UNTIL KEYWORD SUCCEEDS    80x    15s    CI_commssion.All Hw Should Be Detected
    ...    testline=${var_dict}[testline]    build=${var_dict}[build]    stream=${var_dict}[stream]
    ...    ute_env=${var_dict}[ute_env]   connection=${connection}
    [Teardown]  taf.sbts.oam.coam.admin.teardown   connection=${connection}
