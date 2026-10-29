*** Settings ***
Documentation     This contains common keywords which are needed to run NR FDD ULCA L3 Calls.

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
Library    XML    use_lxml=True
Library    taf.sw.scout    WITH NAME    scout
Library    taf.collectors.tcpdump    WITH NAME    TCPDUMP
Library    taf.collectors.l2stream3    WITH NAME    L2STREAM3
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot

*** Variables ***
#Suite Setup Parameters
${bts_ip}                192.168.255.129
${ADMIN_ALIAS}			 admin_1
${INSTALL_Radio}         ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations/Install_Radios.sh
${scf_file_Config}       ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations/SCF_UTE_VM_FDD_1_NRCELL.xml
${DELTA_FILE_OLD}        ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations/vlanid_old.json
${DELTA_FILE_NEW}        ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations/vlanid_new.json
${LOG_PATH}              ${OUTPUT_DIR}

#WTS parameters
&{WTS}                   Ip=127.0.0.1        Username=ute         Connection=Wts
${AMF_ID}                1
${WTS_DIR}               /opt/iphy/latest
${4G5G_Combo}            0
${Target_gNB}            2
${SUITE_WTS_CFG}         basic_setup_FJT.cfg
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
${RRC_Reconfig_pattern}      rrcReconfiguration
${eNB_ID}            1
${eNB_target}        2
${st_ue_id}          1
${en_ue_id}          1
${numofLayer}        RANK1
${numprb}            79
${physcellid}        ${50}
&{GNB_SYSLOG}       ip=192.168.255.126    file_limit=209715200    log_name=Gnb_syslog    alias=Gnb_syslog
&{authentication}   id=1    defaultNetconfAccount=&{default_user}
&{default_user}=    defaultNetconfAccountName=xranuser
...                 defaultNetconfAccountPwd=xran-password
@{sudo_list}=        &{authentication}

*** Keywords ***
Suite Setup
	Log to console    \n--Test Setup--\n
	admin.setup_admin    bts_host=${bts_IP}    alias=${ADMIN_ALIAS}
	${BTS_details}      admin.get_bts_info       connection=${ADMIN_ALIAS}
    ${sw_info}=    admin.get_sw_version     connection=${ADMIN_ALIAS}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}    MRBTS-${BTS_ID}/NRBTS-2
    Set global variable    ${Cell1_dist}    MRBTS-${BTS_ID}/NRBTS-2/NRCELL-1
    Set suite Variable     ${sw_info}
    Log    ${sw_info}
	UTE_Common_resource.Start Syslogs
	Install TDD and FDD ORU
    Check VlanId
    Configure Netconf Credentials
    Load BTS Configuration
	Check if Radio state is enabled
	Change VlanId
    Run WTS configuration
	#Configure DSS and cell seutp
	ADMIN Assert BTS is onAir    timeout=900
	ADMIN Assert All NRCells Are In Enabled State    timeout=900
	Verify Ng Link Status

Test Preconditions
    BuiltIn.Log    \n+ Common Test Preconditions started    console=yes
	Log Variables
    ${Active_alarm}    admin.get_active_alarms    connection=${ADMIN_ALIAS}
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarm
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${ADMIN_ALIAS}
    ...    reconnect=true    log_dir=/tmp
	BuiltIn.Log    \n+ Common Test Preconditions finished    console=yes

Test Postconditions
	Log    \n+ Common Test Postconditions started    console=yes
	UTE_Common_resource.Stop Syslog
	#Wait Until Keyword Succeeds    500s    20s	admin.Collect snapshot     ${OUTPUT_DIR}/${TEST_NAME}/snapshot.zip    alias=${ADMIN_ALIAS}
    #Collect SosReport	${OUTPUT_DIR}/${TEST_NAME}/sos_report_log
    #Log Variables
	#RP Settings
	#Link SCOUT SCF to Configuration ID for Reporting	7_2_UTE5GBOAMETCLOUDTL2
    #Set QC_Tag
    ${Active_alarm}    admin.get_active_alarms    connection=${ADMIN_ALIAS}
    LOG     ${Active_alarm}
    alarm.check_detected_alarms
    alarm.stop_watching_alarms
    Link SCOUT SCF to Configuration ID for Reporting
    Log    \n+ Common Test Postconditions finished    console=yes

#Link SCOUT SCF to Configuration ID for Reporting
    #[Arguments]   ${scout_testline_name}
    #[Documentation]    :Author: krishnamurthy
    #...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    #log to console     ${scout_testline_name}
	#Wait Until Keyword Succeeds    3min    10s    Request Scout SCF    ${scout_testline_name}

Configure Netconf Credentials
    admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=${ADMIN_ALIAS}
    ...    accounts=@{sudo_list}

Install TDD and FDD ORU
    Run    chmod a+x ${INSTALL_Radio}
    Run    sh ${INSTALL_Radio}
    sleep    150s
    Log to console    \n [INFO] Installing NR TDD and NR FDD ORAN radio

Stop Syslog
    RUN Keyword and Ignore Error    taf_syslog.Stop Syslog    alias=${GNB_SYSLOG.alias}

Suite Teardown
    Log to console   \n--End Test--\n
    admin.teardown_admin    connection=${ADMIN_ALIAS}

Start Syslogs
    Log To Console    \n [INFO] bts collector creation is in progress
    RUN Keyword and Ignore Error    taf_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=/tmp/btslog2
    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}

Install FDD ORU
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
    Create File   ./testsuite/Bangalore/ORAN/SG04/resources/UTE_resources/configurations/vlanid_new.json      ${replace}

Load BTS Configuration
    [Documentation]    Perform BTS Full Commissioning
	Log to console    \n Performing BTS commission...
    UTE_Common_resource.ADMIN Perform Commissioning     ${BTS_ID}     ${scf_file_Config}     ${ADMIN_ALIAS}

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
	UTE_Common_resource.ADMIN Perform Delta Recommissioning
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

Activate Dynamic Swtich
	Parameter value change     ${Cell1_dist}     actDlDynSwitchAlloc    true
	sleep	10s

Check if Radio state is enabled
    [Documentation]    \n Check if Operational State of all Radio's is enabled
    Radio State should be enabled
	UTE_Common_resource.ADMIN Assert All Rmods Are In Enabled State   timeout=1200

ADMIN Assert All Rmods Are In Enabled State
    [Arguments]    ${timeout}=10
    UTE_Common_resource.ADMIN Assert All Rmods Are In Expected Operational State    expected_state=regex"Enabled|enabled"
    ...                                                         timeout=${timeout}

ADMIN Assert All Rmods Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    UTE_Common_resource.ADMIN Assert All Rmods Are In Expected State    expected_state=${expected_state}
    ...                                             timeout=${timeout}
    ...                                             state_type=operationalState

ADMIN Assert All Rmods Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=RMOD
    UTE_Common_resource.ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

Radio State should be enabled
    Wait Until Keyword succeeds     20min    30s    Verify Coam Radio is Online

Verify Coam Radio is Online
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
    Sleep    80s
    wtsrunner.enb_x2_link_up    enb=1    target=2
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
	Run    sudo ip addr add 10.0.1.99/24 dev eth3

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
    UTE_Common_resource.ADMIN Assert All NRCells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All NRCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=NRCEL
    UTE_Common_resource.ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

ADMIN Assert BTS is onAir
    [Arguments]    ${state_type}=proceduralState
    ...            ${expected_state}=regex"[oO]nAir"
    ...            ${timeout}=10
    ...            ${class_name}=BTS
    UTE_Common_resource.ADMIN Assert Every    parameters=${state_type}=${expected_state}
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
    ${allowed_alarm_11}    Create alarm    alarm_id=7115     fault_id=4681     fault_name=Sanity Check Error
    ${allowed_alarm_12}    Create alarm    alarm_id=7115     fault_id=4720
    ...     fault_name=Mismatch of RU reported capabilities with static HW Validation information
	${allowed_alarm_13}    Create alarm    alarm_id=7115     fault_id=4602     fault_name=5G cell configuration mismatch
	${allowed_alarm_15}    Create alarm    alarm_id=7110     fault_id=4293     fault_name=IP Traffic Capacity Limit
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}  ${allowed_alarm_9}
    ...     ${allowed_alarm_11}  ${allowed_alarm_12}  ${allowed_alarm_13}  ${allowed_alarm_15}
    [Return]    ${allowed_alarms}


L3 Call For DSS NR cell
    [Arguments]    ${UE_ID}=${1}    ${dl_tp}=${175}    ${ul_tp}=${175}
    Attach Single SA UE    ${UE_ID}
    Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=1
    Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=2
	Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=3
    #GET AVG DL DATA TRAFFIC OF CURRENT CELL

Get PDSCH UE Stats for current running throughput
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    Log to Console    PDSCH UE stats for given CC
    ${cmd}	   SET VARIABLE    ue_stats_nr id=${ue_id} type=pdsch scell=${scell_idx}
	${output}    wtsrunner.read_wtsemu_output_until_re    expected=Total       timeout=10
    [Return]      ${output}

Get AVG DL DATA TRAFFIC OF CURRENT CELL
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps
    ${pdsch_ue_stats}    UTE_Common_resource.Get PDSCH UE Stats for current running throughput    ${ue_id}    ${scell_idx}
	${avg_tput}   avg_dl_data.get_avg_dl_data_traffic    ${pdsch_ue_stats}    ${unit}
	Log to Console    ${avg_tput}
	Should Be True Get    ${avg_tput}>250
    [Return]      ${avg_tput}


Attach Single SA UE
    [Arguments]    ${UE_ID}
    SA 5G Attach    ${UE_ID}
    SA Set Traffic Type To Internal    ${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ${UE_ID}

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

SA 5G PDU Session Setup
    [Arguments]    ${UE_ID}    ${pdu_id}=1
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA CA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${UE_ID}    nwslice=1    gw=1
    ${output_0}    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
	BuiltIn.Should Match Regexp   ${output_0}  spCellConfigDedicated(.|\r|\n)*?pdsch-Config setup(.|\r|\n)*?resourceAllocation resourceAllocationType1
    Log to Console    \nSA Attach Complete with Resource allocation as Type1
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

SA 5G Detach
    [Arguments]    ${UE_ID}=1
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

Counter Verification
    Log to console    \n--Tput counter validation step--\n
    @{counter_list1}=    create List    'M55308C00092'    'M55308C00093'
    @{counter_list2}=    create List    'M55139C00029'
    ${log_entry} =    admin.get_pm_counters    counter_ids=M55308C00092,M55308C00093,M55139C00029,
    ...    timeout=300    connection=${ADMIN_ALIAS}
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list1}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry['BTS']['MRBTS-${BTS_ID}']['NRBTS-2']['NRCELL-1']['NCELA'][${pi_id}]}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        ${value}=    evaluate    ${pi_value}!=0
        should be true    ${value}
        Run Keyword If    ${pi_value}!=0
        ...    Log    Value is within range
        ...    ELSE    Fail    Value is not within the specified range
        Log    ${pi_value}
        Log to console    \n--${pi_value}--\n
	END
    FOR    ${pi_id}    IN    @{counter_list2}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry['BTS']['MRBTS-${BTS_ID}']['NRBTS-2']['NRCELL-1']['RSADU'][${pi_id}]}
        ${a}=    get dictionary values    ${count}
        ${pi_value}=    Set Variable    ${a[-1]}
        ${value}=    evaluate    ${pi_value}!=0
        should be true    ${value}
        Run Keyword If    ${value}!=0
        ...    Log    Value is within range
        ...    ELSE    Fail    Value is not within the specified range
        Log    ${pi_value}
        Log to console    \n--${pi_value}--\n
    END

Get value of Counter
    [Arguments]    ${Counter_value}
    [Documentation]     Get total value from list
    FOR    ${a}    IN    @{Counter_value}
        ${i}    Evaluate    ${i} + ${a}
    END
    [Return]    ${i}

Collect SosReport
    [Arguments]    ${log_dir}
    Log to console	\n Start generating Sos Report
    OperatingSystem.Run    rm ${WTS_DIR}/SosReport*.tgz
    Create Directory    ${log_dir}/
    ${output}=		Run         cd ${WTS_DIR}/ && ${WTS_DIR}/sosReport_ASIK_ASIL.sh
    Wait Until Created	${WTS_DIR}/SosReport*.tgz	timeout=5 minute
    Wait Until Keyword Succeeds    100s    20s	OperatingSystem.Run    mv ${WTS_DIR}/SosReport*.tgz ${log_dir}/


Rat1 Allocation Verification
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    ${TTI_log_dir}     Collect TTI Traces      dir_name=RAT1     sleep_time=7
    ${result}    verify_rat1_alocation    ${TTI_log_dir}[ttitrace]/output_dl_formated.csv    ${physcellid}
    Should Contain    ${result}    Pass

Dynamic swtich Allocation Verification
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    ${TTI_log_dir}     Collect TTI Traces      dir_name=RAT1     sleep_time=7
    ${result}    verify_DynSwitch_alocation    ${TTI_log_dir}[ttitrace]/output_dl_formated.csv     ${physcellid}
    Should Contain    ${result}    Array contains both zeros and numbers:pass

Collect TTI Traces
    [Arguments]    ${dir_name}     ${sleep_time}
    Start Log      ttitrace
	Sleep    ${sleep_time}s
    ${tti_log_path}    Stop Log      ttitrace   test_scenario=${dir_name}
    log to console   ${dir_name}
    log to console   ${tti_log_path}
	Decode TTI Trace    ${dir_name}
	[Return]    ${tti_log_path}

Configure DSS and cell seutp
    Enable Phase3 DSS   prb_list=${PRB_LIST_20M}    ALLOC_SUBFRAME=${ALLOC_SUBFRAME}   num_prb=${numprb}
	...    min_dss_ratio=30    max_dss_ratio=100    min_prb_ratio=20    max_prb_ratio=70

Parameter value change
	[Documentation]		Change parameter value in SCF and commision it
	[Arguments]			${dist_name}	 ${parameter}	 ${value}
	Log to console		\nChanging BTS parameter ${parameter} to ${value} [Dist: ${dist_name}]
	${current_value}	Get Current Parameter Value	   ${dist_name}	   ${parameter}
	BuiltIn.LOG					${current_value}
	Run Keyword If		'${current_value.upper()}'!='${value.upper()}'	admin.Perform Parameter Recommissioning	  dist_name=${dist_name}
	...					parameter=${parameter}		operation=update	value=${value}	  skip_parameter_relation_errors=True
	...					connection=${ADMIN_ALIAS}
	...		ELSE		Log to console		\nCurrent ${parameter} value is already set to ${value}, No need to peform commissioning
	${current_value}	Get Current Parameter Value	   ${dist_name}	   ${parameter}
	BuiltIn.LOG					${current_value}
	Should Be Equal As Strings	  ${current_value.upper()}	  ${value.upper()}

Get Current Parameter Value
	[Documentation]		Get current parameter value
	[Arguments]			${dist_name}	${param_name}
	${temp_scf_file}	admin.Get Current Scf File	local_dir_path=/tmp	file_name=temp_scf.xml	  timeout=60	connection=${ADMIN_ALIAS}
	scf.Load Scf		${temp_scf_file}
	${param_value}		scf.get_value_from_scf		dist_name=${dist_name}	p_name=${param_name}
	[Return]			${param_value}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
#    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
# 	use_scout_internal_id= True when running Testcase by reserving TL
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    Log To Console     ${node_id}
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
	Set Suite Variable    ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Suite Variable    ${TC_ID}

Get Hostname
    [Documentation]
    ...    Get HOSTNAME of Testline.
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}