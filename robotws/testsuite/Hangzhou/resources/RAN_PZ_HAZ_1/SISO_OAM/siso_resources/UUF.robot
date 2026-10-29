*** Settings ***
Documentation
...    SISO Common Resource files

Resource    ./common_setup.robot
Library    ./utils/others.py
Library    ./tools/common_tools.py

*** Keywords ***

Update_Sw_Build_By_Yaft
    [Arguments]    ${ute_host}    ${sw_build}      ${access_ip}=${BTS_HOST}
    SSHLibrary.Open Connection    ${ute_host}    timeout=10   alias=update
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    #${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Login    ute    ute
    #run keyword if    "${rc}" == "FAIL"    SSHLibrary.Login    ute    uteUTE!
    SSHLibrary.Write    cd /home/ute/yaft_latest
    SSHLibrary.Read Until    ~/yaft_latest$
    SSHLibrary.Write    source /home/ute/.pyenv/versions/test_repo/bin/activate
    Sleep    10s
    Run Keyword And Ignore Error    SSHLibrary.Read Until    (test_repo)
    SSHLibrary.Write    python yaft.py --force -i ${access_ip} -z ${sw_build} -u --ask_for_password
    #${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    Password:
    #run keyword if    "${rc}" == "PASS"    SSHLibrary.Write    oZPS0POrRieRtu
    Sleep    20s
    ${pwd}    Set Variable    YES
    Set Test Variable    ${yaft_1_access}    NO
    Set Test Variable    ${yaft_ok}    NO
    FOR    ${1}   IN RANGE    ${40}
        ${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    Password:
        Run keyword if    "${rc}" == "PASS"    SSHLibrary.Write    oZPS0POrRieRtu
        Run keyword if    "${rc}" == "PASS"    Set Test Variable    ${yaft_1_access}    YES
        Run keyword if    "${rc}" == "PASS"    exit for loop
        Sleep    1s
    END
    Run Keyword IF    "${yaft_1_access}" == "NO"    log    access bts is not ok
    Run Keyword IF    "${yaft_1_access}" == "NO"    SSHLibrary.Write
    ...    python yaft.py --force -i 192.168.255.119 -z ${sw_build} -u --ask_for_password
    Set Test Variable    ${yaft_7_access}    NO
    FOR    ${1}   IN RANGE    ${40}
        Run keyword if    "${yaft_1_access}" == "YES"    Set Test Variable    ${yaft_7_access}    YES
        Run keyword if    "${yaft_1_access}" == "YES"    exit for loop
        ${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    Password:
        Run keyword if    "${rc}" == "PASS"    SSHLibrary.Write    oZPS0POrRieRtu
        Run keyword if    "${rc}" == "PASS"    Set Test Variable    ${yaft_7_access}    YES
        Run keyword if    "${rc}" == "PASS"    exit for loop
        Sleep    1s
    END
    Run Keyword IF    "${yaft_7_access}" == "NO"    Fail    access bts is not ok
#    Run Keyword IF    "${yaft_7_access}" == "NO"    Fail
    FOR    ${1}   IN RANGE    ${200}
        ${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    Flashing done
        run keyword if    "${rc}" == "PASS"    Set Test Variable    ${yaft_ok}    YES
        run keyword if    "${rc}" == "PASS"    exit for loop
        Sleep    1s
    END
    Run Keyword IF    "${yaft_ok}" == "NO"    FAIL    yaft to init sw failed
    Run Keyword If    "${yaft_ok}" == "YES"    Sleep    2 min
    Set Test Variable    ${ping_ok}    NO
    FOR    ${1}   IN RANGE    ${100}
        SSHLibrary.Write    ping ${BTS_HOST} -c 1
        ${rc1}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    1 received
        SSHLibrary.Write    ping 192.168.255.119 -c 1
        ${rc2}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    1 received
        run keyword if    "${rc1}" == "PASS" or "${rc2}" == "PASS"   Set Test Variable    ${ping_ok}    YES
        run keyword if    "${rc1}" == "PASS" or "${rc2}" == "PASS"    exit for loop
        sleep     10s
    END
    Run Keyword IF    "${ping_ok}" == "NO"    FAIL    after yaft, ping is not ok!
    Run Keyword IF    "${ping_ok}" == "YES"   log    ping 255.1 is ok!
    [Teardown]    Run Keyword And Ignore Error    Run Keywords    SSHLibrary.Write    rm -rf /home/ute/yaft_latest/*
    ...    AND    SSHLibrary.Close Connection

Download_Yaft_Latest
    [Arguments]    ${ute_host}
    ${svnurl}    Set Variable    https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk
    ${svnarg}    Set Variable    --non-interactive --trust-server-cert --username=ca_ute_test --password=utetest
    SSHLibrary.Open Connection    ${ute_host}    timeout=10   alias=download_yaft
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    #${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Login    ute    ute
    #run keyword if    "${rc}" == "FAIL"    SSHLibrary.Login    ute    uteUTE!
    SSHLibrary.Write    rm -rf /home/ute/yaft_latest
    SSHLibrary.Read Until    $
#    SSHLibrary.Write    mkdir /home/ute/Downloads
#    sleep    1s
    Run Keyword And Ignore Error    SSHLibrary.Write    mkdir -p /home/ute/Downloads/cloud
    sleep    1s
    SSHLibrary.Write    mkdir /home/ute/yaft_latest
    sleep    1s
    SSHLibrary.Write    cd /home/ute/yaft_latest
    SSHLibrary.Read Until    ~/yaft_latest$
    SSHLibrary.Write    svn checkout ${svnurl}/. /home/ute/yaft_latest ${svnarg}
    Set Test Variable    ${yaft_sw_download}    NO
    FOR    ${1}   IN RANGE    ${15}
        ${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    ~/yaft_latest$
        run keyword if    "${rc}" == "PASS"    Set Test Variable    ${yaft_sw_download}    YES
        run keyword if    "${rc}" == "PASS"    exit for loop
        Sleep    10s
    END
    Run Keyword IF    "${yaft_sw_download}" == "NO"    log    yaft sw download failed
    Run Keyword IF    "${yaft_sw_download}" == "NO"    FAIL
    #SSHLibrary.Read Until    ~/yaft_latest$
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Download_Uuf_Build
    [Arguments]    ${ute_host}    ${sw_build}
    SSHLibrary.Open Connection    ${ute_host}    timeout=10   alias=download_uuf
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    #${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Login    ute    ute
    #run keyword if    "${rc}" == "FAIL"    SSHLibrary.Login    ute    uteUTE!
    SSHLibrary.Write    cd /home/ute/Downloads
    SSHLibrary.Write    sftp ${tl.UUF_SW_STORAGE['LOGIN']}@${tl.UUF_SW_STORAGE['HOST_IP']}
    FOR    ${1}   IN RANGE    ${10}
        ${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    password:
        run keyword if    "${rc}" == "PASS"    exit for loop
        Sleep    5s
    END
    #SSHLibrary.Read Until    password:
    SSHLibrary.Write    ${tl.UUF_SW_STORAGE['PASSWORD']}
    SSHLibrary.Read Until    sftp>
    SSHLibrary.Write    cd ${tl.UUF_SW_STORAGE['SW_PATH']}
    SSHLibrary.Read Until    sftp>
    SSHLibrary.Write    get ${sw_build}.zip
    Sleep    60s
    FOR    ${1}   IN RANGE    ${50}
        ${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    sftp>
        run keyword if    "${rc}" == "PASS"    exit for loop
        Sleep    10s
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Remove_User_Json_File
    [Arguments]    ${ute_host}
    SSHLibrary.Open Connection    ${ute_host}    timeout=10   alias=rm_json
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    #${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Login    ute    ute
    #run keyword if    "${rc}" == "FAIL"    SSHLibrary.Login    ute    uteUTE!
    SSHLibrary.Write    ssh toor4nsn@${BTS_HOST}
    Run Keyword And Ignore Error    SSHLibrary.Read Until    Password
    Run Keyword And Ignore Error    SSHLibrary.Write    oZPS0POrRieRtu
    SSHLibrary.Read Until    ~ >
    Wait Until Keyword Succeeds    200s    20s    SSHLibrary.Write    rm /ffs/run/config/users.json
    SSHLibrary.Read Until    ~ >
    SSHLibrary.Write    reboot
    SSHLibrary.Read Until    ~ >
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Download SW Build
    [Arguments]    ${swVersion}    ${type}=Normal
    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Not Exist   ${SW_BUILDS_DIR_PATH}
    Run Keyword And Ignore Error    Run Keyword If    ${status}    OperatingSystem.Create Directory    ${SW_BUILDS_DIR_PATH}
    ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
    ${sw_downloaded}    Run Keyword And Return Status    Should Contain Match    ${files}
    ...    regexp=${swVersion}
    Run Keyword If    '${sw_downloaded}'=='False'    sw_package_download    ${swVersion}
    ...    target_dir=${SW_BUILDS_DIR_PATH}    package_type=${type}

Rollback To Redantancy
    ${TARGET_SW_VERSION_DICT}    Evaluate    ${TARGET_SW_VERSION}
    ${btsIds}    Get Dictionary Keys    ${TARGET_SW_VERSION_DICT}
    FOR    ${btsId}   IN    @{btsIds}
        Wait For All Cells OnAir    ${ONAIR_TIME}
        coam.rollback_software    connection=${CASE_NAME}_${btsId}
    END
    Sleep    180s
    Wait Until Keyword Succeeds    400    30    Create Nodes Parameters Init    ${GLO_CONFIG_ID}
    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/setup/
    Logging Multinode Start
    Wait For All Cells OnAir    ${ONAIR_TIME}

Downgrade To Init Build
#    [Arguments]    ${intial_builds}=${INIT_SW_VERSION}    ${yaft}=${YAFT}    ${type}=Normal
    [Arguments]    ${yaft}=${YAFT}
    ${is_exits1}    Run Keyword And Return Status    Variable Should Exist    ${INIT_SW_VERSION}
    ${is_exits2}    Run Keyword And Return Status    Variable Should Exist    ${REQUIRED_BTS_ID}
    Run Keyword If    "${is_exits1}"!="${True}" and "${is_exits2}"!="${True}"
    ...    Fail    Test Variable "INIT_SW_VERSION" or "REQUIRED_BTS_ID" undefined
    ${init_sw_builds}    Run Keyword If    ${is_exits1}    Evaluate    ${INIT_SW_VERSION}
    ${init_bts_ids}    Run Keyword If    ${is_exits1}    Get Dictionary Keys    ${init_sw_builds}
    ${required_bts_ids}    Run Keyword If    ${is_exits2}    Split String    ${REQUIRED_BTS_ID}    :
    ${btsIds}    Set Variable If    ${is_exits1}    ${init_bts_ids}    ${required_bts_ids}
    FOR    ${btsId}   IN    @{btsIds}
#        ${swVersion}    Get From Dictionary    ${INIT_SW_VERSION_DICT}    ${btsId}
#        Download SW Build    ${swVersion}    ${type}
        ${len}    get length    ${tl.test_pcs}
        ${sw_type}    Should Match Regexp    ${UTE_PUSHED_SW_VERSION}    SBTS\\w+_(\\w+)_\\d+_\\d+_\\d+
        ${is_exist}    Run Keyword And Return Status    Variable Should Exist    ${SPECIFIC_BRANCH}
        ${sw_version}    ${sw_release}    Get Node SW Build And Release    ${NODE_CFG["${bts_id}"].node}
        ${init_sw_name}    Run Keyword If    ${is_exist}    common_tools.get_init_sw    sw_type=${sw_type[1]}
        ...      current_rl=${sw_release}
        ...    ELSE    Download_Init_Build    ${tl.test_pcs[0].default_ssh_connection_details.addr}    ${sw_type[1]}
        Run Keyword If    ${is_exist}    Download SW Build to VM
        ...    ${tl.test_pcs[0].default_ssh_connection_details.addr}    ${init_sw_name}    ${sw_type[1]}
#        Run Keyword If    ${len}>1 and ${is_exist}    Download SW Build to VM
#        ...     ${tl.test_pcs[1].default_ssh_connection_details.addr}    ${init_sw_name}    ${sw_type[1]}
#        ...    ELSE IF    ${len}>1
#        ...    Download_Init_Build    ${tl.test_pcs[1].default_ssh_connection_details.addr}    ${sw_type[1]}
        ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
        ${matched_file}    Get Matches   ${files}    ${init_sw_name}*
        Should Not Be Empty    ${matched_file}
        ${swFile}    Set Variable    ${SW_BUILDS_DIR_PATH}${matched_file[0]}
        ${len}    get length    ${tl.test_pcs}
        Run Keyword IF    '${YAFT}' == 'YES'    Download_Yaft_Latest    ${NODE_CFG['${btsId}'].host_ip}
        Run Keyword IF    ${len}>1 and '${YAFT}' == 'YES'    Download_Yaft_Latest
        ...    ${tl.test_pcs[1].default_ssh_connection_details.addr}
#        Run Keyword IF    ${len}>1 and ${is_exist}    Run and Return RC and Output
#        ...    scp ${swFile} ute@${tl.test_pcs[1].default_ssh_connection_details.addr}:${swFile}
        Run Keyword IF    ${len}>1
        ...    Download_Init_Build    ${tl.test_pcs[1].default_ssh_connection_details.addr}    ${sw_type[1]}
        Run Keyword If    ${len}>1 and ${is_exist}    Run and Return RC and Output
        ...    scp ${swFile} ute@${tl.test_pcs[1].default_ssh_connection_details.addr}:${swFile}
        Run Keyword IF    '${YAFT}' == 'NO'    Sleep    180s
        Run Keyword IF    '${YAFT}' == 'NO'    Wait Until Keyword Succeeds    600    30s    Verify SMOD BBMOD Enabled
        ...    ${btsId}    ${CASE_NAME}_${btsId}
        Run Keyword IF    '${YAFT}' == 'NO'    Wait Until Keyword Succeeds    20 min    30s    coam.Update Software
        ...    ${SW_BUILDS_DIR_PATH}/${matched_file[0]}    timeout=3600    connection=${CASE_NAME}_${btsId}
#        Run Keyword IF    ${len}>1 and '${YAFT}' == 'YES'    Run Keywords    Remove_config_Files
#        ...    ${NODE_CFG['${bts_id}'].host_ip}    AND    Remove_config_Files
#        ...    ${tl.test_pcs[1].default_ssh_connection_details.addr}
        Run Keyword IF    ${len}>1 and '${YAFT}' == 'YES'    Update_Sw_Build_By_Yaft
        ...    ${tl.test_pcs[1].default_ssh_connection_details.addr}    ${swFile}
        Run Keyword IF    '${YAFT}' == 'YES'    Update_Sw_Build_By_Yaft    ${NODE_CFG['${bts_id}'].host_ip}
        ...    ${swFile}
    END
#    sleep    180s
#    FOR    ${btsId}   IN    @{btsIds}
#        Wait Until Keyword Succeeds    300    30    Remove_User_Json_File    ${NODE_CFG['${btsId}'].host_ip}
#    END
    sleep    200s
    FOR    ${btsId}   IN    @{btsIds}
        Run Keyword And Ignore Error    Wait Until Keyword Succeeds    180    30s    Verify SMOD BBMOD Enabled
        ...    ${btsId}    ${CASE_NAME}_${btsId}
    END
    Wait Until Keyword Succeeds    300    30    Create Nodes Parameters Init    ${GLO_CONFIG_ID}
    Run Keyword And Ignore Error    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/setup/
    Logging Multinode Start
    FOR    ${btsId}   IN    @{btsIds}
        ${active_sw_version}    ${active_sw_release}    Get Node SW Build And Release   ${NODE_CFG["${btsId}"].node}
        Should Be True    "${init_sw_name}"=="${active_sw_version}"
    END

Verify SMOD BBMOD Enabled
    [Arguments]    ${btsId}    ${alias}=${CASE_NAME}_${btsId}
    Admin HW Check    SMOD   ${NODE_CFG['${btsId}'].sm_sn_list}    parameters=operationalState=regex"(?i)Enabled"
    ...    timeout=600s    connection=${alias}
    Admin HW Check    BBMOD   ${NODE_CFG['${btsId}'].bbmod_sn_list}    parameters=operationalState=regex"(?i)Enabled"
    ...    timeout=600s    connection=${alias}

Testcase UUF Precondition
    [Arguments]    ${case_name}    ${config_id}=${EMPTY}    ${recover}=downgrade
    Set Test Variable    ${CASE_NAME}    ${case_name}
    Set Test Variable    ${GLO_CONFIG_ID}    ${config_id}
    Set TC Dir Path
    Create Nodes Parameters Init    ${config_id}
    Update Qc Id Tag
    ${PRE_NODE_CFG}    Copy Dictionary    ${NODE_CFG}    deepcopy=True
    #Set Suite Variable    ${PRE_NODE_CFG}    ${NODE_CFG}

    Logging Multinode Start    ${TEST_LOGS_DIR_PATH}/setup
    Log Dictionary    ${NODE_CFG}
#    ${status}    ${return}    Run Keyword And Ignore Error    Variable Should Exist    ${PKG_TYPE}
#    ${type}    Set Variable If    '${status}'=='FAIL'    Normal    ${PKG_TYPE}
    Set Test Variable    ${UTE_PUSHED_SW_VERSION}    ${sw_version}
    Run Keyword If    '${recover}'=='downgrade'    Downgrade To Init Build
    Run Keyword If    '${recover}'=='rollback'    Rollback To Redantancy
    Create Nodes Parameters Init    ${config_id}
    ${PRE_NODE_CFG}    Copy Dictionary    ${NODE_CFG}    deepcopy=True
    Set Suite Variable    ${PRE_NODE_CFG}
    Run Keyword If    '${recover}'=='downgrade'    Change Testline Configuration    ${config_id}
    Wait For All Cells OnAir    ${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/setup/
    Logging Multinode Start
    ${NODE_CFG}    Copy Dictionary    ${PRE_NODE_CFG}    deepcopy=True
    ${NODE_INFO}    Get Dictionary Values    ${NODE_CFG}
    ${SingleSite}    Get From List    ${NODE_INFO}    0
    Set Suite Variable    ${INITBUILD}    ${SingleSite['software_active']}

teardown_kpi
    FOR   ${btsId}    IN     @{ALL_BTS_ID_LIST}
        coam.teardown    connection=kpi_${btsId}
    END

Remove_config_Files
    [Arguments]    ${ute_host}
    SSHLibrary.Open Connection    ${ute_host}    timeout=10   alias=rm_hwbin
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    #${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Login    ute    ute
    #run keyword if    "${rc}" == "FAIL"    SSHLibrary.Login    ute    uteUTE!
    SSHLibrary.Write    ping ${BTS_HOST} -c 1
    ${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    1 received
    Run Keyword IF    "${rc}" == "PASS"    Set Test Variable    ${access_ip}    ${BTS_HOST}
    Run Keyword IF    "${rc}" == "FAIL"    Set Test Variable    ${access_ip}    192.168.255.119
    SSHLibrary.Write    ssh toor4nsn@${access_ip}
    Run Keyword And Ignore Error    SSHLibrary.Read Until    Password
    Run Keyword And Ignore Error    SSHLibrary.Write    oZPS0POrRieRtu
    Run Keyword And Ignore Error    SSHLibrary.Read Until    ~ >
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    200s    20s    SSHLibrary.Write
    ...    rm -rf /ffs/run/config/*
    Run Keyword And Ignore Error    SSHLibrary.Read Until    ~ >
#    Run Keyword And Ignore Error    SSHLibrary.Write    reboot
#    Run Keyword And Ignore Error    SSHLibrary.Read Until    ~ >
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Download_Init_Build
    [Arguments]    ${ute_host}    ${sw_type}
    [Documentation]   Auther: lisa.ding@nokia-sbell.com
    ...    "IMPORTANT"
    ...     yi cheng will put build into 10.68.180.140 under /home/siso/LTE/UUF/
    ...    user/password ---> siso/siso
    SSHLibrary.Open Connection    ${ute_host}    timeout=10   alias=download_uuf
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    #${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Login    ute    ute
    #run keyword if    "${rc}" == "FAIL"    SSHLibrary.Login    ute    uteUTE!
    ${path_exist}    Run Keyword And Return Status    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
#    Run Keyword And Ignore Error    Run Keyword If    "${path_exist}"=="False"
#    ...    SSHLibrary.Write    mkdir -p /home/ute/Downloads/cloud
#    ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
    Run Keyword And Ignore Error   SSHLibrary.Write    mkdir -p /home/ute/Downloads/cloud
    SSHLibrary.Write    cd /home/ute/Downloads/cloud
    ${output}    SSHLibrary.Read Until    $
    SSHLibrary.Write    sftp siso@10.68.180.140
    FOR    ${1}   IN RANGE    ${10}
        ${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    password:
        run keyword if    "${rc}" == "PASS"    exit for loop
        Sleep    5s
    END
    #SSHLibrary.Read Until    password:
    SSHLibrary.Write    siso
    ${output}    SSHLibrary.Read Until    sftp>
#    Should Contain    ${output}    Connected to siso@10.68.180.140
    SSHLibrary.Write    cd /home/siso/LTE/UUF/
    ${output}   SSHLibrary.Read Until    sftp>
    SSHLibrary.Write    ls
    ${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    sftp>
    Should Contain    ${output}    ${sw_type}
    ${init_sw_name}    Should Match Regexp    ${output}    SBTS\\w+_${sw_type}_\\d+_\\d+_\\d+
    SSHLibrary.Write    get SBTS*_${sw_type}*_release_BTSSM_downloadable_A54.zip
    Sleep    60s
    FOR    ${1}   IN RANGE    ${50}
        ${rc}    ${output}    Run Keyword And Ignore Error    SSHLibrary.Read Until    sftp>
        run keyword if    "${rc}" == "PASS"    exit for loop
        Sleep    10s
    END
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection
    [Return]    ${init_sw_name}

Download SW Build to VM
    [Arguments]    ${ute_host}    ${swVersion}    ${type}=Normal
    SSHLibrary.Open Connection    ${ute_host}    timeout=10   alias=download_uuf_from_server
    Login With Public Key    ute    /home/ute/.ssh/id_rsa
    Download SW Build    ${swVersion}    ${type}
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Get_Init_Build
    [Arguments]    ${builds}    ${type}=Normal
    Log    ${builds}
    ${node_info}=         Get Dictionary Keys    ${NODE_CFG}
    ${sw}=      Run Keyword If  "software_active" in "${node_info}"
    ...    Get Dictionary Keys    ${NODE_CFG['software_active']}
    ${rc}    ${output}    Run Keyword And Ignore Error    Should Contain    ${sw}    FSM
    ${build_list}    split string    ${output}    \r\n
    ${intial_build}    Set Variable    ${EMPTY}
    FOR   ${build}    IN     @{build_list}
        ${intial_build}=      Run Keyword If  "${rc}"=="PASS" and '${type}'=='Normal'
        ...   and "FSM" in "${build}" and "CMCC" not in "${build}"
        ${intial_build}=      Run Keyword If  "${rc}"=="PASS" and '${type}'=='CMCC'
        ...   and "FSM" in "${build}" and "CMCC" in "${build}"
        ${intial_build}=      Run Keyword If  "${rc}"=="FAIL" and '${type}'=='CMCC'
        ...   and "FSM" not in "${build}" and "CMCC" in "${build}"
        ${intial_build}=      Run Keyword If  "${rc}"=="FAIL" and '${type}'=='Normal'
        ...   and "FSM" not in "${build}" and "CMCC" not in "${build}"
    END
    [Return]    ${intial_build}
