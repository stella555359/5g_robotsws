*** Settings ***
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pdu.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  cli
Library     SSHLibrary

*** Variables ***

*** Keywords ***
CB007010_suite_setup
    Prepare TL
    ADMIN CLI connection
    Turn ON Pano and check if is connected
    ${bts_id}    bts_states.Get BTS ID
    Set Test Variable    ${BTS_ID}    ${bts_id}
    ADMIN Collect Scf
    SCF Get Mrbts Plane Ip Address
    Prepare Json IPv4
    Connect BTS to ONAP
    Remove JSON delta file

CB007010_suite_teardown
    Log    CB007010_suite_teardown    console=${True}
    Remove ONAP from SCF
    Close Connections

CB007010_test_teardown
    Turn OFF Pano and check if is disconnected

CB007010_test_setup
    Log    CB007010_test_setup    console=${True}
    Remove Files    PM*.xml
    Remove Files    PM*.gz

Prepare TL
    Log    WARNING: Please check if in WebEM:\n1) Ethernet port security status: Disabled;    console=${True}
    Log    2) R&D service port status: Enabled;    console=${True}
    Log    3) Service account SSH status: Enabled    console=${True}
    Log    Starting preparing TL for CB007010    console=${True}
    ${TL_state}    Set variable   ${False}
    Log    Creating connection via adminCLI    console=${True}
    Create connection via adminCLI

Get IPIF interface
    ${ipif_object}  Query Infomodel  get object //IPIF_A-*/IPADDRESSV4_A-* is [localIpAddr=${MPLANE_IP}]
    ${ipif_ipaddr}  Fetch From Right  ${ipif_object}[dist_name]  IPIF_A-
    ${ipif_ipaddr_nr}  Fetch From Left  ${ipif_ipaddr}    /

    Set Test Variable    ${IPIF_ID}    ${ipif_ipaddr_nr}
    Log     mplane ipif number= ${IPIF_ID}    console=${True}

SFTP download PM and extract
    [Arguments]       ${PM_to_download}
    Get PM by SFTP    ${PM_to_download}
    UNZIP PM on VM    ${PM_to_download}

Get PM by SFTP
    [Arguments]    ${PM_to_download}
    ONAP_keywords.check_sftp_for_pms    ${MPLANE_IP}    ${PM_to_download}

UNZIP PM on VM
    [Arguments]
    ...    ${pm_to_unzip}
    Run    gzip -dk ./${pm_to_unzip}

Wait Until New PM Is Available on BTS
    [Documentation]
    ...    Succeeds if there is a new PM file generated on BTS during 5min interval
    ssh.connect_to    hostname=${hostname}    username=${username}    password=${password}    alias=${ssh_alias}
    ${pm_out}=    ssh.execute    command=${get_current_PMs}   connection=default    timeout=10 s
    ${latest_pm_on_BTS}=    ONAP_keywords.get_pms_bts    ${pm_out}
    Should Not Be Empty   ${latest_pm_on_BTS}
    Set Suite Variable    ${FIRST_PM}    ${latest_pm_on_BTS}
    Wait Until Keyword Succeeds    6min    5sec    Compare last two PMs on BTS

Compare last two PMs on BTS
    Get Latest PM from BTS
    Should Not Be Equal     ${FIRST_PM}    ${LATEST_PM_ON_BTS}

Get Latest PM from BTS
    [Documentation]
    ...    Sets Suite Variable that holds whole name of the latest PM file on BTS:/data/onapusers/measurements
    ${pm_out}=    ssh.execute    command=${get_current_PMs}   connection=default    timeout=10 s
    ${latest_pm_on_BTS}=    ONAP_keywords.get_pms_bts    ${pm_out}
    Should Not Be Empty   ${latest_pm_on_BTS}
    Set Suite Variable    ${LATEST_PM_ON_BTS}    ${latest_pm_on_BTS}

Start Logs collection
    [Arguments]     ${test_level}=${EMPTY}   ${F_sysLog}=${False}
    Log    \n ---- START ${test_level} collecting: sysLog=${F_sysLog} ----    console=${True}
    Run keyword if  ${F_sysLog}==${True}    BTSLOG Start btslog on local machine

Remove ONAP from SCF
    coam.Perform Commissioning  ${BTS_ID}  ${COMMISSIONING_PATH}  skip_parameter_relation_errors=True  timeout=900
    Sleep    120s
    Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check All Modules And All Cells Working States

Close Connections
    ssh.Disconnect    connection=${ssh_alias}

Create connection via adminCLI
    Log    Logs from TL preparation:
    ${connection_established}=    run keyword and return status    wait until keyword succeeds  5 min   30 sec   ADMIN CLI connection
    Log    connection_established: ${connection_established}    console=${True}
    run keyword if    '${connection_established}'=='True'    run keywords    log    Connection via adminCLI is created.
    ...    AND   return from keyword
    set suite variable    ${adminCLI_ready}    False
    Netboot check
    Log    Connection via adminCLI cannot be created. Check and repair actions has been started.
    ${ssh_asix}=    run keyword and return status    Create connection to Asix
    run keyword if    '${ssh_asix}'=='False'    run keywords    log    Connection refused. Start SMOD reset procedure.
    ...    AND    Power reset SMOD during preparation
    run keyword if    '${adminCLI_ready}'=='True'    run keywords   log    Connection via adminCLI is created.    AND
    ...    return from keyword
    run keywords    Check BTS and reboot
    run keyword if    '${adminCLI_ready}'=='True'    log    Connection via adminCLI is created.
    ...  ELSE    log    Conncection via adminCLI cannot be created despite repair actions.

ADMIN CLI connection
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Common keyword to established connection with ADMIN API of tested gNB.
    ...     As arguments it takes:
    ...                            - bts_host - by default is 192.168.255.1
    ...                            - bts_port - by default is 443
    ...                            - username - by default is Nemuadmin
    ...                            - password - by default is nemuuser
    ...                            - connection - by default alias is 'default'
    ...     -----------------------------------------------------------------------------------------
    [Arguments]    ${bts_host}=${gNB_IP_MPLANE_LOCAL}    ${bts_port}=${gNB_MPLANE_IF_PORT}
    ...            ${username}=Nemuadmin  ${password}=nemuuser  ${connection}=default

    ${actual_build}=    Check build version
    cli.connect_to    bts_host=${bts_host}     bts_port=${bts_port}    username=${username}
    ...                     password=${password}     name=${connection}    release=${actual_build}

Turn ON Pano and check if is connected
    Log    \nTurn ON the Pano    console=${True}
    Log    Warning! Before start this test it is recomended:    console=${True}
    Log    the pano.sh script should be disabled on the VM,    console=${True}
    Log    the file pano.log should be removed and pano/pm directory should be empty    console=${True}
    SSHLibrary.Open Connection    ${VM_WITH_PANO_IP}
    SSHLibrary.Login    ${VM_WITH_PANO_USR}    ${VM_WITH_PANO_PASSWD}
    ${msg_pano_start}=    SSHLibrary.Execute Command   cd /home/ute/pano; ./pano.sh start
    Log to console    ${msg_pano_start}    console=${True}
    should contain    ${msg_pano_start}    Pano script is now running in the background.
    Sleep    3s
    ${msg_pano_status}=    SSHLibrary.Execute Command  cd /home/ute/pano/; ./pano.sh status
    Log to console    ${msg_pano_status}    console=${True}
    should contain    ${msg_pano_status}    Pano script is running.

    ${msg_pano_log}=    SSHLibrary.Execute Command    ls /home/ute/pano | grep pano.log
    Log to console    ${msg_pano_log}    console=${True}
    should contain    ${msg_pano_log}    pano.log
    SSHLibrary.Close Connection

Turn OFF Pano and check if is disconnected
    Log    \nTurn OFF the Pano    console=${True}
    Run    sshpass -p "${VM_WITH_PANO_PASSWD}" scp ${VM_WITH_PANO_USR}@${VM_WITH_PANO_IP}:/home/ute/pano/pano.log ${BTS_Files}
    Run    sshpass -p "${VM_WITH_PANO_PASSWD}" scp -r ${VM_WITH_PANO_USR}@${VM_WITH_PANO_IP}:/home/ute/pano/pm/ ${BTS_Files}/

    SSHLibrary.Open Connection    ${VM_WITH_PANO_IP}
    SSHLibrary.Login    ${VM_WITH_PANO_USR}    ${VM_WITH_PANO_PASSWD}
    ${msg_pano_stop}=    SSHLibrary.Execute Command   cd /home/ute/pano; ./pano.sh stop
    Log to console    ${msg_pano_stop}    console=${True}
    should contain    ${msg_pano_stop}    stopped
    Sleep    3s
    ${msg_pano_status}=    SSHLibrary.Execute Command  cd /home/ute/pano/; ./pano.sh status
    Log to console    ${msg_pano_status}    console=${True}
    should contain    ${msg_pano_status}    No running Pano script found.

    SSHLibrary.Execute Command    rm -rf /home/ute/pano/pano.log
    SSHLibrary.Execute Command    rm -rf /home/ute/pano/pm/*.*

    SSHLibrary.Close Connection


ADMIN Collect Scf
    ${scf}=    cli.get_current_scf_file    local_dir_path=${BTS_Files}/
    ...                      file_name=SCF.xml
    ...                      timeout=120
    ...                      connection=${ssh_alias}
    Set Suite Variable    ${OUT_SCF_FILE_PRETEST}    ${scf}

SCF Get Mrbts Plane Ip Address
    ${bts_obj}=    cli.Get Parameters For All  BTS
    ${m_plane_ip}    Convert To String  ${bts_obj[0]['btsMplaneIp4V']}
    Set Test Variable    ${m_plane_ip}    ${MPLANE_IP}
    Log    mplane: ${MPLANE_IP}    console=${True}
    Get IPIF interface

Prepare Json IPv4
    ${base_delta}  set variable  ${TL_REPO_PATH}/deltaIPv4.json
    ${output_delta}  set variable  ${TL_REPO_PATH}/ready_delta.json

    ONAP_keywords.edit_json    ${base_delta}    ${output_delta}   ${BTS_ID}    ${IPIF_ID}    ${VM_WITH_PANO_IP}    ${VES_PORT}

Connect BTS to ONAP
    Log    Connect BTS to ONAP (it cause SBTS reset)   console=${True}
    cli.Perform Delta Recommissioning    delta_file=${TL_REPO_PATH}/ready_delta.json  skip_parameter_relation_errors=${True}
    Sleep    90s
    Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check All Modules And All Cells Working States
    Remove JSON delta file

Remove JSON delta file
    Remove File    ${TL_REPO_PATH}/ready_delta.json

Netboot check
    run    sudo systmectl stop dnsmasq

Power reset SMOD during preparation
    Log    Power reset SMOD during preparation    console=yes
    ${interfaces}  bts_states.Get Modules For Interfaces
    FOR  ${module_distname}  IN  @{interfaces}
      ${match}  run keyword and ignore error  should contain  ${module_distname}  SMOD_
      run keyword if  '${match[0]}'=='PASS'  run keywords
      ...  pdu.Pdu BTS Interface Off  ${module_distname}
      ...  AND  log    power on pdu interface ${module_distname} is turned OFF    console=yes
      ...  AND  sleep  1s
      ...  AND  pdu.Pdu BTS Interface On  ${module_distname}
      ...  AND  log    power on pdu interface ${module_distname} is turned ON    console=yes
    END
    ${RESET_DATE}  DateTime.get current date  time_zone=UTC
    set test variable  ${RESET_DATE}
    Log    Wait for restore ping to BTS    console=yes
    Sleep  180s
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    Log    All modules reached working state    console=yes
    bts_states.Check Active Alarms

Create connection to Asix
    ${129_ready}=    run keyword and return status    trs_ssh.Connect To
    ...    hostname=192.168.255.129
    ...    username=${username}
    ...    password=${password}
    ...    alias=asik
    run keyword if    '${129_ready}'=='False'    trs_ssh.Connect To
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=asik

Set Gude PDU power off RU
    [Arguments]    ${model}    ${host}    ${version}   ${port}
    pdu.setup_pdu       model=${model}    host=${host}    version=${version}    alias=pdu
    pdu.power_off    port=${port}    pdu_device=pdu

Check build version
    Connect Ssh To Asix
    ${hash_build}=    ssh.execute    ls /ffs/run | grep HashContainerSignature.*.p7   connection=asik
    ${hash_build}=    remove string    ${hash_build}    HashContainerSignature_
    ${hash_build}=    fetch from left    ${hash_build}    _
    [Teardown]    Disconnect Ssh From Asix
    [Return]    ${hash_build}

Disconnect Ssh From Asix
    [Documentation]
    ...  Break connection with ASIx via SSH
    [Arguments]    ${connection}=asik
    trs_ssh.Disconnect      connection=${connection}

Connect Ssh To Asix
    [Documentation]
    ...  Establish connection with ASIx via SSH
    [Arguments]    ${connection}=asik
    trs_ssh.Connect To
    ...    hostname=192.168.255.129
    ...    username=${username}
    ...    password=${password}
    ...    alias=${connection}

Check BTS and reboot
    ${active_partition}=    ssh.execute    ls /ffs/run   connection=asik
    ${valid_partition}=    run keyword and return status    Check partition    ${active_partition}
    run keyword if    '${valid_partition}'=='False'    run keywords   log    Files are missing on active partition    AND    FAIL
    ssh.Send Command     /sbin/reboot    connection=asik
    ${adminCLI_2_try}=    run keyword and return status    wait until keyword succeeds  5 min   30 sec   ADMIN CLI connection
    run keyword if    '${adminCLI_2_try}'=='True'    set suite variable    ${adminCLI_ready}    True

Check partition
    [Arguments]    ${to_check}
    should contain X times    ${to_check}    HashContainer    6
    should contain X times    ${to_check}    TargetBD    2
