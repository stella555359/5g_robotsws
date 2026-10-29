*** Settings ***
Documentation    These keywords allow common actions, such as ssh connection to remote machine.
    ...    IP addresses are available in common variables files or can be overwritten in every TL config.
    ...    robot -V /home_local/Code/Classical_bts/testline_configuration_5G/Hangzhou/7_5_HZ_CLAS_WD0205 -L TRACE
    ...    /home_local/CRT_Test/robotws5g/testsuite/RRM/ECE/Resource/robot/common.robot
    ...    author:  Wang, Robert
    ...    contact: Wang, Robert 2. (NSB - CN/Hangzhou) <robert.2.wang@nokia-sbell.com>

Library           OperatingSystem
Library           Collections
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.gnb.oam.megazone_client    WITH NAME    megazone_client
#Library           ${CURDIR}/../python/frt_common.py
#Library           ${CURDIR}/../python/frt_scf.py
Library           taf.gnb.oam.commissioning    WITH NAME    commissioning
Library           taf.config.scf    WITH NAME    cscf
Library           taf.lteemu    WITH NAME    lteemu
#Library           ${CURDIR}/../../../../../resources/python_libs/gnb_test_modes.py    WITH NAME    gnb_test_modes
#Resource          ${CURDIR}/../../../../../resources/common/DEPRECATED/bb1.robot
#Resource          ${CURDIR}/frt_scf.robot
#Resource          ${CURDIR}/frt_operation.robot
#Resource          taf/rfrl/common_resources/robot/preconditions.robot
#Resource          ${CURDIR}/frt_oam.robot
#Resource          ${CURDIR}/../../../../../resources/common/common_definitions.robot
#Resource          ${CURDIR}/../../../../../resources/common/DEPRECATED/wireshark_parsing.robot

*** Variables ***
${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${AIRPHONE_URL}
${SSH_OAM_AUTHENTICATION_TIMEOUT}      10 min
${SSH_AUTHENTICATION_RETRY_INTERVAL}      5 s
${SSH_AUTHENTICATION_TIMEOUT}      5 min
${SCF_DIR_PATH}    /tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/5gClassicalBTS/
${PROFILE_PATH}    /tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/profiles
@{slottype_list}    Slot:\ \ 0, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 1, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 2, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 3, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot:\ \ 4, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot:\ \ 5, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 6, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 7, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 8, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot:\ \ 9, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot: 10, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 11, Type:\ \ \ \ SLOT_TYPE_41
...    Slot: 12, Type:\ \ \ \ SLOT_TYPE_41
...    Slot: 13, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot: 14, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot: 15, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 16, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 17, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 18, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot: 19, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot:\ \ 0, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 1, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 2, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 3, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot:\ \ 4, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot:\ \ 5, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 6, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 7, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 8, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot:\ \ 9, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot: 10, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 11, Type:\ \ \ \ SLOT_TYPE_41
...    Slot: 12, Type:\ \ \ \ SLOT_TYPE_41
...    Slot: 13, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot: 14, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot: 15, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 16, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 17, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 18, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot: 19, Type:\ \ \ \ SLOT_TYPE_PRACH
...    Slot:\ \ 0, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 1, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 2, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 3, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot:\ \ 4, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot:\ \ 5, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 6, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 7, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 8, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot:\ \ 9, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot: 10, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 11, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 12, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 13, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot: 14, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot: 15, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 16, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 17, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 18, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot: 19, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot:\ \ 0, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 1, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 2, Type:\ \ SLOT_TYPE_SSBURST
...    Slot:\ \ 3, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot:\ \ 4, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot:\ \ 5, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 6, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 7, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot:\ \ 8, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot:\ \ 9, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot: 10, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 11, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 12, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 13, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot: 14, Type:\ \ \ \ SLOT_TYPE_C5
...    Slot: 15, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 16, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 17, Type:\ \ \ \ SLOT_TYPE_B0
...    Slot: 18, Type:\ \ \ \ SLOT_TYPE_B2
...    Slot: 19, Type:\ \ \ \ SLOT_TYPE_PRACH

*** Keywords ***
Connect to DU for cloud
    [Arguments]    ${alias}=DU
    [Documentation]    This keyword will create new cloud DU connection and the default connection name is "DU".
    ...
    ...    Make sure that IP addresses are available in common variables files.
    ...
    ...    :aram alias: string, ${alias}=DU
    ...
    ...    :return: Du connection instance: ${alias}
    ...
    ...    **Examples:**
    ...
    ...    | Connect to DU for cloud
    csn.connect_to      hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                 password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    alias=${alias}

Reboot DU and Reconnect
    [Documentation]
    ...   Reboot DU and reconnect, if cloud gNB, DU means DU, if classical, DU means gNB
    ...
    ...    **Examples:**
    ...
    Connect to gNB DU
    Ssh Execute With Timeout    reboot    connection=DU_conn
    Run Keyword And Ignore Error    csn.Disconnect    connection=DU_conn
    wait until keyword succeeds    10 min    10 sec    Connect to gNB DU

connect to ASIK
    [Arguments]    ${alias}=asik
    [Documentation]    This keyword will create new ASIK's connection and the default connection name is "asik".
    ...    Make sure that IP addresses are available in common variables files.
    ...
    ...    :param alias: string,${alias}=asik
    ...
    ...    :return: ASIK connection instance: ${alias}
    ...
    ...    **Examples:**
    ...
    ...    | connect to ASIK
    ...
    csn.Connect to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    alias=${alias}



connect to fsp
    [Arguments]    ${hostname}=fsp1_c    ${alias}=fsp    ${proxy}=asik
    [Documentation]    This keyword will create new fsp1_c connection and the default connection name is "fsp",
    ...    Make sure the ASIK's connection "asik" has been created.
    ...
    ...    :param alias: string ,${hostname}=fsp1_c    ${alias}=fsp    ${proxy}=asik
    ...
    ...    :return: fsp1_c connection instance: ${alias}
    ...
    ...    **Examples:**
    ...
    ...    | connect to fsp
    ...
    connections.Connect via root if passed username fails    hostname=fsp1_c
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    alias=${alias}    proxy=${proxy}

connect to host
    [Arguments]    ${alias}=testPC
    [Documentation]    This keyword will create new testPC's connection and the default connection name is "testPC".
    ...    Make sure that IP addresses are available in common variables files.
    ...
    ...    :param alias: string ,${alias}=testPC
    ...
    ...    :return: testPC connection instance: ${alias}
    ...
    ...    **Examples:**
    ...
    ...    | connect to host
    ...
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=${alias}

Connect to BB1 master
    [Arguments]    ${alias}=BB1
    [Documentation]    This keyword will create new BB1 master connection and the default connection name is "BB1".
    ...    Make sure that IP addresses are available in common variables files.
    ...
    ...    :param alias: string, ${alias}=BB1
    ...
    ...    :return: BB1 master connection instance: ${alias}
    ...
    ...    **Examples:**
    ...
    ...    | Connect to BB1 master
    ...
    csn.Connect to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    alias=${alias}

Connect to BB1 slave
    [Arguments]    ${alias}    ${proxy}=BB1
    [Documentation]    This keyword will create new BB1 slave connection and you must define connection name ${alias}.
    ...    Make sure the BB1 master connection "BB1" has been created.
    ...
    ...    :param alias: string, ${alias}
    ...
    ...    :return: BB1 slave connection instance: ${alias}
    ...
    ...    **Examples:**
    ...
    ...    | Connect to BB1 slave    alias=BB1 slave
    ...
    csn.Connect to    hostname=fctlb
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    alias=${alias}    proxy=${proxy}

Connect to BB1 ABIL
    [Arguments]    ${alias}    ${proxy}=BB1
    [Documentation]    This keyword will create new BB1 ABIL connection and you must define connection name ${alias}.
    ...    Make sure the BB1 master connection "BB1" has been created.
    ...
    ...    :param alias: string, ${alias}
    ...
    ...    :return: BB1 ABIL connection instance: ${alias}
    ...
    ...    **Examples:**
    ...
    ...    | Connect to BB1 ABIL    alias=BB1 ABIL
    ...
    csn.Connect to    hostname=fsp1_c
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    alias=${alias}    proxy=${proxy}

Connect to Capacity Unit Master
    [Arguments]    ${alias}    ${proxy}=BB1
    [Documentation]    This keyword will create new ABIL master connection and you must define connection name ${alias}.
    ...    Make sure the BB1 master connection "BB1" has been created.
    ...
    ...    :param alias: string, ${alias}
    ...
    ...    :return: ABIL master connection instance: ${alias}
    ...
    ...    **Examples:**
    ...
    ...    | Connect to Capacity Unit Master   alias=ABIL master
    ...
    csn.Connect to    hostname=fsp1_a
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    alias=${alias}    proxy=${proxy}

Connect to Capacity Unit Slave
    [Arguments]    ${alias}    ${proxy}=BB1
    [Documentation]    This keyword will create new ABIL slave connection and you must define connection name ${alias}.
    ...    Make sure the BB1 master connection "BB1" has been created.
    ...
    ...    :param alias: string, ${alias}
    ...
    ...    :return: ABIL slave connection instance: ${alias}
    ...
    ...    **Examples:**
    ...
    ...    | Connect to Capacity Unit Slave   alias=ABIL slave
    ...
    csn.Connect to    hostname=fsp1_b
    ...    username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}    alias=${alias}    proxy=${proxy}

check board status
    [Arguments]    ${connection}    ${board_id}    ${CCS_Daemon_node_id}='0x1011'
    [Documentation]    This keyword will check board status according to your environment.
    ...    Make sure the connection has been created, and you'd better get correct ${board_id} and ${CCS_Daemon_node_id} first with the keyword of
    ...    "Get CCS Node ID and Borad ID".
    ...
    ...    :param alias: string, ${connection} ${board_id} ${CCS_Daemon_node_id}
    ...
    ...    :return: True or False
    ...
    ...    **Examples:**
    ...
    ...    | Get CCS Node ID and Borad ID
    ...
    ...    | check board status    connection=asik    board_id=${ASIK_board_id}    CCS_Daemon_node_id=${CCS_Daemon_node_id}
    ...
    ${result}    frt_common.check hw status    hw_node=${board_id}    alias=${connection}    CCS_Daemon_node_id=${CCS_Daemon_node_id}
    should be true      ${result}

Get CCS Node ID and Borad ID
    [Documentation]    This keyword will help to get ${CCS_Daemon_node_id}, ${ASIK_board_id} and ${ABIL_board_id}.
    ...
    ...    :return: three variable: ${CCS_Daemon_node_id} ${ASIK_board_id} ${ABIL_board_id}
    ...
    ...    **Examples:**
    ...
    ...    | Get CCS Node ID and Borad ID
    ...
    Connect to BB1 master    alias=asik
    ${CCS_Daemon_node_id}=    frt_common.get_CCS_Daemon_node_id    connection=asik
    ${ASIK_board_id}=    run keyword if    '${CCS_Daemon_node_id}'=='0x1011'    set variable    0x10
    ...    ELSE IF    '${CCS_Daemon_node_id}'=='0x2011'    set variable    0x20
    ${ABIL_board_id}=    run keyword if    '${CCS_Daemon_node_id}'=='0x1011'    set variable    0x12
    ...    ELSE IF    '${CCS_Daemon_node_id}'=='0x2011'    set variable    0x22
    set suite variable    ${CCS_Daemon_node_id}
    set suite variable    ${ASIK_board_id}
    set suite variable    ${ABIL_board_id}

check autodetection service on abil
    [Documentation]    This keyword will check autodetection service on abil.
    ...
    ...    :return: True or False
    ...
    ...    **Examples:**
    ...
    ...    | check autodetection service on abil
    ...
    connect to ASIK
    connect to fsp
    ${status}    verify_fsp_status    service=autodetection    alias=fsp
    should be true    ${status}

Check if ASIK and ABIL Ready
    [Documentation]    This keyword will check if ASIK and ABIL are ready. If until timeout the boards are nor ok will reset.
    ...
    ...    :return: True or Reset
    ...
    ...    **Examples:**
    ...
    ...    | Check if ASIK and ABIL Ready
    ...
    Get CCS Node ID and Borad ID
    Wait Until Keyword Succeeds    6min    10sec
    ...    check board status    connection=asik    board_id=${ASIK_board_id}    CCS_Daemon_node_id=${CCS_Daemon_node_id}
    ${match}  ${value}=    Run Keyword and ignore error    Wait Until Keyword Succeeds    15min    10sec
    ...    check board status    connection=asik    board_id=${ABIL_board_id}    CCS_Daemon_node_id=${CCS_Daemon_node_id}
    run keyword if    '${match}'=='FAIL'    Reset ABIL or Powerreset BTS

Connect to LTEEMU
    [Arguments]    ${alias}=lteemu
    [Documentation]    This keyword will create new LTEEMU's connection and the default connection name is "lteemu".
    ...    Make sure that IP addresses are available in common variables files.
    ...
    ...    :param alias: string, ${alias}=lteemu
	...
    ...    :return: LTEEMU connection instance: ${alias}
    ...
    ...    **Examples:**
    ...
    ...    | connect to LTEEMU
    ...
    csn.connect_to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...               username=${tl.core.default_ssh_connection_details.username}
    ...               password=${tl.core.default_ssh_connection_details.password}
    ...               alias=${alias}

Connect to OAM via Https
    [Documentation]    This keyword will create new OAM session via Https.
    ...    Make sure ${WEBUI_URL} is available.
    ...
    ...    :return: new OAM session via Https
    ...
    ...    **Examples:**
    ...
    ...    | Connect to OAM via Https
    ...
    run keyword and ignore error    megazone_client.teardown_session
    megazone_client.create_session    base_url=${WEBUI_URL}

Connect to Airphone OAM via Https
    [Documentation]    This keyword will create new Airphone OAM session via Https.
    ...
    ...    :return: new Airphone OAM session via Https
    ...
    ...    **Examples:**
    ...
    ...    | Connect to Airphone OAM via Https
    ...
    run keyword and ignore error    megazone_client.teardown_session    session=WEB_AIRPHONE
    megazone_client.create_session    base_url=${AIRPHONE_URL}    alias=WEB_AIRPHONE

Sync Time
    [Arguments]    ${base_alias}    ${target_alias}    ${sudo_flag}='False'
    [Documentation]    This KW sync time from base_alias to target_alias.
    ...    Make sure that base_alias and target_alias connections are created.
    ...
    ...    :param alias: string, ${base_alias} ${target_alias} ${sudo_flag}='False'
    ...
    ...    **Examples:**
    ...
    ...    | connect to host     alias=testPC
    ...
    ...    | Connect to LTEEMU    alias=lteemu
    ...
    ...    | Sync time    testPC    lteemu
    ...
    ${time_base}=    csn.execute      date -u     connection=${base_alias}
    BuiltIn.Log     Set time ${time_base}
    Run Keyword if  ${sudo_flag}=='True'
    ...     csn.execute      date -s "${time_base}"   connection=${target_alias}
    ...     ELSE
    ...     csn.execute      date -s "${time_base}"   connection=${target_alias}

Check CPRI Status
    [Arguments]    ${log_path}    ${connection}
    [Documentation]    This KW to check the CPRI status should be ok in the log file, alawys with the log file of startup_NODEOAM_LOG.
    ...    Make sure the log file is exist.
    ...
    ...    :param alias: string, ${log_path} ${connection}
    ...
    ...    **Examples:**
    ...
    ...    | Check CPRI Status    log_path=/tmp/startup_NODEOAM.log    connection=BB1
    ...
    ${cpri_cont}    csn.execute    grep 'CPRI link state' ${log_path}    ${connection}
    Should Contain    ${cpri_cont}    link state is F

Get SWconfig from QT and Upload
    [Arguments]    ${swconfig_in_qt}    ${swconfig_addon}   ${connection}
    [Documentation]    Download swconfig.txt from Quicktest repository on Gerrit server
    ...     https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/CI/QT/qt_configs.git;a=blob_plain;f=${swconfig_in_qt};hb=HEAD
    ...     and upload it to DU.
    ...
    ...    :param alias: string, ${swconfig_in_qt} ${swconfig_addon} ${connection}
    ...
    ...    **Examples:**
    ...
    ...    | Connect to BB1 master    alias=BB1
    ...
    ...    | ${stream}=    map_version_to_stream_name    ${version}
    ...
    ...    | Get SWconfig from QT and Upload
    ...
    ...    | swconfig_in_qt=global_configs/streams/${stream}/swconfig.txt
    ...
    ...    | swconfig_addon=${CURDIR}/config/ClassicalBTS/swconfig_addon_${stream}.txt
    ...
    ...    | connection=BB1
    ...
    ${swconfig_url}     Set Variable
    ...     https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/CI/QT/qt_configs.git;a=blob_plain;f=${swconfig_in_qt};hb=HEAD
    ${rc}   Run And Return Rc
    ...     curl -k -s "${swconfig_url}" > ${TEMP_PATH}/swconfig.txt
    Should Be Equal As Integers     ${rc}   0
    ...     msg=No access to ${swconfig_url}
    ${swconfig}     Get File    ${TEMP_PATH}/swconfig.txt
    # if qt file not exists, curl returns html page containing "Cannot find file"
    Should Not Contain      ${swconfig}     Cannot find file    msg=Do not find ${swconfig_url}     values=False
    # add FRT specific changes to swconfig
    OperatingSystem.Run     cat ${swconfig_addon} >> ${TEMP_PATH}/swconfig.txt
    csn.upload_file
    ...    local_path=${TEMP_PATH}/swconfig.txt
    ...    remote_path=/ffs/run/swconfig.txt    connection=${connection}

Check Cell Setup On L2PS
    [Documentation]    This KW to check whether cell setup successfully on L2PS in the jour log.
    ...    This kw will create new jour abil master log and check the message, and then remove the jour log.
    ...
    ...    :param alias: string, ${log_path} ${connection}
    ...
    ...    **Examples:**
    ...
    ...    | Check CPRI Status    log_path=/tmp/startup_NODEOAM.log    connection=BB1
    ...
    Connect to BB1 master
    Connect to Capacity Unit Master   alias=ABIL master
    ${abil_master_jour_log}    csn.execute    journalctl -b > journal_abil_master.log 2> /dev/null    connection=ABIL master
    ${check_cell_setup_mes}    csn.execute
    ...    cat journal_abil_master.log | grep 'itf::l2::ps::internal::SysInfoConfigResp received'    connection=ABIL master
    ${remove_master_jour_log}    csn.execute    rm journal_abil_master.log   connection=ABIL master
    Should Contain    ${check_cell_setup_mes}    itf::l2::ps::internal::SysInfoConfigResp received

Recovery cell on air on cloud
    [Documentation]    This keyword is to Recovery cell on air on cloud testline.
    ...
    ...    **Examples:**
    ...
    ...    | Recovery cell on air on cloud
    ...
    Do commission on cloud
    Connect to OAM via Https
    megazone_client.wait_for_site_availability    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}    20
    Wait Until Keyword Succeeds    240s    5s    Check all VM statuses should be right
    Check DU status should be right    20min
    ${passed}=     Run Keyword and Return Status    Wait Until Keyword Succeeds    30s    2s    Verify cell on air
    Run Keyword If    '${passed}' == 'False'    Setup LTEemu environment
    Wait Until Keyword Succeeds    60s    5s    Verify Cell on air

Recovery cell on air on classical
    [Documentation]    This keyword is to Recovery cell on air on cloud testline.
    ...
    ...    :Author:  Miao yonggang
    ...    :Contact: yonggang.miao@nokia-sbell.com
    ...
    ...    **Examples:**
    ...
    ...    | Recovery cell on air on cloud
    ...
    Do commission on classical
    Connect to OAM via Https
    Check DU status should be right    10min
    ${passed}=     Run Keyword and Return Status    Wait Until Keyword Succeeds    30s    2s    Verify Cell on air
    Run Keyword If    '${passed}' == 'False'    Setup LTEemu environment
    Wait Until Keyword Succeeds    60s    5s    Verify Cell on air

Do commission on classical
    [Documentation]
    ...
    ...    **Examples:**
    ...
    wait until keyword succeeds    10 sec    3 sec    Connect to BB1 master    alias=BB1
    ${scf_path}=    commissioning.get_scf_from_oam_vm    scf_remote_dir=${SCF_DIR_PATH}    scf_filename=${tl.scf.filename}    log_path=${LOG_PATH}
    ...    oam_connection=BB1
    ${ip_v6_flag}          Get Variable Value   ${ip_v6_flag}      False
    Set Suite Variable    ${ip_v6_flag}
    run keyword if  '${ip_v6_flag}'=='True'     Change SCF layout to IPv6    scf_path=${scf_path}
    ${scf_params}=    Update_scf_interface_distname    ${scf_path}    ${tl.scf.scf_params}
    commissioning.modify_scf    input_scf=${scf_path}    output_scf=${scf_path}    parameters_lists=${scf_params}
    ${should_gnb_without_ru_mode_be_applied}=    gnb_test_modes.should_gnb_without_ru_mode_be_applied
    Run Keyword If    ${should_gnb_without_ru_mode_be_applied}
    ...    gnb_test_modes.update_gnb_test_mode_to_gnb_without_ru_without_restart
    ...    oam_connection=BB1   scf_path=${scf_path}    log_path=${LOG_PATH}
    run keyword unless    'pid12_classical' in '${tl.scf.filename}'    Remove Elements From Scf    ${scf_path}
    ${dist_name}=    Set Variable    MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    #Add Elements To Scf    ${scf_path}    ${dist_name}
    #the temporary solution to modify the testmode to  GNBWORU
    ${rap_profile}=    frt_scf.get_profile_from_scf_file    ${scf_path}
    ${profile_name}    set variable    ${PROFILE_PATH}/${rap_profile}.json
    BuiltIn.log    ${profile_name}
    Connect to BB1 master    alias=BB1
    Ssh Execute With Timeout    sed -i '/"testState":/{N; s/state": ""/state": "GNBWORU"/;}' ${profile_name}    connection=BB1
    ${output}    Ssh Execute With Timeout    cat ${profile_name} | grep GNBWORU    connection=BB1
    should contain    ${output}    "state": "GNBWORU"
    #set totalDelayFromSHM
    cscf.load_scf    ${scf_path}
    ${syncInputType} =  cscf.get_value_from_scf    dist_name=${dist_name}    p_name=syncInputType
    Run Keyword If    '${syncInputType}'=='1pps/ToD from Sync Hub Master'    cscf.add_element_to_scf    ${dist_name}    totalDelayFromSHM    5
    cscf.save_scf    ${scf_path}
    Run    sed -i \'s/<p name=\"systemAcctPermEnable\">true<\\/p>/<p name=\"systemAcctPermEnable\">false<\\/p>/g\' ${scf_path}
    commissioning.wait for oam node port    oam_node_ip=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    run keyword if  '${ip_v6_flag}'=='True'     Change SCF layout to IPv6    scf_path=${scf_path}
    commissioning.commission    oam_ip=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    scf_xml=${LOG_PATH}/${tl.scf.filename}

Do commission on cloud
    [Documentation]    This keyword is to do commission on cloud.
    ...
    ...    **Examples:**
    ...
    ...    | Do commission on cloud
    ...
    commissioning.wait for oam node port    oam_node_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    Connect to OAM    alias=OAM
    Create log directories
    Set Suite Variable    \${LOG_PATH}    ${LOG_PATH}
    ${scf_path}=    commissioning.get_scf_from_oam_vm    scf_remote_dir=${tl.scf.dir_path}    scf_filename=${tl.scf.filename}    log_path=${LOG_PATH}
    ...    oam_connection=OAM
    ${ip_v6_count}=    OperatingSystem.Grep File    ${tl.gnbs[0].cloud_deployment.default_cfg_dir}/config_ext_net.env    ip_ver: 6
    ${ip_v6_flag}=    run keyword and return status    should not be empty    ${ip_v6_count}
    Run Keyword If    ${ip_v6_flag}    Change SCF layout to IPv6    scf_path=${scf_path}
    ${scf_params}=    Update_scf_interface_distname    ${scf_path}    ${tl.scf.scf_params}
    commissioning.modify_scf    input_scf=${scf_path}    output_scf=${scf_path}    parameters_lists=${scf_params}
    ${distname}=    frt_scf.check_out_test_states_distname    ${scf_path}
    ${should_gnb_without_ru_mode_be_applied}=    Set Variable    True
    Run Keyword If    ${should_gnb_without_ru_mode_be_applied}    gnb_test_modes.update_gnb_test_mode_to_gnb_without_ru_without_restart
    ...    oam_connection=OAM    scf_path=${scf_path}    log_path=${LOG_PATH}    dist_name=${distname}
    ...    profile_name=rapProfile
    Run    sed -i \'s/<p name=\"systemAcctPermEnable\">true<\\/p>/<p name=\"systemAcctPermEnable\">false<\\/p>/g\' ${scf_path}
    Remove Elements From Scf    ${scf_path}
    ${dist_name}=    Set Variable    MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1
    cscf.load_scf    ${scf_path}
    ${syncInputType} =    cscf.get_value_from_scf    dist_name=${dist_name}    p_name=syncInputType
    Run Keyword If    '${syncInputType}'=='1pps/ToD from Sync Hub Master'    cscf.add_element_to_scf    ${dist_name}    totalDelayFromSHM    5
    cscf.save_scf    ${scf_path}
    Add Elements To Scf    ${scf_path}    ${dist_name}
    Run Keyword If    ${ip_v6_flag}    Change SCF layout to IPv6    scf_path=${scf_path}
    commissioning.commission    oam_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}    scf_xml=${scf_path}

Execute Delta Commissioning
    [Arguments]    ${delta_scf}
    [Documentation]    Execute delta commissioning for the parameters in the delta SCF file
    ...    :Author:  Georg Klein-Hessling
    ...    :Contact: Georg.Klein-Hessling@nokia.com
    ...
    ...    :param delta_scf: string， path and name of the delta SCF file
    ...
    ...    **Examples:**
    ...
    ...    | Execute Delta Commissioning    delta_scf=${CURDIR}/delta_scf_1.xml
    ...
    BuiltIn.LogToConsole    \nExecute Delta Commissioning
    Wait Until Keyword Succeeds    ${SSH_AUTHENTICATION_TIMEOUT}    ${SSH_AUTHENTICATION_RETRY_INTERVAL}
    ...    megazone_client.create_session    base_url=${tl.gnbs[0].cu.oam_http_connection_details.addr}    alias=OAM-local-session
    megazone_client.get_current_scf_file    ${resultBaseDir}    SCFC_orig.xml    session=OAM-local-session
    ${out}=  megazone_client.validate_scf  ${delta_scf}  10  OAM-local-session
    ${result}=  megazone_client.perform_commissioning  ${delta_scf}  session=OAM-local-session
    Run Keyword And Ignore Error    megazone_client.teardown_session    session=OAM-local-session
    [Return]  ${result}

Ssh Execute With Timeout
    [Arguments]    ${command}    ${connection}    ${timeout}=10
    [Documentation]    This KW to do ssh Execute With Timeout.
    ...
    ...    :param command: string, ssh commond
    ...    :param alias: string, ${connection}
    ...    :param timeout: string ,timeout of execute ssh commond
    ...    :return: output
    ...
    ...    **Examples:**
    ...
    ...    | ${output}    Ssh Execute With Timeout    grep "Startup " /startup_RACOAM.log    OAM
    ...
    csn.Send Command    ${command}    timeout=${timeout}    connection=${connection}
    ${output}=    csn.Read Output    connection=${connection}
    [Return]    ${output}

Setup LTEemu environment
    [Documentation]    This keyword is to Setup LTEemu environment.
    ...
    ...    **Examples:**
    ...
    ...    | Setup LTEemu environment
    ...
    wait until keyword succeeds    ${SSH_AUTHENTICATION_TIMEOUT}    ${SSH_AUTHENTICATION_RETRY_INTERVAL}    csn.connect_to
    ...    hostname=${tl.core.default_ssh_connection_details.addr}    username=${tl.core.default_ssh_connection_details.username}
    ...    password=${tl.core.default_ssh_connection_details.password}
    ...    alias=edaemon_lteemu
    Update LTEemu Config
    lteemu.Configure Lteemu Edaemon    edaemon_lteemu    ${tl.core.dir_path}    ${tl.core.edaemon_port}
    lteemu.Configure Lteemu Egate    edaemon_lteemu    ${tl.core.dir_path}    ${tl.core.egate_port}
    lteemu.Start Lteemu    ${tl.core.default_ssh_connection_details.addr}    ${tl.core.egate_port}
    lteemu.Reset Lteemu Cfg
    Sleep    10s
    lteemu.Configure    ${tl.core.dir_path}/${tl.core.cfg_filename}
    Sleep    20s
    Wait Until Keyword Succeeds    1 min    10 sec
    ...    lteemu.Read Lteemu Output Until    expected=CHANGE STATE: ACTIVE - SimMode is ready now    timeout=10
    lteemu.Enb X2 Link Up
    lteemu.Read Lteemu Output Until Re    expected=ENB-1: X2AP Link with [EG]NB-2 .*(\\n)?? (\\n)??i(\\n)??s(\\n)?? (\\n)??u(\\n)??p    timeout=10

Setup LTEemu environment with Start of L3
    [Documentation]    Start edaemon, egate, and L3. Execute specified configuration file in egate console.
    ...    :Author:  Georg Klein-Hessling
    ...    :Contact: Georg.Klein-Hessling@nokia.com
    ...
    ...    **Examples:**
    ...
    BuiltIn.LogToConsole    \nSetup LTEemu environment
    connections.Connect to OAM
    wait until keyword succeeds    ${SSH_AUTHENTICATION_TIMEOUT}    ${SSH_AUTHENTICATION_RETRY_INTERVAL}    ssh.connect_to
    ...    hostname=${tl.core.default_ssh_connection_details.addr}    username=${tl.core.default_ssh_connection_details.username}
    ...    password=${tl.core.default_ssh_connection_details.password}    alias=edaemon_lteemu
    ssh.execute    sudo fuser -k 2152/udp    edaemon_lteemu
    lteemu.configure_lteemu_edaemon    edaemon_lteemu    ${tl.core.dir_path}    ${tl.core.edaemon_port}
    sleep    2s
    lteemu.configure_lteemu_egate    edaemon_lteemu    ${tl.core.dir_path}    ${tl.core.egate_port}
    sleep    2s
    lteemu.start_lteemu    ${tl.core.default_ssh_connection_details.addr}    ${tl.core.egate_port}
    sleep    5s
    Start L3 binary in Airphone UECP
    sleep    5s
    BuiltIn.LogToConsole    \tReset WTS and read test specific configuration file
    lteemu.reset_lteemu_cfg
    sleep    2s
    lteemu.configure    ${tl.core.dir_path}/${tl.core.cfg_filename}
    sleep    5s
    Wait Until Keyword Succeeds    1 min    10 sec
    ...    lteemu.read_lteemu_output_until    expected=CHANGE STATE: ACTIVE - SimMode is ready now    timeout=10

Update LTEemu Config
    [Documentation]    This keyword is to update LTEemu Config.
    ...
    ...    **Examples:**
    ...
    ...    | Update LTEemu Config
    ...
    ${lua_in_config}=    Run Keyword and Return Status    File Should Exist    ${tl.gnbs[0].cloud_deployment.default_cfg_dir}/${tl.core.cfg_filename}
    Return from Keyword IF    ${lua_in_config}==False
    Log to Console    \nCopy ${tl.core.cfg_filename} to EPCSim
    csn.Download File    ${tl.gnbs[0].cloud_deployment.default_cfg_dir}/${tl.core.cfg_filename}    ${tl.core.dir_path}/${tl.core.cfg_filename}
    ...    connection=edaemon_lteemu

Verify Cell on air
    [Documentation]    This keyword is to verify Cell on air.
    ...
    ...    **Examples:**
    ...
    ...    | Verify Cell on air
    ...
    ...     Works on classical and cloud with MZ OAM
    ...
    connections.Connect to OAM
    ${output}    Ssh Execute With Timeout    grep "Startup " ${RACOAM_LOGDIR}/startup_RACOAM.log    OAM
    Should Contain    ${output}    Startup completed, BTS on air

NodeId_and_MasterNodeId_configuration_by_RACOAM_in_progress_for_abil
    [Arguments]    ${fsp}
    [Documentation]    This KW to make sure NodeId_and_MasterNodeId_configuration_by_RACOAM_in_progress_for_abil.
    ...
    ...    :param fsp: string, fsp value
    ...
    ...    **Examples:**
    ...
    ...    | NodeId_and_MasterNodeId_configuration_by_RACOAM_in_progress_for_abil    fsp=${fsp}
    ...
    oam_masternid_check.Check MasterNID is set in every FSP for abil    fsp=${fsp}

Check DU status should be right
    [Arguments]    ${wait_time}
    [Documentation]    This KW to check DU status should be right on cloud/classical.
    ...
    ...    :param wait_time: string, the time wait DU to right status
    ...
    ...    **Examples:**
    ...
    ...    | Check DU status should be right    10min
    ...
    Wait Until Keyword Succeeds    ${wait_time}    10 sec    reconnect and check board
    ${fsp}=    megazone_client.get_broadband_fsp
    NodeId_and_MasterNodeId_configuration_by_RACOAM_in_progress_for_abil    fsp=${fsp}

reconnect and check board
    [Documentation]     This KW to reconnect and check board
    ...
    ...    **Examples:**
    ...
    Connect to OAM via Https
    bb1.Common_Board_and_Capacity_Board_detection_in_RACOAM    ASIK    ${Baseband}

Check all VM statuses should be right
    [Documentation]    This KW to check all VM statuses should be right.
    ...
    ...    **Examples:**
    ...
    ...    | Check all VM statuses should be right
    ...
    ${get_all_vm}    megazone_client.get_vm_host_names
    : FOR    ${vm}    IN    @{get_all_vm}
    \    BuiltIn.Log    \nChecking for ${vm}    console=yes
    \    ${vm_status}    megazone_client.get_vm_availability_status    ${vm}
    \    ${status}    ${value}    Run Keyword And Ignore Error    Should Contain    online    ${vm_status}
    \    Run Keyword If    '${status}'=='PASS'    BuiltIn.LogToConsole    -------${vm} availabilityStatus is online------
        ...    ELSE    FAIL    msg=\n-------${vm} availabilityStatus is not online------\n
    \    ${vm_procedural_status}    get_vm_procedural_status    ${vm}
    \    ${status}    ${value}    Run Keyword And Ignore Error    Should Contain    configured    ${vm_procedural_status}
    \    Run Keyword If    '${status}'=='PASS'    BuiltIn.LogToConsole    -------${vm} proceduralStatus is configured------
        ...    ELSE    FAIL    msg=\n-------${vm} proceduralStatus is not configured------\n
    \    ${vm_cloud_device_status}    megazone_client.get_vm_cloud_device_status    ${vm}
    \    ${status}    ${value}    Run Keyword And Ignore Error    Should Contain    configured    ${vm_cloud_device_status}
    \    Run Keyword If    '${status}'=='PASS'    BuiltIn.LogToConsole    -------${vm} cloudDeviceStatus is configured------
        ...    ELSE    FAIL    msg=\n-------${vm} cloudDeviceStatus is not configured------\n

Change SCF layout to IPv6
    [Arguments]     ${scf_path}
    [Documentation]    This KW to Change SCF layout to IPv6.
    ...
    ...    **Examples:**
    ...
    Run    sed -i "s/IPADDRESSV4/IPADDRESSV6/" ${scf_path}
    Run    sed -i "s/ipV4AddressDN1/ipV6AddressDN1/" ${scf_path}

Modify scf for Pm counter activation
    [Documentation]    This keyword is to modify scf file for pm counter activate from the below guide.
    ...    https://confluence.int.net.nokia.com/display/CV/How+to+activate+PM+mechanism
    ...
    ...    :Author:  yonggang.miao@nsn-sbell.com
    ...
    ...    **Examples:**
    ...
    ...    | Modify scf for Pm counter activation
    ...
    ${scf_path}=  OperatingSystem.run     mktemp -d
    ${scf_file}     set variable    ${scf_path}/scf.xml
    ${session}    login_web    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
    set suite variable    ${session}
    get_scf_content    ${tl.gnbs[0].cu.oam_http_connection_details.addr}    ${session}    ${scf_file}
    scf.load_scf    ${scf_file}
    ${class_name}    Run      awk -F '[":]' '/\"MRBTS-1900\\/MNL-1\"/{print $2}' ${scf_file}
    ${version}    Run      awk -F '"' '/\"MRBTS-1900\\/MNL-1\"/{print $8}' ${scf_file}
    comment    add MNLENT
    ${flag}    scf.is_object_in_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2
    run keyword if    not ${flag}    scf.add_object_to_scf    class_name=${class_name}:MNLENT
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-2    version=${version}
    Run Keyword And Ignore Error    scf.remove_element_from_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2
    ...        p_name=targetDNType
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2    p_name=targetDNType
    ...    value=VM
    comment    add SYNC
    ${flag}    scf.is_object_in_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1
    run keyword if    not ${flag}    scf.add_object_to_scf    class_name=${class_name}:SYNC
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1    version=${version}
    Run Keyword And Ignore Error    scf.remove_element_from_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1    p_name=btsSyncMode
    Run Keyword And Ignore Error    scf.remove_element_from_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1    p_name=profileType
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1    p_name=btsSyncMode
    ...    value=PhaseSync
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1    p_name=profileType
    ...    value=RAC
    comment    add TIME
    ${flag}    scf.is_object_in_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/TIME-1
    run keyword if    not ${flag}    scf.add_object_to_scf    class_name=${class_name}:TIME
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/TIME-1    version=${version}
    Run Keyword And Ignore Error    scf.remove_element_from_scf     dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/TIME-1
    ...    p_name=timeZone
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/TIME-1    p_name=timeZone
    ...    value=(GMT-8) Etc/GMT+8
    comment    add CLOCK
    ${flag}    scf.is_object_in_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2
    run keyword if    not ${flag}    scf.add_object_to_scf    class_name=${class_name}:CLOCK
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2    version=${version}
    Run Keyword And Ignore Error    scf.remove_element_from_scf   dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2
    ...    p_name=outputConfiguration1Pps
    Run Keyword And Ignore Error    scf.remove_element_from_scf   dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2
    ...    p_name=outputConfiguration2M048
    Run Keyword And Ignore Error    scf.remove_element_from_scf   dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2
    ...    p_name=totalDelayFromSHM
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2    p_name=outputConfiguration1Pps
    ...    value=EnabledWithoutBtsInputReference
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2    p_name=outputConfiguration2M048
    ...    value=EnabledWithoutBtsInputReference
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2    p_name=totalDelayFromSHM
    ...    value=25
    scf.modify_scf_element    value=15min    dist_name=MRBTS-1900/MNL-1/PMCADM-1    p_name=reportingIntervalPm
    comment    add NTP
    &{dict} =    Create Dictionary    ntpServerIpAddr=10.171.8.4
    ${flag}    scf.is_object_in_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2/NTP-1
    run keyword if    not ${flag}    scf.add_object_to_scf    class_name=${class_name}:NTP
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2/NTP-1    version=${version}
    Run Keyword And Ignore Error    scf.remove_list_from_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2/NTP-1
    ...    list_name=ntpServerList
    scf.add_list_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2/NTP-1    list_name=ntpServerList
    Run Keyword And Ignore Error    scf.remove_element_from_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2/NTP-1
    ...    list_name=ntpServerList    p_name=ntpServerIpAddr
    scf.add_item_to_list    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-2/NTP-1
    ...    list_name=ntpServerList    elements=&{dict}
    comment    add SECADM
    ${flag}    scf.is_object_in_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1
    run keyword if    not ${flag}    scf.add_object_to_scf    class_name=${class_name}:SECADM
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1    version=${version}
    Run Keyword And Ignore Error    scf.remove_element_from_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1
    ...    p_name=actServiceAccountSsh
    Run Keyword And Ignore Error    scf.remove_element_from_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1
    ...    p_name=actServicePortState
    Run Keyword And Ignore Error    scf.remove_element_from_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1
    ...    p_name=ethernetPortSecurityEnabled
    Run Keyword And Ignore Error    scf.remove_element_from_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1
    ...    p_name=sshClientAliveTimer
    Run Keyword And Ignore Error    scf.remove_element_from_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1
    ...    p_name=sshSessionLoginDelayTimer
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1    p_name=actServiceAccountSsh
    ...    value=false
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1    p_name=actServicePortState
    ...    value=false
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1    p_name=ethernetPortSecurityEnabled
    ...    value=true
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1    p_name=sshClientAliveTimer
    ...    value=45
    scf.add_element_to_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/SECADM-1    p_name=sshSessionLoginDelayTimer
    ...    value=10
    comment    add FMCADM
    ${flag}    scf.is_object_in_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/FMCADM-1
    run keyword if    not ${flag}    scf.add_object_to_scf    class_name=${class_name}:FMCADM
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-2/FMCADM-1    version=${version}
    comment    add CERTHENT
    ${flag}    scf.is_object_in_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/CERTHENT-1
    run keyword if    not ${flag}    scf.add_object_to_scf    class_name=${class_name}:CERTHENT
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-2/CERTHENT-1    version=${version}
    comment    add CRLHS
    ${flag}    scf.is_object_in_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/CERTHENT-1/CRLHS-1
    run keyword if    not ${flag}    scf.add_object_to_scf    class_name=${class_name}:CERTHENT
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-2/CERTHENT-1/CRLHS-1    version=${version}
    comment    add CMPS
    ${flag}    scf.is_object_in_scf    dist_name=MRBTS-1900/MNL-1/MNLENT-2/CERTHENT-1/CMPS-1
    run keyword if    not ${flag}    scf.add_object_to_scf    class_name=${class_name}:CERTHENT
    ...    dist_name=MRBTS-1900/MNL-1/MNLENT-2/CERTHENT-1/CMPS-1    version=${version}
    scf.save_scf    ${scf_file}
    Run     cat ${scf_file}
    commissioning.commission    oam_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}    scf_xml=${scf_file}
    comment    add WA
    Connect to OAM via Https
    megazone_client.reset_site
    sleep    5
    wait until keyword succeeds  2 min  30 sec    Connect to OAM
    Check DU status should be right    20min
	disconnect_all_connections
    wait until keyword succeeds    2min    30sec    Connect to OAM
    csn.execute    cat /opt/nokia/SS_MzOam/cloud-racoam/racoam/config/default.json | grep "skipSyncChecking"    OAM
    ${wa_path}    Set Variable    /opt/nokia/SS_MzOam/cloud-racoam/racoam/config/default.json
    csn.execute    sudo sed -i 's/"skipSyncChecking": false/"skipSyncChecking": true/' ${wa_path}    OAM
    csn.execute    cat /opt/nokia/SS_MzOam/cloud-racoam/racoam/config/default.json | grep "skipSyncChecking"    OAM
    [Teardown]     Run Keywords   wait until keyword succeeds  2 min  30 sec
    ...     logout_web    ${tl.gnbs[0].cu.oam_http_connection_details.addr}    ${session}
    ...     AND    Remove Directory    ${scf_path}    recursive=True
    ...     AND    megazone_client.teardown_session

Connect to Airphone OAM
    [Documentation]    This keyword will create new OAM_AIRPHONE connection, you can use the connection by name OAM_AIRPHONE.
    ...
    ...    **Examples:**
    ...
    ...    | Connect to Airphone OAM
    ...
    csn.Connect to    hostname=${tl.ues[0].l1.common_units[0].lmp_connection.addr}
    ...    username=${tl.ues[0].l1.common_units[0].lmp_connection.username}
    ...    password=${tl.ues[0].l1.common_units[0].lmp_connection.password}
    ...    alias=OAM_AIRPHONE

Connect to Airphone UEUP
    [Documentation]    This keyword will create new UEUP_AIRPHONE connection, you can use the connection by name UEUP_AIRPHONE.
    ...
    ...    **Examples:**
    ...
    ...    | Connect to Airphone UEUP
    ...
    Connect to Airphone OAM
    csn.Connect to    hostname=ueup-0.local   username=${tl.ues[0].airphone_cloud.oam_ssh_connection_details.username}
    ...    password=${tl.ues[0].airphone_cloud.oam_ssh_connection_details.password}
    ...    alias=UEUP_AIRPHONE     proxy=OAM_AIRPHONE

Connect to Airphone DU
    [Documentation]    This keyword will create new DU_AIRPHONE connection, you can use the connection by name DU_AIRPHONE.
    ...
    ...    **Examples:**
    ...
    ...    | Connect to Airphone DU
    ...
    csn.Connect to    hostname=${tl.ues[0].l1.common_units[0].lmp_connection.addr}  username=${tl.ues[0].l1.common_units[0].lmp_connection.username}
    ...    password=${tl.ues[0].l1.common_units[0].lmp_connection.password}
    ...    alias=DU_AIRPHONE

Connect to Airphone UECP
    [Documentation]    This keyword will create new UECP AIRPHONE connection, you can use the connection by name UECP_AIRPHONE.
    ...
    ...    **Examples:**
    ...
    ...    | Connect to Airphone UECP
    ...
    Connect to Airphone OAM
    csn.Connect to    hostname=uecp-0.local   username=${tl.ues[0].airphone_cloud.oam_ssh_connection_details.username}
    ...    password=${tl.ues[0].airphone_cloud.oam_ssh_connection_details.password}
    ...    alias=UECP_AIRPHONE     proxy=OAM_AIRPHONE

Connect to Airphone DU ASIK Slave
    [Documentation]    This keyword will create new DU_AIRPHONE slaveconnection, you can use the connection by name ASIK_SLAVE_AIRPHONE.
    ...    make sure DU_AIRPHONE connection is created.
    ...
    ...    **Examples:**
    ...
    ...    | Connect to Airphone DU ASIK Slave
    ...
    csn.Connect to    hostname=192.168.253.81   username=${BB1_LOGIN}     password=${BB1_PASSWORD}    proxy=DU_AIRPHONE
    ...    alias=ASIK_SLAVE_AIRPHONE

Connect to Airphone DU phoner
    [Documentation]    This keyword will create new DU_AIRPHONE slaveconnection, you can use the connection by name ASIK_SLAVE_AIRPHONE.
    ...    make sure DU_AIRPHONE connection is created.
    ...
    ...    **Examples:**
    ...
    ...    | Connect to Airphone DU phoner
    ...
    csn.Connect to    hostname=192.168.253.86   username=${BB1_LOGIN}     password=${BB1_PASSWORD}    proxy=DU_AIRPHONE
    ...    alias=DU_phoner

check slot type for RATIO1_4
    [Documentation]
    ...   The purpose of case is to check slot type for RATIO1_4
    ...
    ...    :Author:  Miao yonggang
    ...    :Contact: yonggang.miao@nokia-sbell.com
    ...
    ...    :param filepath: string, the file path
    ...    :param connection: string, the connection of session
    ...
    ...    **Examples:**
    ...
    ...    | check slot type for RATIO1_4    startup_DEFAULT.log    connection=slave
    ...
    [Arguments]      ${filepath}    ${connection}
    ${line}    csn.execute    awk '/Msg2ToMsg3OffsetCalculator: ulDlDataSlotRatio\=RATIO1_4/{print NR;exit}' ${filepath}    connection=${connection}
    ${content}    csn.execute    sed -n '${line.strip()},+40p' ${filepath}    connection=${connection}
    Should be true    ${line.strip()}!=''
    ${line_num}    set variable    ${line.strip()}
    FOR    ${sub}    IN     @{slottype_list}
         ${line_num}    Evaluate    ${line_num}+1
         ${content}    csn.execute    sed -n '${line_num}p' ${filepath}    connection=${connection}
         Should contain    ${content.replace(" ","")}    ${sub.replace(" ","")}

    END
Connect to gNB DU
    [Documentation]
    ...   Connect to gNB DU
    ...
    ...    **Examples:**
    ...
    csn.connect_to      hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                 password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    alias=DU_conn

Connect to gNB DU loner
    [Documentation]
    ...   Connect to gNB DU loner
    ...
    ...    **Examples:**
    ...
    csn.Connect to    hostname=192.168.253.22   username=${BB1_LOGIN}     password=${BB1_PASSWORD}    proxy=DU_conn
    ...    alias=DU_loner

Connect to CPNRT
    [Arguments]     ${hostname}=cpnrt-0.local
    ...             ${cpif_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...             ${cpif_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...             ${alias}=CPNRT    ${proxy}=OAM
    [Documentation]
    ...   Connect to CPNRT
    ...
    ...    **Examples:**
    ...
    connections.Connect via root if passed username fails    hostname=${hostname}    username=${cpif_username}    password=${cpif_password}
    ...     alias=${alias}    proxy=${proxy}

Reboot ASIK and reconnect
    [Documentation]
    ...   Reboot ASIK and reconnect
    ...
    ...    **Examples:**
    ...
    Connect to BB1 master    alias=BB1
    Ssh Execute With Timeout    reboot    connection=BB1
    Run Keyword And Ignore Error    csn.Disconnect    connection=BB1
    wait until keyword succeeds    10 min    10 sec    Connect to BB1 master    alias=BB1

Get gNB UPUE backhaul IP
    [Documentation]    Connect to GNB UPUE and get Backhaul IP address
    ...
    ...    :Author:  Georg Klein-Hessling
    ...    :Contact: Georg.Klein-Hessling@nokia.com
    ...
    ...    **Examples:**
    ...
    Connect to UPUE
    ${output}    ssh.execute    sudo ip addr show backhaul | grep -Po 'inet \\K[\\d.]+'
    ...    connection=UPUE
    ${output}=    Strip String    ${output}
    should not be empty  ${output}
    [Return]   ${output}

Adapt IP Addresses in CFG File
    [Arguments]    ${cfg_file}
    [Documentation]    Get WTS IP from AP UECP and AP UEUP and adapt them in the WTS configuration file
    ...
    ...    :Author:  Georg Klein-Hessling
    ...    :Contact: Georg.Klein-Hessling@nokia.com
    ...
    ...     :param cfg_file: string , path and name of the WTS configuration file
    ...
    ...    **Examples:**
    ...
    ...    | Adapt IP Addresses in CFG File    cfg_file=${CURDIR}/776A-TC03.cfg
    ...
    Connect to WTS
    @{filename}    Split String    ${cfg_file}    /
    ${cfg_temp}    set variable    ${tl.core.dir_path}/${filename[-1]}
    SSH.Send Command   command= cp ${cfg_file} ${cfg_temp}
    ...    connection=edaemon_lteemu
    ${ipAddress}=    Get Airphone UECP wts IP
    SSH.Send Command   command= sudo sed -i 's/set UECP_ADDR=.*/set UECP_ADDR="${ipAddress}"/g' ${cfg_temp}
    ...    connection=edaemon_lteemu
    ${ipAddress}=    Get Airphone UEUP wts IP
    SSH.Send Command   command= sudo sed -i 's/set UEUP_ADDR=.*/set UEUP_ADDR="${ipAddress}"/g' ${cfg_temp}
    ...    connection=edaemon_lteemu
    connections.Connect to OAM
    ${ipAddress}=    Get gNB UPUE backhaul IP
    SSH.Send Command   command= sudo sed -i 's/set ENB2_S1_ADDR=.*/set ENB2_S1_ADDR="${ipAddress}"/g' ${cfg_temp}
    ...    connection=edaemon_lteemu

Get Average Data Rate
    [Arguments]    ${QCI_id}
    [Documentation]    return average data rate in output of bearer_stats in egate console
    ...
    ...    :Author:  Hua Li
    ...    :Contact: Hua.li@nokia.com
    ...
    ...    | param string QCI_id: Bearer QCI info to be printed to the console log
    ...    | return: status    data_rate
    ...
    ...    **Examples:**
    ...
    ...    | ${data_rate}    ${status}    Run Keyword And Ignore Error    Check Average Data Rate
    ...    |                              QCI_id=id=9
    ...
    ${status}    ${output}    Run Keyword And Ignore Error    lteemu.read_lteemu_output_until    expected=Average packet interval    timeout=10
    Run Keyword If    '${status}'=='FAIL'    Fail
    ...    \tno entry for Average data rate found
    Return From Keyword If    '${status}'=='FAIL'
    ${output}=    Get Lines Containing String    ${output}    Average data rate
    ${output}=    Replace String    ${output}    Average data rate    ${EMPTY}
    @{words}=    Split String    ${output}    (
    ${data_rate}=    Strip String    ${words[0]}
    BuiltIn.LogToConsole    \tAverage data rate for Bearer QCI${QCI_id} is ${data_rate}
    [Return]    ${data_rate}

Start tcpdump on gNB CPIF
    [Documentation]    Start tcpdump on GNB CPIF
    ...
    ...    :Author:  Georg Klein-Hessling
    ...    :Contact: Georg.Klein-Hessling@nokia.com
    ...
    ...    **Examples:**
    ...
    connections.Connect to OAM
    connections.Connect to CPIF
    ssh.execute    sudo rm -rf /tmp/CPIF.pcap    CPIF
    ssh.execute   sudo bash -mc "touch /tmp/CPIF.pcap ; tcpdump -i any sctp -w '/tmp/CPIF.pcap' < /dev/null > /dev/null 2>&1 & echo \\\\$!"
    ...       CPIF
    sleep  5s
    ${output}   ssh.execute    sudo ps -ef |grep tcpdump | grep -v grep    CPIF
    should not be empty  ${output}

Stop tcpdump on gNB CPIF
    [Documentation]    Stop tcpdump on GNB CPIF
    ...
    ...    :Author:  Georg Klein-Hessling
    ...    :Contact: Georg.Klein-Hessling@nokia.com
    ...
    ...    **Examples:**
    ...
    connections.Connect to OAM
    connections.Connect to CPIF
    ssh.execute    sudo kill `ps -ef | grep tcpdump | grep -v grep | awk '{print $2}'`; popd    CPIF
    sleep  5s
    ${output}   ssh.execute    sudo ps -ef | grep tcpdump | grep -v grep    CPIF
    should be empty  ${output}
    ssh.download_file    remote_path=/tmp/CPIF.pcap
    ...    local_path=${resultBaseDir}/tcpdump_gNB_cpif.pcap    connection=CPIF

Verify SgnbAddition by tcpdump on CPIF
    [Documentation]    Check that the CPIF capture file includes the specified message sequence
    ...                and no following release message (32)
    ...
    ...    :Author:  Georg Klein-Hessling
    ...    :Contact: Georg.Klein-Hessling@nokia.com
    ...
    ...    **Examples:**
    ...
    wireshark_parsing.Read Capture File    ${resultBaseDir}/tcpdump_gNB_cpif.pcap
    wireshark_parsing.Check Expression from file    ${CURDIR}/../config/l1ByPass_Cloud/sgNBaddition_filter.txt
    # check that there is no unexpected release message
    Run Keyword And Expect Error   CheckExpressionFailed: x2ap.procedureCode == 32 check failed
    ...    Check_Expression_in_packet_capture    x2ap.procedureCode == 32

Get DU UTC Time
    [Documentation]
    ...      Get DU UTC Time
    ...
    ...    **Examples:**
    ...
    Connect to BB1 master    alias=BB1
    ${utc_time}    csn.execute    date -u "+%Y-%m-%dT%H:%M:%SZ"    connection=BB1
    [Teardown]   ssh.Disconnect   connection=BB1
    [Return]    ${utc_time.strip()}

Cut Specified Log From DU system time
    [Arguments]    ${log_path}    ${logfile}    ${system_time}
    [Documentation]
    ...      Cut Specified Log From DU system time
    ...
    ...    **Examples:**
    ...
    ${new_logfile}    Set Variable    ${logfile.split('.')[0]}_new.${logfile.split('.')[1]}
    Run    cp ${log_path}/${logfile} ${log_path}/${new_logfile}
    ${line}    Run    sed -n '/${system_time[:-4]}/=' ${log_path}/${new_logfile} | head -1
    Run    sed -i '1,${line}d' ${log_path}/${new_logfile}
    [Return]    ${new_logfile}

Collect DU Runtime Log And Uncompress Wanted Log
    [Arguments]    ${zip_path}    ${xz_path}    ${search_logname}
    [Documentation]    This keyword is to uncompress uuntime log.
    ...
    ...    :param zip_path: string, ${zip_path}
    ...    :param xz_path: string, ${xz_path}
    ...    :param search_logname: string, ${search_logname}
    ...
    ...    **Examples:**
    ...
    ...    | Collect DU Runtime Log And Uncompress Wanted Log    ${zip_path}=/tmp/1011_runtime.zip
    ...    | ${xz_path}=/tmp/runtime_DEFAULT.log.xz    ${search_logname}=/tmp/runtime_DEFAULT.log
    ...
    Connect to DU
    ${output}    ssh.execute    (sleep 5 \n echo "log -h" \n sleep 20 \n echo "quit" ) | telnet 0 15007
    ...    DU
    SSH.Send Command   command= ls ${zip_path}    connection=DU
    ${output}=   ssh.Read Output    connection=DU
    ${output}=    Strip String    ${output}
    should contain    ${output}     ${zip_path}
    ssh.execute    unzip -o -d /tmp/ ${output}    connection=DU
    ssh.execute    xz -f -d /tmp/ ${xz_path}    connection=DU
    SSH.Send Command   command= ls ${search_logname}    connection=DU
    ${output}=   ssh.Read Output    connection=DU
    ${output}=    Strip String    ${output}
    should contain    ${output}     ${search_logname}

Generate Suite Log Path
    [Documentation]    Author: Mao Cathy
    ...                Description: Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    ${time_stamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    builtin.log    ${LOG_PATH}
    ${len}    Get Length    ${LOG_PATH}
    ${LOG_PATH}    Set Variable If    ${len} == 0    /tmp/${time_stamp}    ${LOG_PATH}/${time_stamp}/
    ${status}  ${message} =  Run Keyword And Ignore Error  Variable Should Exist  ${LOG_DIR}
    ${LOG_DIR}    Set Variable If    "${status}"=="FAIL"    ${LOG_PATH}    ${LOG_DIR}
    Set Global Variable    ${LOG_DIR}
    ${suite_log_path}    Join path    ${LOG_DIR}    ${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create Directory    ${SUITE_LOG_PATH}
    Set Suite Variable    ${EPC_LOG_PATH}    ${SUITE_LOG_PATH}

Check The Sctp Port UP
    [Arguments]    ${port_num}
    Connect To ASIK    alias=BB1
    csn.sendCommand    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    csn.read_output    connection=BB1
    csn.disconnect     connection=BB1
    should contain     ${sctp_status}     ${port_num}

Connect To Classic Gnb Smod
    [Arguments]    ${alias}=GNB_Smod
    csn.connect_to      hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                 password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    alias=${alias}

Get hardware deploy data
    #get SMOD
    Connect To Classic Gnb Smod
    ${cmd}    Set Variable
    ...    ddal -s ddal_sysinfo_module_get_unit_id 0 | grep 'value' | cut -d'=' -f2 | awk -F \\' '{print $2}'
    ${board_type}=    ssh.execute     ${cmd}    connection=GNB_Smod
    ${board_type}    Split String    ${board_type}    \r\n
    ${SMOD}    Set Variable    @{board_type}[0]
    Set Suite Variable    ${SMOD}
    #get BBMOD
    ${cmd}    Set Variable
    ...    bsh 1:0 ddal -s ddal_sysinfo_module_get_unit_id 0 | grep 'value' | cut -d'=' -f2 | awk -F \\' '{print $2}'
    ${board_type}=    ssh.execute     ${cmd}    connection=GNB_Smod
    ${board_type}    Split String    ${board_type}    \r\n
    ${BBMOD}    Set Variable    @{board_type}[0]
    Set Suite Variable    ${BBMOD}
    #get board dmid and L2PSNodeId
    ${cmd}    Set Variable
    ...    ddal -s ddal_sysinfo_module_get_domain_id 0 | grep "dmid" | cut -d'=' -f2
    ${board_position}=    ssh.execute      ${cmd}    connection=GNB_Smod
    ${board_position}    Split String    ${board_position}    \r\n
    ${board_position}    Set Variable    @{board_position}[0]
    ${BOARD_POSITION}    Set Variable If    '${board_position}' == '1'    LEFT    RIGHT
    Set Suite Variable    ${BOARD_POSITION}
    #get L1_TYPE
    Telnet.Open Connection    host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}    port=15007
    Telnet.Set Prompt    AaShell>
    Telnet.Write    tag -a
    ${output}    Telnet.Read Until Prompt
    Telnet.Close Connection
    ${result}=    frt_common.get_hw_L1_type    ${output}    L1BypassMap
    ${L1_TYPE}=    Set Variable If    "${result}" == "True"    L1B    FS
    Set Suite Variable    ${L1_TYPE}
    ${HW_TYPE}    Catenate    SEPARATOR=_    ${SMOD}    ${BBMOD}    ${BOARD_POSITION}    ${L1_TYPE}
    Set Suite Variable    ${HW_TYPE}
    [RETURN]    ${HW_TYPE}
