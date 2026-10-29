*** Settings ***
Resource   Common.robot


*** Variables ***
${PASSLOG_FLAG}                ${False}
${GNB_SNAPSHOT_FLAG}           ${False}
${GNB_SYSLOG_FLAG}             ${False}
${ENB_SNAPSHOT_FLAG}           ${False}
${ENB_SYSLOG_FLAG}             ${False}
${RU_LOG_FLAG}                 ${False}
${RU_SERIAL_LOG_FLAG}          ${False}
${RU_SYSLOG_FLAG}              ${False}
${ASYNC_ALARM_SNAPSHOT_FLAG}   ${False}

${log_collection_flag}   ALL

*** Keywords ***
UUF Set Log Collection Flags
    # ->  Set The Log Level Flags
    #     ->  How to Set? used for fastrun?
    #     ->  parameter input from jenkins?


    # ${log_collection_flag}   Set Variable   gnb_snapshot;enb_syslog;ru_log
    ${log_collection_flag}   Split String   ${log_collection_flag}   ;

    @{log_collection_flag}   Run Keyword If
    ...         "ALL" in ${log_collection_flag}     Create List   @{Log_Collection_Type}
    ...   ELSE IF
    ...         "NONE" in ${log_collection_flag}    Create List   @{EMPTY}
    ...   ELSE
    ...         Create List   @{log_collection_flag}

    # Set Log Catch Flag
    ${LOG_FLAG}   Create List
    FOR   ${flag}   IN   @{log_collection_flag}
        Run Keyword If   "${flag}" in @{Log_Collection_Category.keys()}
        ...      Append To List   ${LOG_FLAG}   @{Log_Collection_Category['${flag}']}
        ...   ELSE
        ...      Append To List   ${LOG_FLAG}   ${flag}
    END

    # Set Log Exclude Flag
    ${EXCLUDE_LOG_FLAG}   Create List
    @{testline_exclude}   Get Variable Value   ${Exclude_Log_Collection_TL["${TESTLINE_IDENTITY}"]}   @{EMPTY}
    FOR   ${exclude}   IN   @{testline_exclude}
        Run Keyword If   "${exclude}" in @{Log_Collection_Category.keys()}
        ...      Append To List   ${EXCLUDE_LOG_FLAG}   @{Log_Collection_Category['${exclude}']}
        ...   ELSE
        ...      Append To List   ${EXCLUDE_LOG_FLAG}   ${exclude}
    END

    # ${LOG_FLAG}   Run Keyword If   "${TESTLINE_IDENTITY}" in @{Exclude_Log_Collection_TL.keys()}
    # ...   Evaluate   [item for item in ${LOG_FLAG} if item not in ${EXCLUDE_LOG_FLAG}]
    # ...   ELSE   Set Variable   ${LOG_FLAG}

    ${LOG_FLAG}   Evaluate   [item for item in ${LOG_FLAG} if item not in ${EXCLUDE_LOG_FLAG}]

    Run Keyword If   "passlog" in ${LOG_FLAG}                Set Suite Variable   ${PASSLOG_FLAG}                ${True}
    ...   ELSE   Set Suite Variable   ${PASSLOG_FLAG}                ${False}
    Run Keyword If   "gnb_snapshot" in ${LOG_FLAG}           Set Suite Variable   ${GNB_SNAPSHOT_FLAG}           ${True}
    ...   ELSE   Set Suite Variable   ${GNB_SNAPSHOT_FLAG}           ${False}
    Run Keyword If   "gnb_syslog" in ${LOG_FLAG}             Set Suite Variable   ${GNB_SYSLOG_FLAG}             ${True}
    ...   ELSE   Set Suite Variable   ${GNB_SYSLOG_FLAG}             ${False}
    Run Keyword If   "enb_snapshot" in ${LOG_FLAG}           Set Suite Variable   ${ENB_SNAPSHOT_FLAG}           ${True}
    ...   ELSE   Set Suite Variable   ${ENB_SNAPSHOT_FLAG}           ${False}
    Run Keyword If   "enb_syslog" in ${LOG_FLAG}             Set Suite Variable   ${ENB_SYSLOG_FLAG}             ${True}
    ...   ELSE   Set Suite Variable   ${ENB_SYSLOG_FLAG}             ${False}
    Run Keyword If   "ru_general_log" in ${LOG_FLAG}         Set Suite Variable   ${RU_LOG_FLAG}                 ${True}
    ...   ELSE   Set Suite Variable   ${RU_LOG_FLAG}                 ${False}
    Run Keyword If   "ru_serial_log" in ${LOG_FLAG}          Set Suite Variable   ${RU_SERIAL_LOG_FLAG}          ${True}
    ...   ELSE   Set Suite Variable   ${RU_SERIAL_LOG_FLAG}          ${False}
    Run Keyword If   "ru_syslog" in ${LOG_FLAG}              Set Suite Variable   ${RU_SYSLOG_FLAG}              ${True}
    ...   ELSE   Set Suite Variable   ${RU_SYSLOG_FLAG}              ${False}
    Run Keyword If   "async_alarm_snapshot" in ${LOG_FLAG}   Set Suite Variable   ${ASYNC_ALARM_SNAPSHOT_FLAG}   ${True}
    ...   ELSE   Set Suite Variable   ${ASYNC_ALARM_SNAPSHOT_FLAG}   ${False}
    Run Keyword If   "check_error_snapshot" in ${LOG_FLAG}   Set Suite Variable   ${CHECK_ERROR_SNAPSHOT_FLAG}   ${True}
    ...   ELSE   Set Suite Variable   ${CHECK_ERROR_SNAPSHOT_FLAG}   ${False}

    Log To Console   PASSLOG_FLAG: ${PASSLOG_FLAG}
    Log To Console   GNB_SNAPSHOT_FLAG: ${GNB_SNAPSHOT_FLAG}
    Log To Console   GNB_SYSLOG_FLAG: ${GNB_SYSLOG_FLAG}
    Log To Console   ENB_SNAPSHOT_FLAG: ${ENB_SNAPSHOT_FLAG}
    Log To Console   ENB_SYSLOG_FLAG: ${ENB_SYSLOG_FLAG}
    Log To Console   RU_LOG_FLAG: ${RU_LOG_FLAG}
    Log To Console   RU_SERIAL_LOG_FLAG: ${RU_SERIAL_LOG_FLAG}
    Log To Console   RU_SYSLOG_FLAG: ${RU_SYSLOG_FLAG}
    Log To Console   ASYNC_ALARM_SNAPSHOT_FLAG: ${ASYNC_ALARM_SNAPSHOT_FLAG}
    Log To Console   CHECK_ERROR_SNAPSHOT_FLAG: ${CHECK_ERROR_SNAPSHOT_FLAG}


Set ALL Log Flags
    [Arguments]   ${flag}=${True}
    Set Suite Variable   ${PASSLOG_FLAG}                ${flag}
    Set Suite Variable   ${GNB_SNAPSHOT_FLAG}           ${flag}
    Set Suite Variable   ${GNB_SYSLOG_FLAG}             ${flag}
    Set Suite Variable   ${ENB_SNAPSHOT_FLAG}           ${flag}
    Set Suite Variable   ${ENB_SYSLOG_FLAG}             ${flag}
    Set Suite Variable   ${RU_LOG_FLAG}                 ${flag}
    Set Suite Variable   ${RU_SERIAL_LOG_FLAG}          ${flag}
    Set Suite Variable   ${RU_SYSLOG_FLAG}              ${flag}
    Set Suite Variable   ${ASYNC_ALARM_SNAPSHOT_FLAG}   ${flag}
    Set Suite Variable   ${CHECK_ERROR_SNAPSHOT_FLAG}   ${flag}


UUF Start Log Collection Process
    Log To Console   //TODO: UUF Start Log Collection Process
    # ->  start log process
    #         enable ru lmi-eth on
    #         start ru journal log?
    #         start btslog process
    #         start cat ru serial log
    UUF Start Syslog Process
    UUF Start RU Serial Log


UUF Stop Log Collection Process
    Log To Console   //TODO: UUF Stop Log Collection Process
    # ->  ?
    #        stop ru serial log process
    #        stop btslog process
    UUF Stop Syslog Process
    UUF Stop RU Serial Log


UUF Catch All Logs
    Log To Console   //TODO: UUF Catch All Logs
    Return From Keyword If   ${DEBUG}

    Run Keyword If   "${TEST_STATUS}"=="PASS" and ${PASSLOG_FLAG} and ("${TEST_MODE}"=="UUF" or "${TEST_MODE}"=="E2E")
    ...   UUF Check PassLog Directory
    Return From Keyword If   "${TEST_STATUS}"=="PASS"

    ${fail_log_dir}   Set Variable   ${OUTPUT_DIR}/${TEST_NAME}
    ${fail_log_dir_not_exist}   Run Keyword And Return Status   Directory Should Not Exist   ${fail_log_dir}
    Run Keyword If   ${fail_log_dir_not_exist}   OperatingSystem.Create Directory   ${fail_log_dir}
    Set Test Variable   ${FAIL_LOG_DIR}

    Run Keyword And Continue On Failure   UUF Catch Snapshot          log_dir=${fail_log_dir}   prefix=FAIL
    Run Keyword And Continue On Failure   UUF Catch RU Log            log_dir=${fail_log_dir}   prefix=FAIL
    Run Keyword And Continue On Failure   UUF Catch RU Serial Log     log_dir=${fail_log_dir}   prefix=FAIL
    Run Keyword And Continue On Failure   UUF Save Syslog Process     log_dir=${fail_log_dir}   prefix=FAIL


UUF Check PassLog Directory
    Log To Console   //TODO: UUF Check PassLog Directory

    Return From Keyword If   "${TEST_STATUS}"=="FAIL"


    ${package_type}   Set Variable If
    ...   "${UUF_PROCESS}"=="upgrade" or "${UUF_PROCESS}"=="reset"   target
    ...   "${UUF_PROCESS}"=="rollback"   source
    ...   others

    Return From Keyword If   "${package_type}"=="others"

    ${package_version}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT["gnb"]["${package_type}"]["version"]}

    ${passlog_dir}   OperatingSystem.Join Path   ${OUTPUT_DIR}   ..   PASSLOG_${package_version}
    ${status}   Run Keyword And Return Status   Directory Should Not Exist   ${passlog_dir}
    Run Keyword If   ${status}   OperatingSystem.Create Directory   ${passlog_dir}


    ${snapshot_not_exist}   Run Keyword And Return Status   File Should Not Exist   ${passlog_dir}/*Snapshot*
    ${snapshot_not_exist}   Evaluate   ${snapshot_not_exist} and (${GNB_SNAPSHOT_FLAG} or ${ENB_SNAPSHOT_FLAG})
    @{snapshot_file_list}   Run Keyword If   ${snapshot_not_exist}   UUF Catch Snapshot   log_dir=${passlog_dir}   prefix=PASS


    ${syslog_not_exist}   Run Keyword And Return Status   File Should Not Exist   ${passlog_dir}/*SYSLOG*
    ${syslog_not_exist}   Evaluate   ${syslog_not_exist} and (${GNB_SYSLOG_FLAG} or ${ENB_SYSLOG_FLAG} or ${RU_SYSLOG_FLAG})
    @{syslog_file_list}   Run Keyword If   ${syslog_not_exist}   UUF Save Syslog Process   log_dir=${passlog_dir}   prefix=PASS


    ${ru_serial_not_exist}   Run Keyword And Return Status   File Should Not Exist   ${passlog_dir}/*RU_SERIAL_LOG*
    ${ru_serial_not_exist}   Evaluate   ${ru_serial_not_exist} and ${RU_SERIAL_LOG_FLAG}
    @{ru_serial_log_list}   Run Keyword If   ${ru_serial_not_exist}   UUF Catch RU Serial Log   log_dir=${passlog_dir}   prefix=PASS


    ${ru_log_not_exist}   Run Keyword And Return Status   File Should Not Exist   ${passlog_dir}/*RULOG*
    ${ru_log_not_exist}   Evaluate   ${ru_log_not_exist} and ${RU_LOG_FLAG}
    @{ru_log_list}   Run Keyword If   ${ru_log_not_exist}   UUF Catch RU Log   log_dir=${passlog_dir}   prefix=PASS


    Run Keyword If   ${snapshot_not_exist} or ${syslog_not_exist} or ${ru_serial_not_exist} or ${ru_log_not_exist}
    ...   Run Keyword And Ignore Error   UUF Upload Log To FTP Server   log_dir=${passlog_dir}   log_type=PASS


UUF Clear Logs
    Log To Console   //TODO: UUF Clear Logs


UUF Upload Log To FTP Server
    [Arguments]   ${log_dir}=${OUTPUT_DIR}   ${log_type}=FAIL
    Log To Console   //TODO: UUF Upload Log To FTP Server

    Return From Keyword If   ${DEBUG}

    ${isSG07}   Run Keyword And Return Status   Should Contain   ${log_dir}   HZ_7_SG
    Run Keyword And Ignore Error
    ...   Run Keyword If   ${isSG07} and "${log_type}"=="FAIL"
    ...      Run Keyword If Any Tests Failed
    ...      OperatingSystem.Run   command=python ${CURDIR}/../Scripts/upload_logs_to_server.py upload ${log_dir}/ ${TESTLINE_IDENTITY}
    ...   ELSE IF   ${isSG07} and "${log_type}"=="PASS"
    ...      OperatingSystem.Run   command=python ${CURDIR}/../Scripts/upload_logs_to_server.py upload ${log_dir}/ ${TESTLINE_IDENTITY}


#==========================================================================================================================================
#==========================================================================================================================================
#==========================================================================================================================================
# Snapshot
UUF Catch Snapshot
    [Arguments]   ${testline_list}=@{EMPTY}   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL   ${timeout}=5400

    Return From Keyword If   ${DEBUG}

    ${log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${log_dir}
    Run Keyword If   ${log_dir_not_exist}   OperatingSystem.Create Directory   ${log_dir}

    Log To Console   GNB_SNAPSHOT_FLAG: ${GNB_SNAPSHOT_FLAG}
    Log To Console   ENB_SNAPSHOT_FLAG: ${ENB_SNAPSHOT_FLAG}
    @{log_sequence}   Create List
    Run Keyword If   ${GNB_SNAPSHOT_FLAG}   Append To List   ${log_sequence}   @{ALL_GNB_LIST}
    Run Keyword If   ${ENB_SNAPSHOT_FLAG}   Append To List   ${log_sequence}   @{ALL_ENB_LIST}

    ${isEmpty}   Run Keyword And Return Status   Should Be Empty   ${testline_list}
    ${testline_list}   Set Variable If   ${isEmpty}   ${log_sequence}   ${testline_list}
    ${testline_list}   Evaluate   [testline for testline in ${testline_list} if testline in ${log_sequence}]

    # Sort error testline to first
    ${ALL_CHECK_ERROR}   Get Variable Value   ${ALL_CHECK_ERROR}   @{EMPTY}
    ${error_testline}   Evaluate   [i.split(';')[0] for i in ${ALL_CHECK_ERROR}]
    ${error_testline}   Remove Duplicates   ${error_testline}
    ${no_error_testline}   Evaluate   [i for i in ${testline_list} if i not in ${error_testline}]
    ${testline_list}   Create List   @{error_testline}   @{no_error_testline}

    #Draft
    #Can be Update to Async
    @{snapshot_file_list}   Create List
    FOR   ${testline}   IN   @{testline_list}
        ${status}   ${snapshot_file}   Run Keyword And Ignore Error
        ...   Single Testline Catch Snapshot   testline=${testline}    log_dir=${log_dir}    prefix=${prefix}    timeout=${timeout}
        Run Keyword If   "${status}"=="PASS"   Append To List   ${snapshot_file_list}   ${snapshot_file}

        Continue For Loop If   "${prefix}"=="PASS"
        ${dual_status}   ${dual_snapshot_file}   Run Keyword And Ignore Error
        ...   Single Testline Dual Core Catch Snapshot   testline=${testline}   log_dir=${log_dir}   prefix=${prefix}   timeout=${timeout}
        Run Keyword If   "${dual_status}"=="PASS"   Append To List   ${snapshot_file_list}   ${dual_snapshot_file}
    END

    [Return]   ${snapshot_file_list}


Single Testline Catch Snapshot
    [Arguments]   ${testline}   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL   ${timeout}=5400
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    ${common_units}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['common_units']}
    ${lmp_addr}   Get Variable Value   ${common_units[0]['lmp_addr']}
    ${ssh_addr}   Get Variable Value   ${common_units[0]['test_pc_addr']}
    ${ssh_username}   Get Variable Value   ${common_units[0]['test_pc_username']}
    ${ssh_password}   Get Variable Value   ${common_units[0]['test_pc_password']}

    ${mplane_login}   Run Keyword And Return Status
    ...   COAM Login   bts_host=${webem_addr}   username=${webem_username}   password=${webem_password}   alias=${testline}

    ${lmp_login}   Run Keyword And Return Status   Run Keyword If   not ${mplane_login}
    ...   COAM Remote Login   bts_host=${lmp_addr}   username=${webem_username}   password=${webem_password}
    ...   remote_host=${ssh_addr}   remote_host_username=${ssh_username}   remote_host_password=${ssh_password}   connection=LMP_${testline}

    ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    Log To Console  Start To Collect ${testline} Snapshot!
    ${snapshot_name}   Set Variable   Snapshot_${prefix}_${testline}_${time}.zip

    Run Keyword If   ${mplane_login}
    ...      Run Keyword And Ignore Error   coam.Collect snapshot
    ...      target_file_name=${log_dir}/${snapshot_name}   coverage=Full   force=True   timeout=${timeout}   connection=${testline}
    ...   ELSE IF   ${lmp_login}
    ...      Run Keyword And Ignore Error   coam.Collect snapshot
    ...      target_file_name=${log_dir}/${snapshot_name}   coverage=Full   force=True   timeout=${timeout}   connection=LMP_${testline}
    ...   ELSE
    ...      Run Keyword And Ignore Error   Single Testline Catch Snapshot Via SSH
    ...      testline=${testline}   log_dir=${log_dir}   prefix=${prefix}

    ${size_status}    Run Keyword And Return Status    File Should Be Empty    ${log_dir}/${snapshot_name}
    ${file_status}    Run Keyword And Return Status    File Should Not Exist    ${log_dir}/${snapshot_name}

    Run Keyword If   ${size_status} or ${file_status}    Run keywords
    ...   Log To Console   Snapshot Size empty status: ${size_status}, file status:${file_status},will catch snashot via ssh again!
    ...   AND   Run Keyword And Ignore Error   Single Testline Catch Snapshot Via SSH
    ...   testline=${testline}   log_dir=${log_dir}   prefix=${prefix}

    [Return]   ${log_dir}/${snapshot_name}
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    ...   AND
    ...   Run Keyword And Ignore Error   COAM Remote Logout   connection=LMP_${testline}


Single Testline Catch Snapshot Via SSH
    [Arguments]   ${testline}   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL   ${timeout}=5400
    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}
    ${lmp_addr}   Set Variable   ${common_units[0]['lmp_addr']}
    ${lmp_username}   Set Variable   ${common_units[0]['lmp_username']}
    ${lmp_password}   Set Variable   ${common_units[0]['lmp_password']}
    ${ssh_addr}   Set Variable   ${common_units[0]['test_pc_addr']}
    ${ssh_username}   Set Variable   ${common_units[0]['test_pc_username']}
    ${ssh_password}   Set Variable   ${common_units[0]['test_pc_password']}

    ${time}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${snapshot_name}   Set Variable   Snapshot_${prefix}_${testline}_ssh_${time}.zip

    Log To Console   Start To Collect ${testline} Snapshot Via SSH!
    Run Keyword And Ignore Error    UUF_Utils.catch_snapshot_via_vm    vm_ip=${ssh_addr}   vm_username=${ssh_username}   vm_password=${ssh_password}
    ...    ssh_ip=${lmp_addr}    ssh_username=${lmp_username}   ssh_passwd=${lmp_password}

    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=vm
    csn.Connect to   hostname=${lmp_addr}   username=${lmp_username}   password=${lmp_password}   proxy=vm   alias=vm_ssh
    csn.Download File   remote_path=/tmp/snapshot.zip   local_path=${log_dir}/${snapshot_name}   connection=vm_ssh

    [Return]   ${log_dir}/${snapshot_name}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=vm_ssh   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=vm


Single Testline Dual Core Catch Snapshot
    [Arguments]   ${testline}   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL   ${timeout}=5400
    ${isDualCore}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['isDualCore']}
    Return From Keyword If    not ${isDualCore}
    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}

    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}
    ${dual_core_ssh_addr}   Set Variable   ${common_units[1]['test_pc_addr']}
    ${dual_core_ssh_username}   Set Variable   ${common_units[1]['test_pc_username']}
    ${dual_core_ssh_password}   Set Variable   ${common_units[1]['test_pc_password']}
    ${dual_core_lmp_addr}   Set Variable   ${common_units[1]['lmp_addr']}
    ${dual_core_lmp_username}   Set Variable   ${common_units[1]['lmp_username']}
    ${dual_core_lmp_password}   Set Variable   ${common_units[1]['lmp_password']}

    ${time}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
#    ${dual_snapshot_name}   Set Variable   Snapshot_${prefix}_${testline}_Web_Dual_${time}.zip

    Log To Console  start to collect ${testline} Dual Core snapshot!

    ${lmp_login}   Run Keyword And Return Status
    ...   COAM Remote Login   bts_host=${dual_core_lmp_addr}   username=${webem_username}   password=${webem_password}
    ...   remote_host=${dual_core_ssh_addr}   remote_host_username=${dual_core_ssh_username}
    ...   remote_host_password=${dual_core_ssh_password}   connection=LMP_DUAL_${testline}

    ${dual_snapshot_name}    set variable if  ${lmp_login}    Snapshot_${prefix}_${testline}_Web_Dual_${time}.zip
    ...   Snapshot_${prefix}_${testline}_Dual_ssh_${time}.zip

    Run Keyword If   ${lmp_login}
    ...      Run Keyword And Ignore Error   coam.Collect snapshot
    ...      target_file_name=${log_dir}/${dual_snapshot_name}   coverage=Full   force=True   timeout=${timeout}   connection=LMP_DUAL_${testline}
    ...   ELSE
    ...      Run Keyword And Ignore Error   Single Testline Dual Core Catch Snapshot Via SSH
    ...      testline=${testline}   dual_snapshot_name=${dual_snapshot_name}   log_dir=${log_dir}   prefix=${prefix}

#    ${file_info}   OperatingSystem.Run   ls -la ${log_dir}/${dual_snapshot_name}
#    Run Keyword If   "${file_info.split()[4]}"=="0" or "${file_info.split()[4]}"=="No"   Run keywords

    ${size_status}    Run Keyword And Return Status    File Should Be Empty    ${log_dir}/${dual_snapshot_name}
    ${file_status}    Run Keyword And Return Status    File Should Not Exist    ${log_dir}/${dual_snapshot_name}

    Run Keyword If   ${size_status} or ${file_status}    Run keywords
    ...   Log To Console  Dual Snapshot Size empty status: ${size_status}, file status:${file_status},will catch snashot via ssh again!
    ...   AND   Run Keyword And Ignore Error   Single Testline Dual Core Catch Snapshot Via SSH
    ...      testline=${testline}   dual_snapshot_name=${dual_snapshot_name}   log_dir=${log_dir}   prefix=${prefix}

    [Return]   ${log_dir}/${dual_snapshot_name}
    [Teardown]   Run Keyword And Ignore Error   COAM Remote Logout   connection=LMP_DUAL_${testline}


Single Testline Dual Core Catch Snapshot Via SSH
    [Arguments]   ${testline}   ${dual_snapshot_name}   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL   ${timeout}=5400
    ${isDualCore}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['isDualCore']}
    Return From Keyword If    not ${isDualCore}

    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}
    ${dual_core_ssh_addr}   Set Variable   ${common_units[1]['test_pc_addr']}
    ${dual_core_ssh_username}   Set Variable   ${common_units[1]['test_pc_username']}
    ${dual_core_ssh_password}   Set Variable   ${common_units[1]['test_pc_password']}
    ${dual_core_lmp_addr}   Set Variable   ${common_units[1]['lmp_addr']}
    ${dual_core_lmp_username}   Set Variable   ${common_units[1]['lmp_username']}
    ${dual_core_lmp_password}   Set Variable   ${common_units[1]['lmp_password']}

#    ${time}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
#    ${dual_snapshot_name}   Set Variable   Snapshot_${prefix}_${testline}_Dual_ssh_${time}.zip

    UUF_Utils.catch_snapshot_via_vm    vm_ip=${dual_core_ssh_addr}   vm_username=${dual_core_ssh_username}
    ...    vm_password=${dual_core_ssh_password}    ssh_ip=${dual_core_lmp_addr}    ssh_username=${dual_core_lmp_username}
    ...    ssh_passwd=${dual_core_lmp_password}

    csn.Connect to   hostname=${dual_core_ssh_addr}
    ...    username=${dual_core_ssh_username}
    ...    password=${dual_core_ssh_password}
    ...    alias=dual_vm

    csn.Connect to   hostname=${dual_core_lmp_addr}
    ...    username=${dual_core_lmp_username}
    ...    password=${dual_core_lmp_password}
    ...    proxy=dual_vm
    ...    alias=dual_ssh

    csn.Download File   remote_path=/tmp/snapshot.zip
    ...                 local_path=${log_dir}/${dual_snapshot_name}
    ...                 connection=dual_ssh

    [Return]   ${log_dir}/${dual_snapshot_name}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=dual_ssh   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=dual_vm


#==========================================================================================================================================
#==========================================================================================================================================
#==========================================================================================================================================
# Async Alarm Snapshot
UUF Async Alarm Snapshot
    Log To Console   ${ASYNC_ALARM_SNAPSHOT_FLAG}


#==========================================================================================================================================
#==========================================================================================================================================
#==========================================================================================================================================
# SYSLOG
UUF Start Syslog Process
    Log To Console   ${GNB_SYSLOG_FLAG}
    Log To Console   ${ENB_SYSLOG_FLAG}
    Log To Console   ${RU_SYSLOG_FLAG}
    Return From Keyword If   (not ${GNB_SYSLOG_FLAG}) and (not ${ENB_SYSLOG_FLAG}) and (not ${RU_SYSLOG_FLAG})

    ${syslog_testline}   Create List
    Run Keyword If   ${GNB_SYSLOG_FLAG}   Append To List   ${syslog_testline}   @{ALL_GNB_LIST}
    Run Keyword If   ${ENB_SYSLOG_FLAG}   Append To List   ${syslog_testline}   @{ALL_ENB_LIST}


    @{gnb_syslog_list}   Create List
    @{enb_syslog_list}   Create List
    @{ru_syslog_list}   Create List
    FOR   ${testline}   IN   @{syslog_testline}
        @{common_units}   Get Variable Value   ${ALL_CONFIG_INIT["${testline}"]["common_units"]}   @{EMPTY}
        @{ru_list}   Get Variable Value   ${ALL_CONFIG_INIT["${testline}"]["ru_list"]}   @{EMPTY}
        @{special_units}   Get Variable Value   ${ALL_CONFIG_INIT["${testline}"]["special_units"]}   @{EMPTY}


        ${testline_type}   ${testline_index}   Split String   ${testline}   _
        Run Keyword If   "${testline_type}"=="gnb"   Append To List   ${gnb_syslog_list}    @{common_units}
        Run Keyword If   "${testline_type}"=="enb"   Append To List   ${enb_syslog_list}    @{common_units}

        Run Keyword If   ${RU_SYSLOG_FLAG}   Append To List   ${ru_syslog_list}   @{ru_list}
    END

    ${GNB_SYSLOG_LIST}   Remove Duplicates   ${GNB_SYSLOG_LIST}
    ${ENB_SYSLOG_LIST}   Remove Duplicates   ${ENB_SYSLOG_LIST}
    ${RU_SYSLOG_LIST}   Remove Duplicates   ${RU_SYSLOG_LIST}

    Set Suite Variable   ${GNB_SYSLOG_LIST}
    Set Suite Variable   ${ENB_SYSLOG_LIST}
    Set Suite Variable   ${RU_SYSLOG_LIST}


    FOR   ${common_unit}   IN   @{GNB_SYSLOG_LIST}
        Run Keyword And Ignore Error   Single Testline Start Syslog Process   common_unit=${common_unit}   syslog_type=GNB
    END

    FOR   ${common_unit}   IN   @{ENB_SYSLOG_LIST}
        Run Keyword And Ignore Error   Single Testline Start Syslog Process   common_unit=${common_unit}   syslog_type=ENB
    END

    FOR   ${common_unit}   IN   @{RU_SYSLOG_LIST}
        Run Keyword And Ignore Error   Single Testline Start Syslog Process   common_unit=${common_unit}   syslog_type=RU
    END
    Sleep   5s


UUF Stop Syslog Process
    Log To Console   ${GNB_SYSLOG_FLAG}
    Log To Console   ${ENB_SYSLOG_FLAG}
    Log To Console   ${RU_SYSLOG_FLAG}
    Return From Keyword If   (not ${GNB_SYSLOG_FLAG}) and (not ${ENB_SYSLOG_FLAG}) and (not ${RU_SYSLOG_FLAG})


    FOR   ${common_unit}   IN   @{GNB_SYSLOG_LIST}
        Run Keyword And Ignore Error   Single Testline Stop Syslog Process   common_unit=${common_unit}   syslog_type=GNB
    END

    FOR   ${common_unit}   IN   @{ENB_SYSLOG_LIST}
        Run Keyword And Ignore Error   Single Testline Stop Syslog Process   common_unit=${common_unit}   syslog_type=ENB
    END

    FOR   ${common_unit}   IN   @{RU_SYSLOG_LIST}
        Run Keyword And Ignore Error   Single Testline Stop Syslog Process   common_unit=${common_unit}   syslog_type=RU
    END


UUF Save Syslog Process
    [Arguments]   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL
    Log To Console   ${GNB_SYSLOG_FLAG}
    Log To Console   ${ENB_SYSLOG_FLAG}
    Log To Console   ${RU_SYSLOG_FLAG}
    Return From Keyword If   (not ${GNB_SYSLOG_FLAG}) and (not ${ENB_SYSLOG_FLAG}) and (not ${RU_SYSLOG_FLAG})

    ${SYSLOG_FILE_LIST}   Create List
    FOR   ${common_unit}   IN   @{GNB_SYSLOG_LIST}
        ${status}   ${file_path}   Run Keyword And Ignore Error
        ...   Single Testline Save Syslog Process   common_unit=${common_unit}   syslog_type=GNB   log_dir=${log_dir}   prefix=${prefix}
        Run Keyword If   "${status}"=="PASS" and ("${file_path}"!="${None}" and "${file_path}"!="")
        ...   Append To List   ${SYSLOG_FILE_LIST}   ${file_path}
    END

    FOR   ${common_unit}   IN   @{ENB_SYSLOG_LIST}
        ${status}   ${file_path}   Run Keyword And Ignore Error
        ...   Single Testline Save Syslog Process   common_unit=${common_unit}   syslog_type=ENB   log_dir=${log_dir}   prefix=${prefix}
        Run Keyword If   "${status}"=="PASS" and ("${file_path}"!="${None}" and "${file_path}"!="")
        ...   Append To List   ${SYSLOG_FILE_LIST}   ${file_path}
    END

    FOR   ${common_unit}   IN   @{RU_SYSLOG_LIST}
        ${status}   ${file_path}   Run Keyword And Ignore Error
        ...   Single Testline Save Syslog Process   common_unit=${common_unit}   syslog_type=RU   log_dir=${log_dir}   prefix=${prefix}
        Run Keyword If   "${status}"=="PASS" and ("${file_path}"!="${None}" and "${file_path}"!="")
        ...   Append To List   ${SYSLOG_FILE_LIST}   ${file_path}
    END
    Set Suite Variable   ${SYSLOG_FILE_LIST}
    [Return]   ${SYSLOG_FILE_LIST}


Single Testline Start Syslog Process
    [Timeout]   5m
    [Arguments]   ${common_unit}   ${syslog_type}

    ${test_pc_addr}   Get Variable Value   ${common_unit["test_pc_addr"]}   ${EMPTY}
    ${test_pc_username}   Get Variable Value   ${common_unit["test_pc_username"]}   ${EMPTY}
    ${test_pc_password}   Get Variable Value   ${common_unit["test_pc_password"]}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    Log To Console   Start Syslog Process In ${syslog_type} PC: ${test_pc_addr}

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    Clean BTSlog Process   connection=${test_pc_addr}
    Clean BTSlog File   connection=${test_pc_addr}

    &{executor}   Create Dictionary    host=${test_pc_addr}   user=${test_pc_username}   password=${test_pc_password}
    btslog.create_btslog_collector
    ...   name=btslog_${test_pc_addr}
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    ...   executor=${executor}
    btslog.Set Global Alias   btslog_${test_pc_addr}
    core.setup_collectors   names=btslog_${test_pc_addr}
    core.start_collectors   names=btslog_${test_pc_addr}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


Single Testline Stop Syslog Process
    [Arguments]   ${common_unit}   ${syslog_type}

    ${test_pc_addr}   Get Variable Value   ${common_unit["test_pc_addr"]}   ${EMPTY}
    ${test_pc_username}   Get Variable Value   ${common_unit["test_pc_username"]}   ${EMPTY}
    ${test_pc_password}   Get Variable Value   ${common_unit["test_pc_password"]}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    Log To Console   Stop Syslog Process In ${syslog_type} PC: ${test_pc_addr}

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    core.stop_collectors   names=btslog_${test_pc_addr}
    Clean BTSlog Process   connection=${test_pc_addr}


Single Testline Save Syslog Process
    [Arguments]   ${common_unit}   ${syslog_type}   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL

    ${test_pc_addr}   Get Variable Value   ${common_unit["test_pc_addr"]}   ${EMPTY}
    ${test_pc_username}   Get Variable Value   ${common_unit["test_pc_username"]}   ${EMPTY}
    ${test_pc_password}   Get Variable Value   ${common_unit["test_pc_password"]}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    Log To Console   Save Syslog Process In ${syslog_type} PC: ${test_pc_addr}

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    ${btslog_name}   Set Variable   SYSLOG_${prefix}_${syslog_type}_${test_pc_addr}.zip
    Run Keyword And Ignore Error   csn.Execute   command=cd /tmp/btslog2; zip ${btslog_name} SYSLOG_*.LOG;   connection=${test_pc_addr}

    Run Keyword And Ignore Error   csn.Download File
    ...   remote_path=/tmp/btslog2/${btslog_name}
    ...   local_path=${log_dir}/${btslog_name}
    ...   connection=${test_pc_addr}
    ...   timeout=${300}
    Run Keyword And Ignore Error   Clean BTSlog File   connection=${test_pc_addr}
    Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}

    Log To Console   ${syslog_type} Syslog: ${OUTPUT_DIR}/${btslog_name}
    [Return]   ${OUTPUT_DIR}/${btslog_name}


Clean BTSlog Process
    [Arguments]   ${connection}

    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -NOGUI'     connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -nogui'     connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog'            connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/BTSLogCommandsLocalServer          connection=${connection}   timeout=${60}

    ${status}   ${iptables_ruls}   Run Keyword And Ignore Error   csn.Execute    sudo iptables -L   connection=${connection}   timeout=${60}
    ${contain_100}   Run Keyword And Return Status   Should Contain   ${iptables_ruls}   192.168.100.0/24
    ${contain_101}   Run Keyword And Return Status   Should Contain   ${iptables_ruls}   192.168.101.0/24
    Run Keyword And Ignore Error   run keyword if  not ${contain_100}   csn.Execute
    ...   command=sudo iptables -I INPUT -p udp -s 192.168.100.1/24 -j ACCEPT   timeout=${60}   connection=${connection}
    Run Keyword And Ignore Error   run keyword if  not ${contain_101}    csn.Execute
    ...   command=sudo iptables -I INPUT -p udp -s 192.168.101.1/24 -j ACCEPT   timeout=${60}   connection=${connection}


Clean BTSlog File
    [Arguments]   ${connection}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/BTSLOG_TRACE_*.bin         connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/SYSLOG_*.LOG               connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/SYSLOG_*.zip               connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=mkdir /tmp/btslog2                             connection=${connection}   timeout=${60}


#==========================================================================================================================================
#==========================================================================================================================================
#==========================================================================================================================================
# Comments: Catch RU Serial Log Currently Not Support Windows PC
UUF Start RU Serial Log
    [Timeout]   10m
    Return From Keyword If   not ${RU_SERIAL_LOG_FLAG}
    Log To Console   RU_SERIAL_LOG_FLAG is :${RU_SERIAL_LOG_FLAG}, Start to collect RU_SERIAL_LOG
    FOR   ${ru_detail}   IN   @{ALL_RU_LIST}
        Single RU Start RU Serial Log   ru_detail=${ru_detail}
    END

Single RU Start RU Serial Log
    [Timeout]   5m
    [Arguments]   ${ru_detail}
    ${hostname}   Set Variable   ${ru_detail['test_pc_addr']}
    ${username}   Set Variable   ${ru_detail['test_pc_username']}
    ${password}   Set Variable   ${ru_detail['test_pc_password']}

    Return From Keyword If   '${hostname}'=='1.1.1.1' or '${hostname}'=='' or '${hostname}'=='${None}'

    ${connection}   Set Variable   ru_serial_${hostname}
    ${status}    run keyword and return status    csn.Connect to   hostname=${hostname}   username=${username}   password=${password}
    ...   alias=${connection}   timeout=10s
    Return From Keyword If   not ${status}

    ${Return_Status}   csn.Execute    command=systemd-detect-virt   connection=${connection}
    ${if_vm}   run keyword and return status   Should Contain    ${Return_Status}    kvm
    Return From Keyword If   '${if_vm}' == '${True}'

    # ${kill_serial_command}   set variable  ps -ef|grep "cat /dev/ttyUSB0" |grep -v grep| awk '{print $2}' |xargs sudo kill -9
    # Run Keyword And Ignore Error   csn.Execute    command=${kill_serial_command}   connection=${connection}

    Run Keyword And Ignore Error   csn.Execute    command=sudo chmod 777 /tmp/putty.txt    connection=${connection}
    Run Keyword And Ignore Error   csn.Execute    command=cat /dev/null > /tmp/putty.txt    connection=${connection}


    # ${connection_obj}    csn.get_connection_by_alias    alias=${connection}

    # ${channel}    Call Method    ${connection_obj}    invoke_shell

    # Call Method    ${channel}    send    sudo -i\n
    # Sleep    1 sec
    # Call Method    ${channel}    recv    ${65535}

    # Call Method    ${channel}    send    cat /dev/ttyUSB0 &> /tmp/putty.txt &\n
    # Sleep    3 sec
    # ${output}    Call Method    ${channel}    recv    ${65535}

    # Call Method    ${channel}    close
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


UUF Stop RU Serial Log
    [Timeout]   10m
    Return From Keyword If   not ${RU_SERIAL_LOG_FLAG}
    Log To Console   RU_SERIAL_LOG_FLAG is :${RU_SERIAL_LOG_FLAG}, Stop collect RU_SERIAL_LOG process

    # :FOR   ${ru_detail}   IN   @{ALL_RU_LIST}
    #     Single RU Stop RU Serial Log   ru_detail=${ru_detail}
    # END

Single RU Stop RU Serial Log
    [Timeout]   5m
    [Arguments]   ${ru_detail}
    ${hostname}   Set Variable   ${ru_detail['test_pc_addr']}
    ${username}   Set Variable   ${ru_detail['test_pc_username']}
    ${password}   Set Variable   ${ru_detail['test_pc_password']}

    Return From Keyword If   '${hostname}'=='1.1.1.1' or '${hostname}'=='' or '${hostname}'=='${None}'

    ${connection}   Set Variable   ru_serial_${hostname}

    ${status}    run keyword and return status    csn.Connect to   hostname=${hostname}   username=${username}   password=${password}
    ...    alias=${connection}    timeout=10s
    Return From Keyword If   not ${status}

    ${Return_Status}   csn.Execute    command=systemd-detect-virt   connection=${connection}
    ${if_vm}   run keyword and return status   Should Contain    ${Return_Status}    kvm
    Return From Keyword If   '${if_vm}' == '${True}'

    ${kill_serial_command}   set variable  ps -ef|grep "cat /dev/ttyUSB0" |grep -v grep| awk '{print $2}' |xargs sudo kill -9
    csn.Execute    command=${kill_serial_command}   connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


UUF Catch RU Serial Log
    [Timeout]   10m
    [Arguments]  ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL
    Return From Keyword If   not ${RU_SERIAL_LOG_FLAG}

    Log To Console   //TODO: UUF Catch RU Serial Log
    @{ru_serial_log_list}   Create List
    FOR   ${ru_detail}   IN   @{ALL_RU_LIST}
        ${ru_log_path}   Single RU Catch RU Serial Log   ru_detail=${ru_detail}   log_dir=${log_dir}   prefix=${prefix}
        Append To List   ${ru_serial_log_list}   ${ru_log_path}
    END
    [Return]   ${ru_serial_log_list}


Single RU Catch RU Serial Log
    [Timeout]   5m
    [Arguments]   ${ru_detail}   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL
    ${hostname}   Set Variable   ${ru_detail['test_pc_addr']}
    ${username}   Set Variable   ${ru_detail['test_pc_username']}
    ${password}   Set Variable   ${ru_detail['test_pc_password']}
    ${ru_type}   Set Variable   ${ru_detail['ru_type']}

    Return From Keyword If   '${hostname}'=='1.1.1.1' or '${hostname}'=='' or '${hostname}'=='${None}'

    ${connection}   Set Variable   ru_serial_${hostname}

    ${status}    run keyword and return status    csn.Connect to   hostname=${hostname}   username=${username}   password=${password}
    ...    alias=${connection}    timeout=10s
    Return From Keyword If   not ${status}

    ${Return_Status}   csn.Execute    command=systemd-detect-virt   connection=${connection}
    ${if_vm}   run keyword and return status   Should Contain    ${Return_Status}    kvm
    Return From Keyword If   '${if_vm}' == '${True}'

    ${ru_serial_log_path}   Set Variable   ${log_dir}/RU_SERIAL_LOG_${prefix}_${ru_type}_${hostname}.txt
    Run Keyword And Ignore Error
    ...   csn.Download File    remote_path=/tmp/putty.txt   local_path=${ru_serial_log_path}   connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}
    [Return]   ${ru_serial_log_path}


#==========================================================================================================================================
#==========================================================================================================================================
#==========================================================================================================================================
# Catch RU Log
UUF Catch RU Log
    [Arguments]   ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}   ${prefix}=FAIL   ${ru_list}=ALL
    Log To Console   //TODO: UUF Catch RU Log
    Log To Console   ${RU_LOG_FLAG}

    ${log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${log_dir}
    Run Keyword If   ${log_dir_not_exist}   OperatingSystem.Create Directory   ${log_dir}

    ${ru_log_list}   Create List
    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{CONCURRENT_ENB_LIST}

        ${RU_Log_through_LMI}   ${smod_ru_log_list}   Catch Detected RU Logs via System Module
        ...   testline=${testline}  log_dir=${log_dir}   prefix=${prefix}   ru_list=${ru_list}

        Run Keyword And Ignore Error   Append To List   ${ru_log_list}   @{smod_ru_log_list}

        ${status1}   Run Keyword And Return Status   Should Not Be Empty   ${RU_Log_through_LMI}

        ${ru_pc_info1}   Run Keyword If  ${status1}   UUF Get RU PC Info Accordind To Serial   ${RU_Log_through_LMI}
        @{lmi_ru_log_list}   Run Keyword If  ${status1}   Run Keyword And Ignore Error   UUF Catch RU Log From LMI
        ...   ${testline}   ${ru_pc_info1}   log_dir=${log_dir}   prefix=${prefix}
        ...   ELSE   Create List
        Append To List   ${ru_log_list}   @{lmi_ru_log_list}

    END
    [return]   ${ru_log_list}



#==========================================================================================================================================
#==========================================================================================================================================
#==========================================================================================================================================
Check All Testline Flag in Swconfig File
    Return From Keyword If   ${DEBUG}

    Log To Console   Start To Check All Testline swconfig.txt.
    @{swconfig_list}   Create List
    FOR   ${testline}   IN   @{ALL_GNB_LIST}   @{CONCURRENT_ENB_LIST}
        Log To Console   Checking swconfig.txt: ${testline}
        ${status}   ${needReset}   Run Keyword And Ignore Error
        ...   Check Single Testline Flag in Swconfig File    testline=${testline}
        Run Keyword If   "${status}"=="PASS" and ${needReset}   Run Keywords
        ...   Log To Console   swconfig.txt Updated. Waiting testline Reseting...
        ...   AND   Single Testline Reset Site And Wait Cell Onair   testline=${testline}
        Log To Console   Checking swconfig.txt Finished: ${testline}
    END


Check Single Testline Flag in Swconfig File
    [Arguments]    ${testline}
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}
    ${ssh_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_username']}
    ${ssh_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_password']}
    ${isDualCore}   Set Variable   ${ALL_CONFIG_OTHERS['${testline}']['isDualCore']}


    ${swconfig_path}   Set Variable   ${GOLDEN_SCF_DIR}/TL${TESTLINE_IDENTITY}/swconfig.txt
    ${swconfig_content}   Catenate   SEPARATOR=
    ...   0x1A0020=1 \#Enabled SSH even with TRS\n
    ...   0x10041=5 \#Enabled UDP log\n

    ${swconfig_file_not_exist}   Run Keyword And Return Status   File Should Not Exist   path=${swconfig_path}
    Run Keyword If   ${swconfig_file_not_exist}
    ...   OperatingSystem.Create File   path=${swconfig_path}   content=${swconfig_content}

    # Run Keyword If   ${swconfig_file_not_exist}   Log To Console   Golden swconfig.txt do not exist, skip check swconfig.
    # Return From Keyword If   ${swconfig_file_not_exist}


    ${swconfig_content}   OperatingSystem.Get File   path=${swconfig_path}
    ${reset_swconfig_content}   Catenate   SEPARATOR=
    ...   ${swconfig_content}\n
    ...   \# HWF reset flag for releases before 15 December 2021\n
    ...   0x190030=0\n
    ...   \# HWF reset flag for releases after 15 December 2021\n
    ...   0x4F0214=0\n

    ${reset_swconfig_path}   Set Variable   ${GOLDEN_SCF_DIR}/TL${TESTLINE_IDENTITY}/swconfig_reset.txt
    ${reset_swconfig_file_not_exist}   Run Keyword And Return Status   File Should Not Exist   path=${reset_swconfig_path}
    Run Keyword If   ${reset_swconfig_file_not_exist}
    ...   OperatingSystem.Create File   path=${reset_swconfig_path}   content=${reset_swconfig_content}

    ${golden_swconfig_path}   Set Variable If
    ...   "${UUF_FUNCTION}"=="reset"   ${reset_swconfig_path}
    ...   ${swconfig_path}

    Log To Console   UUF_FUNCTION: ${UUF_FUNCTION}
    Log To Console   Golden swconfig File Path: ${golden_swconfig_path}

    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}  alias=${testline}
    ${primary_swconfig_exist}    csn.File Exists   remote_path=/ffs/run/swconfig.txt   connection=${testline}

    Run Keyword If   ${primary_swconfig_exist}
    ...   csn.Download File
    ...   remote_path=/ffs/run/swconfig.txt
    ...   local_path=${OUTPUT_DIR}/swconfig.txt
    ...   connection=${testline}
    ...   timeout=${300}
    ${primary_swconfig_same}   Run Keyword If   ${primary_swconfig_exist}
    ...   Evaluate   filecmp.cmp("${golden_swconfig_path}", "${OUTPUT_DIR}/swconfig.txt")   filecmp
    ...   ELSE   Set Variable   ${False}

    Run Keyword If   not ${primary_swconfig_same}    csn.Upload File
    ...   local_path=${golden_swconfig_path}
    ...   remote_path=/ffs/run/swconfig.txt
    ...   connection=${testline}

    # Run Keyword If   "${UUF_FUNCTION}"=="reset"   Add Reset Without HWF Flag To Swconfig   connection=${testline}

    Run Keyword If   not ${primary_swconfig_same}   csn.Execute
    ...   command=crasign /ffs/run/swconfig.txt
    ...   connection=${testline}

    ${needReset}   Evaluate   not ${primary_swconfig_same}

    Return From Keyword If   not ${isDualCore}   ${needReset}

    # DualCore swconfig.txt
    ${output}   csn.Execute   command=hostname   connection=${testline}
    ${output}   Strip String   ${output}
    ${dual_core_host}   Set Variable If
    ...   '${output}'=='fct-0a'   fct-4a
    ...   '${output}'=='fct-4a'   fct-0a

    csn.Connect to  hostname=${dual_core_host}  username=${ssh_username}  password=${ssh_password}  proxy=${testline}  alias=${testline}_dual
    ${secondary_swconfig_exist}    csn.File Exists   remote_path=/ffs/run/swconfig.txt   connection=${testline}_dual

    Run Keyword If   ${secondary_swconfig_exist}
    ...   csn.Download File
    ...   remote_path=/ffs/run/swconfig.txt
    ...   local_path=${OUTPUT_DIR}/swconfig_dual.txt
    ...   connection=${testline}_dual
    ...   timeout=${300}

    ${secondary_swconfig_same}   Run Keyword If   ${secondary_swconfig_exist}
    ...   Evaluate   filecmp.cmp("${golden_swconfig_path}", "${OUTPUT_DIR}/swconfig_dual.txt")   filecmp
    ...   ELSE   Set Variable   ${False}

    Run Keyword If   not ${secondary_swconfig_same}    csn.Upload File
    ...   local_path=${golden_swconfig_path}
    ...   remote_path=/ffs/run/swconfig.txt
    ...   connection=${testline}_dual

    # Run Keyword If   "${UUF_FUNCTION}"=="reset"   Add Reset Without HWF Flag To Swconfig   connection=${testline}_dual

    Run Keyword If   not ${secondary_swconfig_same}   csn.Execute
    ...   command=crasign /ffs/run/swconfig.txt
    ...   connection=${testline}_dual
    ${needReset}   Evaluate   (not ${primary_swconfig_same}) or (not ${secondary_swconfig_same})
    [Return]   ${needReset}
    [Teardown]  Run Keyword And Ignore Error   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${isDualCore}   csn.Disconnect   connection=${testline}_dual   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}
