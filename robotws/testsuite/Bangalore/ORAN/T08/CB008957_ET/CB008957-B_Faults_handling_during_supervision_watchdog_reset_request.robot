*** Settings ***
Documentation
...   author: Kancham Reddy Madhuri Reddy
...   contact: kancham.reddy_madhuri_reddy@nokia.com
...   Description: CB008957 BOAM ET TC

Library    OperatingSystem
Library    String
Library    SSHLibrary    WITH NAME    ssh
Library    Collections
Library    DateTime
Library    BuiltIn
Library    SeleniumLibrary
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.transport.ssh
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    classical
Library    taf.analyzer.netconf    WITH NAME    yang
Library    taf.selenium.sbts    WITH NAME    selenium
Library    taf.selenium.sbts    WITH NAME    soam
Library    taf.sw.ping    WITH NAME    ping

#Resource	../../SG09/resources/robot/configuration_id.robot

Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${oran_alias}=                          oran_sim
${DOCKER_NAME}=                         orusim3
${RPC_CMD}=                             user-rpc --content /opt/UE_APP_OAM/service/oran/xml/supervision-watchdog-reset.xml\r\n
${ORU_SIM_IP}=                          10.53.188.150
${VM_IP}				10.53.188.144
${WebEM IP}                             https://192.168.255.1:3600
${oran_version}=				5
@{mplane_ip}            10.53.188.248
@{ALLOWED_ALARMS}    &{FAULT_61524}    &{FAULT_4654}    &{FAULT_4655}
...                  &{FAULT_61649}    &{FAULT_4176}    &{FAULT_4720}
&{FAULT_4654}              fault_id=4654
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Ethernet port security is disabled"
...                        notifier=
&{FAULT_61524}             fault_id=61524
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="SSH enabled"
...                        notifier=
&{FAULT_4655}              fault_id=4655
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Service account root access is enabled"
...                        notifier=
&{FAULT_4176}              fault_id=4176
...                        alarm_id=7240
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="SFP Error"
...                        notifier=
&{FAULT_4720}              fault_id=4720
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Mismatch of RU reported capabilities with static HW Validation information"
...                        notifier=
&{FAULT_61649}             fault_id=61649
...                        alarm_id=7220
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name=regex"LMP access via port \\d+"
...                        notifier=
&{10}                      fault_id=10
...                        alarm_id=7116
...                        alarm_severity=regex"Critical"
...                        fault_name="No connection to unit"
...                        alarm_resource=

*** Test Cases ***
CB008957-B_Faults handling during supervision watchdog reset request
	[Tags]    QC_31539    QCD_MN_RAN    QCP_RAN_VRF
	Step1: Send command to docker shell
	Step2: Send command by Netopeer Cli
	Step3: Check for fault id 10 and restart ORU
#	[Teardown]		Run Keyword And Ignore Error     Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Test Preconditions
    Log To Console    \nconnecting to BTS
    CoamAdmin.Teardown All Aliases For Admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console   \n BTS is Connected
    Wait Until Keyword Succeeds    2m    10s    Check BTS is OnAir
    ${opt}    set variable    ${OUTPUT_DIR}/BOAM_ET/
    set test variable    ${opt}
    create directory     ${opt}
    Start Syslogs

Start Syslogs
    Log to console   \n--Starting Syslogs--
    Run     killall btslog
    ${executor_test_vm}=  Create Dictionary
    ...  host=${VM_IP}
    ...  user=ute
    ...  password=BT5l@bus3rl0g1n
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   executor=${executor_test_vm}
    ...   log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias	btslog
    core.start_collectors      names=btslog

Step1: Send command to docker shell
    [Arguments]		${docker_name}=${DOCKER_NAME}
	Log to Console    \n--Connecting Docker--
    Create SSH Session To Docker
    ssh.write    sudo docker exec -it ${docker_name} /bin/bash
    ssh.Read Until         root@
    Log to Console    \n--Docker connection successful--

Create SSH Session To Docker
    [Arguments]    ${oran_sim_host_ip}=${ORU_SIM_IP}	${alias}=${oran_alias}
    ${oran_sim_host}    Set Variable     ${oran_sim_host_ip}
    Set Global Variable     ${oran_sim_host}
    ssh.Open Connection
    ...   host=${oran_sim_host}
    ...   alias=${alias}
    ...   timeout=180
    ssh.Login
    ...   username=ute
    ...   password=BT5l@bus3rl0g1n
    ssh.Write    sudo su
    ssh.Read Until    root@
    ssh.Set Client Configuration        timeout=60
    ssh.Switch Connection     ${oran_alias}

Clear SSH Session To Docker
    [Arguments]    ${alias}=${oran_alias}
    Run Keyword and Ignore Error    ssh.Switch Connection    ${alias}
    Run Keyword and Ignore Error    ssh.Close Connection

Step2: Send command by Netopeer Cli
    Log To Console    \n--Sending command by Netopeer Cli--
    ssh.write   netopeer2-cli
    ssh.Read Until    >
    Log to Console    \n--Connecting Netopeer Cli--
    ssh.write   connect --ssh --login netconf --host 127.0.0.1 --port 830\r\n
    ssh.Read Until     netconf@127.0.0.1 password:
    ssh.write          netconf
    Log to Console    \n--Netopeer Cli connection successful--
    ssh.Read Until    >
    ssh.write   ${RPC_CMD}
    Log to Console    \n--Watchdog reset file sent successfully--

Step3: Check for fault id 10 and restart ORU
	Log To Console    \n--Checking for fault id 10--
	Wait Until Keyword Succeeds    2m    10s    Assert Alarm Active    10
	Log to Console    \n--Fault 10 is active--
	Log to Console    \n--Restarting ORU--
	ssh.write    exit\r\n
	ssh.write    oranrestart 1 ${oran_version}
	Wait Until Keyword Succeeds    2m    10s    Check BTS is OnAir

Test Postconditions
    Download SCF
    Collect Snapshot
    Clear SSH Session To Docker
    Log to console   \n--Stopping Syslogs--
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog    target_dir=${opt}
    core.teardown_collectors      names=btslog
    CoamAdmin.teardown    oam
    Log To Console    \nBTS IS Disconnected
#    Run Keyword And Ignore Error     Link SCOUT SCF to Configuration ID for Reporting

Assert Alarm Active
    [Arguments]    ${alarm}
    Log     \nChecking active alarm: ${alarm}     console=yes
    Admin assert alarm active    fault_id=${${alarm}}[fault_id]
    ...                          alarm_id=${${alarm}}[alarm_id]
    ...                          alarm_severity=${${alarm}}[alarm_severity]
    ...                          fault_name=${${alarm}}[fault_name]
    ...                          timeout=100

Admin assert alarm active
    [Arguments]    ${fault_id}
    ...            ${alarm_id}
    ...            ${alarm_severity}
    ...            ${fault_name}
    ...            ${timeout}=30
    CoamAdmin.Assert Alarm Active    parameters=faultId=${fault_id}
    ...                                            alarmId=${alarm_id}
    ...                                            severity=${alarm_severity}
    ...                                            faultName=${fault_name}
    ...                                            timeout=${timeout}
    ...                                            alias=oam

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    [Arguments]  ${connection}=oam
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    \nBTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail

Download SCF
    [Documentation]    ... Downloading SCF
    ${timestamp}    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S
    ${filename}    SET VARIABLE    ${opt}${timestamp}_scf.xml
    CoamAdmin.get_current_scf_file    connection=oam    file_name=${filename}    timeout=60    local_dir_path=${opt}
    OperatingSystem.File Should Exist    ${filename}
    Log To Console    \nSCF Downloaded
    Log To Console    \nSCF file name is ${filename}
    [Return]    ${filename}

Collect Snapshot
    ${snapshot_file_path}    set variable    ${opt}Snapshot.zip
    CoamAdmin.collect_snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    timeout=300
    ...    connection=oam
    Log To Console    \nSnapshot collected and saved on path ${snapshot_file_path}
