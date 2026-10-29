*** Settings ***
Documentation
...    author: Wu Fangmin
...    contact: fangmin.wu@nokia-sbell.com
...    squad group: MMW_HZ_SG_03


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library     taf.sbts.oam.coam.admin   WITH NAME   coam
Library     taf.transport.ssh    WITH NAME    csn
Library     OperatingSystem
Library     Collections
Library 	DateTime
Library 	String

*** Variables ***
${ADMIN_ALIAS}     GNB_OAM
${Results}		 	/tmp/5GC000371
${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}
${ru_sn}    ${tl.gnbs[0].dus[0].rus[0].serial_number}
${ASIL_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIL_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIL_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${LSS_addr}                     10.57.167.134
${LSS_username}                 coam
${LSS_password}                 zO&n1W*ktp7
*** Keywords ***

PREPOST Get Bts Name
    ${bts_name}=    coam.Get Bts Info    connection=${ADMIN_ALIAS}
    Set Suite Variable    ${OUT_ADMIN_BTS_NAME}    ${bts_name['name']}

ADMIN Perform Delta Recommissioning
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=${False}
    ...            ${should_activate}=${True}
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    coam.Perform Delta Recommissioning
    ...                                        delta_file=${delta_file}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}


Remove Snapshot from LSS server
    Set Suite Variable    ${snapshot_path_LSS}    /home/coam/Snapshot_MRBTS-${mrbtsId}_${OUT_ADMIN_BTS_NAME}*
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=rm -rf ${snapshot_path_LSS}  connection=LSS
    [Teardown]    csn.disconnect    connection=LSS

Check if Snapshot is collected on LSS
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-${mrbtsId}_${OUT_ADMIN_BTS_NAME}
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=ls -l /home/coam/   connection=LSS
    ${snap_exists}    csn.read output    connection=LSS
    Should contain  ${snap_exists}  ${snapshot_LSS}  connection=LSS
    csn.send_command    command=find ${snapshot_LSS}* | wc -l   connection=LSS
    ${snap_list}    csn.read output    connection=LSS
    ${snap_list}    convert to integer  ${snap_list}
    should be true      ${snap_list}>=1
    [Teardown]    csn.disconnect    connection=LSS

Check if BTS_metadata.txt exists
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-${mrbtsId}_${OUT_ADMIN_BTS_NAME}
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=find ${snapshot_LSS}*/*metadata.txt   connection=LSS
    ${snap_list}    csn.read output    connection=LSS
    Set Suite Variable    ${BTS_metadata}    metadata.txt
    should contain  ${snap_list}  ${BTS_metadata}
    [Teardown]    csn.disconnect    connection=LSS

veryfy destination is not pingable
    [Arguments]    ${destination}    ${connection}
    ${output}=         csn.Execute       ping -c 5 -W 5 ${destination}    connection=${connection}
    Should contain      ${output}    5 packets transmitted, 0 received

Clear alarm 6450 before test
    ${status}    run keyword and return status    Fault Should Not Be Present    fault_id=6450
     run keyword if    ${status} == False    General_SiSo_Auto_BTS_site_reset



Fault Should Be Present
    [Documentation]
    [Arguments]    ${fault_id}
    Log To Console    KW - Fault Should Be Present fault_id=${fault_id}
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=GNB_OAM
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain     ${list}    ${fault_id}

Alarm Should Be Present
    [Documentation]
    [Arguments]    ${alarm_id}
    Log To Console    KW - Alarm Should Be Present alarm_id=${alarm_id}
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=GNB_OAM
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain   ${list}    ${alarm_id}

Fault Should Not Be Present
    [Documentation]
    [Arguments]    ${fault_id}
    Log To Console    KW - Fault Should Not Be Present fault_id=${fault_id}
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=GNB_OAM
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Not Contain     ${list}    ${fault_id}

Alarm Should Not Be Present
    [Documentation]
    [Arguments]    ${alarm_id}
    Log To Console    KW - Alarm Should Not Be Present alarm_id=${alarm_id}
    ${active_alarms}    coam.get_active_alarms    timeout=60    connection=GNB_OAM
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Not Contain   ${list}    ${alarm_id}

Wait For Fault with Alarm to appear
    [Arguments]  ${FaultID}     ${AlarmID}
    Log to console    Wait For Fault with Alarm to appear
    wait until keyword succeeds  1080      20    Fault Should Be Present   ${FaultID}
    wait until keyword succeeds  20       5     Alarm Should Be Present   ${AlarmID}

Wait For Fault with Alarm to disappear
    [Arguments]  ${FaultID}     ${AlarmID}
    Log to console    Wait For Fault with Alarm to appear
    wait until keyword succeeds  920s      60s    Fault Should Not Be Present   ${FaultID}
    wait until keyword succeeds  20       5     Alarm Should Not Be Present   ${AlarmID}

Connect to RU and generate Fault 4527
    Log to console    Connect to RU and generate Fault 4527
	Wait For Fault with Alarm to disappear    FaultID=4527   AlarmID=7115
	csn.Connect to     hostname=${ASIL_IP}    username=${ASIL_USERNAME}    password=${ASIL_PASSWORD}	alias=ASIL Master
    ${ru_ip_addr}   Coam Get RU IP via RMOD object  ru_serial_number=${ru_sn}
    set test variable    ${RU_IP}    ${ru_ip_addr}
    Connect To RU Via FHNET Container    ru_ip_addr=${ru_ip_addr}    ru_alias=RU_${ru_sn}    asik_alias=ASIL Master
	${ps_cmd_RU}=    csn.execute     command=ps | grep CCSDaemonExe | awk \'{print $1}\' | xargs -n1		connection=RU_${ru_sn}
	${ps_Killcmd_RU}=    csn.execute    command=ps | grep CCSDaemonExe | awk \'{print $1}\' | xargs kill -9 $1    connection=RU_${ru_sn}
	Verify Ru is disconnectd
	Wait For Fault with Alarm to appear    FaultID=4527   AlarmID=7115

Trigger Fault 10 by radio reboot
    Log to console    Trigger Fault 10 by radio reboot
	csn.Connect to     hostname=${ASIL_IP}    username=${ASIL_USERNAME}    password=${ASIL_PASSWORD}	alias=ASIL Master
    ${ru_ip_addr}   Coam Get RU IP via RMOD object  ru_serial_number=${ru_sn}
    set test variable    ${RU_IP}    ${ru_ip_addr}
    Connect To RU Via FHNET Container    ru_ip_addr=${ru_ip_addr}    ru_alias=RU_${ru_sn}    asik_alias=ASIL Master
	${ps_cmd_RU}=    csn.send_command     command=reboot    connection=RU_${ru_sn}
	Verify Ru is disconnectd

Verify Ru is disconnectd
    Log to console     Verify Ru is disconnectd
    csn.Connect to     hostname=${ASIL_IP}    username=${ASIL_USERNAME}    password=${ASIL_PASSWORD}	alias=ASIL
    csn.send command     command=lxc-attach -n 0x1018   connection=ASIL
    wait until keyword succeeds    120s    10s   veryfy destination is not pingable     destination=${RU_IP}     connection=ASIL
    [Teardown]    csn.Disconnect    connection=ASIL

Get time from site
    [Documentation]    Description: Get the real time from site,return as '2020-08-15T05'
    [Arguments]    ${alias}=ASIL
    csn.send command    command=date +"%Y-%m-%dT%H"    connection=${alias}
    ${date_time}     csn.read output    connection=${alias}
    ${date_time}     Strip String   ${date_time}
    [Return]    ${date_time}

Connect to and restart ABIO
    Log to console    Connect to and restart ABIO
    csn.Connect to     hostname=${ASIL_IP}    username=${ASIL_USERNAME}    password=${ASIL_PASSWORD}	alias=ASIL Master
    ${hoststr}    ssh.Execute    arp -a| grep 'fsp-...a.*etha01'    connection=ASIL Master
    ${hostnames}    Get Hosts From String    connection=${hoststr}
    ssh.Connect to    hostname=${hostnames}[0]
    ...               username=${ASIL_USERNAME}
    ...               password=${ASIL_PASSWORD}
    ...               proxy=ASIL Master    alias=ABIO
    csn.execute   command=ps -edf | grep CCSDaemonExe | awk \'{print $2}\' | xargs kill -11 $1    connection=ABIO
    Verify ABIO is disconnected
    sleep    10min
    [Teardown]    csn.Disconnect    connection=ASIL Master

Verify ABIO is disconnected
    csn.Connect to     hostname=${ASIL_IP}    username=${ASIL_USERNAME}    password=${ASIL_PASSWORD}	alias=ASIL
    wait until keyword succeeds    240s    10s      veryfy destination is not pingable     destination=fsp-1-1a    connection=ASIL
    [Teardown]    csn.Disconnect    connection=ASIL

Connect to and restart ASIL
    Log to console    Connect to and restart ASIL
    csn.Connect to     hostname=${ASIL_IP}    username=${ASIL_USERNAME}    password=${ASIL_PASSWORD}	alias=ASIL Master
    ${reset_time}    Get time from site    alias=ASIL Master
    set suite variable    ${reset_time}
    csn.execute   command=ps -edf | grep CCSDaemonExe | awk \'{print $2}\' | xargs kill -11 $1    connection=ASIL Master
    Wait until keyword succeeds    5 min    1 sec    Verify ASIL is disconnected
    sleep    100s
    [Teardown]    csn.Disconnect    connection=ASIL Master

Verify ASIL is disconnected
    ${status} =    Run Keyword And Return Status    Ping to destination from local should be success
    ...    destation=${ASIL_IP}
    Should Be Equal    ${status}    ${False}

Ping to destination from local should be success
    [Documentation]     ${destation} can be host name or IP or gateway
    [Arguments]     ${destation}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${rc}=    Run and return rc    ping ${destation} -w 10
    Should be equal as numbers    first=${0}    second=${rc}

Collect snapshot and check ru specific log
    [Arguments]   ${ru_index}=${1}    ${connection}=GNB_OAM
    ${release_version}    Get gnb release in rrm    host=${ASIL_IP}    username=${ASIL_USERNAME}    password=${ASIL_PASSWORD}
    Set Test Variable    ${release_version}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    run keyword if    '${release_version}'=='9999'      Check specific log in the snapshot
    ...    specific_file=BTS_${serial_number}_RMOD_L_1_runtime.zip    key_string=IPCCrash    case_type=ru
    run keyword if    '${release_version}'=='0011'      Check specific log in the snapshot
    ...    specific_file=BTS_${serial_number}_RMOD_L_1_pm_1_syslog.zip    key_string=IPCCrash    case_type=ru

Get gnb release in rrm
    [Arguments]   ${host}   ${username}   ${password}
    csn.Connect To   ${host}   ${username}   ${password}   alias=release_info
    ${info}   csn.Execute    ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[3]}
    set suite variable    ${release_info}    ${release_info}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info



Check specific log in the snapshot
    Log to console    Check specific log in the snapshot
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}
    ...    ${specific_file}=BTS${tl.gnbs[0].global_bts_id}_105D_crash.tgz    ${key_string}=killed    ${case_type}=rau
    ${release_version}    Get gnb release in rrm    host=${ASIL_IP}    username=${ASIL_USERNAME}    password=${ASIL_PASSWORD}
    Set Test Variable    ${release_version}
    Run   rm -rf ${snapshot_path}/
    ${extract_path}=    Collect the snapshot and extract specific file    snapshot_log_folder=${TS_CASE_LOG_PATH}
    ...    connection=GNB_OAM    specific_file=${specific_file}    case_type=${case_type}
    Run keyword if    '${case_type}'=='ru' and '${release_version}'=='9999'
    ...    Run    xz -d ${extract_path}/runtime_DEFAULT.log.xz
    Run keyword if    '${case_type}'=='ru' and '${release_version}'=='0011'
    ...    Run    xz -d ${extract_path}/pm_1_DEFAULT.log.xz
    Run keyword if    '${case_type}'=='rau'
    ...    Run    xz -d ${extract_path}/runtime_LFS.log.xz
    Run keyword if    '${case_type}'=='cu'
    ...    Run    xz -d ${extract_path}/${specific_file}
    ${key_string}    Run keyword if     '${case_type}'=='ru'    Catenate    ${key_string}
    ...    ELSE IF    '${case_type}'=='rau'    Catenate    ${key_string} Exception Report for "CCS"
    ...    ELSE IF    '${case_type}'=='cu'    Catenate    probably SW ${key_string}
    ${output}   Run keyword if    '${case_type}'=='ru' and '${release_version}'=='9999'
    ...    OperatingSystem.grep file    ${extract_path}/runtime_DEFAULT.log
    ...    ${key_string}    encoding_errors=replace
    ...    ELSE IF    '${case_type}'=='ru' and '${release_version}'=='0011'
    ...    OperatingSystem.grep file    ${extract_path}/pm_1_DEFAULT.log
    ...    ${key_string}    encoding_errors=replace
    ...    ELSE IF    '${case_type}'=='rau'    OperatingSystem.grep file    ${extract_path}/runtime_LFS.log
    ...    ${key_string}    encoding_errors=replace
    ...    ELSE IF    '${case_type}'=='cu'    OperatingSystem.grep file    ${extract_path}/BTS${tl.gnbs[0].global_bts_id}_1011_blackbox
    ...    ${key_string}    encoding_errors=replace
    Should not be empty    ${output}
    Run keyword if    '${case_type}'=='cu'   Should Contain    ${output}   ${reset_time}

Collect the snapshot and extract specific file
    [Arguments]    ${snapshot_log_folder}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
    ...    ${specific_file}=BTS${tl.gnbs[0].global_bts_id}_105D_crash.tgz    ${case_type}=rau
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_log_folder}    snapshot_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   timeout=600   connection=${connection}
    ${snapshot_unzip_folder}    Join Path    ${snapshot_log_folder}    snapshot_${timestamp}
    Extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_folder}
    OperatingSystem.File should exist    ${snapshot_unzip_folder}/snapshot_file_list.txt
    ${release_version}    Get gnb release in rrm    host=${ASIL_IP}    username=${ASIL_USERNAME}    password=${ASIL_PASSWORD}
    Set Test Variable    ${release_version}
    ${output}    Run keyword if    '${case_type}'=='rau'    OperatingSystem.get file    ${snapshot_unzip_folder}/snapshot_file_list.txt
    Run keyword if    '${case_type}'=='rau'    Should contain    ${output}    blackbox.xz
    Run keyword if    '${case_type}'=='rau'    Should contain    ${output}    blackbox_adet_data.xz
    Run keyword if    '${case_type}'=='rau'    Should contain    ${output}    blackbox_alarms.xz
    Run    grep -e 'zip:' -e '${specific_file}' ${snapshot_unzip_folder}/snapshot_file_list.txt > ${snapshot_unzip_folder}/tmp_test1.txt
    Run    cat ${snapshot_unzip_folder}/tmp_test1.txt
    Run    grep -B1 '${specific_file}' ${snapshot_unzip_folder}/tmp_test1.txt > ${snapshot_unzip_folder}/tmp_test2.txt
    Run    cat ${snapshot_unzip_folder}/tmp_test2.txt
    ${rc}    ${specific_file_in}    Run and return rc and output
    ...    grep -v '${specific_file}' ${snapshot_unzip_folder}/tmp_test2.txt
    ${specific_file_in}    Fetch from left    ${specific_file_in}    :
    ${specific_dir}    Fetch from left    ${specific_file_in}    .zip
    Extract zip file    ${snapshot_unzip_folder}/${specific_file_in}    ${snapshot_unzip_folder}/${specific_dir}
    OperatingSystem.File should exist    ${snapshot_unzip_folder}/${specific_dir}/${specific_file}
    ${specific_file_name}    Run keyword if    '${case_type}'=='ru'    Fetch from left    ${specific_file}    .zip
    ...    ELSE IF    '${case_type}'=='rau'    Fetch from left    ${specific_file}    .zip
    ...    ELSE IF    '${case_type}'=='cu'    Fetch from left    ${specific_file}    .xz
    Run    mkdir ${snapshot_unzip_folder}/${specific_dir}/${specific_file_name}
    ${specific_compress_file_path}    Set variable    ${snapshot_unzip_folder}/${specific_dir}/${specific_file_name}
    ${specific_compress_file}    Set variable    ${snapshot_unzip_folder}/${specific_dir}/${specific_file}
    Run keyword if    '${case_type}'=='ru'
    ...    Extract zip file    ${specific_compress_file}    ${specific_compress_file_path}
    Run keyword if    '${case_type}'=='rau'
    ...    Extract zip file    ${specific_compress_file}   ${specific_compress_file_path}
    Run keyword if    '${case_type}'=='cu'
    ...    Run    cp -r ${specific_compress_file} ${specific_compress_file_path}
    [Return]    ${specific_compress_file_path}


coamteardown
	coam.teardown    connection=coam_admin
