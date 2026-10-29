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
Library    ../../../ORAN/resources/python/downloadwftpackage.py
Resource    ./testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot
Library    taf.sw.scout    WITH NAME    scout



*** Variables ***
#Suite Setup Parameters
${bts_ip}                192.168.255.129
${ADMIN_ALIAS}			 admin_1
${INSTALL_Radio}         ${CURDIR}/configurations/Install_Radios.sh
${scf_file_Config}       ${CURDIR}/configurations/SCF_TDD_AZQI_FDD_2xOFEGSA.xml
${DELTA_FILE_OLD}        ${CURDIR}/configurations/vlanid_old.json
${DELTA_FILE_NEW}        ${CURDIR}/configurations/vlanid_new.json
${DLCA_delta_file}       ${CURDIR}/configurations/enable_DLCA.json
${enable_ULCA_file}      ${CURDIR}/configurations/enable_CB009169.json
${disable_ULCA_file}    ${CURDIR}/configurations/disable_CB009169.json

#WTS parameters
&{WTS}                   Ip=127.0.0.1        Username=ute         Connection=Wts
${AMF_ID}                1
${WTS_DIR}               /opt/iphy/latest
${4G5G_Combo}            0
${Target_gNB}            2
${SUITE_WTS_CFG}         basic_setup_11066.cfg
${Total_Timeout}         5 min
${Retry_Timeout}         15 sec
${Ng_link_pattern}       NG primary peer address.*up
${Ng_link_pattern_dual_stack}    NG link is Up
@{timeout}               300

#CA parameters
@{ca_list1}
...    ca_Fr1Tdd_Any_Sa
...    ca_Fr1Tdd_Sa
...    ca_Fr1Tdd_Fdd_Sa
...    ca_Fdd_Fr1Tdd_Sa
...    ca_Fdd_Any_Sa
...    ca_Fr1Tdd_Fdd_Sa_WithUl
...    ca_Fdd_Fdd


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
${scell_activation_pattern}       S\nCellIndex 1 activated successfully at airphone.
${UE_deregister_pattern}      UE Context Release Complete
${scell_release_pattern}      sCellToReleaseList

&{GNB_SYSLOG}       ip=192.168.255.126    file_limit=209715200    log_name=Gnb_syslog    alias=Gnb_syslog


*** Keywords ***
Suite Setup
	Log to console    \n--Test Setup--\n
	admin.setup_admin    bts_host=${bts_IP}    alias=${ADMIN_ALIAS}
	${BTS_details}      admin.get_bts_info       connection=${ADMIN_ALIAS}
    ${sw_info}=    admin.get_sw_version     connection=${ADMIN_ALIAS}
    Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    Set global variable    ${NRDU_dist}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRDU-1
    Set global variable    ${NRREL1_dist}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCEL-3/NRREL-6
    Set suite Variable     ${sw_info}
    Log    ${sw_info}
	Start Syslogs
    Install TDD and FDD ORU
    Check VlanId
    Load BTS Configuration
	log    Download latest sbts software
	${SBTS_type}=    Get_SBTS_build_type
	IF   '${SBTS_type}'== 'SBTS26R1'
		${SBTS_type}    Set Variable    SBTS00
	END
    Create Directory    /home/ute/Downloads/Builds
	${sw_path}=    latestSbtsBuild    downloadable_type=A54	  branch=${SBTS_type}
	log    ${sw_path}
	log    Install SBTS software
	admin.update_software   sw_package=${sw_path}    should_activate=True   timeout=600
	...    connection=admin_1   should_reset_radios=False    override_ru_software=None    independent_sw_update_type=None
	Check if Radio state is enabled
	Change VlanId
    Run WTS configuration
	ADMIN Assert BTS is onAir    timeout=900
	ADMIN Assert All NRCells Are In Enabled State    timeout=900
	Verify Ng Link Status

Test Preconditions
    Log    \n+ Common Test Preconditions started    console=yes
	Log Variables
    ${Active_alarm}    admin.get_active_alarms    connection=${ADMIN_ALIAS}
    LOG     ${Active_alarm}
    ${allowed_alarms}    Expected alarm
    alarm.Watch alarms    allowed_alarms=${allowed_alarms}    connection_kwargs=${ADMIN_ALIAS}
    ...    reconnect=true    log_dir=/tmp
    Run Keyword And Ignore Error     Enable DL CA    ${DLCA_delta_file}    ${ADMIN_ALIAS}
	Log    \n+ Common Test Preconditions finished    console=yes

Test Postconditions
	Log    \n+ Common Test Postconditions started    console=yes
    Run Keyword And Ignore Error     Disable CB009169 UL CA    ${disable_ULCA_file}    ${ADMIN_ALIAS}
	Stop Syslog
	Wait Until Keyword Succeeds    500s    20s	admin.Collect snapshot     ${OUTPUT_DIR}/${TEST_NAME}/snapshot.zip    alias=${ADMIN_ALIAS}
    Collect SosReport	${OUTPUT_DIR}/${TEST_NAME}/sos_report_log
    Log Variables
	#RP Settings
	#Link SCOUT SCF to Configuration ID for Reporting	7_2_UTE5GBOAMETCLOUDTL2
    #Set QC_Tag
    ${Active_alarm}    admin.get_active_alarms    connection=${ADMIN_ALIAS}
    LOG     ${Active_alarm}
    alarm.check_detected_alarms
    alarm.stop_watching_alarms
    Link SCOUT SCF to Configuration ID for Reporting
    Log    \n+ Common Test Postconditions finished    console=yes


Stop Syslog
    core.stop_collectors      names=btslog
    RUN Keyword and Ignore Error	core.collect_collectors      names=btslog      target_dir=${OUTPUT_DIR}
    core.teardown_collectors      names=btslog

Suite Teardown
    Log to console   \n--End Test--\n
    admin.teardown_admin    connection=${ADMIN_ALIAS}


Start Syslogs
	Log To Console    \n [INFO] bts collector creation is in progress
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
	Log To Console    \n [INFO] bts collector creation success
    core.setup_collectors      names=btslog
    core.set_suite_alias    btslog
    core.start_collectors      names=btslog

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

Enable DL CA
    [Documentation]     Change parameter value in SCF and commision it
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=false
    ...            ${should_activate}=true
    ...            ${timeout}=300
    admin.perform delta recommissioning    delta_file=${delta_file}
    ...            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...            should_activate=${should_activate}
    ...            timeout=${timeout}
    ...            connection=${ADMIN_ALIAS}

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
    ...            parameters=${parameters}
    ...            timeout=${timeout}
    ...            alias=${alias}

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
    ${allowed_alarm_11}    Create alarm    alarm_id=7115     fault_id=4681     fault_name=Sanity Check Error
    ${allowed_alarm_12}    Create alarm    alarm_id=7115     fault_id=4720
    ...     fault_name=Mismatch of RU reported capabilities with static HW Validation information
	${allowed_alarm_13}    Create alarm    alarm_id=7115     fault_id=4602     fault_name=5G cell configuration mismatch
    ${allowed_alarm_15}    Create alarm    alarm_id=7110     fault_id=4293     fault_name=IP Traffic Capacity Limit
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}  ${allowed_alarm_9}
    ...     ${allowed_alarm_11}  ${allowed_alarm_12}  ${allowed_alarm_13}  ${allowed_alarm_15}
    [Return]    ${allowed_alarms}

Activate UL CA Feature
    [Arguments]    ${dist_name}     ${parameter}    ${value}
    [Documentation]     Change parameter value in SCF and commision it
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    ${compare_result}    Run Keyword And Return Status    List Should Contain Sub List
    ...    ${current_value}    ${value}    msg=false
    LOG    ${compare_result}
    Run Keyword If    '${compare_result}' == 'False'    Enable CB009169 UL CA    ${enable_ULCA_file}    ${ADMIN_ALIAS}
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    Run keyword And Continue On Failure    Should Be Equal As Strings    ${current_value}    ${value}
    Sleep    10s

Enable CB009169 UL CA
    [Documentation]     Change parameter value in SCF and commision it
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=false
    ...            ${should_activate}=true
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    admin.perform delta recommissioning    delta_file=${delta_file}
    ...            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...            should_activate=${should_activate}
    ...            timeout=${timeout}
    ...            connection=${connection}

Get Current Parameter Value
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get current parameter value
    ${temp_scf_file}    admin.Get Current Scf File    local_dir_path=/tmp    file_name=temp_scf.xml    connection=${ADMIN_ALIAS}
    scf.Load Scf    ${temp_scf_file}
    ${param_value}    scf.get_all_values_from_scf_by_pattern    dist_name=${dist_name}    list_name=${param_name}
    [Return]    ${param_value}

Disable CB009169 UL CA
    [Documentation]     Change parameter value in SCF and commision it
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=false
    ...            ${should_activate}=true
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    admin.perform delta recommissioning    delta_file=${delta_file}
    ...            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...            should_activate=${should_activate}
    ...            timeout=${timeout}
    ...            connection=${connection}

L3 Call For DLCA
    [Arguments]    ${UE_ID}=${3}    ${dl_tp}=${175}    ${ul_tp}=${175}    ${A1_add}=${True}
    ...     ${start_id}=${3}    ${end_id}=${15}
    Attach Single SA CA UE    ${UE_ID}    ${A1_add}
    Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=1
    Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=2
    FOR	    ${trf_id}   IN RANGE    ${start_id}	  ${end_id}
        SA Start DL Traffic Internal And Check Scell Activation    ${UE_ID}    pdu_id=1
        ...    mbps=${dl_tp}    trf_id=${trf_id}
    END
    Check Scell Activaiton
    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    Log to Console    Primary cell Downlink Throughput=${pcell_dl_tp}
    ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    Log to Console    Secondary cell Downlink Throughput=${scell_dl_tp}
    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
    Log to Console    Single Cell Uplink Throughput=${pcell_ul_tp}
    ${DLCA_Tput}     Evaluate     ${pcell_dl_tp} + ${scell_dl_tp}
    Log to Console    2CC CA Downlink Tput=${DLCA_Tput}
    log     DL Troughput of pcell and scell is ${pcell_dl_tp},${scell_dl_tp}
    log     UL Troughput of pcell is ${pcell_ul_tp}
    ${pcell_dl_tp2}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    ${pcell_ul_tp2}=    Get CA Cell Average Throughput    ${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
    Should Be True    ${pcell_dl_tp2}>0
    Should Be True    ${pcell_ul_tp2}>0

L3 Call For ULCA
    [Arguments]    ${UE_ID}=${3}    ${dl_tp}=${175}    ${ul_tp}=${175}    ${A1_add}=${True}
    ...     ${start_id}=${3}    ${end_id}=${14}
    Attach Single SA CA UE    ${UE_ID}    ${A1_add}
    SA Start UL Traffic Internal And Check Scell Activation    ${UE_ID}    pdu_id=1    mbps=${ul_tp}    trf_id=1
    Check Scell Activaiton
    FOR	    ${trf_id}   IN RANGE    ${start_id}	  ${end_id}
       Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=${trf_id}
    END
    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    Log to Console    Primary cell Downlink Throughput=${pcell_dl_tp}
    ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=scell    scell_index=1
    Log to Console    Secondaray cell Downlink Throughput=${scell_dl_tp}
    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
    Log to Console    Primary cell Uplink Throughput=${pcell_ul_tp}
    ${scell_ul_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=ul    cell_type=scell    scell_index=1
    Log to Console    Secondary cell uplink Throughput=${scell_ul_tp}
    ${DLCA_Tput}     Evaluate     ${pcell_dl_tp} + ${scell_dl_tp}
    Log to Console    2CC CA Downlink Tput=${DLCA_Tput}
    ${ULCA_Tput}     Evaluate     ${pcell_ul_tp} + ${scell_ul_tp}
    Log to Console    2CC CA Uplink Tput=${ULCA_Tput}
    log     DL Troughput of pcell and scell is ${pcell_dl_tp},${scell_dl_tp}
    log     UL Troughput of pcell is ${pcell_ul_tp}
    Trigger A2 Scell Release    ${UE_ID}    1    36    50
    Sleep    10s    reason=wait A2 process
    Check Scell Release
    ${pcell_dl_tp2}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    ${pcell_ul_tp2}=    Get CA Cell Average Throughput    ${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
    Should Be True    ${pcell_dl_tp2}>0
    Should Be True    ${pcell_ul_tp2}>0

Attach Single SA CA UE
    [Arguments]    ${UE_ID}    ${A1_add}=${True}
    SA 5G Attach    ${UE_ID}
	Sleep	5
    SA Set Traffic Type To Internal    ${UE_ID}    pdu_id=1
	Sleep	5
    SA CA 5G PDU Session Setup    ${UE_ID}    A1_add=${A1_add}
	Sleep	5

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
    [Arguments]    ${UE_ID}    ${pdu_id}=1    ${A1_add}=${False}    ${drx_on}=${False}
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | A1_add | No | ${True} |
    ...    | drx_on | No | ${True} |
    ...    Example:
    ...    | SA CA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${UE_ID}    nwslice=1    gw=1
	Sleep 	15
    ${output_0}    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
	Sleep 	15
    ${output}    Run Keyword Unless    ${A1_add}    String.Get Lines Matching Regexp    ${output_0}
    ...    SCellIndex 1 activated successfully    partial_match=${true}
	Sleep 	15
    ${output}    Run Keyword If     ${drx_on}    String.Get Lines Matching Regexp    ${output_0}     drx-Config setup    partial_match=${true}
	Sleep 	15
    Run Keyword If    ${A1_add}    Trigger A1 Scell Addition    ${UE_ID}    1
	Sleep 	15
    Log to Console    \nA1 Measurement Triggered for scell addition
    Log To Console    ${output}

Read WTS Output For Pattern And Print matching Lines
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ${output}    Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
	Sleep 	15
    Print Matching Lines from Output File    ${output}    ${pattern}
	Sleep 	15
    [Return]    ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ${output}        String.Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    Log to Console    \n${output}

Trigger A1 Scell Addition
    [Arguments]    ${UE_ID}    ${meas_id}=${EMPTY}    ${srsrp_nr}=80    ${phycell_id}=52
    [Documentation]    This keyword is to trigger A1 scell added.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | the id of ue |
    ...    | srsrp_nr | Yes | the value of srsrp_nr |
    ...    | phycell_id | Yes | phycell id of the cell |
    ...    Examples:
    ...    | Trigger A1 Scell Addition | 1 | 80 | 52 |
    ${meas_id_from_egate}    Get Measurement Id From Egate Log    A1    ${UE_ID}
    ${measida1}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
	Sleep 	15
    ${ret}    wtsrunner.ue_measurement_send_nr     id=${UE_ID}    meas_id=${measida1}    event=A1    srsrp_nr=${srsrp_nr}
    ...     phycell_id=${phycell_id}
    Sleep    3s
    [Return]    ${ret}

Get Measurement Id From Egate Log
    [Arguments]    ${event_tag}    ${UE_ID}=3
    Sleep    2s
    wtsrunner.ue_meas_cfg_disp    id=${UE_ID}
    ${reportconfigidregex}=    Set Variable    reportConfigId (?P<report_id>\\d+)[\\s\\S]{1,150}eventId event${event_tag}
    wtsrunner.sim_log_set
	Sleep 	15
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
	Sleep 	15
    ${report_id_list}=    String.Get Regexp Matches    ${content}    ${reportconfigidregex}    report_id
	Sleep 	15
    ${report_id}=    Set Variable    ${report_id_list}[-1]
    ${measidregex}=    Set Variable    measId (?P<measId>\\d+)[\\s\\S]{1,100}reportConfigId ${report_id}
	Sleep 	15
    ${measid_list}=    String.Get Regexp Matches    ${content}    ${measidregex}    measId
	Sleep 	15
    [Return]    ${measid_list}[-1]

SA Start UL Traffic Internal And Check Scell Activation
    [Arguments]    ${UE_ID}    ${pdu_id}    ${mbps}    ${trf_id}
    Log To Console    start UL traffic...
    ${output}    wtsrunner.trf_data_start    ue=${UE_ID}    pdu=${pdu_id}    dir=ul    mbps=${mbps}
    ...    trf_id=${trf_id}
    sleep    5s

SA Start DL Traffic Internal And Check Scell Activation
    [Arguments]    ${UE_ID}    ${pdu_id}    ${mbps}    ${trf_id}
    Log To Console    start DL traffic...
    ${output}    wtsrunner.trf_data_start    ue=${UE_ID}    pdu=${pdu_id}    dir=dl    mbps=${mbps}
    ...    trf_id=${trf_id}
    sleep    5s

Check Scell Activaiton
    ${output_0}    Read WTS Output For Pattern And Print matching Lines    ${scell_activation_pattern}    ${Timeout_SA}
    Log To Console    \nScell activation successful

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

Get CA Cell Average Throughput
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
    ...    | ${scell1_tput} | Get CA Cell Average Throughput | 1 | dl | scell | 1 |
    ...    | ${scell2_tput} | Get CA Cell Average Throughput | 1 | ul | scell | 2 |
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

Trigger A2 Scell Release
    [Arguments]    ${UE_ID}    ${scell_id}=1    ${scell_rsrp}=36    ${physcell_id}=50    ${meas_id}=${EMPTY}
    [Documentation]    This keyword is to trigger A2 scell release
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | yes | the id of ue |
    ...    | scell_id | yes | the id of scell |
    ...    | scell_rsrp | yes | the value of scell_rsrp |
    ...    | phycell_id | yes | phycell id for scell |
    ...
    ...    Examples:
    ...    | Trigger A2 Scell Release | 1 | 1 | 1 | 51 |
    ...
    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A2    ${UE_ID}
    ${measida2}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ${ret1}    wtsrunner.ue_measurement_send_nr     id=${UE_ID}    meas_id=${measida2}    event=A2    scell=${scell_id}
    ...     scell_rsrp=${scell_rsrp}    phycell_id=${physcell_id}
    Sleep    3s
    Log to Console    \nA2 Measurement triggered for scell release
    [Return]    ${ret1}

Check Scell Release
    ${output_1}    Read WTS Output For Pattern And Print matching Lines    ${scell_release_pattern}    ${Timeout_SA}
    Log To Console    \nScell release successful

SA 5G Detach
    [Arguments]    ${UE_ID}=3
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
    @{counter_list1}=    create List    'M55316C14001'    'M55316C14003'       #pcell counters
    @{counter_list2}=    create List    'M55316C14002'    'M55316C14004'       #scell counters
    ${log_entry} =    admin.get_pm_counters    counter_ids=M55316C14001,M55316C14003,M55316C14002,M55316C14004,                #counters for NR
    ...    timeout=300    connection=${ADMIN_ALIAS}
    log    ${log_entry}
    FOR    ${pi_id}    IN    @{counter_list1}
        log    ${pi_id}
        ${count}=    set variable    ${log_entry['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-3']['NCADU'][${pi_id}]}
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
        ${count}=    set variable    ${log_entry['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-1']['NCADU'][${pi_id}]}
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
    FOR    ${a}    IN    ${Counter_value}
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

Get_SBTS_build_type
    [Documentation]     Fetched current SBTS build and return SBTS00 or branch
    &{a}=	admin.get_software_info   admin_1
    log    ${a}
    ${value}=    Get From Dictionary	${a}	Active SW version
    log to console    ${value}
    ${SBTS}=	Fetch From Left    ${value}     _
    log to console    ${SBTS}
    [Return]  ${SBTS}