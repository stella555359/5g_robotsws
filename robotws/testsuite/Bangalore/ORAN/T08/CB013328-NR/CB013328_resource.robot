*** Settings ***
Documentation     This contains common keywords which are needed to run NR TDD+FDD ULCA L3 Calls.

Library    Telnet
Library    String
Library    Process
Library    BuiltIn
Library    DateTime
Library    Collections
Library    OperatingSystem
Library    taf.analyzer.netconf
Library    taf.config.scf   WITH NAME    scf
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.config.wts    WITH NAME    wts_conf
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.collectors.core    WITH NAME    core
Library    taf.ul.alarms_watchdog   WITH NAME    alarm
Library    taf.collectors.btslog    WITH NAME    btslog
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.sbts.oam.coam.admin    WITH NAME   admin
Library    taf.sw.syslog     WITH NAME    taf_syslog
Library    taf.file.pack
Library    taf.sw.scout    WITH NAME    scout
Library     ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Resource    ./testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot

*** Variables ***
#Suite Setup Parameters
${bts_ip}                192.168.255.129
${ADMIN_ALIAS}			 admin_1
${INSTALL_Radio}         ${CURDIR}/configurations/Install_Radios.sh
${scf_file_Config}       ${CURDIR}/configurations/CB013328_SCF_KDDI_GMC.xml
${DELTA_FILE_OLD}        ${CURDIR}/configurations/vlanid_old.json
${DELTA_FILE_NEW}        ${CURDIR}/configurations/vlanid_new.json
${OUT_LOG_PATH}          /home/ute/results/
${BTS_path}=                       /home/ute/logs/CB013328

#WTS parameters
&{WTS}                   Ip=127.0.0.1        Username=ute         Connection=Wts
${AMF_ID}                1
${WTS_DIR}               /opt/iphy/latest
${4G5G_Combo}            0
${Target_gNB}            2
${SUITE_WTS_CFG}         basic_setup_KDDI.cfg
${Total_Timeout}         5 min
${Retry_Timeout}         15 sec
${Ng_link_pattern}       NG primary peer address.*up
${Ng_link_pattern_dual_stack}    NG link is Up
@{timeout}               300

${CELL_ID}                          1
${BEARER_ID}                        2
${Timeout_SA}    120
${Register_complete_pattern}    REGISTRATION COMPLETE
${Cell_setup_complete_pattern}    Cell Setup completed
${UE_register_complete_pattern}    .*REGISTRATION COMPLETE.*
${Initial_UE_message_pattern}    I\nnitial UE Message Success
${Initial_UE_success_pattern}    .*Initial UE Message Success.*
${UE_SIB_decoding_pattern_eNB}    SystemInformationBlockType2
${Initial_context_setup_pattern}    Initial Context Setup Successful
${UE_deregister_pattern}      UE Context Release Complete

&{GNB_SYSLOG}       ip=192.168.255.126    file_limit=209715200    log_name=Gnb_syslog    alias=Gnb_syslog

@{Delay_list}
...    dlMinDelay
...    ulMinDelay

${No.of.Iteration}     2
${Password_toor4nsn}=        oZPS0POrRieRtu
${user_toor4nsn}             toor4nsn
${snapshotfilename}=               Snapshot.zip
${snapshottimeout}=                400s
${snapshotfilename_unzip}          Snapshot_unzipped
&{authentication}   id=1    defaultNetconfAccount=&{default_user}
&{default_user}=    defaultNetconfAccountName=xranuser
...                 defaultNetconfAccountPwd=xran-password
@{sudo_list}=        &{authentication}
${phraseinput}=         static-config-supported>PRACH
${PRACH_REC_IND}=       M55306C10002
${PRACH_REC_REQ}=       M55306C10003
${artifactory_link}     https://lterel.es-si-s3-z2.eecloud.nsn-net.net/RFM_PLUGIN/RFMPlugin_O-RU_FJ_CB013328FDD_0001.zip
${local_save_path}      /home/ute/Downloads
${RFplugin_file}        RFMPlugin_O-RU_FJ_CB013328FDD_0001.zip
${Rach_CountersPath}=       BTS']['MRBTS-1']['NRBTS-1']['NRCELL-1']['NRACH
${Rach_Counter}=	    M55306C00001
${c_dump}=     /home/ute/results/coredump/
${d_dump}=     /home/ute/results/netconf/
${match_pattern1}       RMOD_*_RPC_*.log
${match_pattern2}       RMOD_*_NetconfRpcMessageTrace_*.log
@{PHRASES}     eaxc-id>256     eaxc-id>257     eaxc-id>384     eaxc-id>385

*** Keywords ***
Suite Setup
	Log to console    \n--Test Setup--\n
	admin.setup_admin    bts_host=${bts_IP}    alias=${ADMIN_ALIAS}
	${BTS_details}      admin.get_bts_info       connection=${ADMIN_ALIAS}
    ${sw_info}=    admin.get_sw_version     connection=${ADMIN_ALIAS}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    Set suite Variable     ${sw_info}
    Log    ${sw_info}
	Configure Netconf Credentials
	Install TDD and FDD ORU
	Get and Update RFMplugin    ${RFplugin_file}      ${artifactory_link}
    Check VlanId
    Load BTS Configuration
	Check if Radio state is enabled
	Change VlanId
    Run WTS configuration
	ADMIN Assert BTS is onAir    timeout=100
	ADMIN Assert All NRCells Are In Enabled State    timeout=100
	Verify Ng Link Status
	Log Variables
    ${Active_alarm}    admin.get_active_alarms    connection=${ADMIN_ALIAS}
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarm
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${ADMIN_ALIAS}
    ...    reconnect=true    log_dir=/tmp
	Log    \n+ Suite Setup finished    console=yes

Get and Update RFMplugin
     [Arguments]      ${sw_file_name}      ${artifactory_link}
     OperatingSystem.Run    wget ${artifactory_link} -P ${local_save_path}
     ADMIN Update Software With Activation
     ...           sw_package=${local_save_path}/${sw_file_name}

ADMIN Update Software
    [Arguments]    ${sw_package}
    ...            ${should_activate}
    ...            ${timeout}=240
    ...            ${alias}=${ADMIN_ALIAS}
    admin.Update Software    sw_package=${sw_package}
    ...                          should_activate=${should_activate}
    ...                          timeout=${timeout}
    ...                          alias=${alias}

ADMIN Update Software With Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=240
    ...            ${alias}=${ADMIN_ALIAS}
    ADMIN Update Software    sw_package=${sw_package}
    ...                      should_activate=True
    ...                      timeout=${timeout}
    ...                      alias=${alias}

Stop Syslog
    RUN Keyword and Ignore Error    taf_syslog.Stop Syslog    alias=${GNB_SYSLOG.alias}

Suite Teardown
    Log to console   \n--End Test--\n
	#Wait Until Keyword Succeeds    500s    20s	admin.Collect snapshot     ${OUTPUT_DIR}/${TEST_NAME}/snapshot.zip    alias=${ADMIN_ALIAS}
    #Collect SosReport	${OUTPUT_DIR}/${TEST_NAME}/sos_report_log
    Log Variables
    ${Active_alarm}    admin.get_active_alarms    connection=${ADMIN_ALIAS}
    LOG     ${Active_alarm}
    alarm.check_detected_alarms
    alarm.stop_watching_alarms
    admin.teardown_admin    connection=${ADMIN_ALIAS}
    Link SCOUT SCF to Configuration ID for Reporting
    Log    \n+ Suite teardown finished    console=yes

Start Syslogs
    Log To Console    \n [INFO] bts collector creation is in progress
    RUN Keyword and Ignore Error    taf_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=/tmp/btslog2
    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}

Install TDD and FDD ORU
    Run    chmod a+x ${INSTALL_Radio}
    Run    sh ${INSTALL_Radio}
    sleep    150s
    Log to console    \n [INFO] Installing NR TDD and NR FDD ORAN radio

Check VlanId
    ${vlanId}=    admin.Get Parameters
	...		dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/TNLSVC_CONF_M-1/TNL_CONF_M-1/ETHSVC_CONF_M-1/ETHIF_CONF_M-1/VLANIF_CONF_M-1
    ...     connection=${ADMIN_ALIAS}
	${vlanId_1}=		Get From Dictionary    ${vlanId}    vlanId
    ${vlanId_str}=    Convert to String    ${vlanId_1}
    ${json}=   OperatingSystem.Get File    ${DELTA_FILE_OLD}
    ${replace}=     Replace String    ${json}    10000    ${vlanId_str}
    Create File   ${CURDIR}/configurations/vlanid_new.json      ${replace}

Load BTS Configuration
    [Documentation]    Perform BTS Full Commissioning
	Log to console    \n Performing BTS commission...
    ADMIN Perform Commissioning     ${BTS_ID}     ${scf_file_Config}     ${ADMIN_ALIAS}

ADMIN Perform Commissioning
    [Arguments]    ${bts_id}
    ...            ${scf_file}
    ...            ${skip_parameter_relation_errors}=False
    ...            ${should_activate}=True
    ...            ${timeout}=600
    ...            ${alias}=${ADMIN_ALIAS}
    admin.Perform Commissioning    bts_id=${bts_id}
    ...                                scf_file=${scf_file}
    ...                                skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                should_activate=${should_activate}
    ...                                timeout=${timeout}
    ...                                alias=${alias}

Change VlanId
	ADMIN Perform Delta Recommissioning
        ...    delta_file=${DELTA_FILE_NEW}
        ...    skip_parameter_relation_errors=${True}

ADMIN Perform Delta Recommissioning
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=False
    ...            ${should_activate}=True
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    admin.Perform Delta Recommissioning    delta_file=${delta_file}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        alias=${alias}

Check if Radio state is enabled
    [Documentation]    \n Check if Operational State of all Radio's is enabled
    Radio State should be enabled
	ADMIN Assert All Rmods Are In Enabled State   timeout=1200

ADMIN Assert All Rmods Are In Enabled State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Operational State    expected_state=regex"Enabled|enabled"
    ...                                                         timeout=${timeout}

ADMIN Assert All Rmods Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Rmods Are In Expected State    expected_state=${expected_state}
    ...                                             timeout=${timeout}
    ...                                             state_type=operationalState

ADMIN Assert All Rmods Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=RMOD
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

Radio State should be enabled
    Wait Until Keyword succeeds     20min    30s    Verify coam Radio is Online

Verify coam Radio is Online
    ${bts_hw_info}                admin.Get Bts Info    connection=${ADMIN_ALIAS}
    ${radio_state}                Set Variable
    ...                           ${bts_hw_info['radioModules']['rmod'][0]['status']['operationalState']}
    Log to Console    \n [INFO] RADIO STATE : ${radio_state}
    Should Be Equal As Strings    ${radio_state}    enabled    ignore_case=${TRUE}

Run WTS configuration
    [Documentation]    \n To Start WTS configuration for AMF & MME Simulation
    Start UTE WTS

Start UTE WTS
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS
    Stop Edaemon Egate
    Configure UTE ETH3 FOR BOAM_ET_CONF
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    ...                                   nostats=True
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    ${cfg_filename}  set variable   ${WTS_DIR}/${SUITE_WTS_CFG}
    wtsrunner.configure                      file=${cfg_filename}
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=300
    Wait Until Keyword Succeeds    10 min    30 sec    Verify if sim state is active
    sleep	80s

Stop Edaemon Egate
    [Documentation]    Kill edaemon and egate if already running.
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    Run    sudo pkill -9 egate
    Run Keyword If    ${edaemon_status} or ${egate_status}    sleep      5s

Configure UTE ETH3 FOR BOAM_ET_CONF
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.150/24 dev eth3
    Run    sudo ip addr add 10.0.1.112/24 dev eth3

Connect To WTS VM
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    ssh.Connect to     hostname=${WTS.Ip}
    ...                username=${WTS.Username}
    ...                alias=${WTS.Connection}
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...               sysctl -w net.sctp.rto_min=200 &&
    ...               sysctl -w net.sctp.rto_initial=200 &&
    ...               sysctl -w net.sctp.rto_max=800
    Run               ${command}
    Run               cat /proc/sys/net/sctp/rto_min

Verify if sim state is active
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=20

Verify Ng Link Status
    [Documentation]    \n -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP
	Log to console    \n NG Link is available

NG Link Should be UP
    [Documentation]    This keyword checks if the NG link is up for the SA variant in egate_console.log file
    ...                Modified Date: 10-Jun-2021
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    NG link check using AMF Link Status    ${AMF_ID}    ${TARGET_GNB}


NG link check using AMF Link Status
    [Arguments]    ${amf_id}=${AMF_ID}    ${gnb_id}=${Target_gNB}
    [Documentation]    This Keyword checks if the NG link status for the mentioned gNB ID using the amf_disp command
    ...    on egate console
    wtsrunner.amf_disp    id=${amf_id}    type=link_info    gnb=${gnb_id}
	${amf_link_status}=    Run Keyword And Return Status
    ...    wtsrunner.read_wtsemu_output_until_re    expected=${Ng_link_pattern}    timeout=60
    Run Keyword If    '${amf_link_status}'=='False' and '${4G5G_Combo}'=='1'
    ...    Search pattern should Exists In EGATE
    ...    ${WTS_DIR}/egate_console.log    ${Ng_link_pattern_dual_stack}
    ...    ELSE IF    '${amf_link_status}'=='True'    Log    "NG Link in UP"
    ...    ELSE    Fail    msg="NG Link is not Up"

Search pattern should Exists In EGATE
    [Arguments]    ${file}    ${pattern}    ${grepArgs}=grep -i
    ${command}        Catenate    ${grepArgs} '${pattern}' ${file}
    ${result}         Run    ${command}
    Log               ${result}
    Should Contain    """${result}"""    ${pattern}    ignore_case=${TRUE}

ADMIN Assert Every
    [Arguments]    ${class_name}
    ...            ${parameters}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    admin.Assert Every    class_name=${class_name}
    ...                       parameters=${parameters}
    ...                       timeout=${timeout}
    ...                       alias=${alias}

ADMIN Assert All NRCells Are In Enabled State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Enabled|enabled"
    ...            ${class_name}=NRCEL
    ADMIN Assert All NRCells Are In Expected Operational State    expected_state=${expected_state}
    ...                                                         timeout=${timeout}
    ...                                                         class_name=${class_name}

ADMIN Assert All NRCells Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=operationalState
    ...            ${class_name}=NRCEL
    ADMIN Assert All NRCells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All NRCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=NRCEL
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

ADMIN Assert BTS is onAir
    [Arguments]    ${state_type}=proceduralState
    ...            ${expected_state}=regex"[oO]nAir"
    ...            ${timeout}=10
    ...            ${class_name}=BTS
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

Expected alarm
    [Documentation]     Alarms which are ignored on runtime
    ${allowed_alarm_1}    Create alarm    alarm_id=7220     fault_id=61524    fault_name=SSH enabled
    ${allowed_alarm_2}    Create alarm    alarm_id=7220     fault_id=4654     fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}    Create alarm    alarm_id=7220     fault_id=61649    fault_name=LMP access via port 443
    ${allowed_alarm_4}    Create alarm    alarm_id=7220     fault_id=4655     fault_name=Service account root access is enabled
    ${allowed_alarm_5}    Create alarm    alarm_id=7220     fault_id=61652    fault_name=R&D Service Port enabled
    ${allowed_alarm_6}    Create alarm    alarm_id=61641    fault_id=61641    fault_name=IP Traffic Capturing ongoing
    ${allowed_alarm_7}    Create alarm    alarm_id=7115     fault_id=4592     fault_name=BTS Reset Cause
    ${allowed_alarm_8}    Create alarm    alarm_id=7115     fault_id=8000     fault_name=Failure in connection between BTS and 3rd party tool
    ${allowed_alarm_9}    Create alarm    alarm_id=7102     fault_id=49       fault_name=Cell blocked
	${allowed_alarm_10}    Create alarm    alarm_id=7115     fault_id=4740     fault_name=EFaultId_ClearFaultNotifUnderMoAl
    ${allowed_alarm_11}    Create alarm    alarm_id=7115     fault_id=4681     fault_name=Sanity Check Error
    ${allowed_alarm_12}    Create alarm    alarm_id=7115     fault_id=4720
	...    fault_name=Mismatch of RU reported capabilities with static HW Validation information
	${allowed_alarm_13}    Create alarm    alarm_id=7115     fault_id=4602     fault_name=5G cell configuration mismatch
	${allowed_alarm_14}    Create alarm    alarm_id=7114     fault_id=7509
	...    fault_name=EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM
	${allowed_alarm_15}    Create alarm    alarm_id=7110     fault_id=4293     fault_name=IP Traffic Capacity Limit
	${allowed_alarm_16}    Create alarm    alarm_id=7107     fault_id=7300     fault_name=No X2 link available
    ${allowed_alarm_17}    Create alarm    alarm_id=7115     fault_id=4720
    ...     fault_name=Mismatch of RU reported capabilities with static HW Validation information
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}  ${allowed_alarm_9}  #${allowed_alarm_10}
    ...     ${allowed_alarm_11}  ${allowed_alarm_12}  ${allowed_alarm_13}  ${allowed_alarm_14}  ${allowed_alarm_15}  ${allowed_alarm_16}
	...     ${allowed_alarm_17}
    [Return]    ${allowed_alarms}

L3 Call
    [Arguments]    ${UE_ID}=${2}    ${dl_tp}=${175}    ${ul_tp}=${175}    ${start_id}=${1}    ${end_id}=${15}
    Attach Single SA CA UE    ${UE_ID}
    Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=1
    Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=2
    FOR	    ${trf_id}   IN RANGE    ${start_id}	  ${end_id}
       Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=${trf_id}
    END
    ${pcell_dl_tp}=    Get Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    Log to Console    Primary Cell Downlink Throughput=${pcell_dl_tp}
    ${pcell_ul_tp}=    Get Cell Average Throughput    ${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
    Log to Console    Primary Cell Uplink Throughput=${pcell_ul_tp}
    log     DL Troughput of pcell is ${pcell_dl_tp}
    log     UL Troughput of pcell is ${pcell_ul_tp}
    Should Be True    ${pcell_dl_tp}>300
    Should Be True    ${pcell_ul_tp}>100

Attach Single SA CA UE
    [Arguments]    ${UE_ID}
    SA 5G Attach    ${UE_ID}
    SA Set Traffic Type To Internal    ${UE_ID}    pdu_id=1
    SA CA 5G PDU Session Setup    ${UE_ID}

SA 5G Attach
    [Arguments]    ${UE_ID}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 3 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G Attach | 1 |
    Log To Console    start 5G attach...
    Sleep    20s
    wtsrunner.ue_register    id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    REGISTRATION COMPLETE
    Run Keyword If    "${ret}"=="${False}"    Fail    SA 5G Attach fails!!!
    Should Be True    ${ret}
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    I\nnitial UE Message Success
    Sleep    3s    reason=wait 5G attach is stable

Read WTS Output Until Pattern Matches
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks the output file until the ${pattern} matches in the file.
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]    ${output}

SA Set Traffic Type To Internal
    [Arguments]    ${UE_ID}    ${pdu_id}=1
    wtsrunner.set_pdu_param     ue=${UE_ID}    pdu=${pdu_id}    trf_type=internal

SA CA 5G PDU Session Setup
    [Arguments]    ${UE_ID}    ${pdu_id}=1
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${UE_ID}    nwslice=1    gw=1
    ${output_0}    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log To Console    ${output_0}

Read WTS Output For Pattern And Print matching Lines
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ${output}    Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
    Print Matching Lines from Output File    ${output}    ${pattern}
    [Return]    ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ${output}        String.Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    Log to Console    \n${output}

Start SA Internal Traffic
    [Arguments]    ${UE_ID}    ${pdu_id}    ${dir}    ${mbps}    ${trf_id}
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    Log To Console    start Internal traffic...
    wtsrunner.trf_data_start    ue=${UE_ID}    pdu=${pdu_id}    dir=${dir}    mbps=${mbps}
    ...    trf_id=${trf_id}
    Sleep    5s    reason=wait traffic is stable

Get Cell Average Throughput
    [Arguments]    ${UE_ID}    ${dir}    ${cell_type}    ${scell_index}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${UE_ID} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${cell_type} | Yes | pcell/scell |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl | pcell | 0 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    wtsrunner.ue_stats_nr    id=${UE_ID}    type=${type}    scell=${scell_index}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=Total       timeout=300
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Get Cell Throughput From Btslog
    [Arguments]    ${duration}=20s    ${log_dir}=${OUTPUT_DIR}
    ${savepoint}=    taf_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Sleep    ${duration}
    taf_syslog.Collect From Savepoint    savepoint=${savepoint}    destination_file=${log_dir}/target_syslog.txt    alias=${GNB_SYSLOG.alias}
    ${tp}=    Analyze_syslog.get_tp_from_syslog    ${log_dir}/target_syslog.txt
    [Return]    ${tp}

Check Cell Throughput Quality From Btslog
    [Arguments]    ${tp_list}    ${cell_id}    ${direction}    ${target_tp}    ${aver_ratio}=${0.95}    ${min_ratio}=${0.85}
    [Documentation]    Check Throughput Quality from keyword "Get Cell Throughput From Btslog"
    ...    | Input Parameters | Man. | Description |
    ...    | ${tp_list} | YES | return value from keyword "Get Throughput From Bts" |
    ...    | ${cell_id} | YES | cell id|
    ...    | ${direction} | YES | dl/ul|
    Should Be True    ${tp_list}[${direction}][${cell_id}][ave]>${target_tp}*${aver_ratio}    Syslog average TP is lower than Target
    Should Be True    ${tp_list}[${direction}][${cell_id}][min]>${target_tp}*${min_ratio}    Syslog min TP is lower than Target

SA 5G Detach
    [Arguments]    ${UE_ID}=2
    [Documentation]    This keyword is used to simulate UE detach on 5GNR side.
    ...    Expected output is: " UE Context Release Complete " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G Detach | 1 |
    Log To Console    start 5G detach...
    wtsrunner.ue_deregister    id=${UE_ID}    ue_deregister_type=switch_off
    ${output_0}    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
    ${output1}    String.Get Lines Matching Regexp    ${output_0}    UE Context Release Complete
    ...    partial_match=${true}
    Log To Console    \n${output1}

Collect SosReport
    [Arguments]    ${log_dir}
    Log to console	\n Start generating Sos Report
    OperatingSystem.Run    rm ${WTS_DIR}/SosReport*.tgz
    Create Directory    ${log_dir}/
    ${output}=		Run         cd ${WTS_DIR}/ && ${WTS_DIR}/sosReport_ASIK_ASIL.sh
    Wait Until Created	${WTS_DIR}/SosReport*.tgz	timeout=5 minute
    Wait Until Keyword Succeeds    100s    20s	OperatingSystem.Run    mv ${WTS_DIR}/SosReport*.tgz ${log_dir}/

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
	...    /home/ute/robotws/testsuite/Bangalore/ORAN/SG08/CB009301/configurations/hanging.py ${OUT_LOG_PATH}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

ResetAllRadio
    ${listRMOD}=    admin.get_ids_for_all    RMOD     connection=${ADMIN_ALIAS}
    log    ${listRMOD}
    ${len}=    Get length    ${listRMOD}
    log    ${len}
    FOR    ${i}    IN RANGE   ${len}
        admin.reset_unit        dist_name=${listRMOD}[${i}]
        ...                     reset_type=Soft
        ...                     timeout=400
        ...                     connection=${ADMIN_ALIAS}
        ...                     detailed_output=False
    END

Get RAT Type
    ${rat_types}    Create List
    ${nr_cells}    admin.get_cells_info    cell_type=nr    connection=${ADMIN_ALIAS}
    ${ne_cell_count}    Get Length    ${nr_cells}
    ${lte_cells}    admin.get_cells_info    cell_type=lte    connection=${ADMIN_ALIAS}
    ${lte_cell_count}    Get Length    ${lte_cells}
    Run Keyword If    ${ne_cell_count}!=${0}    Append To List    ${rat_types}    NR
    Run Keyword If    ${lte_cell_count}!=${0}    Append To List    ${rat_types}    LTE
    [Return]    ${rat_types}
	Set global variable      ${rat_types}

Perform RAT Reset
    Get RAT Type
    FOR    ${RAT}    IN    @{rat_types}
        Run Keyword    admin.rat_reset    rat_type=${RAT}    connection=${ADMIN_ALIAS}    timeout=180    reset_type=Soft
    END

All Cells block and unblock
    Get RAT Type
    FOR    ${RAT}    IN    @{rat_types}
        Run Keyword    admin.block_all_cells    rat=${RAT}    timeout=300    detailed_output=False    connection=${ADMIN_ALIAS}
    END
    sleep	 30
    FOR    ${RAT}    IN    @{rat_types}
        Run Keyword    admin.unblock_all_cells    rat=${RAT}    timeout=300    detailed_output=False    connection=${ADMIN_ALIAS}
    END
	sleep	 30

Reset Site
    admin.reset_site
    ...    wait_for_reconnection=True
    ...    connection=${ADMIN_ALIAS}
    ...    timeout=600
    ...    detailed_output=False
    sleep	 300

BBMOD Reset
    ${BBMODS}  admin.get_ids_for_all    BBMOD    connection=${ADMIN_ALIAS}
    Log to console  \n--Performing BBMOD reset--\n
    FOR    ${BBMOD}    IN  @{BBMODS}
      admin.reset_unit    dist_name=${BBMOD}    reset_type=Warm    timeout=300s    connection=${ADMIN_ALIAS}
    END
    Log to console  \n--BBMOD reset Completed and waiting for BBMOD to come up--\n
    Sleep	150s

Multiple cell block and unblock
	FOR    ${i}    IN RANGE    1    ${No.of.Iteration}
	    All Cells block and unblock
		Check Cells are ON-Air
		L3 Call
		SA 5G Detach
		Check Cells are ON-Air
		alarm.check_detected_alarms
	END

Multiple RMOD Reset
	FOR    ${i}    IN RANGE    1    ${No.of.Iteration}
	    ResetAllRadio
		Check Cells are ON-Air
		L3 Call
		SA 5G Detach
		Check Cells are ON-Air
		alarm.check_detected_alarms
	END

Multiple BBMOD Reset
	FOR    ${i}    IN RANGE    1    ${No.of.Iteration}
	    BBMOD Reset
		Check Cells are ON-Air
		L3 Call
		SA 5G Detach
		Check Cells are ON-Air
		alarm.check_detected_alarms
	END

Multiple Site Reset
	FOR    ${i}    IN RANGE    1    ${No.of.Iteration}
	    Reset Site
		Check Cells are ON-Air
		L3 Call
		SA 5G Detach
		Check Cells are ON-Air
		alarm.check_detected_alarms
	END

Configure Netconf Credentials
    admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=${ADMIN_ALIAS}
    ...    accounts=@{sudo_list}

Log collection and validation
    Log folder creation
    admin.Collect Snapshot    target_file_name=${out}/${snapshotfilename}    timeout=${snapshottimeout}    connection=${ADMIN_ALIAS}
    taf.file.pack.Extract      path=${out}/${snapshotfilename}     output_dir=${out}/${snapshotfilename_unzip}
	${status}    ${result}=    Run Keyword And Ignore Error
	...    OperatingSystem.Run And Return Rc And Output
	...    find ${out}/${snapshotfilename_unzip} -name "*RPC.log"
	# result[0] = rc
	# result[1] = stdout
	${rc}=    Set Variable    ${result}[0]
	${output}=    Set Variable    ${result}[1]
	IF    '${output}' == ''
		${rc2}    ${output}=    OperatingSystem.Run And Return Rc And Output
		...    find ${out}/${snapshotfilename_unzip} -name "*NetconfRpcMessageTrace.log"
	END
	Run Keyword If    '${output}' == ''    Log To Console    No matching log files found!    WARN
	Log    Found log files:\n${output}
	Set Global Variable    ${output}
    validate_netconf_reply_message    file_path=${output}    rpctag=get    replytag=data    subtag=section-type    value=3
	OperatingSystem.Get file     ${output}
	${Prach_phrase}=    Set Variable    ${phraseinput}
	Set global variable    ${Prach_phrase}

Search Phrase In File
    [Arguments]    ${output}    ${Prach_phrase}
    ${contents}=    Grep File    ${output}    ${Prach_phrase}
    ${lines}=    Split To Lines    ${contents}
    ${found}=    Set Variable    ${False}
    FOR    ${line}    IN    @{lines}
        IF    '${line.strip()}' == '${Prach_phrase}'
            Log    Phrase found: ${Prach_phrase}
            ${found}=    Set Variable    ${True}
            Exit For Loop
        END
    END
	Run Keyword If    not ${found}    Log To Console    \nPhrase not found: ${Prach_phrase}\n
	Should Not Be True    ${found}    Phrase was not found in the file: ${Prach_phrase}

Log folder creation
	${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
	${CurrentDate}=    Convert to String     ${CurrentDate}
	${SUITE NAME}    Set Variable    ${SUITE NAME}
	${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
	OperatingSystem.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}
	${out}    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/logfolder
	Set global variable    ${out}

RACH Counter Verification
    Run Keyword and Continue On Failure    Counter_Value_Check    ${Rach_CountersPath}    ${Rach_Counter}

Counter_Value_Check
    [Arguments]    ${path}    @{ListofCountervalues}
    Log to console      \nChecking gnb counter
    ${result}     admin.get_pm_counters    counter_ids=${Rach_Counter}    timeout=100    connection=${ADMIN_ALIAS}
    log    ${result}
    ${values}    Get Dictionary Values    ${result['${path}']}
    ${Total_Count}    Get value of Counter    ${values}
    Run Keyword If    ${Total_Count} < 1    Fail     ${Total_Count} Rach counter is not updated
    [Return]    ${Total_Count}

Get value of Counter
    [Arguments]    ${Counter_value}
    ${total}    Set Variable    0
    ${dict}=    Get From List    ${Counter_value}    0
    ${values}=    Evaluate    list(${dict}.values())
    FOR    ${value}    IN    @{values}
        ${total}=    Evaluate    ${total} + ${value}
    END
    [Return]    ${total}

EAXCID Verification
    Netconf log collection from FHNET
    Search for EAXCID In File    ${d_dump}    @{phrases}

Netconf log collection from FHNET
    ${executor}    Create Dictionary    host=${bts_ip}    user=${user_toor4nsn}    password=${Password_toor4nsn}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET80/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    30s
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    OperatingSystem.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    ${all_files}=    List Files In Directory    ${c_dump}
    FOR    ${file}    IN    @{all_files}
        ${result1}=    Run Keyword And Ignore Error    Should Match    ${file}    ${match_pattern1}
        ${result2}=    Run Keyword And Ignore Error    Should Match    ${file}    ${match_pattern2}
        Run Keyword If    '${result1[0]}' == 'PASS' or '${result2[0]}' == 'PASS'    Move File    ${c_dump}${file}    ${d_dump}
	END

Search for EAXCID In File
    [Arguments]    ${directory}    @{phrases}
    ${files}=    List Files In Directory    ${directory}
    FOR    ${phrase}    IN    @{phrases}
        ${found_files}=    Create List
        ${not_found_files}=    Create List
        FOR    ${file}    IN    @{files}
            ${file_path}=    Set Variable    ${directory}/${file}
            Log    Searching for phrase '${phrase}' in file '${file_path}'
            ${contents}=    Run Keyword    Get File    ${file_path}
            ${is_found}=    Run Keyword And Return Status    Should Contain    ${contents}    ${phrase}
            IF    ${is_found}
                Log    Phrase '${phrase}' FOUND in file '${file_path}'
                Append To List    ${found_files}    ${file}
            ELSE
                Append To List    ${not_found_files}    ${file}
           END
        END
        IF    ${found_files}
            Log    Phrase '${phrase}' was found in files:
            FOR    ${file}    IN    @{found_files}
                Log    Found in file: ${file}
            END
        ELSE
            Log    Phrase '${phrase}' NOT found in any file under '${directory}'. Listing files checked:
            FOR    ${file}    IN    @{not_found_files}
                Log    Checked file (not found): ${file}
            END
            Fail    Phrase '${phrase}' NOT found in any file under '${directory}'.
        END
    END