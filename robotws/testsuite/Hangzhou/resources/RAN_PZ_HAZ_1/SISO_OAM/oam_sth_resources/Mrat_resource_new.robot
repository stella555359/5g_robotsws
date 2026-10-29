*** Settings ***
Documentation     [PURPOSE] New added General keywords
...               CA-SWM/CA-HW
Library          taf.transport.ssh  WITH NAME  tafssh
Library           ute_fsmaccess
Resource          hran_frame_sbts.robot
Library           taf.nms.netact
Library           taf.fdsw.rc   WITH NAME  fdsw
Library           taf.ul.alarms_watchdog    WITH NAME    watchalarm
Variables         lib/alarms_variable.py
Library           lib/alarms_variable.py


*** Variables ***
${USE_SSL}       True
${ALIAS_ADMIN}    admin
${BTS_PORT_SRAN}    443
${current_release}    SBTS23R4_
${cm2}     --all-proxy="" --continue --max-connection-per-server=16
${scm_esp_server}  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local
${scm_server}  https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local
&{bangSshConfig}    host_ip=10.41.146.248     ssh_port=22    ssh_username=root    ssh_password=Nokia_150
${down_server}   10.68.93.70


*** Keyword ***
Setup Test Line Watchdog
    [Documentation]    Short description.
    Run keyword if    ${tl.gnbs}
    ...    watchalarm.watch_alarms    allowed_alarms=${CRT_ALLOWED_ALARMS}     bts_config=${tl.gnbs[0]}
    ...    ELSE
    ...    Run keyword
    ...    watchalarm.watch_alarms    allowed_alarms=${CRT_ALLOWED_ALARMS}     bts_config=${tl.enbs[0]}

Add CRT Alarms And Initial WatchAlarm
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${crt_alarms}: <description>
    [Arguments]    ${crt_alarms}
    Run keyword and ignore error    Stop Watching Alarms
    set test variable    ${crt_alarms}
    add crt allowed alarms    ${CRT_ALLOWED_ALARMS}    ${crt_alarms}
    Setup Test Line Watchdog

Del CRT Alarms And Initial WatchAlarm
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${crt_alarms}: <description>
    [Arguments]    ${crt_alarms}
    Run keyword and ignore error    Stop Watching Alarms
    set test variable    ${crt_alarms}
    del crt allowed alarms    ${CRT_ALLOWED_ALARMS}    ${crt_alarms}
    Setup Test Line Watchdog

Login_with_multiway
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${host}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    [Arguments]    ${host}    ${username}  ${password}
    SSHLibrary.Open Connection    ${host}
    ${status}=  Run keyword and return status  SSHLibrary.Login  ${username}  ${password}
    Return from keyword if  ${status}
    ${status}=  Run keyword and return status  SSHLibrary.Login with public key  ${username}
    ...  /home/${username}/.ssh/id_rsa
    Run keyword if    not ${status}  Fail  Remote connection unavailable
Get release num
    [Documentation]    Get release number of build
    [Arguments]    ${sw_path}
    ${sw_release_name}  Get TargetBD Node Attribute Value  softwareReleaseVersion  ${sw_path}
    ${matches}    Get Regexp Matches    ${sw_release_name}    SBTS\\d+R\\d+
    ${release_NUM}    set variable    ${matches[0]}
    [Return]    ${release_Num}

Choose_Mid_Server4Netact
    [Arguments]  ${IP}=${NETACT_SERVER_INFO.IP}
    [Documentation]    This kw is used to choose the server closed with Netact integrated of BTS,speeding.
    ...    Author: amaand.li
    ...    Contact: amaand.li@nokia-sbell.com
    ...    | Input Parameters | Opti. | Description |
    ...    | IP | yes | Netact ip the bts integrated |
    ...    | Return Value | Description |
    ...    | Mid_Server | the server ip used to store the build for netact usage |
    ...    | Mid_Server_usr | the server usrname |
    ...    | Mid_Server_pwd | the server password |
    ...
    ...    Example
    ...    | Choose_Mid_Server4Netact | 10.110.144.154 |
    # @{HZ_NA_list}    create list  10.110.144.154  10.107.183.26
    # ...    10.68.84.15  10.110.188.146  10.108.248.82   10.56.3.18   10.56.3.19
    # Run keyword if  str("""${IP}""") in @{HZ_NA_list}
    # ...  Run keywords
    #              ...  set test variable  ${Mid_Server}  ${down_server}
    #              ...  AND  set test variable  ${Mid_Server_usr}  ute
    #              ...  AND  set test variable  ${Mid_Server_pwd}  ute
    # ...  ELSE
    # ...  Run keywords
    #              ...  set test variable  ${Mid_Server}  10.41.146.248
    #              ...  AND  set test variable  ${Mid_Server_usr}  root
    #              ...  AND  set test variable  ${Mid_Server_pwd}  Nokia_150
    #              ...  AND  Clean remoteVM disk space    remote    &{bangSshConfig}
    Log    ${IP}
    set test variable  ${Mid_Server}  ${down_server}
    set test variable  ${Mid_Server_usr}  ute
    set test variable  ${Mid_Server_pwd}  ute@dmin5
    [Return]  ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}

build_download_upload_on_remote_server_and_import_to_Netact
    [Arguments]   ${target_sw}
             ...  ${release_NUM}
             ...  ${sw_type}=Basic
             ...  ${remote_ip}=10.41.146.248
             ...  ${remote_usr}=root
             ...  ${remote_pwd}=Nokia_150
             ...  ${copy_build_to_local}=False
    [Documentation]    This KW used to download sw from wft to remote server and import to netact.
    ...    Author: amaand.li
    ...    Contact: amaand.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | target_sw | yes | Build num. of package need to be import |
    ...    | release_NUM | yes | release num. of target_sw |
    ...    | remote_ip | No | Server ip which used to store target_sw for netact import, closed to netact is better  |
    ...    | remote_usr | No | Username of remote ip |
    ...    | remote_pwd | No | Password of remote_ip |
    ...
    ...    Example
    ...    | build_download_upload_on_remote_server_and_import_to_Netact | SBTS00_ENB_9999_221014_000005 | SBTS23R1 |
    ...
    ${remote_full_path}    ${local_full_path}    Download_Specify_Build_on_SpecifyHost_By_Aria
    ...    ${target_sw}    ${sw_type}   ${remote_ip}  22  ${remote_usr}   ${remote_pwd}  ${copy_build_to_local}
    Precondition Netact with TAF

    ${sw_release_changed}    Run keyword if
    ...    '9999'in '${target_sw}'    Replace String    ${target_sw}    SBTS00    ${release_NUM}
    ...    ELSE    set variable    ${target_sw}

    set test variable  ${sw_release_changed}

    ${rename_package}  set variable if
    ...   '${sw_type}'=='Basic'  ${sw_release_changed}
    ...   ${sw_release_changed}${sw_type}

    set test variable  ${rename_package}

    ${sw_fullname}   Run keyword if
    ...  '${sw_type}'=='Basic'  set variable  ${target_sw}_release_BTSSM_downloadable_A54.zip
    ...  ELSE    set variable    ${target_sw}_release_BTSSM_downloadable_testpackage_${sw_type}_A54.zip

    ${status}    taf.nms.netact.Is Imported    ${sw_release_changed}

    Run keyword if   '${status}'=='False'
    ...  Run keywords    Put_buid_from_Server_to_netacttmp
    ...  ${remote_ip}   ${remote_usr}   ${remote_pwd}  ${remote_full_path}
    ...  ${sw_fullname}  ${target_sw}    ${release_NUM}
    ...    AND  set test variable    ${sw_release}    ${target_sw}
    ...    AND  _import sw to netact    ${sw_release_changed}
    ...    ELSE	  set test variable    ${sw_release_changed}
    set test variable  ${local_full_path}
    [Teardown]    Run keyword and ignore error    Postcondition Netact with TAF

Download_Specify_Build_on_SpecifyHost_By_Aria
    [Arguments]    ${enb_build}    ${Package_type}   ${IP}  ${port}  ${usr}  ${pwd}   ${copy_build_to_local}
    ...   ${target_local_path}=/home/ute/sw_bak
    [Documentation]
    ...  | Time | Release | Author | Modification | Relevant feature |
    ...  | 20200428 | SRAN22R3 | li yanan | New KW | SWM releated download package on specifyhost |
    ...  |  This KW is about downloading specify package to specify server by speed-up.
    ...  |  parameter1: enb_build (string) ? e.g. SBTS00_ENB_9999_200727_000001
    ...  | parameter2: Package_type(string) ? e.g. Basic | T1 | T2
    ...  | If Basic, SBTS00_ENB_9999_200727_000001__release_BTSSM_downloadable_A54.zip
    ...  | If T1, \ SBTS00_ENB_9999_200727_000001_release_BTSSM_downloadable_testpackage_T1_A54.zip
    ...  | If T2, \ SBTS00_ENB_9999_200727_000001_release_BTSSM_downloadable_testpackage_T2_A54.zip
    ...  | parameter3,4,5: IP,port,usr,pwd, all these parameter type is string. Info of specify host,
    ...    eg:banglore_server(10.41.146.248 22 root Nokia_150)
    ...  | parameter: copy_build_to_local, type is boolean, Indicates whether to copy the package from the specified
    ...    server to the local, the default value is false
    ...  | parameter: target_local_path(string),if copy_build_to_local is set true, need to set local path for copy,
    ...    default value is /home/ute/sw_bak
    Log    ${port}
    ${enb_build}=    Run Keyword If    '9999' in '${enb_build}'    Replace String Using Regexp    ${enb_build}
    ...    SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set variable    ${enb_build}
   ${platform_R3}  Run keyword and return status  Should be true  'FSM3' in '${enb_build}'
    ${release}  Run keyword if  ${platform_R3}  Run Keyword  Should Match Regexp  ${enb_build}
    ...  [SBTS]{4}[0-5]{2}[R]{0,1}[0-5]{0,1}_[FSM3]{0,4}  flags=IGNORECASE
    ...   ELSE  Run Keyword  Fetch from left    ${enb_build}    _
	${num}    Should Match Regexp    ${release}    [0-9][0-9]
	${scm_server}    Set variable
	...  ${scm_server}/build/${release}/${enb_build}
    ${download_path}    Run Keyword If    '9999' in '${enb_build}'
    ...  Set variable    /home/ute/HZOAM/01_BTS_SW/New_Trunk
    ...    ELSE    Set variable    /home/ute/HZOAM/01_BTS_SW/${release}
    ${build_match_no}    Run keyword if    'SBTS00' in '${release}'    Set variable    A54
	...    ELSE IF    '${num}'>='21'    Set variable    A54
    ...    ELSE IF    '${num}'>='20' and ('C' in '${release}')    Set variable    A54
    ...    ELSE IF    '${num}'<='20' and ('00' not in '${release}') and ('C' not in '${release}')    Set variable    A53
    ${build_url}    Set Variable If
    ...  '${Package_type}'=='Basic'
    ...  ${scm_server}/${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip
    ...  '${Package_type}'=='T1'
    ...  ${scm_server}/${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${scm_server}/${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    ${remote_full_path}    Set Variable If    '${Package_type}'=='Basic'
    ...   ${download_path}${/}${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip
    ...  '${Package_type}'=='T1'
    ...  ${download_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${download_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    #set test Variable    ${cm1}  --all-proxy="" --continue --max-connection-per-server=16
    #set test Variable    ${cmd1}
    #...  aria2c \ --file-allocation=none ${cm1} --split=16 ${build_url} -d ${download_path}
    ${cmd1}=    Catenate    aria2c
    ...    --file-allocation=none    --all-proxy=""
    ...    --continue --max-connection-per-server=16
    ...    --header="Authorization: Bearer cmVmdGtuOjAxOjE4MzYxNzg5MDM6eXpCbjVpUnF2T1lFMm1WOTdlRXBwdG9jY01Y"
    ...    --split=16 ${build_url} -d ${download_path}
    SSHLibrary.Open Connection    ${IP}
    SSHLibrary.Login    ${usr}    ${pwd}
    ${rc}=    SSHLibrary.Execute Command    find ${remote_full_path}    return_stdout=False    return_rc=True
    Run keyword if    ${rc}!=0
    ...  Wait Until Keyword Succeeds    60 minutes    5 secs    SSHLibrary.Execute Command    ${cmd1}
    Set test Variable    ${local_path}    ${target_local_path}
    ${status_curl}=    Run Keyword And Ignore Error    OperatingSystem.Directory Should Exist    ${local_path}
    Run Keyword If    '${status_curl[0]}'=='FAIL'    Create Directory    ${local_path}
    OperatingSystem.Directory Should Exist    ${local_path}
    ${local_full_path}    Set Variable If    '${Package_type}'=='Basic'
    ...  ${local_path}/${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip
    ...  '${Package_type}'=='T1'
    ...  ${local_path}/${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${local_path}/${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    ${build_exist_local_before}   Run keyword and return status    OperatingSystem.File should exist    ${local_full_path}
    ${copy_build_to_local}  Evaluate  '${copy_build_to_local}'.lower()
    Run keyword if     '${build_exist_local_before}'=='False' and '${copy_build_to_local}'=='true'
    ...  Run keywords   sftp download    ${IP}  ${usr}    ${pwd}    ${remote_full_path}    ${local_path}/
    ...  AND    BuiltIn.Log To Console    Finished download ${Package_type} build to ${local_path}/
    [Return]    ${remote_full_path}    ${local_full_path}

sftp upload
    [Arguments]   ${hostname}  ${user}  ${password}  ${source_filepath}  ${desnation_filepath}  ${alias}=default
    [Documentation]  This keyword is used to upload local file to remote server
        ...
    ...  *AUTHOR* amaand.li@nokia-sbell.com
    ...
    ...    |Input Parameters| Man. | Description|
    ...    | hostname | Yes | the ip of destination server  |
    ...    | user   | Yes  | the username of destination server  |
    ...    | password | Yes | the password of destination server  |
    ...    | source_filepath   | Yes  | local file path |
    ...    | desnation_filepath | Yes | remote destination paht  |
    ...    | alias   | No  | default alias is used:"default" |
    ...   Example
    ...  | Sftp Upload | /etc/hosts | /home/TheUser/hosts_from_remote|
    tafssh.Connect To    ${hostname}    ${user}    ${password}   alias=${alias}
    tafssh.Upload File    ${source_filepath}  ${desnation_filepath}   connection=${alias}
    tafssh.Disconnect    connection=${alias}

sftp download
    [Arguments]   ${hostname}  ${user}  ${password}  ${source_filepath}  ${desnation_filepath}  ${alias}=default
    [Documentation]  This keyword is used to download local file from remote server
        ...
    ...  *AUTHOR* amaand.li@nokia-sbell.com
    ...
    ...    |Input Parameters| Man. | Description|
    ...    | hostname | Yes | the ip of destination server  |
    ...    | user   | Yes  | the username of destination server  |
    ...    | password | Yes | the password of destination server  |
    ...    | source_filepath   | Yes  | local file path |
    ...    | desnation_filepath | Yes | remote destination paht  |
    ...    | alias   | No  | default alias is used:"default" |
    ...   Example
    ...  | Sftp Upload | /etc/hosts | /home/TheUser/hosts_from_remote|
    tafssh.Connect To    ${hostname}    ${user}    ${password}   alias=${alias}
    tafssh.Download File    ${source_filepath}  ${desnation_filepath}   connection=${alias}
    tafssh.Disconnect    connection=${alias}

Put_buid_from_Server_to_netacttmp
    [Arguments]    ${remote_ip}   ${remote_usr}   ${remote_pwd}  ${build_path_server}
    ...   ${sw_fullname}  ${sw_release}	 ${release_NUM}
    [Documentation]
    ...  | Time | Release | Author | Modification | Relevant feature |
    ...  | 20220428 | SRAN21A | li yanan | New KW | put build from remoteServer to netact |
    ...  | This KW is about put build from serverX to netact
    ...  | parameter1,2,3: remote_ip,remote_usr,remote_pwd (string), server info
    ...  | parameter2: sw_release(string) \u2013 e.g. \ SBTS00_ENB_9999_200727_000001
    ...  | parameter4: build_path_server (string)
    ...     \u2013 e.g. /home/ute/HZOAM/SBTS00_ENB_9999_200727_000001__release_BTSSM_downloadable_A54.zip
    ...  | parameter5: sw_release(string) \u2013 e.g. \ SBTS00_ENB_9999_200727_000001
    Log    ${release_NUM}
    ${sw_release_match}  Fetch from right  ${sw_release}  S
    ${netact_connection}    Connect To Netact_bySSHLIB
    set test variable    ${netact_connection}
    SSHLibrary.Switch Connection    ${netact_connection}
    SSHLibrary.Write    cd /d/oss/global/swmanager/swm_temp/
    sleep  2s
    SSHLibrary.Write    du -h *${sw_release_match}*
    ${output}  SSHLibrary.Read  delay=4s
    @{info}  split string  ${output}  \t
    ${size}  Fetch from left  ${info[0]}  G
    ${status_include1}  ${msg1}=  Run keyword and ignore error   Evaluate   ${size}>8
    Run keyword if  '${status_include1}' == 'FAIL'
        ...  upload build from remoteA to remoteB   ${remote_ip}   ${remote_usr}   ${remote_pwd}
        ...  ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
        ...  ${build_path_server}  /d/oss/global/swmanager/swm_temp/
    ${netact_connection1}  Run keyword if  '${status_include1}' == 'FAIL'  Connect To Netact_bySSHLIB
    Run keyword if  '${status_include1}' == 'FAIL'
    ...  Run Keywords
        ...  SSHLibrary.Switch Connection    ${netact_connection1}
        ...  AND    SSHLibrary.Write    cd /d/oss/global/swmanager/swm_temp/
        ...  AND    SSHLibrary.Write    mv ${sw_fullname} ${rename_package}.zip
        ...  AND    set test variable    ${sw_release_changed}

    Run keyword if  '${status_include1}' == 'PASS' and '${sw_release_changed}.zip' not in '''${output}'''
    ...  Run Keywords
        ...  SSHLibrary.Switch Connection    ${netact_connection}
        ...  AND    SSHLibrary.Write    mv ${sw_fullname} ${rename_package}.zip
    [Teardown]  Run keyword and ignore error  SSHLibrary.Close Connection

upload build from remoteA to remoteB
    [Arguments]  ${serverA_ip}   ${serverA_usr}   ${serverA_pwd}   ${serverB_ip}
    ...          ${serverB_usr}   ${serverB_pwd}   ${serverA_full_path}  ${serverB_path}
    [Documentation]
    ...  | Time | Release | Author | Modification | Relevant feature |
    ...  | 20220428 | SRAN21A | li yanan | New KW | This KW is about upload build/file from server A to server B |
    ...  | parameter1,2,3: serverA_ip,serverA_usr,serverA_pwd (string), serverA info
    ...  | parameter4,5,6: serverB_ip,serverB_usr,serverB_pwd(string), serverB info
    ...  | parameter7: serverA_full_path(string), full path of build/file on server A,
    ...  eg:/home/ute/HZOAM/01_BTS_SW/New_Trunk/SBTS00_ENB_9999_220427_000012_rele \x08ase_BTSSM_downloadable_A54.zip
    ...  | parameter8: serverB_path(string), path of target serverB,eg:/d/oss/global/swmanager/swm_temp/
    #set library search order  SSHLibrary
    SSHLibrary.Open Connection    ${serverA_ip}
    SSHLibrary.Login    ${serverA_usr}    ${serverA_pwd}
#    ${rc}=    SSHLibrary.Execute Command    find ${remote_full_path}    return_stdout=False    return_rc=True
    SSHLibrary.Write  sftp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${serverB_usr}@${serverB_ip}
#    ${res1}=    Read    delay=3s
#    ${res2}    Run keyword and return status    should end with    ${res1}    (yes/no/[fingerprint])?
#    Run keyword if    '${res2}'=='True'    SSHLibrary.Execute Command    yes
    SSHLibrary.Read Until    password:
    SSHLibrary.write    ${serverB_pwd}
    Set Client Configuration    prompt=sftp>
    ${res3}=    SSHLibrary.Read Until prompt
    SSHLibrary.write    put ${serverA_full_path} ${serverB_path}
    Set Client Configuration    prompt=sftp>
    Wait until keyword Succeeds    3600s  3s  SSHLibrary.Read Until prompt
    SSHLibrary.Write    exit
    [Teardown]  SSHLibrary.Close connection

_Get Scf By Admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${target_path}: <description>
    ...        ${Export_Type}: <description>
    [Arguments]    ${target_path}    ${Export_Type}=None
    ${Export_Type}    set variable    configurationAndRuntimeObjects
    Start Admin_MRAT    alias=get_scf
    taf.sbts.oam.coam.admin.Collect Scf    ${target_path}    export_type=${Export_Type}    timeout=600    alias=get_scf
    ${scf}=    OperatingSystem.Get File    ${target_path}
    Should Start WIth    ${scf}    <?xml version=
    [Teardown]    taf.sbts.oam.coam.admin.Teardown Admin    alias=get_scf
_Get Scf By Admin default
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${target_path}: <description>
    ...        ${Export_Type}: <description>
    [Arguments]    ${target_path}    ${Export_Type}=None
    ${Export_Type}    set variable    configurationAndRuntimeObjects
    taf.sbts.oam.coam.admin.Collect Scf    ${target_path}    export_type=${Export_Type}    timeout=600    alias=default
    ${scf}=    OperatingSystem.Get File    ${target_path}
    Should Start WIth    ${scf}    <?xml version=
Start Admin_MRAT
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${host}: <description>
    ...        ${port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${use_ssl}: <description>
    ...        ${alias}: <description>
    [Arguments]    ${host}=192.168.255.129    ${port}=443    ${username}=Nemuadmin    ${password}=nemuuser
    ...            ${use_ssl}=True    ${alias}=hfv
    Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.Teardown Admin    alias=${alias}
    Wait Until Keyword Succeeds    10min    1min    taf.sbts.oam.coam.admin.Setup Admin    bts_host=${host}
    ...  bts_port=${port}    username=${username}    password=${password}    use_ssl=${use_ssl}    alias=${alias}
    ...  admin_api_log_dir=${CURDIR}

Get Timestamp
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${timestamp}: <description>
    ${timestamp}=    get time
    ${str1}=    Replace String    ${timestamp}    -    ${SPACE}
    ${str2}    Replace String    ${str1}    :    ${SPACE}
    ${timestamp}=    Evaluate    '${str2}'.replace(' ','')
    [Return]    ${timestamp}

_Perform Full Commision By Admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${scfc}: <description>
    ...        ${BTS_INFO.ID}: <description>
    ...        ${timeout}: <description>
    [Arguments]    ${scfc}    ${BTS_INFO.ID}    ${timeout}=15min
    taf.sbts.oam.coam.admin.Perform Commissioning    bts_id=${BTS_INFO.ID}    scf_file=${scfc}    skip_parameter_relation_errors=${True}
    ...  should_activate=${True}    timeout=${timeout}

Check BTS State By Admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${expected_BTS_status}: <description>
    [Arguments]    ${expected_BTS_status}
    ${current_status}=    taf.sbts.oam.coam.admin.get mrbts state
    should match regexp    ${current_status}    ${expected_BTS_status}

Download_Specify_Build_By_Aria
    [Arguments]    ${enb_build}    ${Package_type}    ${target_path}
    [Documentation]    \ \ \ [Documentation] \ \ \ | Time | Release | Author | Modification | Relevant feature |
    ...    \ \ ... \ \ \ | 20200730 | SRAN21A | li yanan | New KW | SWM releated download package on UTE |
    ...    \ ...
    ...    ... \ \ \ This KW is \ about downloading specify package by using multi-progress
    ...
    ...    ... \ \ \ parameter1: enb_build (string) ? e.g. SBTS00_ENB_9999_200727_000001
    ...
    ...    ... \ \ \ parameter2: Package_type(string) ? e.g. Basic | T1 | T2 |ADMINCLI
    ...    ... \ \ ... \ \ If Basic, SBTS00_ENB_9999_200727_000001__release_BTSSM_downloadable_A54.zip
    ...    ... \ \ If T1, \ SBTS00_ENB_9999_200727_000001_release_BTSSM_downloadable_testpackage_T1_A54.zip
    ...    ... \ \ If T2, \ SBTS00_ENB_9999_200727_000001_release_BTSSM_downloadable_testpackage_T2_A54.zip
    ...    ... \ \ If ADMINCLI, \ SBTS00_ENB_9999_200727_000001_ADMIN_CLI.zip

    ${enb_build}=    Run Keyword If    '9999' in '${enb_build}'
    ...  Replace String Using Regexp    ${enb_build}    SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set variable    ${enb_build}
	${platform_R3}  Run keyword and return status  Should be true  'FSM3' in '${enb_build}'
    ${release}  Run keyword if  ${platform_R3}  Run Keyword  Should Match Regexp  ${enb_build}
    ...  [SBTS]{4}[0-5]{2}[R]{0,1}[0-5]{0,1}_[FSM3]{0,4}  flags=IGNORECASE
    ...   ELSE  Run Keyword  Fetch from left    ${enb_build}    _
	${num}    Should Match Regexp    ${release}    [0-9][0-9]
	${scm_server}    Set variable    ${scm_server}/build/${release}/${enb_build}
    ${download_path}    Run Keyword If    '9999' in '${enb_build}'
    ...  Set variable    /home/ute/HZOAM/01_BTS_SW/New_Trunk
    ...    ELSE    Set variable    /home/ute/HZOAM/01_BTS_SW/${release}
    ${build_match_no}    Run keyword if    'SBTS00' in '${release}'    Set variable    A54
    ...    ELSE IF    '${num}'>='21'    Set variable    A54
    ...    ELSE IF    '${num}'>='20' and ('C' in '${release}')    Set variable    A54
    ...    ELSE IF    '${num}'<='20' and ('00' not in '${release}') and ('C' not in '${release}')    Set variable    A53
    ${build_url}    Set Variable If
    ...  '${Package_type}'=='Basic'    ${scm_server}/${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip
    ...  '${Package_type}'=='T1'
    ...  ${scm_server}/${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${scm_server}/${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    ...  '${Package_type}'=='ADMINCLI'
    ...  ${scm_server}/${enb_build}_ADMIN_CLI.zip
    ${Package_full_path}    Set Variable If    '${Package_type}'=='Basic'
    ...  ${download_path}${/}${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip    '${Package_type}'=='T1'
    ...  ${download_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${download_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    ...  '${Package_type}'=='ADMINCLI'
    ...  ${download_path}${/}${enb_build}_ADMIN_CLI.zip
    log    ${target_path}
    ${curl_path}    Set Variable    ${target_path}
    ${status_curl}=    Run Keyword And Ignore Error    OperatingSystem.Directory Should Exist    ${curl_path}
    Run Keyword If    '${status_curl[0]}'=='FAIL'    Create Directory    ${curl_path}
    OperatingSystem.Directory Should Exist    ${curl_path}
    ${curl_full_path}    Set Variable If
    ...  '${Package_type}'=='Basic'    ${curl_path}${enb_build}_release_BTSSM_downloadable_${build_match_no}.zip
    ...  '${Package_type}'=='T1'
    ...  ${curl_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T1_${build_match_no}.zip
    ...  '${Package_type}'=='T2'
    ...  ${curl_path}${/}${enb_build}_release_BTSSM_downloadable_testpackage_T2_${build_match_no}.zip
    ...  '${Package_type}'=='ADMINCLI'
    ...  ${curl_path}${/}${enb_build}_ADMIN_CLI.zip
    Run keyword and ignore error    OperatingSystem.Remove File    ${curl_full_path}
    # ${cmd1}    set Variable
    # ...  aria2c \ --file-allocation=none ${cm2} --split=16 ${build_url} -d ${download_path}
    ${cmd1}=    Catenate    aria2c
    ...    --file-allocation=none    --all-proxy=""
    ...    --continue --max-connection-per-server=16
    ...    --header="Authorization: Bearer cmVmdGtuOjAxOjE4MzYxNzg5MDM6eXpCbjVpUnF2T1lFMm1WOTdlRXBwdG9jY01Y"
    ...    --split=16 ${build_url} -d ${download_path}
    ${build_path}    Set Variable    ${curl_full_path}
    SSHLibrary.Open Connection    ${down_server}
    SSHLibrary.Login    ute    ute@dmin5
    ${rc}=    SSHLibrary.Execute Command    find ${package_full_path}    return_stdout=False    return_rc=True
    Run keyword if    ${rc}!=0
    ...  Wait Until Keyword Succeeds    60 minutes    5 secs    SSHLibrary.Execute Command    ${cmd1}
    BuiltIn.Log To Console    Finished download ${Package_type} build to ${download_path}
    sleep  30s
    SSHLibrary.Get File    ${Package_full_path}    ${curl_full_path}        SCP=ALL
    sleep  30s
    SSHLibrary.Close Connection
    ${Package_size}    Get File Size    ${curl_full_path}
    run keyword if    '${Package_type}'=='ADMINCLI'    log  ADMINCLI package download successfully
    ...  ELSE   Should Be True    ${Package_size} > 400000000
    [Return]    ${build_path}

_Download_Specify_A54E_Build_By_Aria
    [Arguments]    ${enb_build}    ${target_path}
    [Documentation]    \ \ \ [Documentation] \ \ \ | Time | Release | Author | Modification | Relevant feature |
    ...    \ \ ... \ \ \ | 20200730 | SRAN21A | li yanan | New KW | SWM releated download package on UTE |
    ...    \ ...
    ...    ... \ \ \ This KW is \ about downloading specify package by using multi-progress
    ...
    ...    ... \ \ \ parameter1: enb_build (string) ? e.g. SBTS00_ENB_9999_200727_000001
    ...
    ...    ... \ \ \ parameter2: Package_type(string) ? e.g. Basic | T1 | T2
    ...    ... \ \ ... \ \ If Basic, SBTS00_ENB_9999_200727_000001__release_BTSSM_downloadable_A54.zip
    ...    ... \ \ If T1, \ SBTS00_ENB_9999_200727_000001_release_BTSSM_downloadable_testpackage_T1_A54.zip
    ...    ... \ \ If T2, \ SBTS00_ENB_9999_200727_000001_release_BTSSM_downloadable_testpackage_T2_A54.zip
    ${enb_build}=    Run Keyword If    '9999' in '${enb_build}'
    ...  Replace String Using Regexp    ${enb_build}    SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set variable    ${enb_build}
    ${release}    Fetch from left    ${enb_build}    _
    ${num}    BuiltIn.Should Match Regexp    ${release}    [0-9][0-9]
    ${scm_server}    Set variable    ${scm_server}/build/${release}/${enb_build}
    ${download_path}    Run Keyword If
    ...  '9999' in '${enb_build}'    Set variable    /home/ute/HZOAM/01_BTS_SW/New_Trunk
    ...    ELSE    Set variable    /home/ute/HZOAM/01_BTS_SW/${release}
    ${build_match_no}    Run keyword if    '${release}'=='SBTS00'    Set variable    A54
    ...    ELSE IF    '${num}'>'20'    Set variable    A54
    ...    ELSE IF    '${num}'='20' and ('C' in '${release}')    Set variable    A54
    ...    ELSE IF    '${num}'<='20' and ('00' not in '${release}') and ('C' not in '${release}')    Set variable    A53
    ${build_url}    Set Variable    ${scm_server}/${enb_build}_release_BTSSM_downloadable_${build_match_no}E.zip
    ${Package_full_path}
    ...  Set Variable    ${download_path}${/}${enb_build}_release_BTSSM_downloadable_${build_match_no}E.zip
    OperatingSystem.Remove File    ${Package_full_path}
    log    ${target_path}
    ${curl_path}    Set Variable    ${target_path}
    ${status_curl}=    Run Keyword And Ignore Error    OperatingSystem.Directory Should Exist    ${curl_path}
    Run Keyword If    '${status_curl[0]}'=='FAIL'    Create Directory    ${curl_path}
    OperatingSystem.Directory Should Exist    ${curl_path}
    ${curl_full_path}    Set Variable if   '${curl_path[-1]}'=='/'
    ...  ${curl_path}${enb_build}_release_BTSSM_downloadable_${build_match_no}E.zip
    ...  ${curl_path}${/}${enb_build}_release_BTSSM_downloadable_${build_match_no}E.zip
    Remove File    ${curl_full_path}
    #${cm3}    set Variable      --all-proxy="" --continue --max-connection-per-server=16
    #${cmd1}    set Variable
    #...  aria2c \ --file-allocation=none ${cm3}  --split=16 ${build_url} -d ${download_path}
    ${cmd1}=    Catenate    aria2c
    ...    --file-allocation=none    --all-proxy=""
    ...    --continue --max-connection-per-server=16
    ...    --header="Authorization: Bearer cmVmdGtuOjAxOjE4MzYxNzg5MDM6eXpCbjVpUnF2T1lFMm1WOTdlRXBwdG9jY01Y"
    ...    --split=16 ${build_url} -d ${download_path}

    ${build_path}    Set Variable    ${curl_full_path}
    SSHLibrary.Open Connection    ${down_server}
    SSHLibrary.Login    ute    ute@dmin5
    ${result}=    Wait Until Keyword Succeeds    60 minutes    5 secs    SSHLibrary.Execute Command    ${cmd1}
    BuiltIn.Log To Console    Finished download build to ${download_path}
    SSHLibrary.Get File    ${Package_full_path}    ${curl_path}
    SSHLibrary.Close Connection
    ${Package_size}    Get File Size    ${curl_full_path}
    Should Be True    ${Package_size} > 400000000
    [Return]    ${build_path}

Choose Target SW build version from list
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_list}: <description>
    ...
    ...    Returns:
    ...        ${sw_build}: <description>
    ...        ${sw_build_path}: <description>
    [Arguments]    ${sw_list}=${release_list}
    Log    ${sw_list}
    ${SW_Status}    Run Keyword And Return Status    should contain    ${PASSIVE_SW_BEFORE}     9999
    ${PASSIVE_SW_BEFORE}    Run Keyword If    ${SW_Status}==True    Replace String Using Regexp    ${PASSIVE_SW_BEFORE}
    ...  SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set Variable    ${PASSIVE_SW_BEFORE}
    ${SW_Status}    Run Keyword And Return Status    should contain    ${ACTIVE_SW_BEFORE}    9999
    ${ACTIVE_SW_BEFORE}    Run Keyword If    ${SW_Status}==True    Replace String Using Regexp    ${ACTIVE_SW_BEFORE}
    ...  SBTS\\d{2,2}\\w[0-9]?_    SBTS00_
    ...    ELSE    Set Variable    ${ACTIVE_SW_BEFORE}
    ${sw_temp}    split string    ${ACTIVE_SW_BEFORE}    _
    ${Release_Num}    Run Keyword If    ${SW_Status}==True    Set Variable    SBTS00
    ...    ELSE    Set Variable    ${sw_temp[0]}
    ${sw_build}    Run Keyword If
    ...  '${release_list_1}'!='${PASSIVE_SW_BEFORE}' and '${release_list_1}'!='${ACTIVE_SW_BEFORE}'
    ...  Set Variable    ${release_list_1}
    ...    ELSE IF    '${release_list_2}'!='${PASSIVE_SW_BEFORE}' and '${release_list_2}'!='${ACTIVE_SW_BEFORE}'
    ...  Set Variable    ${release_list_2}
    ...    ELSE    Set Variable    ${release_list_3}
    ${sw_build_path}    Run Keyword If
    ...  '${release_list_1}'!='${PASSIVE_SW_BEFORE}' and '${release_list_1}'!='${ACTIVE_SW_BEFORE}'
    ...  Set Variable    ${SW_path}
    ...    ELSE IF    '${release_list_2}'!='${PASSIVE_SW_BEFORE}' and '${release_list_2}'!='${ACTIVE_SW_BEFORE}'
    ...  Set Variable    ${SW_path_T1}
    ...    ELSE    Set Variable    ${SW_path_T2}
    Set Suite Variable    ${sw_build}
    Set Suite Variable    ${Release_Num}
    [Return]    ${sw_build}    ${sw_build_path}

_check provision triggered by NE
    [Documentation]    Short description.
    Precondition Netact with TAF
	${output}    taf.nms.netact.Get Mo Status    dist_names=PLMN-PLMN/${BTS_INFO.MRBTS}
    log    ${output}
    ${result}    Get From Dictionary    ${output}    PLMN-PLMN/${BTS_INFO.MRBTS}
    ${last_sw_op}    Get From Dictionary    ${result}    last_sw_op
    Should Be Equal    ${last_sw_op}    SWProvision
    ${last_op_status}    Get From Dictionary    ${result}    last_op_status
    Should Be Equal    ${last_op_status}    SUCCESS
	[Teardown]    Postcondition Netact with TAF

_do SW provision from NetAct with RU only
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...
    ...    Returns:
    ...        ${op_id}[1]: <description>
    [Arguments]    ${sw_release}
    &{dict_atrribute}=    Create Dictionary       independentSwUpgradeType=RuSwOnly
    Precondition Netact with TAF
    ${op_id}=    run keyword and ignore error    taf.nms.netact.start_swm_operation    provision      PLMN-PLMN/${BTS_INFO.MRBTS}     ${sw_release}
    ...   ${dict_atrribute}
    Postcondition Netact with TAF
    Should Be Equal    ${op_id}[0]    PASS
    [Return]    ${op_id}[1]

_do SW provision from NetAct with RUSW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...
    ...    Returns:
    ...        ${op_id}[1]: <description>
    [Arguments]    ${sw_release}
    &{dict_atrribute}=    Create Dictionary       overrideIndependentRUSW=yes
    Precondition Netact with TAF
    ${op_id}=    run keyword and ignore error    taf.nms.netact.start_swm_operation    provision      PLMN-PLMN/${BTS_INFO.MRBTS}     ${sw_release}
    ...   ${dict_atrribute}
    Postcondition Netact with TAF
    Should Be Equal    ${op_id}[0]    PASS
    [Return]    ${op_id}[1]

_do SW activation from NetAct with RU only
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...
    ...    Returns:
    ...        ${op_id}[1]: <description>
    [Arguments]    ${sw_release}
    &{dict_atrribute}=    Create Dictionary       independentSwUpgradeType=RuSwOnly
    Precondition Netact with TAF
    ${op_id}=
    ...    run keyword and ignore error     taf.nms.netact.start_swm_operation    activation      PLMN-PLMN/${BTS_INFO.MRBTS}     ${sw_release}
    ...   ${dict_atrribute}
    Postcondition Netact with TAF
    Should Be Equal    ${op_id}[0]    PASS
    [Return]    ${op_id}[1]

_do SW activation from NetAct with RUSW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...
    ...    Returns:
    ...        ${op_id}[1]: <description>
    [Arguments]    ${sw_release}
    &{dict_atrribute}=    Create Dictionary        overrideIndependentRUSW=yes
    Precondition Netact with TAF
    ${op_id}=
    ...    run keyword and ignore error     taf.nms.netact.start_swm_operation    activation      PLMN-PLMN/${BTS_INFO.MRBTS}     ${sw_release}
    ...   ${dict_atrribute}
    Postcondition Netact with TAF
    Should Be Equal    ${op_id}[0]    PASS
    [Return]    ${op_id}[1]

_do SW download from NetAct with RUSW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...
    ...    Returns:
    ...        ${op_id}[1]: <description>
    [Arguments]    ${sw_release}
    &{dict_atrribute}=    Create Dictionary       overrideIndependentRUSW=yes
    Precondition Netact with TAF
    ${op_id}=
    ...    run keyword and ignore error     taf.nms.netact.start_swm_operation    download      PLMN-PLMN/${BTS_INFO.MRBTS}     ${sw_release}
    ...   ${dict_atrribute}
    Postcondition Netact with TAF
    Should Be Equal    ${op_id}[0]    PASS
    [Return]    ${op_id}[1]

_do SW download from NetAct with RU only
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...
    ...    Returns:
    ...        ${op_id}[1]: <description>
    [Arguments]    ${sw_release}
    &{dict_atrribute}=    Create Dictionary        independentSwUpgradeType=RuSwOnly
    Precondition Netact with TAF
    ${op_id}=
    ...    run keyword and ignore error     taf.nms.netact.start_swm_operation    download      PLMN-PLMN/${BTS_INFO.MRBTS}     ${sw_release}
    ...   ${dict_atrribute}
    Postcondition Netact with TAF
    Should Be Equal    ${op_id}[0]    PASS
    [Return]    ${op_id}[1]

_do SW provision from NetAct
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...        ${timeout}: <description>
    [Arguments]    ${sw_release}    ${timeout}
    Precondition Netact with TAF
    ${log}    taf.nms.netact.Provision Sw    PLMN-PLMN/${BTS_INFO.MRBTS}     ${sw_release}    ${timeout}
    Should Contain    ${log}    SUCCESS
    [Teardown]    Postcondition Netact with TAF

_do SW Activate from NetAct
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...        ${timeout}: <description>
    [Arguments]    ${sw_release}    ${timeout}
    Precondition Netact with TAF
    ${log}    taf.nms.netact.Activate Sw    PLMN-PLMN/${BTS_INFO.MRBTS}     ${sw_release}    ${timeout}
    Should Contain    ${log}    SUCCESS
    [Teardown]    Postcondition Netact with TAF

Get imported package name
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${SW_package}: <description>
    ...        ${sw_changed}: <description>
    #Trunk version changed, the verion number for ${sw_changed} also need changed.
    ${file}    get newest file from directory    ${TARGET_SW_DIR}  *.zip
    ${SW_package}    Get regexp Matches    ${file}    SBTS([09]{0,2}).+
    ${SW_package}    Get regexp Matches    ${SW_package[0]}
    ...  SBTS[0-9]{0,2}[A-Z]?[0-9]?_ENB_([0-9]{0,4})_([0-9]{0,6})_([0-9]{0,6})
    ${SW_package}    set variable    ${SW_package[0]}
    ${sw_changed}=    Run Keyword If    '9999' in '${SW_package}'
    ...  Replace String Using Regexp    ${SW_package}    SBTS00_    ${current_release}
    ...    ELSE    Set variable    ${SW_package}
    [Return]    ${SW_package}    ${sw_changed}

Put_buid_from_local_to_netact_R4R3
    [Arguments]    ${local_path}    ${sw_release}
    [Documentation]    [Documentation] \ \ \ | Time | Release | Author | Modification | Relevant feature |
    ...    ... | 20200730 | SRAN21A | li yanan | New KW | put build from local to netact \ |
    ...
    ...    ... \ This KW is about put build from local to netact. For trunk, version need to be changed to SBTS00,
    ...  so set two parameters for using.
    ...
    ...    ... parameter1: local_path (string) ¨C
    ...  e.g. /home/ute/SBTS00_ENB_9999_200727_000001__release_BTSSM_downloadable_A54.zip
    ...
    ...    ... parameter2: ${sw_release}(string) ¨C e.g. \ SBTS21B_ENB_9999_200727_000001
    ${netact_connection}    Common Connect To Netact
    Execute Shell Command    cd /d/oss/global/swmanager/swm_temp/
    #Execute Shell Command    rm *.zip
    sftp upload    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.PORT}    ${NETACT_SERVER_INFO.USERNAME}
    ...  ${NETACT_SERVER_INFO.PASSWORD}    ${local_path}    /d/oss/global/swmanager/swm_temp/${sw_release}.zip
    Switch Host connection    ${netact_connection}
    Set Shell Prompt    .zip
    ${result}    Execute Shell Command    ls | grep ${sw_release}
    log    ${result}
    should contain    ${result}    ${sw_release}
    set shell Prompt    $
    Execute Shell Command    find . -type f -size +300M

Common Connect To Netact
    [Documentation]    This keyword used to connect to Netact
    ...
    ...    return ${netact_connection}
    ...
    ...    example 1
    ...    | Common Connect To Netact |
    ...    example 2
    ...    | Common Connect To Netact |
    ...    | Switch Host Connection | ${netact_connection} |
    ${netact_connection}    connect_to_host    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.PORT}
    ...  ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}    conn_type=SSH
    Set Suite Variable    ${netact_connection}
    [Return]    ${netact_connection}

Connect To Netact
    [Documentation]    | Time | Release | Author | Modification | Relevant feature |
    ...    | 20210730 | SRAN21A | li yanan | New KW | This keyword used to connect to Netact|
    ...    return ${netact_connection}
    ...    example 1
    ...    |Connect To Netact |
    ...    example 2
    ...    |Connect To Netact |
    ...    | Switch Host Connection | ${netact_connection} |
    ${netact_connection}=    SSHLibrary.Open Connection    ${NETACT_SERVER_INFO.IP}
    SSHLibrary.Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Suite Variable    ${netact_connection}
    [Return]    ${netact_connection}

Change parameter to connect netact with BTS
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/MPLANENW-1  parameter=oamTls  operation=update  value=off
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default

Change parameter to disconnect netact with BTS
    [Documentation]    Short description.
    Run keyword and ignore error    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/MPLANENW-1  parameter=oamTls  operation=update  value=forced
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=default

_Get Runtime ID By Infomodel
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${runtime_id}: <description>
    Start Infomodel
    ${result}    Run Keyword And Return Status
    ...  ute_admin_infomodel.Query Infomodel    /MRBTS-1/RAT-1/RUNTIME_VIEW-1    alias=default
    ${result1}    Run Keyword And Return Status
    ...  ute_admin_infomodel.Query Infomodel    /MRBTS-1/RAT-1/RUNTIME_VIEW-4    alias=default
    ${runtime_id}=    Set Variable If    ${result}    1    ${result1}    4
    [Teardown]    Teardown Infomodel
    [Return]    ${runtime_id}

Precondition Netact with TAF And Upload
    [Documentation]    Short description.
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${web_url}=    taf.nms.netact.Detect WEB URL
    taf.nms.netact.Add WEB URL    ${web_url}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    #taf.nms.netact.upload_configuration	PLMN-PLMN/${BTS_INFO.MRBTS}

Precondition Netact with TAF
    [Documentation]    Short description.
    Run keyword and ignore error    Postcondition Netact with TAF
    taf.nms.netact.Add Node    cmwas    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    ${web_url}=    taf.nms.netact.Detect WEB URL
    taf.nms.netact.Add WEB URL    ${web_url}    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}

Postcondition Netact with TAF
    [Documentation]    Short description.
    taf.nms.netact.Delete Node    cmwas
    taf.nms.netact.Clean All

_import sw to netact
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
	[Arguments]    ${sw_release}
    Run keyword and ignore error    Postcondition Netact with TAF
    Precondition Netact with TAF
    ${build_path}=    Set Variable    /d/oss/global/swmanager/swm_temp/${sw_release}.zip
    ${status}    taf.nms.netact.Is Imported    ${sw_release}
    Run Keyword If    '${status}'=='False'   taf.nms.netact.Import Build    ${build_path}
    Wait until keyword Succeeds    30 min    10 sec    Check_Import_Status    ${sw_release}    "True"
    Log    Success Imported!    console=true
    [Teardown]    Postcondition Netact with TAF

Check_Import_Status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${software}: <description>
    ...        ${Boolean}: <description>
    [Arguments]    ${software}   ${Boolean}
    ${status}=     taf.nms.netact.Is Imported    ${software}
    ${are_we_there_yet}=    Evaluate    "${status}" == ${Boolean}
    Should Be True    ${are_we_there_yet}

NR_Switch_Open
    [Documentation]    Short description.
    ${SCF_NR}    set variable    ${True}
    set test variable    ${SCF_NR}

_Perform Delta Commission By Admin
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${delta_file}: <description>
    ...        ${timeout}: <description>
    [Arguments]    ${delta_file}    ${timeout}=800s
    Wait Until Keyword Succeeds    ${timeout}    10    taf.sbts.oam.coam.admin.Perform Delta Recommissioning    ${delta_file}
    ...  skip_parameter_relation_errors=${True}    timeout=${timeout}
    ...    alias=default

Check build in Netact otherwise Import
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Build_Full_path}: <description>
    ...        ${Build_Version}: <description>
    ...        ${release_NUM}: <description>
    [Arguments]  ${Build_Full_path}    ${Build_Version}    ${release_NUM}
    Log    ${release_NUM}
    Log    ${Build_Version}
    ${sw_release_changed}    Run keyword if    '9999'in '${Build_Version}'
    ...  Replace String    ${Build_Version}    SBTS00    ${release_NUM}
    ...    ELSE    set variable    ${Build_Version}
    set test variable  ${sw_release_changed}
    ${status}  ${msg}=  Run keyword and ignore error  Check Target SW is imported by netact  ${sw_release_changed}
    Log    ${release_NUM}

    Run keyword if  '${status}'=='FAIL'
    ...  Run Keywords
        ...  Put_buid_from_local_to_netact    ${Build_Full_path}    ${Build_Version}    ${sw_release_changed}
        ...  AND  import sw to netact    ${sw_release_changed}

Check Target SW is imported by netact
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    [Arguments]  ${sw_release}
    Precondition Netact with TAF
    ${sw_list}=  get_list_of_imported_builds
    list should contain value  ${sw_list}  ${sw_release}
    [Teardown]    Postcondition Netact with TAF

Put_buid_from_local_to_netact
    [Arguments]    ${local_path}    ${sw_release}	${sw_release_changed}
    [Documentation]    [Documentation] \ \ \ | Time | Release | Author | Modification | Relevant feature |
    ...    ... | 20200730 | SRAN21A | li yanan | New KW | put build from local to netact \ |
    ...
    ...    ... \ This KW is about put build from local to netact
    ...
    ...    ... parameter1: local_path (string) ?
    ...          e.g. /home/ute/SBTS00_ENB_9999_200727_000001__release_BTSSM_downloadable_A54.zip
    ...    ... parameter2: ${sw_release}(string) ? e.g. \ SBTS00_ENB_9999_200727_000001
    ...    ... Parameter3: ${sw_release_changed} -e.g. \ SBTS22R1_ENB_9999_200727_000001
    ${sw_release_match}  Fetch from right  ${sw_release}  S
    ${netact_connection}    Connect To Netact
    set test variable    ${netact_connection}
    SSHLibrary.Switch Connection    ${netact_connection}
    SSHLibrary.Write    cd /d/oss/global/swmanager/swm_temp/
    sleep  2s
    SSHLibrary.Write  du -h *${sw_release_match}*
    ${output}  SSHLibrary.Read  delay=4s
    @{info}  split string  ${output}  \t
    ${size}  Fetch from left  ${info[0]}  G
    ${status_include1}  ${msg1}=  Run keyword and ignore error   Evaluate   ${size}>8
#    ${status_include1}  ${msg1}=  Run keyword and ignore error  should contain  ${output_release}  ${sw_release_match}
    Run keyword if  '${status_include1}' == 'FAIL'
    ...  Upload build to NA Temp  ${local_path}  ${sw_release}  ${sw_release_changed}
#    ...  Run Keywords
#        ...  Install Library In Loacal PC  ta-kiss-files
#        ...  AND  import Library    ta_kiss_files
#        ...  AND  Upload build to NA Temp  ${local_path}  ${sw_release}  ${sw_release_changed}
    Log    ${sw_release_changed}
    Run keyword if  '${status_include1}' == 'PASS'
    ...  Run Keywords
        ...  SSHLibrary.Switch Connection    ${netact_connection}
        ...  AND  SSHLibrary.Write    mv ${sw_release}_release_BTSSM_downloadable_A54.zip ${sw_release_changed}.zip
        ...  AND  set test variable    ${sw_release_changed}

Upload build to NA Temp
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${local_path}: <description>
    ...        ${sw_release}: <description>
    ...        ${sw_release_changed}: <description>
    [Arguments]  ${local_path}  ${sw_release}  ${sw_release_changed}
    sftp upload    ${NETACT_SERVER_INFO.IP}    ${NETACT_SERVER_INFO.PORT}    ${NETACT_SERVER_INFO.USERNAME}
    ...  ${NETACT_SERVER_INFO.PASSWORD}    ${local_path}    /d/oss/global/swmanager/swm_temp/
#    sftp upload    10.41.146.105    22    omc   Medsql!_1893     ${local_path}    /d/oss/global/swmanager/swm_temp/
    ${netact_connection2}   Connect to Netact
    set test variable    ${netact_connection2}
    SSHLibrary.Switch Connection    ${netact_connection2}
    sleep  30s
    SSHLibrary.Write    cd /d/oss/global/swmanager/swm_temp/
    sleep  1s
    SSHLibrary.Write   ls | grep ${sw_release}
    ${result}    SSHLibrary.Read    delay=2s
    should contain    ${result}    ${sw_release}
    SSHLibrary.Write    mv ${sw_release}_release_BTSSM_downloadable_A54.zip ${sw_release_changed}.zip
    SSHLibrary.Write    find . -type f -size +300M
    set test variable    ${sw_release_changed}

Install Library In Loacal PC
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${lib_name}: <description>
    [Arguments]  ${lib_name}
    ${PC_connection}    SSHLibrary.Open Connection    ${BTS_PC_INFO.IP}
    SSHLibrary.Login with public key    ${BTS_PC_INFO.USERNAME}    /home/${BTS_PC_INFO.USERNAME}/.ssh/id_rsa
    SSHLibrary.Switch Connection    ${PC_connection}
    ${cmd_query}    set variable    pip list|grep ${lib_name}
    SSHLibrary.Write    ${cmd_query}
    ${output_query}=  SSHLibrary.Read  delay=30s
    ${contain}  ${message}=  Run Keyword And Ignore Error   Should Contain   ${output_query}  ${lib_name}
    Run keyword if    '${contain}'=='FAIL'
    ...  Run keywords
        ...  SSHLibrary.write  pip install ${lib_name}
        ...  AND  SSHLibrary.Read    delay=1min

NetAct Create Plan And Objects
    [Arguments]    ${name}    ${description}    ${mo_id}
    [Documentation]    Helper keyword used for create new plan and parameter edit
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | name | Yes | Plan Name |
    ...    | description | Yes | Plan description |
    ...    | mo_id | Yes | MO distName |
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | parameters_dict | Yes | parameters_dict (dictionary format - key:value) |
    ${status}    ${plan}=    Run Keyword And Ignore Error    taf.nms.netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    ${name}    ${description}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...  meta_version=${MO_items['version']}    mo_id=${mo_id}    &{parameters_dict}
    [Return]    ${plan}

NetAct Create Plan
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${name}: <description>
    ...        ${description}: <description>
    ...
    ...    Returns:
    ...        ${plan}: <description>
    [Arguments]    ${name}    ${description}
    ${plan }=    Create Plan Configuration    ${name}    ${description}
    ${status}=    Run Keyword And Return Status    taf.nms.netact.Get Plan Configuration    ${name}
    Run Keyword If    ${status}    Log    Plan successfully created: ${plan}    console=True
    ...    ELSE    Run Keywords    Log    Plan creation failed!    level=ERROR
    ...    AND    Fail    Plan creation failed!
    [Return]    ${plan}

NetAct Create And Edit Plan
    [Arguments]    ${name}    ${description}    ${mo_id}    ${scf_distName}    &{parameters_dict}
    [Documentation]    Helper keyword used for create new plan and parameter edit
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | name | Yes | Plan Name |
    ...    | description | Yes | Plan description |
    ...    | mo_id | Yes | MO distName |
    ...    | scf_distName | Yes | SCF distName of MO for given parameter |
    ...    | parameters_dict | Yes | parameters_dict (dictionary format - key:value) |
    ${status}    ${plan}=    Run Keyword And Ignore Error    taf.nms.netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    ${name}    ${description}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${scf_distName}"]
    NetAct Create Managed Object    plan=${plan}
    ...  meta_class=${MO_items['class']}    meta_version=${MO_items['version']}    mo_id=${mo_id}    &{parameters_dict}
    [Return]    ${plan}

NetAct Create Managed Object
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${plan}: <description>
    ...        ${meta_class}: <description>
    ...        ${meta_version}: <description>
    ...        ${mo_id}: <description>
    ...        &{parameters_dict}: <description>
    [Arguments]    ${plan}    ${meta_class}    ${meta_version}    ${mo_id}    &{parameters_dict}
    ${managed_object}=    Create Managed Object    plan=${plan}    meta_class=${meta_class}
    ...  meta_version=${meta_version}    mo_id=${mo_id}    &{parameters_dict}
    ${status}=    Run Keyword And Return Status    taf.nms.netact.Get Managed Object    configuration=${plan}    mo_id=${mo_id}
    Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${managed_object}    console=True
    ...    AND    Log    Parameters were set with plan ${plan}    console=True
    ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
    ...    AND    Fail    MO creation failed!

NetAct Delete Plan
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${name}: <description>
    ...        ${plan}: <description>
    [Arguments]    ${name}    ${plan}
   taf.nms.netact.Delete Plan    ${name}
    ${status}=    Run Keyword And Return Status    taf.nms.netact.Get Plan Configuration    ${name}
    Run Keyword If    ${status}    Run Keywords    Log    Plan deletion failed!    level=ERROR
    ...    AND    Fail    Plan deletion failed!
    ...    ELSE    Log    Plan successfully deleted: ${plan}    console=True

NetAct Check Actual Configuration Parameters
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${dist_name}: <description>
    ...        ${ui_values}: <description>
    ...        &{parameter_dict}: <description>
    [Arguments]    ${dist_name}    ${ui_values}=false    &{parameter_dict}
    ${status}=    Run Keyword And Return Status
    ...  Check Actual Configuration Parameters    dist_name=${dist_name}    ui_values=${ui_values}    &{parameter_dict}
    Run Keyword If    ${status}
    ...  Log    For ${dist_name}, parameters config has expected values in actual configuration!    console=True
    ...    ELSE    Run Keywords
    ...  Log    For ${dist_name}, parameters config has not expected values in actual configuration!    level=ERROR
    ...    AND    Fail    For ${dist_name}, parameters config has not expected values in actual configuration!

NetAct Export Plan
    [Arguments]    ${local_dir}    ${file_name}    ${dist_names}    ${plan_name}    ${operation_type}=plan
    [Documentation]    Helper keyword used for export plan from NetAct to local_dir/file_name place
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    *INPUT*
    ...    | Parameter | Mandatory | Description |
    ...    | local_dir | Yes | Path to local directory where NetAct plan should be stored |
    ...    | file_name | Yes | File name for local stored plan |
    ...    | dist_names | Yes | MO distName |
    ...    | plan_name | Yes | Name of plan on NetAct |
    ...    | operation_type | No | Specifies the type of the export operation
    ...                  (plan/actual/reference/template/siteTemplate |
    ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_dir}
    Run keyword if    not ${status}    Create Directory    ${local_dir}
    ${status}=    Run Keyword And Return Status    taf.nms.netact.Export Configuration    local_dir=${local_dir}
    ...  file_name=${file_name}    operation_type=${operation_type}    dist_names=${dist_names}
    ...    plan_name=${plan_name}
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    Run Keyword If    ${status}
    ...  Log    Plan ${plan_name} available at ${local_dir}/${file_name}    level=INFO    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} not available at ${local_dir}/${file_name}    level=ERROR
    ...    AND    Fail    Plan ${plan_name} not available at ${local_dir}/${file_name}

Connect To Netact_bySSHLIB
    [Documentation]    | Time | Release | Author | Modification | Relevant feature |
    ...    | 20210730 | SRAN21A | li yanan | New KW | This keyword used to connect to Netact|
    ...    return ${netact_connection}
    ...    example 1
    ...    |Connect To Netact |
    ...    example 2
    ...    |Connect To Netact |
    ...    | Switch Host Connection | ${netact_connection} |
    ${netact_connection}=    SSHLibrary.Open Connection    ${NETACT_SERVER_INFO.IP}  timeout=7200s
    SSHLibrary.Login    ${NETACT_SERVER_INFO.USERNAME}    ${NETACT_SERVER_INFO.PASSWORD}
    Set Suite Variable    ${netact_connection}
    [Return]    ${netact_connection}

Upload SCF To NetAct
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${path}: <description>
    ...        ${file}: <description>
	[Arguments]		${path}		${file}
    taf.nms.netact.Upload Configuration    PLMN-PLMN/MRBTS-${BTS_INFO.ID}
	${year}  ${month}  ${day}  ${hour}  ${min}	${sec}=  Get Time  format=year,month,day,hour,min,sec
    ${timestamp}=  Set Variable  ${year}-${month}-${day}_${hour}-${min}-${sec}
    Set Test Variable  ${timestamp}
	${file_name}	Set Variable	${timestamp}_${file}
	Set Test Variable  ${file_name}
	SSHLibrary.open connection		${NETACT_SERVER_INFO.IP}	alias=netact    timeout=10s
    SSHLibrary.login				${NETACT_SERVER_INFO.USERNAME}		${NETACT_SERVER_INFO.PASSWORD}
	SSHLibrary.Put File				${path}/${file}		/var/opt/oss/global/racops/import/${file_name}

Operation_KPI_Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${end_time}: <description>
    ...        ${start_time}: <description>
    ...        ${expeted_KPI}: <description>
    ...        ${operation_description}: <description>
    ...
    ...    Returns:
    ...        ${compare_result}: <description>
    [Arguments]  ${end_time}  ${start_time}  ${expeted_KPI}  ${operation_description}
    ${timedelta}  Subtract Date From Date   ${end_time}  ${start_time}
    Log   Software ${operation_description}: ${timedelta}
    ${compare_result}  Evaluate    ${timedelta}<=${expeted_KPI}
    set tags for KPI    ${operation_description}    ${timedelta}
    Run keyword if    '${compare_result}'=='True'    Log    ${operation_description}: ${timedelta} is as expected.
    ...  ELSE   FAIL   ${operation_description} actually exceed the expected time:${expeted_KPI}s.
    [Return]  ${compare_result}

Get_HW_Type
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${HW_TYPE}: <description>
    ${SMOD1_HW}    Get From Dictionary    ${SMOD1}    HW_TYPE
    set test variable    ${SMOD1_HW}
    ${status}    Run keyword and return status    Variable should exist    ${SMOD2}
    ${SMOD2_HW}    Run keyword if    '${status}'=='True'    Get From Dictionary    ${SMOD2}    HW_TYPE
    ${Combine_TYPE}    Run keyword if    '${status}'=='True'    Catenate    SEPARATOR=_    ${SMOD1_HW}    ${SMOD2_HW}
    ${HW_TYPE}    set variable if    '${status}'=='True'    ${Combine_TYPE}    ${SMOD1_HW}
    [Return]  ${HW_TYPE}

set tags for KPI
    [Documentation]
    ...  KPI will be visible in log file, in tag section.
    ...
    ...  | Parameter            | Man. | Description        |
    ...  | operation_type       | Yes  | Operation type     |
    ...  | active_sw_version    | Yes  | Active software    |
    ...  | passive_sw_version   | Yes  | Passive software   |
    ...     *AUTHOR*   amaand.li@nokia-sbell.com
    [Arguments]  ${operation_type}  ${actual_time}
    Set tags  ${operation_type}_${actual_time}s

Get_QCID
    [Documentation]    This kw is used to get QCID from tags
    ...    Author: amaand.li
    ...    Contact: amaand.li@nokia-sbell.com
    ...    | Return Value | Description |
    ...    |QC_ID|
    FOR  ${tag}  IN  @{TEST TAGS}
        ${tag_str}=  Convert To String  ${tag}
        Run keyword and ignore error   Run keyword if  'QC_' in '${tag_str}'
        ...  set test variable  ${QC_ID}  ${tag}
    END

prepare lower build on SBTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    ...        ${target_path}: <description>
    [Arguments]    ${sw_release}=24R2    ${target_path}=/home/ute/btsauto/
    ${N_1_pkg_list}   Get Enb     SBTS${sw_release}
    ${N_1_pkg_num}    set variable  ${N_1_pkg_list[1]}
    ${fullpath}  Download_Specify_Build_By_Aria   enb_build=${N_1_pkg_num}  Package_type=Basic  target_path=${target_path}
    prepare pre release build on SBTS    release=${sw_release}   pkg_full_path=${fullpath}

prepare pre release build on SBTS
    [Documentation]    KW used to back to FDSW, then upgrade to low release for prepare BTS ENV.
    ...    Author: amaand.li
    ...    Contact: amaand.li@nokia-sbell.com
    ...    | Input Parameters | Opti. | Description |
    ...    | release | yes | The release you want to prepare on BTS |
    ...    | pkg_full_path | yes | absolute or relative path to software package(zip) that will be uploaded |
    ...    Example
    ...    | prepare pre release build on SBTS  | 23R3 |
    ...    | /home/ute/SBTS23R3_ENB_0000_000381_000000_release_BTSSM_downloadable_A54.zip |
    ...
    [Arguments]  ${release}=24R2
    ...    ${pkg_full_path}=/home/ute/btsauto/SBTS24R2_ENB_0000_000204_000000_release_BTSSM_downloadable_A54.zip
    ...     ${ip_addr}=192.168.255.129
    Change parameter to disconnect netact with BTS
    run keyword and ignore error    taf.sbts.oam.coam.admin.Reset Configuration
    ...    remove_operator_certificates=False
    ...    remove_user_account_credentials=False
    ...    alias=default    timeout=800    reset_type=ConfigurationWithDiagnosticAndRecoverySw
    sleep    9min
    Software update from FDSW    sw_pkg_path=${pkg_full_path}     ip_addr=${ip_addr}
    Run keyword and ignore error    taf.sbts.oam.coam.admin.Teardown Admin
    Run keyword and ignore error    Teardown Infomodel
    Run Keyword And Continue On Failure  Start Admin    bts_host=${ip_addr}
    Run Keyword And Continue On Failure    Start Infomodel     bts_host=${ip_addr}
    Run Keyword If    '${ip_addr}' == '192.168.255.129'    Import Configuration by release  sw_release=${release}
    ...    ELSE      Import Configuration by release for remote BTS    ${local_scf_storage}     sw_release=${release}
    wait until keyword Succeeds  5min  30s  Change parameter to disconnect netact with BTS
    Fault23 check and update software to Onair    ${pkg_full_path}

Software update from FDSW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_pkg_path}: <description>
    ...        ${ip_addr}: <description>
    [Arguments]    ${sw_pkg_path}=123     ${ip_addr}=192.168.255.129
    Wait Until Keyword Succeeds  10 min  5 sec    Connect and authorize To FDSW     ip_address=${ip_addr}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    1min    fdsw.enable_ethernet_port_security
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    1min    fdsw.enable_ssh_service
    ${dic_inventory}    fdsw.get_all_software_inventory
    set test variable    ${list_inventory}    ${dic_inventory['slots']}
    ${sw_slot_id}     Choose slot id    ${list_inventory}
    fdsw_update_software  sw_pkg_path=${sw_pkg_path}   sw_slot_id=${sw_slot_id}   ip_address=${ip_addr}
    [Teardown]    Run keyword and ignore error    Teardown FDSW

Import Configuration by release for remote BTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${local_scf_storage}: <description>
    ...        ${sw_release}: <description>
    [Arguments]   ${local_scf_storage}   ${sw_release}=23R3
    Log    ${sw_release}
    Log    ${CURDIR}
    ${commission_path}  Modify scf in local
    ...  ${local_scf_storage}
    wait until keyword Succeeds  10min  30s  _Perform Full Commision By Admin
    ...  scfc=${commission_path}  BTS_INFO.ID=${BTS_INFO.ID}

Import Configuration by release
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_release}: <description>
    [Arguments]   ${sw_release}=23R3
    ${commission_path}  Modify scf in local
    ...  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/BTS_${tl.tl_cloud_topology}_SBTS${sw_release}.xml
    wait until keyword Succeeds  10min  30s  _Perform Full Commision By Admin
    ...  scfc=${commission_path}  BTS_INFO.ID=${BTS_INFO.ID}

Modify scf in local
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${scf_full_path}: <description>
    ...
    ...    Returns:
    ...        ${BTS Files}/pre_scf.xml: <description>
    [Arguments]    ${scf_full_path}
    ${scf_con}    OperatingSystem.Get File    ${scf_full_path}
    ${scf_con_changed}    Replace String Using Regexp
    ...    ${scf_con}    <p name="oamTls">off</p>    <p name="oamTls">forced</p>
    Create File    ${BTS Files}/pre_scf.xml    ${scf_con_changed}
    [return]    ${BTS Files}/pre_scf.xml

Fault23 check and update software to Onair
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_pkg_path}: <description>
    [Arguments]   ${sw_pkg_path}=123
    taf.sbts.oam.coam.admin.wait_sw_update_possible    readiness_timeout=2400    timeout=1500
    Critical Fault 23 Verification on ESM
    sleep    2min
    Run keyword if    ${is_fault_active_ESM}
    ...    Wait Until Keyword Succeeds    90min    5min    sw update     ${sw_pkg_path}
    Run keyword if    ${is_fault_active_ESM}  Reset admin and infomodel connection if broken
    Reset admin and infomodel connection if broken
    No Fault 23 on SBTS by multi upgrade    sw_pkg_path=${sw_pkg_path}
    wait until keyword Succeeds     5min     30s
    ...    Change parameter to connect netact with BTS

No Fault 23 on SBTS by multi upgrade
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_pkg_path}: <description>
    [Arguments]    ${sw_pkg_path}=123
    ute_admin_infomodel.reset_infomodel
    FOR   ${run}  IN RANGE  1  10
      ${all_cell_status}  ${cell_state_table}  Infomodel Check If All Objects From Path Are Online  ${dist_cells}
      Run keyword if    ${all_cell_status}==${True}  exit for loop
      ${is_fault_active_RMOD}=    Run keyword if    ${all_cell_status}==${False}
      ...    Check If Fault 23 present on module    mo=RMOD_R
      ${sta}    taf.sbts.oam.coam.admin.Wait Sw Update Possible    readiness_timeout=2400  timeout=3000
      ${update_avaliable}   set variable if   'succeed' in '${sta}'   ${TRUE}   ${FALSE}
      Run keyword if    '${is_fault_active_RMOD}'=='True' and ${update_avaliable}
      ...    Run keywords   wait until keyword Succeeds     15min     30s     sw update  ${sw_pkg_path}
      ...    AND    sleep    480s
    END
    Log   Fault 23 cleared by multi upgrade.    console=${TRUE}

Choose slot id
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${list_inventory}: <description>
    ...
    ...    Returns:
    ...        ${slot_id}: <description>
    [Arguments]    ${list_inventory}
    FOR    ${item}    IN    @{list_inventory}
    ${slot_id}    Run keyword and return if    '${item['mode']}'=='Active'
    ...    set variable    ${item['id']}
    END
    [Return]    ${slot_id}

fdsw_update_software
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_pkg_path}: <description>
    ...        ${sw_slot_id}: <description>
    ...        ${ip_address}: <description>
    ...        ${alias}: <description>
    [Arguments]  ${sw_pkg_path}=123    ${sw_slot_id}=1     ${ip_address}=192.168.255.129    ${alias}=default
    fdsw.software_update   sw_slot_id=${sw_slot_id}     sw_pkg_path=${sw_pkg_path}
    ...  timeout=4000  activate=True  connection=${alias}
    ${ping loss status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${ip_address}  timeout=${Ping loss timeout}
    Run keyword if  ${ping loss status}==${FALSE}
    ...   Log    BTS RESET after successful sw update DID NOT OCCUR   console=${TRUE}
    ...   ELSE
    ...   Log    BTS is resetting after successful sw update          console=${TRUE}
    ${ping regain status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${ip_address}  timeout=1000
    Run keyword if  ${ping regain status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ${ping stable status}  Run keyword and return status
    ...  Check If Target Is Stable  ${ip_address}  min_uptime=60  max_downtime=0  timeout=61

Critical Fault 23 Verification on ESM
    [Documentation]    Wait for fault 23 report on secondary core. return from kw if it's single core
    ${objs}=    taf.sbts.oam.coam.admin.get_managed_objects    SMOD_A
    ${SMOD_count}=    Get Length    ${objs}
    Set test variable    ${is_fault_active_ESM}    ${FALSE}
    Return From Keyword If    ${SMOD_count}==1
    Log step header  Fault 23 for ESM verification
    sleep    5min
    FOR  ${run}  IN RANGE  1  30
        ${is_fault_active_ESM}=  Check If Fault 23 present on module    mo=SMOD_R
        Run keyword if    '${is_fault_active_ESM}'=='True'    exit for loop
    END
    Set test variable  ${is_fault_active_ESM}
    Log  Fault 23 For esm active: ${is_fault_active_ESM}  console=${TRUE}

Check If Fault 23 present on module
    [Arguments]    ${mo}=SMOD_R
    [Documentation]  If active alarm exist and is Major return True otherwise return False
    @{active_alarms} =  taf.sbts.oam.coam.admin.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        sleep   10
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=yes
        ${is_notifier}=  run keyword and return status  should contain  ${alarm.notifier}  ${mo}
        Run Keyword If  '${alarm.faultId}'=='23' and '${alarm.severity}'=='Critical' and ${is_notifier}
        ...  Return From Keyword  ${TRUE}
    END
    Log  Out of loop false  console=yes
    [Return]  ${FALSE}

Connect and authorize To FDSW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ip_address}: <description>
    ...        ${port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${fdsw_version}: <description>
    ...        ${auto_discover}: <description>
    ...        ${secure}: <description>
    ...        ${name}: <description>
    [Arguments]  ${ip_address}=192.168.255.129
           ...   ${port}=443
           ...   ${username}=Nemuadmin
           ...   ${password}=nemuuser
           ...   ${fdsw_version}=fdsw21c
           ...   ${auto_discover}=True
           ...   ${secure}=True
           ...   ${name}=default
    Log    ${fdsw_version}
    fdsw.connect to    ip_address=${ip_address}   port=${port}    username=${username}    password=${password}
    ...    auto_discover=${auto_discover}    secure=${secure}    name=${name}

Teardown FDSW
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${alias}: <description>
    [Arguments]  ${alias}=default
    fdsw.teardown  connection=${alias}
