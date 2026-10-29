*** Settings ***
Documentation
...    author: winnie he
...    contact: winnie.he@nokia-sbell.com
...    file operation

Resource          RRM_Common_Resource.robot
Resource          RRM_File_Operation.robot
Resource          RRM_MultiBTS_Log_Resource.robot
*** Variables ***
# ${PA_MaxValue}           ${93}
# ${PA_NormalValue}        ${1}
# ${PA_MinValue}           ${0}
${RFS}                   ${False}
${DCAP_BASE_URL}    10.109.2.184
${ONAIR_MAX_DURATION}    30 min
${CONFIGURAED_MAX_DURATION}    15 min
${LANIP}          192.168.255.126
${CALIBRATE_WAIT}    10
${CTRL_VM_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
${CTRL_VM_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${CTRL_VM_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${Aria2c_Default_Path}    /home/ute/Project/aria2c
${SW_SERVER_LINK}    http://sw1.tc.china.nsn-net.net/build
${SW_Download_Path}    /home/ute/Downloads
# ${SRAN_Download_Link}    http://files.ute.nsn-rdnet.net/builds/enb/base
${SRAN_Download_Link}    http://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
${SRAN_Postfix}    A54
${5G_Download_link}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${5G_PRE}    5G
${SRAN_PRE}    SBTS00
# ${attenuation_ports}    ${tl.attenuator.attenuator_ports}
# ${attenuation_vendor}    ${tl.attenuator.vendor}
${PA_NormalValue}    ${2}
${BIP_SCRIPT_PATH}    ../../Resources/BIP
&{BTSLITE_INFO}        path=/shared/TA2021/BTSLite
...                    USERNAME=root
...                    PASSWORD=uteadmin
...                    Host=10.56.198.140
...                    local_path=/home/ute/BTSLite
...                    btslog_save_path=/home/ute
...                    btslog_read_path=/home/ute
${DEBUG_MODE}              ${False}
${REMOTE_MODE}             ${False}
&{fault_4590}              faultId=${4590}
@{PowerReset_Allow_Alarms}    &{fault_4590}
*** Keywords ***
Get Release
    [Arguments]    ${sw}
    ${sw_slice}    Split String    ${sw}    _
    ${release}    Run Keyword If   "_9999_" in '${sw}'    Set Variable    SBTS00
    ...    ELSE    Set Variable    ${sw_slice}[0]
    [Return]    ${release}

Kill Process
    [Arguments]    ${process_list}    ${connection}=BTS0_VM
    FOR    ${process}    IN    @{process_list}
        csn.execute    command=ps -ef|grep ${process} | awk '{print $2}' |xargs kill -9
        ...    connection=${connection}
    END

GNB Alarm Check
    [Arguments]    ${Alarm_Check_List}
    Comment    @{Faultid_list}    Split String    ${Alarm_Check_List}    ;;
    ${act_state}    ${act_id}    Run Keyword And Ignore Error    Check No Except Alarm By Faultid    ${active_alarms}
    ...    ${Alarm_Check_List}
    ${his_state}    ${his_id}    Run Keyword And Ignore Error    Check No Except Alarm By Faultid    ${historical_alarms}
    ...    ${Alarm_Check_List}
    Run Keyword If    '${act_state}'=='FAIL' and '${his_state}'=='PASS'    Fail    Active: ${act_id}
    Run Keyword If    '${act_state}'=='PASS' and '${his_state}'=='FAIL'    Fail    Historical: ${his_id}
    Run Keyword If    '${act_state}'=='FAIL' and '${his_state}'=='FAIL'    Fail    Active: ${act_id} and Historical: ${his_id}

Capture Log for Calibration
    Run Keyword And Ignore Error    Stop Bts Log
    Run Keyword And Ignore Error    Sleep    ${CALIBRATE_WAIT}
    ${timext}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    Create Directory    ${SUITE_LOG_PATH}/Calibration_log
    Start Local Bts Log Collect    log_dir=${SUITE_LOG_PATH}/Calibration_log    log_file=Syslog_${timext}.log
    Set Suite Variable    ${timext}
    Sleep    2m
    Stop Bts Log

Check Unexpect Alarm Within List
    [Arguments]    ${allowed_alarm_list}    ${common_allowed_alarm_list}    ${connection}=COAM_0
    ${Allowed_previous}    Combine Lists    ${common_allowed_alarm_list}    ${allowed_alarm_list}
    ${alarm_status}    Run Keyword And Return Status    Check Unexpect Alarm Should Not Exist
    ...    allowed_faults=@{Allowed_previous}    connection=${connection}
    should be true    ${alarm_status}


########################### For mutli BTS ##########################
Common MultiBTS Suite Setup For RRM
    [Documentation]    Author: winnie.he@nokia-sbell.com
    ...                this keyword create suite name directory path as ${SUITE_LOG_DIRECTORY}//logs//
    _Create Suite Directory
    Create BTS PC INFO Global Dictionary
    Run Keyword And Ignore Error    _Get All Gnb Active Sw Version
    Run Keyword And Ignore Error    Set Suite Variable    ${ACTIVE_SW_VERSION}
    ...    ${BTS0_ACTIVE_SW_VERSION}
    Run Keyword And Ignore Error    Get Testline Type
    Run Keyword And Ignore Error    Get TestLine Name
    Run Keyword And Ignore Error    Get Expect Sw Version
    Run Keyword And Ignore Error    Get Release By Sw Version    sw=${ACTIVE_SW_VERSION}
    Run Keyword And Ignore Error    Get UTE Image Version
    Run Keyword And Ignore Error    Prepare Netrc On VM
    Run Keyword And Ignore Error    Prepare MCShark Files
    Run Keyword If     '${REMOTE_MODE}'=='${TRUE}'    Debug Mode Change Variable

Debug Mode Change Variable
    Set To Dictionary    ${BTSLITE_INFO}    path=/shared/TA2021/BTSLite.exe
    Set To Dictionary    ${BTSLITE_INFO}    local_path=/home/ute/BTSLite.exe
    Set To Dictionary    ${BTSLITE_INFO}    btslog_save_path=/cygwin64/home/ute
    Set To Dictionary    ${BTSLITE_INFO}    btslog_read_path=/home/ute

Normal Mode Change Variable
    Set To Dictionary    ${BTSLITE_INFO}    btslog_save_path=/home/ute
    Set To Dictionary    ${BTSLITE_INFO}    btslog_read_path=/home/ute

Common MutliBTS Suite Teardown For RRM
    # Run Keyword And Ignore Error    Remove Netrc On VM
    Teardown All GNB FCT Connect

Common MultiBTS Test Setup For RRM
    [Documentation]    Author: winnie.he@nokia-sbell.com
    [Arguments]    ${is_need_load_scf}=${True}    ${is_need_load_swconfig}=${True}
    ...    ${other_method}=${None}
    ...    ${tl_allowed_faults_file_path}=${testline_configuration_path}${/}${TestLine_Name}${/}${tl_allow_faults_file_name}
    ...    ${airphone_config_tag}=${None}
    ...    ${call_type}=sa
    ...    ${base_path}=${None}
    _Create Test Directory
    Run Keyword If     '${REMOTE_MODE}'=='${False}'    Normal Mode Change Variable
    Run Keyword And Ignore Error    Clear Legacy Logs On Sbts
    Run Keyword And Ignore Error    Start To Get Resources Usage
    Login All Coam Admin
    Run Keyword And Ignore Error    MultiBTS BackupSCF For All GNB
    ${combined_allow_fault_alarms}    Get All Allow Faults    tl_allowed_faults_file_path=${tl_allowed_faults_file_path}
    Run Keyword If    "_AP_" in '${TESTLINE_TYPE}'
    ...    Setup All Airphone Env     airphone_config_tag=${airphone_config_tag}
    ...    call_type=${call_type}
    ...    base_path=${base_path}
    Run Keyword If    '${other_method}'!='${None}'    ${other_method}
    Return From Keyword If     '${DEBUG_MODE}'=='${TRUE}'    ${TRUE}
    ${sw_config_loaded_sites_index}    Run Keyword If    ${is_need_load_swconfig}    Load SWConfig For All GNB
    ${full_commissioned_sites_index}    Run Keyword If    ${is_need_load_scf}    Commission Full SCF For All GNB
    ${restart_bts_index_list}    _Get Sub List    ${sw_config_loaded_sites_index}    ${full_commissioned_sites_index}
    Restart BTS If Needed By Index     restart_bts_index_list=${restart_bts_index_list}
    Wait Until Keyword Succeeds   2x   7min    Check All GNB Alarm    ${combined_allow_fault_alarms}
    Run Keyword And Ignore Error    Start Alarm Watch Dog

Common MultiBTS Test Setup For CUS
    [Documentation]    Author: winnie.he@nokia-sbell.com
    _Create Test Directory
    COAM_Admin.Login
    Wait Until Keyword Succeeds    15 min    30 sec    Verify LTE cells should be onair
    Run Keyword And Ignore Error    COAM_Admin.Logout

Common MultiBTS Test Teardown For CUS
    [Documentation]    Author: winnie.he@nokia-sbell.com
    Log To Console    test teardown for cus

Common MultiBTS Test Teardown For RRM
    [Arguments]    ${other_method}=${None}
    Run Keyword And Ignore Error    Stop And Analysis Alarm Watch Dog
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
    Run Keyword And Ignore Error    Stop All BTSLog And Download to Local
    Run Keyword And Ignore Error    MultiBTS BackupSCF For All GNB
    Run Keyword If    '${DEBUG_MODE}'!='${TRUE}'
    ...    Run keyword if test failed     Collect Coam Snapshot For All GNB
    Run Keyword And Ignore Error    interface.Common step trigger
    run keyword if test Passed    Run Keyword And Ignore Error    _Zip Test Logs
    Run Keyword If    '${other_method}'!='${None}'    ${other_method}
    Teardown All GNB FCT Connect
    Logout All Coam Admin
    Run Keyword And Ignore Error    End Get Resources Usage And Compare
    Run Keyword And Ignore Error    AT Teardown
    Run Keyword If    "_AP_" in '${TESTLINE_TYPE}'
    ...    Run Keywords   Airphone Common Teardown    AND
    ...    Wait Until RRU Configured

_Zip Test Logs
    [Arguments]    ${connection}=BTS0_VM
    ${testlog_name}    OperatingSystem.Split Path    ${TEST_LOG_DIRECTORY}
    csn.execute
    ...    command=zip -m -D -j -r ${TEST_LOG_DIRECTORY}/${testlog_name}[-1].zip ${TEST_LOG_DIRECTORY}
    ...    connection=${connection}

_Get Sub List
    [Arguments]    ${first_list}    ${second_list}
    ${list}    Create List
    FOR    ${i}    IN    @{first_list}
        ${count}    Count Values In List    ${second_list}    ${i}
        Run keyword If    ${count}==${0}    Append To List   ${list}    ${i}
    END
    [Return]    ${list}

Restart BTS If Needed By Index
    [Arguments]    ${restart_bts_index_list}
    FOR    ${i}    IN    @{restart_bts_index_list}
        Log to Console    \***Restart BTS ${i}****\
        COAM_Admin.ResetSite     connection=COAM_${i}
    END
    Wait All GNB Status    expect_status=OnAir

MultiBTS BackupSCF For All GNB
    [Documentation]    Author: winnie.he@nokia-sbell.com
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        COAM_Admin.BackupSCF    connection=COAM_${i}
        ...    local_dir=${TEST_LOG_DIRECTORY}
        ...    file_name=back_${i}_commission.xml
    END
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Connect To One Site FCT    bts_index=${i}
        Run Keyword And Ignore Error    swconf.download_swConfig_file_from_asib_to_test_pc
        ...    localFilePath=${TEST_LOG_DIRECTORY}/back_bts${i}_swconfig.txt
        ...    remoteFilePath=/ffs/run/swconfig.txt    asib_alias=BTS${i}_LOCAL_Conn
    END

Login Coam Admin
    [Documentation]    Author: winnie.he@nokia-sbell.com
    ...     todo shold connect admin by release
    [Arguments]    ${bts_index}
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    bts_host=${BTS${bts_index}_INFO.IP}
    ...    username=${BTS${bts_index}_INFO.http_USERNAME}
    ...    password=${BTS${bts_index}_INFO.http_PASSWORD}
    ...    alias=COAM_${bts_index}
    Set Suite Variable    ${COAM_${bts_index}}    COAM_${bts_index}
    [Return]    COAM_${bts_index}

Login All Coam Admin
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Login Coam Admin    bts_index=${i}
    END

Logout All Coam Admin
    [Documentation]    Author: winnie.he@nokia-sbell.com
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Run Keyword And Ignore Error    COAM_Admin.Logout    connection=COAM_${i}
    END

Get Load Scf Path
    [Documentation]    if bts0, not post tag, other bts , add posttag BTS1
    ...   if trunk, not post tag, branch will add posttag _release
    [Arguments]    ${scf_posttag}=BTS0    ${release}=${RELEASE}
    ${matches}    Get Matches    ${TEST TAGS}    regexp=SCF_[0-9a-zA-Z-_]+
    ${scf_need_tag}    Get Length    ${matches}
    Return From Keyword If    ${scf_need_tag}==${0}
    ${matches}    Split String    ${matches[0]}    SCF_
    ${scf_file_path}    Get Load Scf Path Without Tag    scf_prefix=${matches[-1]}
    ...    scf_posttag=${scf_posttag}    release=${RELEASE}
    [Return]    ${scf_file_path}

Get Load Scf Path Without Tag
    [Documentation]    if bts0, not post tag, other bts , add posttag BTS1
    ...   if trunk, not post tag, branch will add posttag _release
    [Arguments]    ${scf_prefix}=GLODEN    ${scf_posttag}=BTS0    ${release}=${RELEASE}
    ...    ${base_scf_path}=${SCF_DIR_PATH}
    ...    ${file_suffix}=xml
    ${TestLine_Name_without_localtion}    Split String    ${TestLine_Name}    .
    ${scf_file_path}    Run keyword If    '${scf_posttag}'=='BTS0'
    ...    Join Path    ${base_scf_path}    ${TestLine_Name_without_localtion[-1]}
    ...    ${scf_prefix}.${file_suffix}
    ...    ELSE    Join Path    ${base_scf_path}    ${TestLine_Name_without_localtion[-1]}
    ...    ${scf_prefix}_${scf_posttag}.${file_suffix}
    ${scf_file_path}    Run Keyword If    '${release}'=='SBTS00'
    ...    Set Variable    ${scf_file_path}
    ...    ELSE    Join Path    ${base_scf_path}    ${TestLine_Name_without_localtion[-1]}
    ...    ${scf_prefix}_${scf_posttag}_${release}.${file_suffix}
    ${is_exist}    Run Keyword And Return Status    File Should Exist    path=${scf_file_path}
    ${scf_file_path}    Run Keyword If    '${is_exist}'=='False'
    ...    Replace String    ${scf_file_path}    _${release}    ${EMPTY}
    ...    ELSE    Set Variable    ${scf_file_path}
    ${scf_file_path}    Run Keyword If    '${is_exist}'=='False' and '${scf_posttag}'=='BTS0'
    ...    Replace String    ${scf_file_path}    _${scf_posttag}    ${EMPTY}
    ...    ELSE    Set Variable    ${scf_file_path}
    [Return]    ${scf_file_path}

Get TL SCF Path
    ${TestLine_Name_without_localtion}    Split String    ${TestLine_Name}    .
    ${scf_file_path}    Join Path    ${SCF_DIR_PATH}    ${TestLine_Name_without_localtion[-1]}
    [Return]    ${scf_file_path}

Get Load Delta Scf Json Path
    [Arguments]    ${delta_scf_posttag}=BTS0    ${release}=${RELEASE}
    ${matches}    Get Matches    ${TEST TAGS}    regexp=Delta_SCF_[0-9a-zA-Z-_]+
    ${delta_scf_need_tag}    Get Length    ${matches}
    Return From Keyword If    ${delta_scf_need_tag}==${0}
    ${matches}    Split String    ${matches[0]}    Delta_SCF_
    ${TestLine_Name_without_localtion}    Split String    ${TestLine_Name}    .
    ${delta_scf_file_path}    Run keyword If    '${delta_scf_posttag}'=='BTS0'
    ...    Join Path    ${SCF_DIR_PATH}    ${TestLine_Name_without_localtion[-1]}    ${matches[-1]}.json
    ...    ELSE    Join Path    ${SCF_DIR_PATH}    ${TestLine_Name_without_localtion[-1]}
    ...    ${matches[-1]}_${delta_scf_posttag}.json
    ${delta_scf_file_path}    Run Keyword If    '${release}'=='SBTS00'
    ...    Set Variable    ${delta_scf_file_path}
    ...    ELSE    Join Path    ${SCF_DIR_PATH}    ${TestLine_Name_without_localtion[-1]}
    ...    ${matches[-1]}_${delta_scf_posttag}_${release}.json
    [Return]    ${delta_scf_file_path}

Commission Full SCF For One GNB
    [Arguments]    ${timeout}=${600}    ${bts_index}=${0}    ${scf_file_path}=${None}
    ${release}    Get Release By Sw Version    sw=${BTS${bts_index}_ACTIVE_SW_VERSION}
    ${scf_file_path}    Run Keyword If     '${scf_file_path}'=='${None}'
    ...    Get Load Scf Path    scf_posttag=BTS${bts_index}    release=${release}
    ...    ELSE    Set Variable    ${scf_file_path}
    # ${scf_file_path}    Run Keyword If     '${scf_file_path}'=='${None}'
    # ...    Get Load Scf Path    scf_posttag=BTS${bts_index}
    # ...    ELSE    Set Variable    ${scf_file_path}
    ${status}    ${path}    Run Keyword And Ignore Error    File Should Exist    path=${scf_file_path}
    Return From Keyword If    '${status}'=='FAIL'
    ${result}    COAM_Admin.ValidateSCF    scf_file=${scf_file_path}
    ...    timeout=${timeout}
    ...    connection=COAM_${bts_index}
    Log    ${result}
    COAM_Admin.commission    scf_file=${scf_file_path}
    ...    timeout=${timeout}
    ...    connection=COAM_${bts_index}
    # Wait One GNB Status    bts_index=${bts_index}
    [Return]    ${status}

Commission Delta SCF For One GNB
    [Arguments]    ${timeout}=${600}    ${bts_index}=${0}
    ${delta_scf_file_path}    Get Load Delta Scf Json Path     delta_scf_posttag=BTS${bts_index}
    ${status}    ${path}    Run Keyword And Ignore Error    File Should Exist    path=${delta_scf_file_path}
    Run Keyword If    '${status}'=='PASS'    coam.perform_delta_recommissioning
    ...   delta_file=${delta_scf_file_path}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${timeout}
    ...   connection=COAM_${bts_index}
    # Wait One GNB Status    bts_index=${bts_index}
    [Return]    ${status}

Commission Full SCF For All GNB
    [Arguments]    ${timeout}=${600}
    ${full_commissioned_sites_index}    Create List
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Log To Console    /*** commission full scf for ${BTS${i}_INFO.IP} ***/
        ${full_commission_status}    Commission Full SCF For One GNB    bts_index=${i}
        Run Keyword If    '${full_commission_status}'=='PASS'    Append To List
        ...    ${full_commissioned_sites_index}    ${i}
    END
    Wait All GNB Status    expect_status=OnAir
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Log To Console    /*** commission delta scf for ${BTS${i}_INFO.IP} ***/
        Commission Delta SCF For One GNB     bts_index=${i}
    END
    Wait All GNB Status    expect_status=OnAir
    Sleep    180s    reason=wait for alarm display
    Log    ${timeout}
    [Return]    ${full_commissioned_sites_index}

Commission Golden SCF For All GNB
    [Documentation]    Author:Lu nicky, if bts0, not post tag, other bts , add posttag BTS1
    ...   if trunk, not post tag, branch will add posttag _release
    Log To Console    Commission Golden SCF For All GNB
    [Arguments]    ${timeout}=${600}
    ${full_commissioned_sites_index}    Create List
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Log To Console    /*** commission golden scf for ${BTS${i}_INFO.IP} ***/
        ${full_commission_status}    Commission Golden SCF For One GNB    bts_index=${i}
        Run Keyword If    '${full_commission_status}'=='PASS'    Append To List
        ...    ${full_commissioned_sites_index}    ${i}
        Wait One GNB Status    bts_index=${i}    wait_max_time=${timeout}
    END

Commission Golden SCF For One GNB
    [Documentation]    Author:Lu nicky, if bts0, not post tag, other bts , add posttag BTS1
    ...   if trunk, not post tag, branch will add posttag _release
    [Arguments]    ${timeout}=${600}    ${bts_index}=${0}    ${scf_file_path}=${None}
    ${release}    Get Release By Sw Version    sw=${BTS${bts_index}_ACTIVE_SW_VERSION}
    ${scf_file_path}    Run Keyword If     '${scf_file_path}'=='${None}'
    ...    Get Golden Scf Path    scf_posttag=BTS${bts_index}    release=${release}
    ...    ELSE    Set Variable    ${scf_file_path}
    ${status}    ${path}    Run Keyword And Ignore Error    File Should Exist    path=${scf_file_path}
    Return From Keyword If    '${status}'=='FAIL'
    ${result}    COAM_Admin.ValidateSCF    scf_file=${scf_file_path}
    ...    timeout=${timeout}
    ...    connection=COAM_${bts_index}
    Log    ${result}
    COAM_Admin.commission    scf_file=${scf_file_path}
    ...    timeout=${timeout}
    ...    connection=COAM_${bts_index}
    # Wait One GNB Status    bts_index=${bts_index}
    [Return]    ${status}

Get Golden Scf Path
    [Documentation]    Author:Lu nicky, if bts0, not post tag, other bts , add posttag BTS1
    ...   if trunk, not post tag, branch will add posttag _release
    [Arguments]    ${scf_posttag}=BTS0    ${release}=${RELEASE}
    ${matches}    Get Matches    ${TEST TAGS}    regexp=SCF_[0-9a-zA-Z-_]+
    ${scf_need_tag}    Get Length    ${matches}
    Return From Keyword If    ${scf_need_tag}==${0}
    ${matches}    Split String    ${matches[0]}    SCF_
    ${scf_file_path}    Get Golden Scf Path Without Tag    scf_posttag=${scf_posttag}    release=${RELEASE}
    [Return]    ${scf_file_path}

Get Golden Scf Path Without Tag
    [Documentation]    Author:Lu nicky, if bts0, not post tag, other bts , add posttag BTS1
    ...   if trunk, not post tag, branch will add posttag _release
    [Arguments]    ${scf_prefix}=GLODEN    ${scf_posttag}=BTS0    ${release}=${RELEASE}
    ${TestLine_Name_without_localtion}    Split String    ${TestLine_Name}    .
    ${scf_file_path}    Run keyword If    '${scf_posttag}'=='BTS0'
    ...    Join Path    ${SCF_DIR_PATH}    ${TestLine_Name_without_localtion[-1]}    ${scf_prefix}.xml
    ...    ELSE    Join Path    ${SCF_DIR_PATH}    ${TestLine_Name_without_localtion[-1]}
    ...    ${scf_prefix}_${scf_posttag}.xml
    ${scf_file_path}    Run Keyword If    '${release}'=='SBTS00'
    ...    Set Variable    ${scf_file_path}
    ...    ELSE    Join Path    ${SCF_DIR_PATH}    ${TestLine_Name_without_localtion[-1]}
    ...    ${scf_prefix}_${scf_posttag}_${release}.xml
    ${is_exist}    Run Keyword And Return Status    File Should Exist    path=${scf_file_path}
    ${scf_file_path}    Run Keyword If    '${is_exist}'=='False' and '${scf_posttag}'=='BTS0'
    ...    Replace String    ${scf_file_path}    _${scf_posttag}    ${EMPTY}
    ...    ELSE    Set Variable    ${scf_file_path}
    ${is_exist1}    Run Keyword And Return Status    File Should Exist    path=${scf_file_path}
    ${scf_file_path}    Run Keyword If    '${is_exist1}'=='False'
    ...    Replace String    ${scf_file_path}    _${release}    ${EMPTY}
    ...    ELSE    Set Variable    ${scf_file_path}
    [Return]    ${scf_file_path}

Verify All GNB Status
    [Arguments]    ${expect_status}=OnAir
    FOR    ${i}    IN RANGE    ${GNB_NUMBER}
        Verify One GNB Onair     connection=COAM_${i}    expect_status=${expect_status}
    END

Verify One GNB Status
    [Arguments]    ${connection}=COAM    ${expect_status}=OnAir
    ${bts_status}    coam.get_bts_statuses    timeout=20    connection=${connection}
    ${status}   Set Variable   ${bts_status['proceduralState']}
    Should Be Equal   ${status}    ${expect_status}
    Run Keyword If    '${expect_status}'=='OnAir'    Run Keywords
    ...    Verify LTE cells should be onair    connection=${connection}    AND
    ...    Verify 5G cells should be onair    connection=${connection}

Wait One GNB Status
    [Arguments]    ${bts_index}    ${expect_status}=OnAir    ${wait_max_time}=${ONAIR_MAX_DURATION}
    Log To Console    /*** wait to reconnect bts ${bts_index} ***/
    Run Keyword And Ignore Error    COAM_Admin.Logout    connection=COAM_${bts_index}
    Wait Until Keyword Succeeds   3x   15min    Login Coam Admin    bts_index=${bts_index}
    Log To Console    /*** wait bts ${bts_index} ${expect_status}***/
    Wait Until Keyword Succeeds    ${wait_max_time}    30s    Verify One GNB Status
    ...    connection=COAM_${bts_index}    expect_status=${expect_status}

Wait All GNB Status
    [Arguments]    ${expect_status}=OnAir
    FOR    ${i}    IN RANGE    ${GNB_NUMBER}
        Wait One GNB Status    bts_index=${i}    expect_status=${expect_status}
    END

Get Load SWConfig Path
    [Arguments]    ${swconfig_tag}=BTS0
    ${matches}    Get Matches    ${TEST TAGS}    regexp=SWCONFIG_[0-9a-zA-Z_]+
    ${swconfig_need_tag}    Get Length    ${matches}
    ${TestLine_Name_without_localtion}    Split String    ${TestLine_Name}    .
    ${swconfig_file_path}    Run Keyword If    ${swconfig_need_tag}>${0}
    ...    Join Path    ${SWCONFIG_DIR_PATH}    ${TestLine_Name_without_localtion[-1]}    ${matches[0]}_${swconfig_tag}.txt
    ...    ELSE    Set Variable    ${None}
    [Return]    ${swconfig_file_path}

Load SWConfig For All GNB
    ${sw_config_loaded_sites_indexs}    Create List
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        ${swconfig_file_path}    Get Load SWConfig Path    swconfig_tag=BTS${i}
        ${status}    ${path}    Run Keyword And Ignore Error    File Should Exist    path=${swconfig_file_path}
        Connect To One Site FCT    bts_index=${i}
        Run Keyword If    '${status}'=='PASS'    Run Keywords    ReplaceSwconfig    local_path=${swconfig_file_path}
        ...    remote_path=/ffs/run/swconfig.txt
        ...    alias=BTS${i}_LOCAL_Conn
        ...    AND    Append To List    ${sw_config_loaded_sites_indexs}    ${i}
    END
    [Return]    ${sw_config_loaded_sites_indexs}

_Create Test Directory
    ${timestamp}    Get TimeStamp With Date
    ${tc_name}    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_NAME}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}

Connect To One Site FCT
    [Arguments]    ${bts_index}=0
    ${exist}    Run Keyword And Return Status    csn.Get Connection By Alias
    ...    alias=BTS${bts_index}_LOCAL_Conn
    Run Keyword If    ${exist}
    ...    csn.Force Reconnect    connection=BTS${bts_index}_LOCAL_Conn
    ...    ELSE
    ...    csn.connect_to    hostname=${BTS${bts_index}_INFO.IP}    username=${BTS${bts_index}_INFO.USERNAME}
    ...    password=${BTS${bts_index}_INFO.PASSWORD}    alias=BTS${bts_index}_LOCAL_Conn

Teardown All GNB FCT Connect
    [Documentation]    Author: winnie.he@nokia-sbell.com
    ...                this keyword use to teardown all gnb connection
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Run Keyword And Ignore Error    Disconnect FCT    alias=BTS${i}_LOCAL_Conn
    END

Check All GNB Alarm
    [Arguments]    ${allow_alarm_list}
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        ${alarm_status}    Run Keyword And Return Status    Check Unexpect Alarm Should Not Exist
        ...    allowed_faults=@{allow_alarm_list}
        ...    file_path=${TEST_LOG_DIRECTORY}
        ...    connection=COAM_${i}
        should be true    ${alarm_status}
    END

Collect Coam Snapshot For All GNB
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        Run Keyword And Ignore Error    Collect Coam Snapshot For One GNB   gnb_index=${i}
        ...    name=gnb${i}_coam_snapshot
    END

Print Anything Test
    Log to console    Print Anything Test

Get BTS Index By S1 Ip
    ${ret}    OperatingSystem.Run    command=sudo ifconfig
    Log    ${ret}
    ${VM_IP_Matched}    Get Regexp Matches    ${ret}    inet ${VM_IP_EXP_STRING}
    ${VM_IP_Splited}    Split String    ${VM_IP_Matched}[0]    inet${SPACE}
    ${test_pc_count}    Get Length    ${tl.test_pcs}
    FOR    ${test_pc_index}    IN RANGE    ${test_pc_count}
        Exit For Loop If
        ...    '${VM_IP_Splited}[-1]'=='${tl.test_pcs[${test_pc_index}].default_ssh_connection_details.addr}'
    END
    Log    ${test_pc_index}
    [Return]    ${test_pc_index}

Get RAT Type
    [Documentation]    judge the bts type
    [Arguments]    ${bts_index}=${0}
    ${rat_types}    Create List
    ${nr_cells}    COAM_Admin.getcellinfo    cell_type=nr    connection=COAM_${bts_index}
    ${ne_cell_count}    Get Length    ${nr_cells}
    ${lte_cells}    COAM_Admin.getcellinfo    cell_type=lte    connection=COAM_${bts_index}
    ${lte_cell_count}    Get Length    ${lte_cells}
    ${wncell_cells}    COAM_Admin.getcellinfo    cell_type=wcdma    connection=COAM_${bts_index}
    ${wncell_cell_count}    Get Length    ${wncell_cells}
    Run Keyword If    ${ne_cell_count}!=${0}    Append To List    ${rat_types}    NR
    Run Keyword If    ${lte_cell_count}!=${0}    Append To List    ${rat_types}    LTE
    Run Keyword If    ${wncell_cell_count}!=${0}    Append To List    ${rat_types}    WCDMA
    [Return]    ${rat_types}

#------------------Upgrade---------------------------------------------------------------------------------
COAM_Admin.UpdateSW One GNB
    [Arguments]    ${SW_Buid_path}
    ...            ${activate}=yes    ${connection}=COAM_local
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Upgrade the SWB for BTS. The SWB should be exist in /home/ute/Downloads .
    ...                And the file's full path and name should be provided.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${SW_Buid_path} | Yes | The SWB file's full path and name |
    ...    | ${activate} | No | Whether the SWB should be activated after upgrade to BTS. Default is yes |
    ...    | ${connection} | No | The alias for this connection, default is COAM_local |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.UpdateSW_local | SW_Buid_path=/home/ute/Downloads/SBTS00_ENB_9999_210925_000001_release_BTSSM_downloadable_A54.zip |
    ...
    Log To Console    Start Software Updating on ${connection}...
    ${should_activate}    Set Variable If    '${activate}'=='yes'    ${True}
    ...    '${activate}'=='no'    ${False}
    coam.update_software    sw_package=${SW_Buid_path}    should_activate=${True}    timeout=${3600}    connection=${connection}
    Log To Console    Software Update Finished, Waiting For ${connection} Resetting...

#-------------------Connect VM---------------------------------------------------------------------------------
Connect All VM
    Create BTS PC INFO Global Dictionary
    ${vm_count}    Get Length    ${tl.test_pcs}
    Set Suite Variable    ${VM_COUNT}    ${vm_count}
    FOR    ${i}    IN RANGE    ${vm_count}
        csn.connect_to    hostname=${BTS${i}_PC_INFO.Host}
        ...    username=${BTS${i}_PC_INFO.USERNAME}
        ...    password=${BTS${i}_PC_INFO.PASSWORD}
        ...    alias=BTS${i}_VM
    END

Disconnect All VM
    ${vm_count}    Get Length    ${tl.test_pcs}
    FOR    ${i}    IN RANGE    ${vm_count}
        csn.disconnect    connection=BTS${i}_VM
    END
#-------------------Run many case---------------------------------------------------------------------------------
